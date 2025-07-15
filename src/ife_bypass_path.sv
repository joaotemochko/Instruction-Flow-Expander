`ifndef IFE_BYPASS_PATH_SV
`define IFE_BYPASS_PATH_SV

module ife_bypass_path #(
  parameter BLOCK_ID_WIDTH = 8,
  parameter INSTR_WIDTH = 32,
  parameter BLOCK_SIZE = 4
)(
  input  logic clk,
  input  logic rst,

  input  logic [BLOCK_ID_WIDTH-1:0] block_id_in,
  input  logic [BLOCK_SIZE-1:0][INSTR_WIDTH-1:0] block_in,
  input  logic valid_in,
  input  logic from_dispatch,
  input  logic from_commit,

  output logic [BLOCK_ID_WIDTH-1:0] block_id_out,
  output logic [BLOCK_SIZE-1:0][INSTR_WIDTH-1:0] block_out,
  output logic valid_out,
  output logic is_fallback
);

  // Pass-through direto
  assign block_id_out = block_id_in;
  assign block_out    = block_in;
  assign valid_out    = valid_in;

  // Identificador de fallback (1 se veio de commit ou dispatch por falha)
  assign is_fallback = valid_in && (from_dispatch || from_commit);

endmodule

`endif
