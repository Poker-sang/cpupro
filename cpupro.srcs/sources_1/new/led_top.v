`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: display
// Author:deng dongyu
//////////////////////////////////////////////////////////////////////////////////


module display(
    input wire clk,
    input wire reset,
    input wire [15:0]s,
    output wire [6:0]seg,
    output reg [3:0]ans
    );
    reg [31:0]count;
    reg [4:0]digit; 
        
    always@(posedge clk or negedge reset)
        if(!reset) count<= 0;
        else count <= count + 1;
       
    always @(posedge clk)
    case(count[17:16])
        2'b00:begin
            ans = 4'b0001;
            digit = s[3:0];
        end
        
        2'b01:begin
            ans = 4'b0010;
            digit = s[7:4];
        end

        2'b10:begin
            ans = 4'b0100;
            digit =s[11:8];
        end
        
        2'b11:begin
            ans = 4'b1000;
            digit = s[15:12];
        end
    endcase
    seg U4(.d_num(digit),.seg_code(seg));
endmodule