`ifndef IFE_COMMIT_UNIT_SV
`define IFE_COMMIT_UNIT_SV

module ife_commit_unit #(
  parameter int BLOCK_ID_WIDTH = 8,
  parameter int NUM_REGS = 32,
  parameter int REG_WIDTH = 32
)(
  input  logic clk,
  input  logic rst,

  input  logic valid_in,
  input  logic [BLOCK_ID_WIDTH-1:0] block_id,

  input  logic [NUM_REGS-1:0][REG_WIDTH-1:0] result_core_0,
  input  logic [NUM_REGS-1:0][REG_WIDTH-1:0] result_core_1,

  output logic commit_ok,
  output logic commit_fail,
  output logic reexecute_serial
);

  logic mismatch;

  always_comb begin
    mismatch = 1'b0;

    if (valid_in) begin
      for (int i = 0; i < NUM_REGS; i++) begin
        if (result_core_0[i] !== result_core_1[i]) begin
          mismatch = 1'b1;
        end
      end
    end
  end

  assign commit_ok        = valid_in && !mismatch;
  assign commit_fail      = valid_in && mismatch;
  assign reexecute_serial = commit_fail;

endmodule

`endif
