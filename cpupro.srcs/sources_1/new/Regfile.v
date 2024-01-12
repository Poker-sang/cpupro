`ifndef _Regfile
`define _Regfile

module Regfile(
    input clk,reset,
    input period5_wb,
    input [4:0] period2_rs,
    input [4:0] period2_rt,
    input [4:0] period5_rd,
    input [31:0] wbdata,
    output [31:0] period2_rsdata,
    output [31:0] period2_rtdata
 );
    // 32-bit memory with 32 entries
    reg [31:0] Reg [0:31];
    reg [31:0] _data1, _data2;
    integer i = 0;
    always @(posedge clk or posedge reset) begin
        if (!reset) begin
            for (integer i = 0; i < 32; i = i + 1) begin
                Reg[i] <= 32'b0;
            end
        end else begin
            if (period5_wb && (period5_rd != 5'd0)) begin
                Reg[period5_rd] <= wbdata;
            end
        end
    end
    always @(*) begin
		if (period2_rs == 5'd0)
			_data1 = 32'd0;
	    // 解决写入问题
		else if ((period2_rs == period5_rd) && period5_wb)
			_data1 = wbdata;
		else
			_data1 = Reg[period2_rs][31:0];
    end
    always @(*) begin
		if (period2_rt == 5'd0)
			_data2 = 32'd0;
		else if ((period2_rt == period5_rd) && period5_wb)
			_data2 = wbdata;
		else
			_data2 = Reg[period2_rt][31:0];
    end
    assign period2_rsdata = _data1;
	assign period2_rtdata = _data2;
	
//	always @(posedge clk) begin
//		if (period5_wb && period5_rd != 5'd0) begin
//			Reg[period5_rd] <= wbdata;
//		end
//	end
    
endmodule

`endif


