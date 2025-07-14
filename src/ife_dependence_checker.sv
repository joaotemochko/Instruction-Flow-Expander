`ifndef IFE_DEPENDENCE_CHECKER_SV
`define IFE_DEPENDENCE_CHECKER_SV

module ife_dependence_checker #(
  parameter int INSTR_WIDTH = 32,
  parameter int REG_ADDR_WIDTH = 5,
  parameter int BLOCK_SIZE = 4
)(
  input  logic [BLOCK_SIZE-1:0][INSTR_WIDTH-1:0] instrs_in,
  input  logic [BLOCK_SIZE-1:0] valid_in,
  output logic is_safe
);

  // Extração dos campos relevantes
  logic [BLOCK_SIZE-1:0][REG_ADDR_WIDTH-1:0] rd, rs1, rs2;
  logic [BLOCK_SIZE-1:0] uses_rd, uses_rs1, uses_rs2;

  for (genvar i = 0; i < BLOCK_SIZE; i++) begin
    assign rd[i]      = instrs_in[i][11:7];
    assign rs1[i]     = instrs_in[i][19:15];
    assign rs2[i]     = instrs_in[i][24:20];
    assign uses_rd[i]  = |rd[i];
    assign uses_rs1[i] = |rs1[i];
    assign uses_rs2[i] = |rs2[i];
  end

  // Verificador conservador de dependência intra-bloco
  logic hazard_detected;

  always_comb begin
    hazard_detected = 1'b0;

    for (int i = 0; i < BLOCK_SIZE; i++) begin
      if (!valid_in[i]) continue;

      for (int j = 0; j < i; j++) begin
        if (!valid_in[j]) continue;

        // RAW
        if (uses_rs1[i] && rs1[i] == rd[j] && rd[j] != 0)
          hazard_detected = 1'b1;
        if (uses_rs2[i] && rs2[i] == rd[j] && rd[j] != 0)
          hazard_detected = 1'b1;

        // WAW
        if (uses_rd[i] && rd[i] == rd[j] && rd[i] != 0)
          hazard_detected = 1'b1;

        // WAR
        if (uses_rd[j] && (rs1[i] == rd[j] || rs2[i] == rd[j]) && rd[j] != 0)
          hazard_detected = 1'b1;
      end
    end
  end

  // TODO: Adicionar verificação de efeitos colaterais (syscall, I/O etc.)

  assign is_safe = !hazard_detected;

endmodule

`endif
