`timescale 1ns / 1ps



`ifndef _IM
`define _IM

module IM(
    input clk,
    input  period1_npc,
    output period1_command
    );
    wire[31:0] period1_npc;
    reg[31:0] period1_command;
    
    // number of instruction
    parameter MEM_NUM = 0;
	parameter IM_DATA_FILENAME = "";
    // 32位的指令 32bits instructions
	reg [31:0] mem [0:MEM_NUM];
    
    // 读取16进制的数据
	initial begin
		$readmemh(IM_DATA_FILENAME, mem,0, MEM_NUM-1);
	end
	always @(*) begin
	   if(period1_npc[8:2] > MEM_NUM) period1_command <= 32'b0;
	   // 加4 第n条  pc <= pc+4 means period1_npc[8:2] not period1_npc[8:0]
	   else period1_command <= mem[period1_npc[8:2]][31:0];   
	end
    
endmodule
`endif
