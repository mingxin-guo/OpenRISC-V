//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2014 leishangwen@163.com                       ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
// Module:  data_ram
// File:    data_ram.v
// Author:  Lei Silei
// E-mail:  leishangwen@163.com
// Description: 数据存储器
// Revision: 1.0
//////////////////////////////////////////////////////////////////////

module data_ram(

	input	wire				clk,
	input wire					ce,				//数据存储器使能信号
	input wire					we,				//是否写操作
	input wire[31:0]			addr,
	input wire[31:0]            addr_s,
	input wire[3:0]				sel,			//字节选择信号
	input wire[31:0]			data_i,
	output reg[31:0]			data_o
	
);

	reg[31:0]  data_mem0[0:131071-1];
	reg[31:0]  data_mem1[0:131071-1];
	reg[31:0]  data_mem2[0:131071-1];
	reg[31:0]  data_mem3[0:131071-1];

	always @ (posedge clk) begin
		if (ce == 1'b0) begin
			//data_o <= ZeroWord;
		end 
		else if(we == 1'b1) begin
			  if (sel[3] == 1'b1) begin
		      data_mem3[addr_s[17+1:2]] <= data_i[31:24]; //2^17 + 1  128k
		    end
			  if (sel[2] == 1'b1) begin
		      data_mem2[addr_s[17+1:2]] <= data_i[23:16];
		    end
		       if (sel[1] == 1'b1) begin
		      data_mem1[addr_s[17+1:2]] <= data_i[15:8];
		    end
			  if (sel[0] == 1'b1) begin
		      data_mem0[addr_s[17+1:2]] <= data_i[7:0];
		    end			   	    
		end
	end
	
	always @ (*) begin
		if (ce == 1'b0) begin
			data_o <= 0;
	  end else if(we == 1'b0) begin
		    data_o <= {data_mem3[addr[17+1:2]],
		               data_mem2[addr[17+1:2]],
		               data_mem1[addr[17+1:2]],
		               data_mem0[addr[17+1:2]]};
		end else begin
				data_o <= 0;
		end
	end		

endmodule