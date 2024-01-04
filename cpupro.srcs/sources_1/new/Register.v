`ifndef _Register
`define _Register
module Register(
    input clk,
    input clear,
    input hold,
    input data_in,
    output data_out
    );
    // ¶àÉÙÎ» the number of bits
    parameter N = 1;
    
    wire [N-1:0] data_in;
    reg [N-1:0] data_out;
    
    always @(posedge clk) begin
        if(clear)
            data_out <= {N{1'b0}};
        else if (hold)
            data_out <= data_out;
        else
            data_out <= data_in;
    end
    
endmodule

`endif