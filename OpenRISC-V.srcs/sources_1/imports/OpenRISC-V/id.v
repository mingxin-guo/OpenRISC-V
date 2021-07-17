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
        //读取register 
        input [31:0]      reg1_data_i,
        input [31:0]      reg2_data_i,
        //如果上一条指令是转移指令，那么下一条指令进入译码阶段的时候
        //输入变量is_in_delayslot_i为true, 表示是延迟槽指令，反之为false
        input             is_in_delayslot_i,
        //输出到regfile
        output reg        reg1_read_o,
        output reg        reg2_read_o,
        output reg [4:0]  reg1_addr_o,                              //rs1
        output reg [4:0]  reg2_addr_o,                              //rs2
        //送出到执行模块
        output reg [6:0]  aluop_o,
        output reg [2:0]  alusel_o,
        output reg [6:0]  funct7_o,
        output reg [31:0] reg1_o,
        output reg [31:0] reg2_o,
        output reg [4:0]  wd_o,
        output reg        wreg_o,
        
        
        output reg        next_inst_in_delayslot_o,                 //下一条进入译码阶段的指令是否位于延迟槽
        output reg        is_in_delayslot_o,                        //当前位于译码阶段的指令是否位于延迟槽
        output reg        branch_flag_o,                            //是否发生转移
        output reg[31:0]  branch_target_address_o,                  //转移到的目标地址
        output reg[31:0]  link_addr_o,                              //转移指令要保存的返回地址
        
        output [31:0]     inst_o,                                   //新增加的输出接口
        
        
        //解决流水线冲突
        input             ex_wreg_i,                                //执行阶段目标寄存器的写使能
        input [31:0]      ex_wdata_i,                               //执行阶段目标寄存器写入的数据
        input [4:0]       ex_wd_i,                                  //执行阶段目标寄存器的地址

        input             mem_wreg_i,                               //访存阶段
        input [31:0]      mem_wdata_i,
        input [4:0]       mem_wd_i
    );

wire [6:0] op  = inst_i[6:0];                                        //运算类型 op
wire [2:0] op1 = inst_i[14:12];                                      //具体运算方式 funt3

reg  [31:0] imm;
wire [31:0] pc_plus_4;
wire [31:0] imm_branch;

assign pc_plus_4 = pc_i + 4;
assign imm_branch = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:7],{0}};
assign inst_o = inst_i;                                             //译码阶段的指令

always @(*) begin
    if(~rst_n) 
        is_in_delayslot_o <= 0;
    else 
        is_in_delayslot_o <= is_in_delayslot_i;
    
end
/***************************************************************************************************
                                第一段：对指令进行译码
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
        wd_o <= inst_i[11:7];                                            //rd的地址
        wreg_o <= 1'b1;                                                  //目的寄存器使能信号
        reg1_read_o <= 0;                         
        reg2_read_o <= 0;
        reg1_addr_o <= inst_i[19:15];                                    //rs1的地址
        reg2_addr_o <= inst_i[24:20];                                    //rs2的地址
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
                                                        //立即数操作
                case (op1)
                    3'b000, 3'b010, 3'b100, 3'b110, 3'b111: begin          //addi, slti, xori, ori, andi
                        wreg_o <= 1'b1;                                    //将运算结果写入目的寄存器
                        aluop_o <= op;                                     //运算类型
                        alusel_o <= op1;                                   //运算方式
                        reg1_read_o <= 1'b1;                               //需要通过Regfile的读端口1读寄存器
                        reg2_read_o <= 1'b0;                               //不需要通过Regfile的读端口2读寄存器
                        imm <= {{20{inst_i[31]}} , inst_i[31:20]};         //立即数扩展
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
                        //有问题
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
                        //有问题
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
                        //有问题
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
                        //有问题
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
                                第二段：确定进行运算的源操作数1
****************************************************************************************************/
//ex_wd_i 执行阶段所需写寄存器的地址
//ex_wreg_i 执行阶段写寄存器使能
//reg1_addr_o 译码阶段所需寄存器的地址
//reg1_read_o 译码阶段读寄存器使能
// r2 + r3 -> r1
// r3 - r2 -> r1
// r2 & r1 -> r3  r1译码需要上一步执行阶段r1的数据 
// mem[r3 + imm] -> r4 访存需要上一步执行阶段r3的数据
always @ (*) begin
    if(~rst_n)
        reg1_o <= 0;
    else if((reg1_read_o) && (ex_wreg_i) && (ex_wd_i == reg1_addr_o))     //译码需要执行阶段的数据                                                                          
        reg1_o <= ex_wdata_i;                                              //读取的数据则直接将其送回译码阶段
    else if((reg1_read_o) && (mem_wreg_i) && (mem_wd_i == reg1_addr_o))   //访存需要执行阶段的数据                                                               
        reg1_o <= mem_wdata_i;                                             //读取的数据则直接将其送回译码阶段     
    else if(reg1_read_o)
        reg1_o <= reg1_data_i;                                             //regfile读端口1的数值
    else if(~reg1_read_o)
        reg1_o <= imm;    
    else
        reg1_o <= 0;
end

/***************************************************************************************************
                                第三段：确定进行运算的源操作数2
****************************************************************************************************/
always @ (*) begin
    if(~rst_n)
        reg2_o <= 0;    
    else if((reg2_read_o) && (ex_wreg_i) && (ex_wd_i == reg2_addr_o))
        reg2_o <= ex_wdata_i;
    else if((reg2_read_o) && (mem_wreg_i) && (mem_wd_i == reg2_addr_o))
        reg2_o <= mem_wdata_i;  
    else if(reg2_read_o)
        reg2_o <= reg2_data_i;                                              //regfile读端口2的数值
    else if(~reg2_read_o)
        reg2_o <= imm;
    else
        reg2_o <= 0;    
end

endmodule