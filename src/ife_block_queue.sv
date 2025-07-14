module ife_block_queue #(
    parameter BLOCK_WIDTH = 128,
    parameter QUEUE_DEPTH = 8
)(
    input  logic                 clk,
    input  logic                 rst,
    input  logic                 push,
    input  logic                 pop,
    input  logic [BLOCK_WIDTH-1:0] in_block,
    output logic [BLOCK_WIDTH-1:0] out_block,
    output logic                 full,
    output logic                 empty
);

    logic [BLOCK_WIDTH-1:0] queue [0:QUEUE_DEPTH-1];
    logic [$clog2(QUEUE_DEPTH):0] head, tail;
    logic [$clog2(QUEUE_DEPTH+1):0] count;

    assign full  = (count == QUEUE_DEPTH);
    assign empty = (count == 0);

    assign out_block = (empty) ? '0 : queue[head];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            head  <= 0;
            tail  <= 0;
            count <= 0;
        end else begin
            if (push && !full) begin
                queue[tail] <= in_block;
                tail <= (tail + 1) % QUEUE_DEPTH;
                count <= count + 1;
            end

            if (pop && !empty) begin
                head <= (head + 1) % QUEUE_DEPTH;
                count <= count - 1;
            end
        end
    end

endmodule
