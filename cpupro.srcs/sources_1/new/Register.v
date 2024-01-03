`ifndef _Register
`define _Register
module Register(
    input clk,
    input clear,
    input hold,
    input in,
    output out
    );
    // ¶àÉÙÎ» the number of bits
    parameter N = 1;
    
    wire [N-1:0] in;
    reg [N-1:0] out;
    
    always @(posedge clk) begin
        if(clear)
            out <= {N{1'b0}};
        else if (hold)
            out <= out;
        else
            out <= in;
    end
    
endmodule

`endif