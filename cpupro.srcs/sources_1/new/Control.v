`ifndef _Control
`define _Control

module Control(
    input [5:0] period2_opcode,
    input [15:0] period2_imm,
    input [4:0] period2_rd,
    input [4:0] period2_rs,
    input [4:0] period2_rt,
    output reg period2_if_imm,
    output reg period2_if_branch,
    output reg period2_if_jump,
    output reg period2_memr,
    output reg period2_memw,
    output reg period2_wb,
    output reg [4:0] period2_rs_fact,
    output reg [4:0] period2_rt_fact
    );
    always @(*) begin
        //default
        period2_if_imm <= 1'b0;
        period2_if_branch <= 1'b0;
        period2_if_jump <= 1'b0;
        period2_memr <= 1'b0;
        period2_memw <= 1'b0;
        period2_wb <= 1'b0;
        // Ĭ�ϼĴ���
        period2_rs_fact <= period2_rs;
        period2_rt_fact <= period2_rt;
        
        case(period2_opcode)
            // ʹ��3���Ĵ�����
            // 'add', 'sub', 'and', 'or', 'nor', 'xor', 'sll', 'srl', 'mul', 'div'
            6'd1,6'd4,6'd5,6'd7,6'd9,6'd11,6'd31,6'd33,6'd35,6'd36: begin
                 period2_wb <= 1'b1;
            end
            
            // ʹ��2���Ĵ��� ����imm�� ������
            // 'addi', 'addiu', 'andi', 'ori', 'nori', 'xori' 'slli', 'srli', 'srai', 'slti'
            6'd2,6'd3,6'd6,6'd8,6'd10,6'd12,6'd30,6'd32,6'd34,6'd37: begin
                period2_wb <= 1'b1;
                period2_if_imm <= 1'b1;
                period2_rt_fact <= 5'b0; 
            end
            // ʹ��2���Ĵ��� ����imm�� �Ƚ����� ��ת
            // 'beq', 'beqz' ,'bne', 'bnez', 'bgt', 'bge', 'blt','ble'
            // ���� bnez beqz ָ������һ�� rtĬ��Ϊ0������ָ��ʱ��
            6'd13,6'd14, 6'd15,6'd16,6'd17,6'd18,6'd19,6'd20:begin
                period2_if_branch <= 1'b1;
                period2_rs_fact <= period2_rd;
                period2_rt_fact <= period2_rs;
            end
            
            // ʹ��2���Ĵ�����
            // 'lb', 'lh', 'lw'
            6'd24,6'd25,6'd26: begin
                period2_wb <= 1'b1;
                period2_memr <= 1'b1;
                period2_rt_fact <= 5'b0;
            end
            // 'sb', 'sh', 'sw'
            6'd27,6'd28,6'd29:begin
                period2_memw <= 1'b1;
                period2_rs_fact <= period2_rs;
                period2_rt_fact <= period2_rd;
            end
            
            // ��һ��imm��
            // 'j'
            6'd21: begin
                period2_if_jump <= 1'b1;
            end
            // ��һ���Ĵ�����
            // 'jr'
            6'd23: begin
                period2_if_jump <= 1'b1;
                period2_rs_fact <= period2_rd;
                period2_rt_fact <= 5'b0;
            end
        endcase
    end
    
    
endmodule
`endif
