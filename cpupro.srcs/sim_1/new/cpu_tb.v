`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: cpu_tb
// Author:lerogo
//////////////////////////////////////////////////////////////////////////////////

module cpu_tb();
    integer i = 0;
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
	
	cpu cpu1(.clk(clk),.reset(reset));
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
 



