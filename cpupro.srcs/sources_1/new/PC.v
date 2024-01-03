`ifndef _PC
`define _PC

module PC(
    input wire clk, reset,
    input wire [1:0] period1_pcway, // 选择计数器
    input wire [31:0] period1_baddr, // 分支地址
    input wire [31:0] period1_jaddr, // 跳转地址
    input wire [31:0] period1_pc, // 计数器当前值
    output reg [31:0] period1_npc // 下个程序计数器值
);

    // 在初始化时对 period1_npc 进行赋值
    initial begin
        period1_npc <= 32'b0;
    end

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            // 在复位时将 period1_npc 设为 0
            period1_npc <= 32'b0;
        end else begin
            // 在时钟上升沿时根据控制信号给 period1_npc 赋值
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

