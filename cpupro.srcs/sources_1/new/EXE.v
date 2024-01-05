`ifndef _EXE
`define _EXE

module EXE(
    input [5:0] period3_exe_op,
    input [31:0] period3_exe_data1,
    input [31:0] period3_exe_data2,
    output reg [31:0] period3_exe_result
    );
    always @(*) begin
        case(period3_exe_op)
            // add addi addiu
            6'd1,6'd2,6'd3: period3_exe_result <= period3_exe_data1 + period3_exe_data2;
            // sub
            6'd4: period3_exe_result <= period3_exe_data1 - period3_exe_data2;
            // and andi
            6'd5,6'd6: period3_exe_result <= period3_exe_data1 & period3_exe_data2;
            // or ori
            6'd7,6'd8: period3_exe_result <= period3_exe_data1 | period3_exe_data2;
            // nor nori
            6'd9,6'd10: period3_exe_result <= ~(period3_exe_data1 | period3_exe_data2);
            // xor xori
            6'd11,6'd12: period3_exe_result <= period3_exe_data1 ^ period3_exe_data2;
            // beq beqz
            6'd13,6'd14: period3_exe_result <= (period3_exe_data1 == period3_exe_data2)?32'b1:32'b0;
            // bne bnez
            6'd15,6'd16: period3_exe_result <= (period3_exe_data1 != period3_exe_data2)?32'b1:32'b0;
            // bgt
            6'd17: period3_exe_result <= (period3_exe_data1 > period3_exe_data2)?32'b1:32'b0;
            // bge
            6'd18: period3_exe_result <= (period3_exe_data1 >= period3_exe_data2)?32'b1:32'b0;
            // blt
            6'd19: period3_exe_result <= (period3_exe_data1 < period3_exe_data2)?32'b1:32'b0;
            // ble
            6'd20: period3_exe_result <= (period3_exe_data1 <= period3_exe_data2)?32'b1:32'b0;
            // j 
            6'd21: period3_exe_result <= 32'b0;
            // jr
            6'd23: period3_exe_result <= period3_exe_data1;
            // lb lh lw
            6'd24,6'd25,6'd26: period3_exe_result <= period3_exe_data1;
            // sb sh sw
            6'd27,6'd28,6'd29: period3_exe_result <= period3_exe_data2;
            // slli
            6'd30: period3_exe_result <= period3_exe_data1 << period3_exe_data2;
            // sll
            6'd31: period3_exe_result <= period3_exe_data1 << period3_exe_data2[4:0];
            // srli
            6'd32: period3_exe_result <= period3_exe_data1 >> period3_exe_data2; 
            // srl
            6'd33: period3_exe_result <= period3_exe_data1 >> period3_exe_data2[4:0];
            //mul
            6'd35:period3_exe_result <=period3_exe_result <= period3_exe_data1 * period3_exe_data2;
            //div
            6'd36:period3_exe_result <=period3_exe_result <= period3_exe_data1 / period3_exe_data2;
        endcase
    end
    
endmodule
`endif