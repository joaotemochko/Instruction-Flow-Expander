`include "ife_top.sv"
`include "nebula_core_with_ife.sv"
`include "shared_dual_port_ram.sv"

module soc_top (
  input  logic clk,
  input  logic rst,

  // Entrada externa para alimentar o IFE com blocos
  input  logic [7:0] block_id_in,
  input  logic [3:0][31:0] block_data_in,
  input  logic block_valid_in
);

  logic [63:0] regfile0 [31:0];
  logic [63:0] regfile1 [31:0];
  logic commit_ready0, commit_ready1;
  logic busy0, busy1;

  logic [7:0] serial_block_id;
  logic [3:0][31:0] serial_block_data;
  logic serial_valid;

  logic [63:0] core_results0 [31:0];
  logic [63:0] core_results1 [31:0];
  logic commit_valid;

  assign core_results0 = regfile0;
  assign core_results1 = regfile1;
  assign commit_valid = commit_ready0 & commit_ready1;

  logic [1:0] core_busy;
  assign core_busy[0] = busy0;
  assign core_busy[1] = busy1;

  logic [3:0][31:0] block_out_parallel [1:0];
  logic [7:0] block_id_out_parallel;
  logic [1:0] dispatch_parallel;

  // Instância do IFE
  ife_top u_ife (
    .clk(clk),
    .rst(rst),
    .ext_block_id(block_id_in),
    .ext_block_data(block_data_in),
    .ext_block_valid(block_valid_in),
    .core_busy(core_busy),
    .core_result_0(core_results0),
    .core_result_1(core_results1),
    .commit_valid_in(commit_valid),
    .serial_block_id(serial_block_id),
    .serial_block_data(serial_block_data),
    .serial_valid(serial_valid),
    .block_out_parallel(block_out_parallel),
    .block_id_out_parallel(block_id_out_parallel),
    .dispatch_parallel_out(dispatch_parallel)
  );

  // Nebula Core 0
  nebula_core u_nebula0 (
    .clk(clk),
    .rst_n(~rst),
    .block_valid(dispatch_parallel[0]),
    .block_data_in(serial_valid ? serial_block_data : block_out_parallel[0]),
    .block_id(block_id_out_parallel),
    .commit_ready(commit_ready0),
    .regfile_out(regfile0),
    .busy(busy0),

    // Preenchendo sinais esperados
    .imem_addr(),
    .imem_req(),

    .dmem_addr0(),
    .dmem_wdata0(),
    .dmem_wstrb0(),
    .dmem_req0(),
    .dmem_we0(),
    .dmem_rdata0(),
    .dmem_ack_in(),
    .dmem_error_in(),

    .dmem_addr1(),
    .dmem_wdata1(),
    .dmem_wstrb1(),
    .dmem_req1(),
    .dmem_we1(),
    .dmem_rdata1(),

    .timer_irq(),
    .external_irq(),
    .software_irq(),

    .debug_req(),
    .debug_ack(),
    .debug_halted(),
    .inst_retired(),
    .cycles(),
    .debug_pc(),
    .debug_next_pc(),
    .debug_regfile(),
    .debug_inst_retired(),
    .debug_cycles(),
    .debug_privilege(),
    .debug_opcode(),
    .debug_valid_instr(),
    .debug_imm(),
    .debug_rs2(),
    .debug_funct3(),
    .debug_result_alu(),
    .debug_mem_rd()
  );

  // Nebula Core 1
  nebula_core u_nebula1 (
    .clk(clk),
    .rst_n(~rst),
    .block_valid(dispatch_parallel[1]),
    .block_data_in(serial_valid && core_busy[0] ? serial_block_data : block_out_parallel[1]),
    .block_id(block_id_out_parallel),
    .commit_ready(commit_ready1),
    .regfile_out(regfile1),
    .busy(busy1),

    .imem_addr(),
    .imem_req(),

    .dmem_addr0(),
    .dmem_wdata0(),
    .dmem_wstrb0(),
    .dmem_req0(),
    .dmem_we0(),
    .dmem_rdata0(),
    .dmem_ack_in(),
    .dmem_error_in(),

    .dmem_addr1(),
    .dmem_wdata1(),
    .dmem_wstrb1(),
    .dmem_req1(),
    .dmem_we1(),
    .dmem_rdata1(),

    .timer_irq(),
    .external_irq(),
    .software_irq(),

    .debug_req(),
    .debug_ack(),
    .debug_halted(),
    .inst_retired(),
    .cycles(),
    .debug_pc(),
    .debug_next_pc(),
    .debug_regfile(),
    .debug_inst_retired(),
    .debug_cycles(),
    .debug_privilege(),
    .debug_opcode(),
    .debug_valid_instr(),
    .debug_imm(),
    .debug_rs2(),
    .debug_funct3(),
    .debug_result_alu(),
    .debug_mem_rd()
  );

endmodule
