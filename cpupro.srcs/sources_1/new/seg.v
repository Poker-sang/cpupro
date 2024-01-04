`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: seg
// Author:deng dongyu
//////////////////////////////////////////////////////////////////////////////////
module seg(
    input wire [3:0] d_num,
    output reg [6:0] seg_code
    );
	   parameter   _0 = ~8'h3f;
	   parameter   _1 = ~8'h06;
	   parameter   _2 = ~8'h5b;
	   parameter   _3 = ~8'h4f;
	   parameter   _4 = ~8'h66;
	   parameter   _5 = ~8'h6d;
	   parameter   _6 = ~8'hfd;
	   parameter   _7 = ~8'h07;
	   parameter   _8 = ~8'h7f;
	   parameter   _9 = ~8'h6f;
	   parameter   _a = ~8'h77;
	   parameter   _b = ~8'h7c;
	   parameter   _c = ~8'h39;
	   parameter   _d = ~8'h5e;
	   parameter   _e = ~8'h7b;
	   parameter   _f = ~8'h71;
	   
always@(*)
    case( d_num )
                    4'd0:seg_code = ~_0;
                    4'd1:seg_code = ~_1;
                    4'd2:seg_code = ~_2;
                    4'd3:seg_code = ~_3;
                    4'd4:seg_code = ~_4;
                    4'd5:seg_code = ~_5;
                    4'd6:seg_code = ~_6;
                    4'd7:seg_code = ~_7;
                    4'd8:seg_code = ~_8;
                    4'd9:seg_code = ~_9;
                    4'd10:seg_code = ~_a;
                    4'd11:seg_code = ~_b;
                    4'd12:seg_code = ~_c;
                    4'd13:seg_code = ~_d;
                    4'd14:seg_code = ~_e;
                    4'd15:seg_code = ~_f;
                    default:
                        seg_code = 8'hff;
                endcase
endmodule