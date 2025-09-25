module soc_top #(
parameter NUM_CORES = 3)(
  input  wire clk,
  input  wire rst,

  // Entrada externa para alimentar o IFE com blocos
  input  wire [7:0] block_id_in,
  input  wire [3:0][31:0] block_data_in,
  input  wire block_valid_in
);

  logic [63:0] regfile[NUM_CORES-1:0] [0:31];
  logic commit_ready0, commit_ready1;

  logic [7:0] serial_block_id;
  logic [3:0][31:0] serial_block_data;
  logic serial_valid;

  logic [63:0] core_results[NUM_CORES-1:0] [0:31];
  logic commit_valid;
  
  assign commit_valid = commit_ready0 & commit_ready1;
  assign core_results = regfile;

  logic [NUM_CORES-1:0] core_busy;

  logic [3:0][31:0] block_out_parallel [1:0];
  logic [7:0] block_id_out_parallel;
  logic [1:0] dispatch_parallel;

  // Dispatcher de blocos
  logic [3:0][31:0] block_data   [NUM_CORES-1:0];
  logic             block_valid  [NUM_CORES-1:0];

  integer i;
  genvar j;
  always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
      for (i = 0; i < NUM_CORES; i++) begin
        block_valid[i] <= 0;
       end
    end else begin
      // valores default
      for (i = 0; i < NUM_CORES; i++) begin
        block_valid[i] <= 0;
      end
      
      for (i = 0; i < NUM_CORES; i++) begin
      // --- Caso serial ---
       if (serial_valid) begin
         if (!core_busy[i]) begin
           block_data[i]  <= serial_block_data;
           block_valid[i] <= 1;
           break; // envia só para o primeiro núcleo livre
         end

      // --- Caso paralelo ---
      end else if (dispatch_parallel != 2'b00) begin
        if (!core_busy[i]) begin
          if (block_data[i - 1] != 0) begin
              block_data[i]  <= block_out_parallel[1];
              block_valid[i] <= dispatch_parallel[1];
              break;
          end else begin
              block_data[i] <= block_out_parallel[0];
              block_valid[i] <= dispatch_parallel[0];
              break;
          end
          end
      end
    end
  end
  end

  // Instância do IFE
  ife_top u_ife (
    .clk(clk),
    .rst(rst),
    .ext_block_id(block_id_in),
    .ext_block_data(block_data_in),
    .ext_block_valid(block_valid_in),
    .core_busy(core_busy),
    .core_result(core_results),
    .commit_valid_in(commit_valid),
    .serial_block_id(serial_block_id),
    .serial_block_data(serial_block_data),
    .serial_valid(serial_valid),
    .block_out_parallel(block_out_parallel),
    .block_id_out_parallel(block_id_out_parallel),
    .dispatch_parallel_out(dispatch_parallel)
  );
  
generate
  for (j = 0; j < NUM_CORES; j++) begin : gen_nebula
    nebula_core u_nebula (
      .clk(clk),
      .rst_n(rst),
      .block_valid(block_valid[j]),
      .block_data_in(block_data[j]),
      .block_id(block_id_out_parallel), // mesmo ID para todos
      .regfile_out(regfile[j]),
      .busy(core_busy[j])
    );
  end
endgenerate

endmodule
