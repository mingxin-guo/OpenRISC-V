`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/24 20:02:44
// Design Name: 
// Module Name: RISCVtop
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RISCVtop(
        input clk,
        input rst_n
    );
wire [31:0] inst_addr;
wire [31:0] inst;
wire        rom_ce;
wire        mem_we_i;
wire [31:0] mem_addr_i;
wire [31:0] mem_addr_s_i;
wire [31:0] mem_data_i;
wire [31:0] mem_data_o;
wire [3:0]  mem_sel_i;
wire        mem_ce_i;


riscv riscv0(
    .clk(clk),
    .rst_n(rst_n),
    .rom_addr_o(inst_addr),
    .rom_data_i(inst),
    .rom_ce_o(rom_ce),

    .ram_we_o(mem_we_i),
    .ram_addr_o(mem_addr_i),
    .ram_addr_s_o(mem_addr_s_i),
    .ram_sel_o(mem_sel_i),
    .ram_data_o(mem_data_i),
    .ram_data_i(mem_data_o),
    .ram_ce_o(mem_ce_i)
);

inst_rom inst_rom0(
    .ce(rom_ce),
    .addr(inst_addr),
    .inst(inst)
);

data_ram data_ram0(
    .clk(clk),
    .ce(mem_ce_i),
    .we(mem_we_i),
    .addr(mem_addr_i),
    .addr_s(mem_addr_s_i),
    .sel(mem_sel_i),
    .data_i(mem_data_i),
    .data_o(mem_data_o)
);
endmodule
