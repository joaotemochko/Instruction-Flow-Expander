`ifndef IFE_BLOCK_QUEUE_SV
`define IFE_BLOCK_QUEUE_SV

module ife_block_queue #(
  parameter int BLOCK_ID_WIDTH = 8,
  parameter int INSTR_WIDTH = 32,
  parameter int BLOCK_SIZE = 4,
  parameter int QUEUE_DEPTH = 8,
  parameter int NUM_CORES = 3
)(
  input  logic clk,
  input  logic rst_n,

  // Entrada
  input  logic [BLOCK_ID_WIDTH-1:0] block_id_in,
  input  logic [BLOCK_SIZE-1:0][INSTR_WIDTH-1:0] block_in,
  input  logic valid_in,
  output logic ready_in,

  // Saída
  output logic [BLOCK_ID_WIDTH-1:0] block_id_out,
  output logic [BLOCK_SIZE-1:0][INSTR_WIDTH-1:0] block_out,
  output logic valid_out,
  input  logic ready_downstream
);

  // Tipo de bloco
  typedef struct packed {
    logic [BLOCK_ID_WIDTH-1:0] id;
    logic [BLOCK_SIZE-1:0][INSTR_WIDTH-1:0] instrs;
  } block_t;

  block_t queue [0:QUEUE_DEPTH-1];

  localparam int PTR_WIDTH = $clog2(QUEUE_DEPTH);
typedef logic [PTR_WIDTH:0] count_t;
logic [PTR_WIDTH-1:0] head, tail;
count_t count;

assign count = tail - head;

logic full, empty;
assign full  = (count == count_t'(QUEUE_DEPTH));
assign empty = (count == 0);

  // Escrita
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      tail <= '0;
      head <= '0;
    end else if (valid_in && !full) begin
      queue[tail].id     <= block_id_in;
      queue[tail].instrs <= block_in;
      tail <= tail + 1;
      
      if (valid_out && ready_downstream && !empty) begin
        head <= head + 1;
      end
     end
  end

  // Sinais externos
  assign ready_in     = !full;
  assign valid_out    = !empty;
  assign block_out    = queue[head].instrs;
  assign block_id_out = queue[head].id;

endmodule

`endif
