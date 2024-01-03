`ifndef _PC
`define _PC

module PC(
    input wire clk, reset,
    input wire [1:0] period1_pcway, // ѡ�������
    input wire [31:0] period1_baddr, // ��֧��ַ
    input wire [31:0] period1_jaddr, // ��ת��ַ
    input wire [31:0] period1_pc, // ��������ǰֵ
    output reg [31:0] period1_npc // �¸����������ֵ
);

    // �ڳ�ʼ��ʱ�� period1_npc ���и�ֵ
    initial begin
        period1_npc <= 32'b0;
    end

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            // �ڸ�λʱ�� period1_npc ��Ϊ 0
            period1_npc <= 32'b0;
        end else begin
            // ��ʱ��������ʱ���ݿ����źŸ� period1_npc ��ֵ
            case (period1_pcway)
                2'b01: period1_npc <= period1_pc + 4;
                2'b10: period1_npc <= period1_baddr;
                2'b11: period1_npc <= period1_jaddr;
                default: period1_npc <= period1_pc;
            endcase
        end
    end
endmodule


`endif

