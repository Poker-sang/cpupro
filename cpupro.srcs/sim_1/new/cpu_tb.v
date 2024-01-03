`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: cpu_tb
// Author:lerogo
//////////////////////////////////////////////////////////////////////////////////

module cpu_tb();
    integer i = 0;
    parameter IM_MEM_NUM = 33;
    parameter MEM_DATA_NUM = 127;
    parameter IM_DATA_FILENAME = "im_data.mem";
	reg	 clk;
	reg	 reset;

//    initial begin
//        clk = 1'b0;
//		reset = 1'b1;
//        #5 reset=0;
//        #5 reset=1;
        

//	end//
	
//	always begin
//	   if(reset==1'b1) begin
//	       clk <= ~clk;
//	   end
//	   else begin
//	       clk <= 1'b0;
//	   end
//	   #5;
//	end//
	
	cpu #(.MEM_NUM(IM_MEM_NUM),.MEM_DATA_NUM(MEM_DATA_NUM), .IM_DATA_FILENAME(IM_DATA_FILENAME))
			cpu1(.clk(clk),.reset(reset));
parameter PERIOD = 10;

always begin
    clk = 1'b1;
    #(PERIOD/2) clk = 1'b0;
    #(PERIOD/2);
end

initial begin
    clk = 1'b1;
    reset = 1'b0;
    #5;
    reset = 1'b0;
    #5;
    reset = 1'b1;
    end
endmodule
 



