#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vsoc_top.h"

vluint64_t main_time = 0;
double sc_time_stamp() { return main_time; }

int main(int argc, char **argv, char **env) {
    Verilated::commandArgs(argc, argv);
    Vsoc_top *top = new Vsoc_top;

    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("soc_top_tb.vcd");

    // Inicialização
    top->clk = 0;
    top->rst = 1;
    top->block_valid_in = 0;
    main_time = 0;

    // Reset
    for (int i = 0; i < 10; i++) {
        top->clk = !top->clk;
        top->eval();
        tfp->dump(main_time);
        main_time += 5;
    }
    top->rst = 0;

    // Enviar um bloco válido para o IFE
    top->block_id_in = 0x01;
    top->block_data_in[0] = 0x00500513; // ADDI x10, x0, 5
    top->block_data_in[1] = 0x00300593; // ADDI x11, x0, 3
    top->block_data_in[2] = 0x00600593; // ADDI x11, x0, 6
    top->block_data_in[3] = 0x00700513; // ADDI x10, x0, 7
    top->block_valid_in = 1;

    for (int i = 0; i < 10; i++) {
        top->clk = !top->clk;
        top->eval();
        tfp->dump(main_time);
        main_time += 5;
    }
    top->block_valid_in = 0;

    // Simula a execução por tempo suficiente
    for (int i = 0; i < 100; i++) {
        top->clk = !top->clk;
        top->eval();
        tfp->dump(main_time);
        main_time += 5;
    }

    tfp->close();
    top->final();
    delete top;
    return 0;
}
