`ifndef IFE_BLOCK_QUEUE_SV
`define IFE_BLOCK_QUEUE_SV

module ife_block_queue #(
  parameter int BLOCK_ID_WIDTH = 8,
  parameter int INSTR_WIDTH = 32,
  parameter int BLOCK_SIZE = 4  // número de instruções por bloco
)(
  input  logic clk,
  input  logic rst,

  // Entrada de bloco
  input  logic [BLOCK_ID_WIDTH-1:0] block_id_in,
  input  logic [BLOCK_SIZE-1:0][INSTR_WIDTH-1:0] block_in,
  input  logic valid_in,
  output logic ready_in,

  // Saída para próxima etapa
  output logic [BLOCK_ID_WIDTH-1:0] block_id_out,
  output logic [BLOCK_SIZE-1:0][INSTR_WIDTH-1:0] block_out,
  output logic valid_out,
  input  logic ready_downstream
);

  // Estrutura da fila
  typedef struct packed {
    logic [BLOCK_ID_WIDTH-1:0] id;
    logic [BLOCK_SIZE-1:0][INSTR_WIDTH-1:0] instrs;
  } block_t;

  localparam int QUEUE_DEPTH = 8;

  block_t queue[QUEUE_DEPTH];
  logic [$clog2(QUEUE_DEPTH):0] head, tail;
  logic full, empty;

  // Controle de fila
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      head <= 0;
      tail <= 0;
    end else begin
      // Escrita
      if (valid_in && !full) begin
        queue[tail].id     <= block_id_in;
        queue[tail].instrs <= block_in;
        tail <= tail + 1;
      end

      // Leitura
      if (valid_out && ready_downstream && !empty) begin
        head <= head + 1;
      end
    end
  end

  // Estado da fila
  assign full  = (tail - head) == QUEUE_DEPTH;
  assign empty = (tail == head);

  // Interface de controle
  assign ready_in   = !full;
  assign valid_out  = !empty;
  assign block_out  = queue[head].instrs;
  assign block_id_out = queue[head].id;

endmodule

`endif
