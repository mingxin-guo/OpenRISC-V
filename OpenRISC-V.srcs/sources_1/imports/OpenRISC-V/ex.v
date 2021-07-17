`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/23 22:55:58
// Design Name: 
// Module Name: ex
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


module ex(
    input                rst_n,
    input [31:0]         inst_i,
    input [6:0]          aluop_i,                       //执行阶段的运算类型
    input [2:0]          alusel_i,                      //执行阶段的运算子类型
    input [6:0]          funct7_i,
    input [31:0]         reg1_i,                        //参与运算的源操作数1
    input [31:0]         reg2_i,                        //参与运算的源操作数2
    input [4:0]          wd_i,                          //要写入的目的寄存器的地址
    input                wreg_i,                        //是否要写入目的寄存器
    input [31:0]         link_address_i,                //当前处于执行阶段的指令啊哟保存的返回地址
    input                is_in_delayslot_i,             //当前处于执行阶段的指令是否位于延迟槽
    output reg [4:0]     wd_o,                          //执行阶段最终要写入的目的寄存器
    output reg           wreg_o,                        //执行阶段最终是否要写入的目的寄存器
    output reg [31:0]    wdata_o,                        //执行阶段最终要写入的目的寄存器的值
    
    output [6:0]        aluop_o,
    output [2:0]        alusel_o,
    output [31:0]       mem_addr_o,                     //加载、存储阶段对应的存储器地址
    output [31:0]       mem_addr_s_o,   
    output [31:0]       reg2_o
    );

reg [31:0] result;
wire [31:0] reg2_i_mux;
wire [31:0] result_sum;
wire reg1_lt_reg2;

//aluop_o会传递到方寸阶段，届时将利用其确定加载，存储类型
assign aluop_o = aluop_i;
assign alusel_o = alusel_i;
//mem_addr_o会传递到访存阶段，是加载、存储指令对应的存储器地址
assign mem_addr_o = reg1_i + {{20{inst_i[31]}}, inst_i[31:20]};
//存储指令的地址
assign mem_addr_s_o = reg1_i +{{26{inst_i[31]}}, inst_i[31:25]};
//reg2_i是存储指令要存储的数据，或者是指令要加载到的目的寄存器的原始值
assign reg2_o = reg2_i;

assign reg2_i_mux = ((aluop_i == 7'b0110011) &&  (funct7_i == 7'b0100000)) ? (~reg2_i)+1 : reg2_i; //sub 
assign result_sum = reg1_i + reg2_i_mux;
assign reg1_lt_reg2 = ((aluop_i == 7'b0110011)|| (aluop_i == 7'b0010011)) ? 
                                            ((reg1_i[31] && !reg2_i[31]) || (!reg1_i[31] && !reg2_i[31] && result_sum[31])|| (reg1_i[31] && reg2_i[31] && result_sum[31] ))
			                                  :	(reg1_i < reg2_i);
//slt  stlu slti sltiu
//assign reg1_lt_reg2 = ((aluop_i == 7'b0110011) && (alusel_i == 3'b000 || alusel_i == 3'b011)) ? 
//                                            ((reg1_i[31] && !reg2_i[31]) || (!reg1_i[31] && !reg2_i[31] && result_sum[31])|| (reg1_i[31] && reg2_i[31] && result_sum[31] ))
//			                                  :	(reg1_i < reg2_i);
			                                  
always @ (*) begin                                      //通过译码阶段发送过来的信息确定具体的运算操作
    if(~rst_n)
        result <= 0;    
    else begin
    
    
        case(aluop_i)
            //I-type
            7'b0000011: begin
                case(alusel_i)                              //lb,lh,lw, lbu, lhu
                    3'b000: begin
                        
                    end
                    default : begin end
                 endcase
            end
        
            7'b0010011: begin
                case(alusel_i)
                    3'b000: result <= reg1_i +  reg2_i;      //addi
                    3'b010, 3'b011: result <= reg1_lt_reg2;  //slti, sltiu
                    3'b100: result <= reg1_i ^  reg2_i;      //xor
                    3'b110: result <= reg1_i |  reg2_i;      //ori
                    3'b111: result <= reg1_i &  reg2_i;      //andi
                    
                    3'b001: begin                            
                        case(funct7_i)                      //slli
                            7'b0000000: result <= reg1_i << reg2_i[5:0];
                            default: begin end
                        endcase    
                    end
                    3'b101: begin                            //srli
                        case(funct7_i)
                            7'b0000000: result <= reg1_i >> reg2_i[5:0];
                            7'b0100000: result <= ({32{reg1_i[31]}} << (6'd32 - {1'b0, reg2_i[5:0]})) | (reg1_i >> reg2_i[5:0]);
                            default : begin end
                         endcase 
                    end
                            
                    default: begin
                        result <= 0;
                    end
                endcase
            end
            
            7'b0110011: begin
                case(alusel_i) 
//                    3'b000: begin
//                        case(funct7_i)
//                            7'b0000000: result <= reg1_i +  reg2_i;         //add
//                            7'b0100000: result <= reg1_i +  ((~reg2_i)+1) ;         //sub
//                            default : begin end
//                        endcase
//                    end
                    3'b000: result <= reg2_i_mux;               //add, sub
                    3'b001: result <= reg1_i << reg2_i;         //sll
                    3'b010,3'b011: result <= reg1_lt_reg2;      //slt, sltu    
                    3'b100: result <= reg1_i ^  reg2_i;         //xor
                    3'b101: begin
                        case(funct7_i)
                            7'b0000000: result <= reg1_i >> {1'b0, reg2_i[4:0]};      //srl                         
                            7'b0100000: result <= ({32{reg1_i[31]}} << (6'd32 - {1'b0, reg2_i[4:0]})) | (reg1_i >> {1'b0, reg2_i[4:0]});        //sra
                            default : begin end
                        endcase
                    end
                    3'b110: result <= reg1_i |  reg2_i;         //or
                    3'b111: result <= reg1_i &  reg2_i;         //and
                    default: begin end
                endcase
             end   
                
             7'b0110111: begin
                  result <= reg1_i << 12;
             end
            default: begin end
        endcase
 
    end
end

always @ (*) begin                                      //将运算结果发送到下一阶段
    wd_o <= wd_i;                                        //写回目的寄存器的地址
    wreg_o <= wreg_i;                                    //是否写回寄存器
    case(aluop_i)
    
        7'b0010011: begin
            case(alusel_i)
               3'b000, 3'b100, 3'b110, 3'b111, 3'b001, 3'b101: wdata_o <= result;  //addi, xori, ori, andi, slli, srlli, srai
                default: begin
                end
            endcase
        end
        
        7'b0110011: begin
            case(alusel_i)
               3'b000, 3'b001, 3'b100, 3'b110, 3'b111: wdata_o <= result;  //add, sll, xor, or, and
                default: begin
                end
            endcase
        end
        
        7'b0110111: begin
            wdata_o <= result;
        end
        
         7'b1100011: begin
            wdata_o <= link_address_i;
         end
        
        
        
        default: begin
            wdata_o <= 0;
        end
    endcase
end
endmodule
