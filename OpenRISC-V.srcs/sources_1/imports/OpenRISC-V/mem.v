`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/24 10:40:48
// Design Name: 
// Module Name: mem
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


module mem(
    input                 rst_n,
    
    input [4:0]           wd_i,
    input                 wreg_i,
    input [31:0]          wdata_i,
    
    input [6:0]           aluop_i,
    input [2:0]           alusel_i,
    input [31:0]          mem_addr_i,
    input [31:0]          mem_addr_s_i,
    input [31:0]          reg2_i,
    
    //来自外部数据存储器RAM的信息
    input [31:0]          mem_data_i,
    
    //送到外部数据存储器RAM的信息
    output reg[31:0]      mem_addr_o,
    output reg[31:0]      mem_addr_s_o, 
    output                mem_we_o,
    output reg[3:0]       mem_sel_o,
    output reg[31:0]      mem_data_o,
    output reg            mem_ce_o,
    
    output reg [4:0]      wd_o,
    output reg            wreg_o,
    output reg [31:0]     wdata_o
    );
    
wire [31:0] zero32;
reg mem_we;
assign mem_we_o = mem_we;
assign zero32 = 32'b0;

always @ (*) begin
    if(~rst_n) begin
        wd_o <= 0;
        wreg_o <= 0;
        wdata_o <= 0;
        mem_addr_o <= 0;
        mem_we <= 0;
        mem_sel_o <= 0;
        mem_data_o <= 0;
        mem_ce_o <= 0;
    end
    else begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        wdata_o <= wdata_i;
        mem_we <= 0;
        mem_addr_o <= 0;
        mem_sel_o <= 4'b1111;
        mem_ce_o <= 0;
        
        case(aluop_i)
            7'b0000011: begin
                case(alusel_i)
                    3'b000: begin                                                           //lb
                        mem_addr_o <= mem_addr_i;
                        mem_we <= 0;
                        mem_ce_o <= 1'b1;
                        
                        case(mem_addr_i[1:0])
                            2'b00: begin
                                wdata_o   <= {{24{mem_data_i[31]}}, mem_data_i[7:0]};
                                mem_sel_o <= 4'b0001;
                            end
                            2'b01: begin
                                wdata_o   <= {{24{mem_data_i[31]}}, mem_data_i[15:8]};
                                mem_sel_o <= 4'b0001;
                            end
                            2'b10: begin
                                wdata_o   <= {{24{mem_data_i[31]}}, mem_data_i[23:16]};
                                mem_sel_o <= 4'b0001;
                            end
                            2'b11: begin
                                wdata_o   <= {{24{mem_data_i[31]}}, mem_data_i[31:24]};
                                mem_sel_o <= 4'b0001;
                            end
                            default : begin wdata_o <= 0; end
                        endcase             
                    end
                    
                    3'b001: begin                                                           //lh
                        mem_addr_o <= mem_addr_i;
                        mem_we <= 0;
                        mem_ce_o <= 1'b1;
                        
                        case(mem_addr_i[1:0])
                            2'b00: begin
                                wdata_o   <= {{16{mem_data_i[15]}}, mem_data_i[15:0]};
                                mem_sel_o <= 4'b0011;
                            end
                            2'b10: begin
                                wdata_o   <= {{16{mem_data_i[31]}}, mem_data_i[31:16]};
                                mem_sel_o <= 4'b1100;
                            end
                            default : begin wdata_o <= 0; end
                        endcase             
                    end
                    
                    3'b010: begin                                                           //lw
                        mem_addr_o  <= mem_addr_i;
                        mem_we      <= 0;
                        wdata_o     <=  mem_data_i;
                        mem_sel_o   <= 4'b1111;
                        mem_ce_o    <= 1'b1;           
                    end
                    
                    3'b100: begin                                                           //lbu
                        mem_addr_o  <= mem_addr_i;
                        mem_we      <= 0;
                        mem_ce_o    <= 1'b1;
                        
                        case(mem_addr_i[1:0])
                            2'b00: begin
                                wdata_o   <= {{24{1'b0}}, mem_data_i[7:0]};
                                mem_sel_o <= 4'b0001;
                            end
                            2'b01: begin
                                wdata_o   <= {{24{1'b0}}, mem_data_i[15:8]};
                                mem_sel_o <= 4'b0001;
                            end
                            2'b10: begin
                                wdata_o   <= {{24{1'b0}}, mem_data_i[23:16]};
                                mem_sel_o <= 4'b0001;
                            end
                            2'b11: begin
                                wdata_o   <= {{24{1'b0}}, mem_data_i[31:24]};
                                mem_sel_o <= 4'b0001;
                            end
                            default : begin wdata_o <= 0; end
                        endcase      
                    end
                    
                    3'b101: begin                                                           //lhu
                        mem_addr_o  <= mem_addr_i;
                        mem_we      <= 0;
                        mem_ce_o    <= 1'b1;
                        
                        case(mem_addr_i[1:0])
                            2'b00: begin
                                wdata_o   <= {{16{1'b0}}, mem_data_i[15:0]};
                                mem_sel_o <= 4'b0011;
                            end
                            2'b10: begin
                                wdata_o   <= {{16{1'b0}}, mem_data_i[31:16]};
                                mem_sel_o <= 4'b1100;
                            end
                            default : begin wdata_o <= 0; end
                        endcase             
                    end
                    
                    
                    
                default : begin end
                endcase
            end
            
            7'b0100011: begin
                case(alusel_i)
                    3'b000: begin
                        mem_addr_s_o  <= mem_addr_s_i;
                        mem_we      <= 1'b1;
                        mem_data_o  <= {reg2_i[7:0], reg2_i[7:0], reg2_i[7:0], reg2_i[7:0]};
                        mem_ce_o    <= 1'b1;
                        case(mem_addr_s_i[1:0])
                            2'b00: mem_sel_o <= 4'b0001;
                            2'b01: mem_sel_o <= 4'b0010;
                            2'b10: mem_sel_o <= 4'b0100;
                            2'b11: mem_sel_o <= 4'b1000;
                            
                            default : begin mem_sel_o <= 4'b0000; end
                        endcase
                    end

                    3'b001: begin
                        mem_addr_s_o <= mem_addr_s_i;
                        mem_we        <= 1'b1;
                        mem_data_o    <= {reg2_i[15:0], reg2_i[15:0]};
                        mem_ce_o      <= 1'b1;
                        case (mem_addr_s_i[1:0])
                            2'b00: mem_sel_o <= 4'b0011;
                            2'b10: mem_sel_o <= 4'b1100; 
                            default: begin mem_sel_o <= 4'b0000;  end
                        endcase
                    end

                    3'b010: begin
                        mem_addr_s_o <= mem_addr_s_i;
                        mem_we       <= 1'b1;
                        mem_data_o   <= reg2_i;
                        mem_sel_o    <= 4'b1111;
                        mem_ce_o     <= 1'b1;
                    end
                    
                    default : begin end
                endcase
            end
            
            
            
            default : begin end
       endcase
    end
end
endmodule
