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
    input [6:0]          aluop_i,                       //ִ�н׶ε���������
    input [2:0]          alusel_i,                      //ִ�н׶ε�����������
    input [6:0]          funct7_i,
    input [31:0]         reg1_i,                        //���������Դ������1
    input [31:0]         reg2_i,                        //���������Դ������2
    input [4:0]          wd_i,                          //Ҫд���Ŀ�ļĴ����ĵ�ַ
    input                wreg_i,                        //�Ƿ�Ҫд��Ŀ�ļĴ���
    input [31:0]         link_address_i,                //��ǰ����ִ�н׶ε�ָ�Ӵ����ķ��ص�ַ
    input                is_in_delayslot_i,             //��ǰ����ִ�н׶ε�ָ���Ƿ�λ���ӳٲ�
    output reg [4:0]     wd_o,                          //ִ�н׶�����Ҫд���Ŀ�ļĴ���
    output reg           wreg_o,                        //ִ�н׶������Ƿ�Ҫд���Ŀ�ļĴ���
    output reg [31:0]    wdata_o,                        //ִ�н׶�����Ҫд���Ŀ�ļĴ�����ֵ
    
    output [6:0]        aluop_o,
    output [2:0]        alusel_o,
    output [31:0]       mem_addr_o,                     //���ء��洢�׶ζ�Ӧ�Ĵ洢����ַ
    output [31:0]       mem_addr_s_o,   
    output [31:0]       reg2_o
    );

reg [31:0] result;
wire [31:0] reg2_i_mux;
wire [31:0] result_sum;
wire reg1_lt_reg2;

//aluop_o�ᴫ�ݵ�����׶Σ���ʱ��������ȷ�����أ��洢����
assign aluop_o = aluop_i;
assign alusel_o = alusel_i;
//mem_addr_o�ᴫ�ݵ��ô�׶Σ��Ǽ��ء��洢ָ���Ӧ�Ĵ洢����ַ
assign mem_addr_o = reg1_i + {{20{inst_i[31]}}, inst_i[31:20]};
//�洢ָ��ĵ�ַ
assign mem_addr_s_o = reg1_i +{{26{inst_i[31]}}, inst_i[31:25]};
//reg2_i�Ǵ洢ָ��Ҫ�洢�����ݣ�������ָ��Ҫ���ص���Ŀ�ļĴ�����ԭʼֵ
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
			                                  
always @ (*) begin                                      //ͨ������׶η��͹�������Ϣȷ��������������
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

always @ (*) begin                                      //�����������͵���һ�׶�
    wd_o <= wd_i;                                        //д��Ŀ�ļĴ����ĵ�ַ
    wreg_o <= wreg_i;                                    //�Ƿ�д�ؼĴ���
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
