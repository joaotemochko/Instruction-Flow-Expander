`ifndef IFE_DISPATCH_UNIT_SV
`define IFE_DISPATCH_UNIT_SV

module ife_dispatch_unit #(
  parameter BLOCK_ID_WIDTH = 8,
  parameter INSTR_WIDTH = 32,
  parameter BLOCK_SIZE = 4,
  parameter NUM_CORES = 4
)(
  input  logic clk,
  input  logic rst,

  input  logic [BLOCK_ID_WIDTH-1:0] block_id_in,
  input  logic [BLOCK_SIZE-1:0][INSTR_WIDTH-1:0] block_in,
  input  logic valid_in,
  input  logic is_safe,
  input  logic [NUM_CORES-1:0] core_idle_mask,

  output logic [BLOCK_ID_WIDTH-1:0] block_id_out_parallel,
  output logic [BLOCK_SIZE-1:0][INSTR_WIDTH-1:0] block_out_parallel,
  output logic [NUM_CORES-1:0] dispatch_parallel,
  output logic valid_parallel,

  output logic [BLOCK_ID_WIDTH-1:0] block_id_out_serial,
  output logic [BLOCK_SIZE-1:0][INSTR_WIDTH-1:0] block_out_serial,
  output logic valid_serial
);

  logic dispatching;

  always_comb begin
    dispatch_parallel = '0;
    valid_parallel = 1'b0;
    valid_serial   = 1'b0;

    if (valid_in && is_safe) begin
      // Encontrar o primeiro core ocioso
      for (int i = 0; i < NUM_CORES; i++) begin
        if (core_idle_mask[i]) begin
          dispatch_parallel[i] = 1'b1;
          valid_parallel = 1'b1;
          break;
        end
      end

      if (!valid_parallel) begin
        // Sem núcleos disponíveis => fallback para execução serial
        valid_serial = 1'b1;
      end

    end else if (valid_in && !is_safe) begin
      // Bloco não é seguro para duplicação => execução serial
      valid_serial = 1'b1;
    end
  end

  // Dados de saída
  assign block_id_out_parallel = block_id_in;
  assign block_out_parallel    = block_in;
  assign block_id_out_serial   = block_id_in;
  assign block_out_serial      = block_in;

endmodule

`endif
