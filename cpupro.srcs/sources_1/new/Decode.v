`ifndef _Decode
`define _Decode

module Decode(
    input [31:0] period2_npc,
    input [31:0] period2_command,
    output [5:0] period2_opcode,
    output [4:0] period2_rs,
    output [4:0] period2_rt,
    output [4:0] period2_rd,
    output [15:0] period2_imm,
    output [31:0] period2_jaddr
    );
    assign period2_opcode  = period2_command[31:26];
	assign period2_rd = period2_command[25:21];
	assign period2_rs = period2_command[20:16];
	assign period2_rt = period2_command[15:11];
	assign period2_imm = period2_command[15:0];
	assign period2_jaddr = {period2_npc[31:28], period2_command[25:0], {2{1'b0}}};
    
endmodule

`endif

