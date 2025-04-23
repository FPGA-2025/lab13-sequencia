`timescale 1ns / 1ps

module tb;

reg clk = 0;
reg rst_n = 0;
reg setar_palavra = 0;
reg [7:0] palavra = 0;
reg start = 0;
reg bit_in = 0;

wire encontrado;

Sequencia dut (
    .clk(clk),
    .rst_n(rst_n),
    .setar_palavra(setar_palavra),
    .palavra(palavra),
    .start(start),
    .bit_in(bit_in),
    .encontrado(encontrado)
);

parameter CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk = ~clk;

reg [24:0] mem; // [23:16] palavra, [15:0] sequência, [16] bit esperado

integer file, status;
integer j;

initial begin
    $display("*** Iniciando teste Sequencia ***");

    file = $fopen("teste.txt", "r");
    status = $fscanf(file, "%b" , mem);
    $fclose(file);

    $dumpfile("saida.vcd"); // gera um arquivo .vcd para visualização no gtkwave
    $dumpvars(0, tb); // salva as variáveis do módulo tb

    // Reset inicial
    #20 rst_n = 1;

    setar_palavra = 1;
    palavra = mem[24:17];
    #CLK_PERIOD;
    setar_palavra = 0;
    palavra = 8'h00; // opcional: limpa palavra depois de setar

    // Iniciar operação
    start = 1;
    #CLK_PERIOD;
    start = 0;

    // Enviar sequência de bits (MSB -> LSB)
    for (j = 16; j >= 1; j--) begin
        bit_in = mem[j];
        #CLK_PERIOD;
    end

    bit_in = 0; // opcional: limpa bit após envio

    // Esperar ciclos extras para avaliação
    #(2*CLK_PERIOD);

    // Verificação
    if (encontrado === mem[0]) begin
        $display("=== OK: palavra=0x%02x encontrado=%b", mem[24:17], encontrado);
    end else begin
        $display("=== FALHA: palavra=0x%02x esperado=%b, obtido=%b",
                    mem[24:17], mem[0], encontrado);
    end

    // Esperar entre os testes
    #CLK_PERIOD;

    $finish;
end

endmodule
