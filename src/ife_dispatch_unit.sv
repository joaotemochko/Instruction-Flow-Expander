`timescale 1ns/1ps

module ife_dispatch_unit #(
  parameter int BLOCK_SIZE = 4,
  parameter int NUM_CORES  = 3
)(
  input  logic clk,
  input  logic rst,

  // Até 2 blocos disponíveis (FIFO ou monitor fornece)
  input  logic [BLOCK_SIZE-1:0][31:0] block_data_in,
  input  logic [7:0] block_id_in,
  input  logic block_valid_in,

  // Status dos núcleos
  input  logic [NUM_CORES-1:0] core_busy,

  // Sinais de despacho por núcleo
  output logic [NUM_CORES-1:0] dispatch_valid,
  output logic [BLOCK_SIZE-1:0][31:0] dispatch_data [1:0],
  output logic [7:0] dispatch_block_id
);

  integer i;

  always_comb begin
    for (i = 0; i < NUM_CORES; i++) begin
      dispatch_valid[i]     = 1'b0;
      dispatch_data[i]      = '0;
      dispatch_block_id  = '0;

      if (!core_busy[i]) begin
        for (int j = 0; j < BLOCK_SIZE / 2; j++) begin
          dispatch_valid[i]     = 1'b1;
          dispatch_data[i][j]      = block_data_in[i + j * 2];
          dispatch_block_id  = block_id_in;
        end
      end
    end
  end

endmodule
