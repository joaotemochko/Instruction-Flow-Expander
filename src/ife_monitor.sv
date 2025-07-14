`ifndef IFE_MONITOR_SV
`define IFE_MONITOR_SV

module ife_monitor #(
  parameter int NUM_CORES = 4
)(
  input  logic clk,
  input  logic rst,

  input  logic [NUM_CORES-1:0] core_busy,
  output logic [NUM_CORES-1:0] core_idle_mask
);

  always_comb begin
    for (int i = 0; i < NUM_CORES; i++) begin
      core_idle_mask[i] = ~core_busy[i]; // núcleo disponível se não estiver ocupado
    end
  end

endmodule

`endif
