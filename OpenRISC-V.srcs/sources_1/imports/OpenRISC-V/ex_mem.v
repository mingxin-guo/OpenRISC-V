`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/23 23:45:15
// Design Name: 
// Module Name: ex_mem
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


module ex_mem(
        input                clk,
        input                rst_n,
        
        input [4:0]          ex_wd,
        input                ex_wreg,
        input [31:0]         ex_wdata,
        
        input [6:0]          ex_aluop,
        input [2:0]          ex_alusel,
        input [31:0]         ex_mem_addr,
        input [31:0]         ex_mem_s_addr,
        input [31:0]         ex_reg2,
        
        
        output reg [4:0]     mem_wd,
        output reg           mem_wreg,
        output reg [31:0]    mem_wdata,
        
        output reg[6:0]      mem_aluop,
        output reg[2:0]      mem_alusel, 
        output reg[31:0]     mem_mem_addr,
        output reg[31:0]     mem_mem_s_addr,
        output reg[31:0]     mem_reg2
        
        
    );
    
always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        mem_wd <= 0;
        mem_wreg <= 0;
        mem_wdata <= 0;
    end
    else begin
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata;
        
        mem_aluop <= ex_aluop;
        mem_alusel <= ex_alusel;
        mem_mem_addr <= ex_mem_addr;
        mem_mem_s_addr <= ex_mem_s_addr;
        mem_reg2 <= ex_reg2;
    end
end
endmodule
