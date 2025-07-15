`timescale 1ns/1ps

module ife_top #(
  parameter BLOCK_ID_WIDTH = 8,
  parameter INSTR_WIDTH = 32,
  parameter BLOCK_SIZE = 4,
  parameter NUM_CORES = 4,
  parameter NUM_REGS = 32,
  parameter REG_WIDTH = 64
)(
  input  logic clk,
  input  logic rst,

  // Entrada externa de bloco de instruções
  input  logic [BLOCK_ID_WIDTH-1:0] ext_block_id,
  input  logic [BLOCK_SIZE-1:0][INSTR_WIDTH-1:0] ext_block_data,
  input  logic ext_block_valid,

  // Status dos núcleos (de fora da CPU)
  input  logic [NUM_CORES-1:0] core_busy,

  // Resultados retornados dos núcleos paralelos
  input  logic [REG_WIDTH-1:0] core_result_0 [NUM_REGS-1:0],
  input  logic [REG_WIDTH-1:0] core_result_1 [NUM_REGS-1:0],
  input  logic commit_valid_in,

  // Saída para caminho serial (fallback)
  output logic [BLOCK_ID_WIDTH-1:0] serial_block_id,
  output logic [BLOCK_SIZE-1:0][INSTR_WIDTH-1:0] serial_block_data,
  output logic serial_valid,
  output logic [3:0][31:0] block_out_parallel,
  output logic [7:0] block_id_out_parallel,
  output logic [3:0] dispatch_parallel_out

);

  // Interconexões internas
  logic [BLOCK_ID_WIDTH-1:0] q_block_id_out;
  logic [BLOCK_SIZE-1:0][INSTR_WIDTH-1:0] q_block_out;
  logic q_valid_out;
  logic ready_in;
  assign ready_in = 1'b1;

  logic [3:0] dispatch_parallel;

  logic is_safe;
  logic [NUM_CORES-1:0] core_idle_mask;

  logic [BLOCK_ID_WIDTH-1:0] block_id_parallel;
  logic [BLOCK_SIZE-1:0][INSTR_WIDTH-1:0] block_data_parallel;
  logic valid_parallel;

  logic [BLOCK_ID_WIDTH-1:0] block_id_serial_dispatch;
  logic [BLOCK_SIZE-1:0][INSTR_WIDTH-1:0] block_data_serial_dispatch;
  logic valid_serial_dispatch;

  logic commit_ok, commit_fail, reexecute_serial;

  // Bypass output
  logic [BLOCK_ID_WIDTH-1:0] bypass_block_id;
  logic [BLOCK_SIZE-1:0][INSTR_WIDTH-1:0] bypass_block_data;
  logic bypass_valid, bypass_fallback;

  // Módulos internos
  ife_block_queue #(
    .BLOCK_ID_WIDTH(BLOCK_ID_WIDTH),
    .INSTR_WIDTH(INSTR_WIDTH),
    .BLOCK_SIZE(BLOCK_SIZE)
  ) u_block_queue (
    .clk(clk), .rst(rst),
    .block_id_in(ext_block_id),
    .block_in(ext_block_data),
    .valid_in(ext_block_valid),
    .ready_in(ready_in),
    .block_id_out(q_block_id_out),
    .block_out(q_block_out),
    .valid_out(q_valid_out),
    .ready_downstream(1'b1)
  );

  ife_dependence_checker #(
    .INSTR_WIDTH(INSTR_WIDTH),
    .REG_ADDR_WIDTH(5),
    .BLOCK_SIZE(BLOCK_SIZE)
  ) u_depcheck (
    .instrs_in(q_block_out),
    .valid_in({BLOCK_SIZE{1'b1}}),
    .is_safe(is_safe)
  );

  ife_monitor #(
    .NUM_CORES(NUM_CORES)
  ) u_monitor (
    .clk(clk),
    .rst(rst),
    .core_busy(core_busy),
    .core_idle_mask(core_idle_mask)
  );

  ife_dispatch_unit #(
    .BLOCK_ID_WIDTH(BLOCK_ID_WIDTH),
    .INSTR_WIDTH(INSTR_WIDTH),
    .BLOCK_SIZE(BLOCK_SIZE),
    .NUM_CORES(NUM_CORES)
  ) u_dispatch (
    .clk(clk), .rst(rst),
    .block_id_in(q_block_id_out),
    .block_in(q_block_out),
    .valid_in(q_valid_out),
    .is_safe(is_safe),
    .core_idle_mask(core_idle_mask),
    .block_id_out_parallel(block_id_parallel),
    .block_out_parallel(block_data_parallel),
    .dispatch_parallel(dispatch_parallel),
    .valid_parallel(valid_parallel),
    .block_id_out_serial(block_id_serial_dispatch),
    .block_out_serial(block_data_serial_dispatch),
    .valid_serial(valid_serial_dispatch)
  );

  ife_commit_unit #(
    .BLOCK_ID_WIDTH(BLOCK_ID_WIDTH),
    .NUM_REGS(NUM_REGS),
    .REG_WIDTH(REG_WIDTH)
  ) u_commit (
    .clk(clk), .rst(rst),
    .valid_in(commit_valid_in),
    .block_id(block_id_parallel),
    .result_core_0(core_result_0),
    .result_core_1(core_result_1),
    .commit_ok(commit_ok),
    .commit_fail(commit_fail),
    .reexecute_serial(reexecute_serial)
  );

  ife_bypass_path #(
    .BLOCK_ID_WIDTH(BLOCK_ID_WIDTH),
    .INSTR_WIDTH(INSTR_WIDTH),
    .BLOCK_SIZE(BLOCK_SIZE)
  ) u_bypass (
    .clk(clk), .rst(rst),
    .block_id_in(valid_serial_dispatch ? block_id_serial_dispatch : block_id_parallel),
    .block_in(valid_serial_dispatch ? block_data_serial_dispatch : block_data_parallel),
    .valid_in(valid_serial_dispatch || reexecute_serial),
    .from_dispatch(valid_serial_dispatch),
    .from_commit(reexecute_serial),
    .block_id_out(bypass_block_id),
    .block_out(bypass_block_data),
    .valid_out(bypass_valid),
    .is_fallback(bypass_fallback)
  );

  assign serial_block_id   = bypass_block_id;
  assign serial_block_data = bypass_block_data;
  assign serial_valid      = bypass_valid;
  assign block_out_parallel = block_data_parallel;
  assign block_id_out_parallel = block_id_parallel;
  assign dispatch_parallel_out = dispatch_parallel;


endmodule
