`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/23 22:37:29
// Design Name: 
// Module Name: id_ex
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


module id_ex(
        input                clk,
        input                rst_n,
        //从译码阶段传递过来的信息
        input [31:0]         id_inst,
        input [6:0]          id_aluop,
        input [2:0]          id_alusel,
        input [6:0]          id_funct7,
        input [31:0]         id_reg1,
        input [31:0]         id_reg2,
        input [4:0]          id_wd,                 //译码阶段要写入的目的寄存器地址
        input                id_wreg,               //译码阶段要写入的目的寄存器使能
        
        
        input wire [31:0]    id_link_address,       //处于译码阶段的转移指令要保存的返回地址
        input                id_is_in_delayslot,    //当前处于译码阶段的指令是否位于延迟槽
        
        input                next_inst_in_delayslot_i, //下一条进入译码阶段的指令是否位于延迟槽
        
               
        //传递到执行阶段的信息
        output reg [31:0]    ex_inst,
        output reg [6:0]     ex_aluop,
        output reg [2:0]     ex_alusel,
        output reg [6:0]     ex_funct7,
        output reg [31:0]    ex_reg1,
        output reg [31:0]    ex_reg2,
        output reg [4:0]     ex_wd,                 //执行阶段要写入的目的寄存器地址
        output reg           ex_wreg,               //执行阶段要写入的目的寄存器使能
        
        output reg [31:0]    ex_link_address,       //当前处于执行阶段的指令要保存的返回地址
        output reg           ex_is_in_delayslot,    //当前处于执行阶段的指令是否位于延迟槽
        output reg           is_in_delayslot_o      //下一条处于译码阶段的指令是否位于延迟槽
    );
    
always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        ex_aluop <= 0;
        ex_alusel <= 0;
        ex_reg1 <= 0;
        ex_reg2 <= 0;
        ex_wd <= 0;
        ex_wreg <= 0;
    end
    else begin
        ex_aluop <= id_aluop;
        ex_alusel <= id_alusel;
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_wd <= id_wd;
        ex_wreg <= id_wreg;  
        ex_inst <= id_inst;
        ex_link_address <= id_link_address;
        ex_is_in_delayslot <= id_is_in_delayslot;
        is_in_delayslot_o <= next_inst_in_delayslot_i;
    end
end
endmodule
