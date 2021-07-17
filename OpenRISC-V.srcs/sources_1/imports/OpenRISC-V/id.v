`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/23 19:49:07
// Design Name: 
// Module Name: id
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


module id(
        input             rst_n,
        input [31:0]      pc_i,
        input [31:0]      inst_i,
        //��ȡregister 
        input [31:0]      reg1_data_i,
        input [31:0]      reg2_data_i,
        //�����һ��ָ����ת��ָ���ô��һ��ָ���������׶ε�ʱ��
        //�������is_in_delayslot_iΪtrue, ��ʾ���ӳٲ�ָ���֮Ϊfalse
        input             is_in_delayslot_i,
        //�����regfile
        output reg        reg1_read_o,
        output reg        reg2_read_o,
        output reg [4:0]  reg1_addr_o,                              //rs1
        output reg [4:0]  reg2_addr_o,                              //rs2
        //�ͳ���ִ��ģ��
        output reg [6:0]  aluop_o,
        output reg [2:0]  alusel_o,
        output reg [6:0]  funct7_o,
        output reg [31:0] reg1_o,
        output reg [31:0] reg2_o,
        output reg [4:0]  wd_o,
        output reg        wreg_o,
        
        
        output reg        next_inst_in_delayslot_o,                 //��һ����������׶ε�ָ���Ƿ�λ���ӳٲ�
        output reg        is_in_delayslot_o,                        //��ǰλ������׶ε�ָ���Ƿ�λ���ӳٲ�
        output reg        branch_flag_o,                            //�Ƿ���ת��
        output reg[31:0]  branch_target_address_o,                  //ת�Ƶ���Ŀ���ַ
        output reg[31:0]  link_addr_o,                              //ת��ָ��Ҫ����ķ��ص�ַ
        
        output [31:0]     inst_o,                                   //�����ӵ�����ӿ�
        
        
        //�����ˮ�߳�ͻ
        input             ex_wreg_i,                                //ִ�н׶�Ŀ��Ĵ�����дʹ��
        input [31:0]      ex_wdata_i,                               //ִ�н׶�Ŀ��Ĵ���д�������
        input [4:0]       ex_wd_i,                                  //ִ�н׶�Ŀ��Ĵ����ĵ�ַ

        input             mem_wreg_i,                               //�ô�׶�
        input [31:0]      mem_wdata_i,
        input [4:0]       mem_wd_i
    );

wire [6:0] op  = inst_i[6:0];                                        //�������� op
wire [2:0] op1 = inst_i[14:12];                                      //�������㷽ʽ funt3

reg  [31:0] imm;
wire [31:0] pc_plus_4;
wire [31:0] imm_branch;

assign pc_plus_4 = pc_i + 4;
assign imm_branch = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:7],{0}};
assign inst_o = inst_i;                                             //����׶ε�ָ��

always @(*) begin
    if(~rst_n) 
        is_in_delayslot_o <= 0;
    else 
        is_in_delayslot_o <= is_in_delayslot_i;
    
end
/***************************************************************************************************
                                ��һ�Σ���ָ���������
****************************************************************************************************/
always @ (*) begin
    if(~rst_n) begin
        aluop_o <= 0;
        alusel_o <= 0;
        funct7_o <= 0;
        wd_o <= 0;
        wreg_o <= 0;
        reg1_read_o <= 0;
        reg2_read_o <= 0;
        reg1_addr_o <= 0;
        reg2_addr_o <= 0;
        imm <= 0;
        link_addr_o <= 0;
        branch_target_address_o <= 0;
        branch_flag_o <= 0;
        next_inst_in_delayslot_o <= 0;        
    end
    else begin
        aluop_o <= 0;
        alusel_o <= 0;
        funct7_o <= 0;
        wd_o <= inst_i[11:7];                                            //rd�ĵ�ַ
        wreg_o <= 1'b1;                                                  //Ŀ�ļĴ���ʹ���ź�
        reg1_read_o <= 0;                         
        reg2_read_o <= 0;
        reg1_addr_o <= inst_i[19:15];                                    //rs1�ĵ�ַ
        reg2_addr_o <= inst_i[24:20];                                    //rs2�ĵ�ַ
        imm <= 0;
        link_addr_o <= 0;
        branch_target_address_o <= 0;
        branch_flag_o <= 0;
        next_inst_in_delayslot_o <= 0;       

        
        
        case(op)
            //I-type
            7'b0000011: begin
                case(op1)
                    3'b000, 3'b001, 3'b010, 3'b100, 3'b101: begin       //lb,lh,lw, lbu, lhu
                        wreg_o <= 1'b1;
                        aluop_o <= op;
                        alusel_o <= op1;                       
                        reg1_read_o <= 1'b1;
                        reg2_read_o <= 1'b0;
                        imm <= {{20{inst_i[31]}} , inst_i[31:20]}; 
                    end
                    default : begin end
                 endcase
            end
            //I-type
            7'b0100011: begin
                case(op1)
                    3'b000, 3'b001, 3'b010: begin       //sb,sh,sw
                        wreg_o <= 1'b1;
                        aluop_o <= op;
                        alusel_o <= op1;                       
                        reg1_read_o <= 1'b1;
                        reg2_read_o <= 1'b1;
                        imm <= {{20{inst_i[31]}} , inst_i[31:25], inst_i[11:7]}; 
                    end
                    default : begin end
                 endcase
            end
            
             
            
            //I-type
            7'b0010011: begin
                                                        //����������
                case (op1)
                    3'b000, 3'b010, 3'b100, 3'b110, 3'b111: begin          //addi, slti, xori, ori, andi
                        wreg_o <= 1'b1;                                    //��������д��Ŀ�ļĴ���
                        aluop_o <= op;                                     //��������
                        alusel_o <= op1;                                   //���㷽ʽ
                        reg1_read_o <= 1'b1;                               //��Ҫͨ��Regfile�Ķ��˿�1���Ĵ���
                        reg2_read_o <= 1'b0;                               //����Ҫͨ��Regfile�Ķ��˿�2���Ĵ���
                        imm <= {{20{inst_i[31]}} , inst_i[31:20]};         //��������չ
                    end
                    
                    3'b000, 3'b101: begin                                   //slli, srli, srai
                         wreg_o <= 1'b1;
                         aluop_o <= op;
                         alusel_o <= op1;
                         funct7_o <= inst_i[31:25];
                         reg1_read_o <= 1'b1;
                         reg2_read_o <= 1'b0;
                         imm <= {{26{0}}, inst_i[25:20]};
                    end
                     3'b011: begin                                          //sltiu
                         wreg_o <= 1'b1;
                         aluop_o <= op;
                         alusel_o <= op1;
                         reg1_read_o <= 1'b1;
                         reg2_read_o <= 1'b0;
                         imm <= {{20{inst_i[0]}}, inst_i[31:20]};
                     end
                    
                    
                    
                    
                    default: begin end
                endcase
                
            end
            
            //R-type
            7'b0110011: begin                                                
                case (op1)
                    3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111: begin            //add, sub, sll, slt, sltu, xor, srl, sra, or, and
                        wreg_o <= 1'b1;
                        aluop_o <= op;
                        alusel_o <= op1;
                        funct7_o <= inst_i[31:25];
                        reg1_read_o <= 1'b1;
                        reg2_read_o <= 1'b1;
                    end
                    default : begin end
                endcase
            end
            
            //U-type
            7'b0110111: begin                                                  //lui
                wreg_o <= 1'b0;
                aluop_o <= op;
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b0;
                imm <= {{12{inst_i[31]}} , inst_i[31:12]};                                
            end
            
            //B-type
            7'b1100011: begin
                case(op1)
                    3'b000: begin
                        wreg_o <= 1'b0;
                        aluop_o <= op;
                        alusel_o <= op1;
                        reg1_read_o <= 1'b1;
                        reg2_read_o <= 1'b1;
                        if(reg1_o == reg2_o) begin
                            branch_target_address_o <= pc_i + imm_branch;
                            branch_flag_o <= 1'b0;
                            next_inst_in_delayslot_o <= 1'b0;
                        end
                    end
                    
                    3'b001: begin
                        wreg_o <= 1'b0;
                        aluop_o <= op;
                        alusel_o <= op1;
                        reg1_read_o <= 1'b1;
                        reg2_read_o <= 1'b1;
                        if(reg1_o != reg2_o) begin
                            branch_target_address_o <= pc_i + imm_branch;
                            branch_flag_o <= 1'b1;
                            next_inst_in_delayslot_o <= 1'b1;
                        end
                    end
                    
                    3'b100: begin
                        wreg_o <= 1'b0;
                        aluop_o <= op;
                        alusel_o <= op1;
                        reg1_read_o <= 1'b1;
                        reg2_read_o <= 1'b1;
                        //������
                        if(reg1_o < reg2_o) begin
                            branch_target_address_o <= pc_i + imm_branch;
                            branch_flag_o <= 1'b1;
                            next_inst_in_delayslot_o <= 1'b1;
                        end
                    end
                    
                    3'b101: begin
                        wreg_o <= 1'b0;
                        aluop_o <= op;
                        alusel_o <= op1;
                        reg1_read_o <= 1'b1;
                        reg2_read_o <= 1'b1;
                        //������
                        if(reg1_o >= reg2_o) begin
                            branch_target_address_o <= pc_i + imm_branch;
                            branch_flag_o <= 1'b1;
                            next_inst_in_delayslot_o <= 1'b1;
                        end
                    end
                    
                    3'b110: begin
                        wreg_o <= 1'b0;
                        aluop_o <= op;
                        alusel_o <= op1;
                        reg1_read_o <= 1'b1;
                        reg2_read_o <= 1'b1;
                        //������
                        if(reg1_o < reg2_o) begin
                            branch_target_address_o <= pc_i + imm_branch;
                            branch_flag_o <= 1'b1;
                            next_inst_in_delayslot_o <= 1'b1;
                        end
                    end
                    
                    3'b111: begin
                        wreg_o <= 1'b0;
                        aluop_o <= op;
                        alusel_o <= op1;
                        reg1_read_o <= 1'b1;
                        reg2_read_o <= 1'b1;
                        //������
                        if(reg1_o >= reg2_o) begin
                            branch_target_address_o <= pc_i + imm_branch;
                            branch_flag_o <= 1'b1;
                            next_inst_in_delayslot_o <= 1'b1;
                        end
                    end
                    
                    
                    
                    default : begin end
                endcase
                
                

                
            end
            
            
            
            
            default: begin end
        endcase
        
        
        
    end
end
/***************************************************************************************************
                                �ڶ��Σ�ȷ�����������Դ������1
****************************************************************************************************/
//ex_wd_i ִ�н׶�����д�Ĵ����ĵ�ַ
//ex_wreg_i ִ�н׶�д�Ĵ���ʹ��
//reg1_addr_o ����׶�����Ĵ����ĵ�ַ
//reg1_read_o ����׶ζ��Ĵ���ʹ��
// r2 + r3 -> r1
// r3 - r2 -> r1
// r2 & r1 -> r3  r1������Ҫ��һ��ִ�н׶�r1������ 
// mem[r3 + imm] -> r4 �ô���Ҫ��һ��ִ�н׶�r3������
always @ (*) begin
    if(~rst_n)
        reg1_o <= 0;
    else if((reg1_read_o) && (ex_wreg_i) && (ex_wd_i == reg1_addr_o))     //������Ҫִ�н׶ε�����                                                                          
        reg1_o <= ex_wdata_i;                                              //��ȡ��������ֱ�ӽ����ͻ�����׶�
    else if((reg1_read_o) && (mem_wreg_i) && (mem_wd_i == reg1_addr_o))   //�ô���Ҫִ�н׶ε�����                                                               
        reg1_o <= mem_wdata_i;                                             //��ȡ��������ֱ�ӽ����ͻ�����׶�     
    else if(reg1_read_o)
        reg1_o <= reg1_data_i;                                             //regfile���˿�1����ֵ
    else if(~reg1_read_o)
        reg1_o <= imm;    
    else
        reg1_o <= 0;
end

/***************************************************************************************************
                                �����Σ�ȷ�����������Դ������2
****************************************************************************************************/
always @ (*) begin
    if(~rst_n)
        reg2_o <= 0;    
    else if((reg2_read_o) && (ex_wreg_i) && (ex_wd_i == reg2_addr_o))
        reg2_o <= ex_wdata_i;
    else if((reg2_read_o) && (mem_wreg_i) && (mem_wd_i == reg2_addr_o))
        reg2_o <= mem_wdata_i;  
    else if(reg2_read_o)
        reg2_o <= reg2_data_i;                                              //regfile���˿�2����ֵ
    else if(~reg2_read_o)
        reg2_o <= imm;
    else
        reg2_o <= 0;    
end

endmodule