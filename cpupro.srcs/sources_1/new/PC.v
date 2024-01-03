`ifndef _PC
`define _PC

module PC(
    input wire clk,reset,
    input wire [1:0] period1_pcway,
    input wire [31:0] period1_baddr,
    input wire [31:0] period1_jaddr,
    input wire [31:0] period1_pc,
	output reg[31:0] period1_npc
);
    always @(negedge reset) begin
        period1_npc <= 32'b0;
    end
	always @(posedge clk) begin
		  case (period1_pcway)
		      2'b01:period1_npc<=period1_pc+4;
		      2'b10:period1_npc<=period1_baddr;
		      2'b11:period1_npc<=period1_jaddr;
		      default:period1_npc<=period1_pc;
		  endcase		
	end
endmodule

`endif

