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
	parameter IM_DATA_FILENAME = "im_data.mem";
    // 32位的指令 32bits instructions
	reg [31:0] mem [0:33];
    
    // 读取16进制的数据
	initial begin
		$readmemh("im_data.mem", mem); 
//        mem[0] = 32'h08200001;
//        mem[1] = 32'h78410004;
//        mem[2] = 32'h08200002;
//        mem[3] = 32'h5c400000;
//        mem[4] = 32'h08800003;
//        mem[5] = 32'h04205800;
//        mem[6] = 32'h44220008;
//        mem[7] = 32'h08a00001;
//        mem[8] = 32'h4ca20004;
//        mem[9] = 32'h08c00058;
//        mem[10] = 32'h08c00058;
//        mem[11] = 32'h08c00058;
//        mem[12] = 32'h78c60002;
//        mem[13] = 32'h0900000f;
//        mem[14] = 32'h6c280000;
//        mem[15] = 32'h61210000;
//        mem[16] = 32'h05490000;
//        mem[17] = 32'h0820000f;
//        mem[18] = 32'h08a0000f;
        end
	always @(*) begin
	   if(period1_npc[8:2] > MEM_NUM) period1_command <= 32'b0;
	   // 加4 第n条  pc <= pc+4 means period1_npc[8:2] not period1_npc[8:0]
	   else period1_command <= mem[period1_npc[8:2]][31:0];   
	end
    
endmodule
`endif
