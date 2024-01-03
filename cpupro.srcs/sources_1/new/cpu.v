`timescale 1ns / 1ps
`include "PC.v"
`include "IM.v"
`include "Regfile.v"
`include "Decode.v"
`include "Control.v"
`include "EXE.v"
`include "Memory.v"
`include "Register.v"

module cpu(clk,reset,op,pc);
    input clk,reset;
    output [7:0] pc;
    output [7:0] op;
   
    // 第一阶段
    // 用于对pc的选择
    reg [1:0] period1_pcway;
    // 跳转的地址 pc地址
    reg [31:0] period1_baddr,period1_jaddr;
    reg hold,flush;
    wire [31:0] period1_npc;
    // 第一阶段获取到的指令
    wire [31:0] period1_command;
    
    // 第二阶段
    // 传递到第二阶段的npc_s2、传递到第二阶段的im_data_s2
    wire [31:0] period2_npc,period2_command;
    // 译码输出
    wire [5:0] period2_opcode;
    wire [4:0] period2_rs,period2_rt,period2_rd;
    wire [15:0] period2_imm;
    wire [31:0] period2_jaddr;
    // b 的地址
    wire [31:0] period2_baddr = period2_npc + { {14{period2_imm[15]}},period2_imm, 2'b0 };
    // 控制器输出的控制信号
    wire period2_if_imm,period2_if_branch,period2_if_jump,period2_memr,period2_memw,period2_wb;
    wire [4:0] period2_rs_fact,period2_rt_fact;
    // 寄存器获得的值
    wire [31:0] period2_rsdata,period2_rtdata;
    
    // 第三阶段
    // 传递
    wire [5:0] period3_opcode;
    wire [4:0] period3_rs_fact,period3_rt_fact,period3_rd;
    wire [15:0] period3_imm;
    wire [31:0] period3_jaddr,period3_baddr;
    wire period3_if_imm,period3_if_branch,period3_if_jump,period3_memr,period3_memw,period3_wb;
    wire [31:0] period3_rsdata,period3_rtdata;
    // alu
    reg [31:0] period3_exe_data1,period3_exe_data2;
    wire [31:0] period3_exe_result;
    reg [1:0] period3_rw_bits;
    // 计算下一阶段用的数据
    
    // 第四阶段
    // 传递
    // 写入目标
    wire [5:0] period4_opcode;
    wire [4:0] period4_rd;
    wire [31:0] period4_jaddr,period4_baddr;
    wire period4_if_branch,period4_if_jump,period4_memr,period4_memw,period4_wb;
    // 如果要读/写内存 那么写mem的地址为period_exe_result
    // 如果要回写，那么回写数据为period_exe_result
    wire [31:0] period4_exe_result;
    // 读/写内存时，读写多少位 默认为00 32位    
    wire [1:0] period4_rw_bits;
    // 读内存的结果    // 写内存的数据
    wire [31:0] period4_rdata,period4_wdata;
    // 回写数据
    wire [31:0] period4_wbdata;
    
    // 第五阶段
    // 传递
    wire period5_wb,period5_memr;
    wire [4:0] period5_rd;
    wire [31:0] period5_wbdata,alu_out_s5,mem_read_data_s5;

    // 其他 用于4，5阶段修改reg数据 直接短链三阶段的寄存器
    reg [1:0] forward_a,forward_b;
      // number of instruction memory
    parameter MEM_NUM = 0;
    // number of datamem
    parameter MEM_DATA_NUM = 0;
    // fileName of instructions restore 
    parameter IM_DATA_FILENAME = "";
    
    assign pc=period1_npc;
    assign op=period2_opcode;

    always @(negedge reset) begin
        hold <= 1'b0;
        flush <= 1'b0;
        period1_pcway <= 2'b01;
        forward_a <= 1'b0;
        forward_b <= 1'b0;
    end
    // 第一阶段
    //例化pc
    PC PC1(
        .clk(clk),.reset(reset),
        .period1_pcway(period1_pcway),.period1_baddr(period1_baddr),.period1_jaddr(period1_jaddr),
        .period1_pc(period1_npc),.period1_npc(period1_npc)
    );
    // 例化指令读取
    IM #(.MEM_NUM(MEM_NUM),.IM_DATA_FILENAME(IM_DATA_FILENAME)) IM1(
        .clk(clk),.period1_npc(period1_npc),.period1_command(period1_command)
    );
    // 把第一阶段的指令转到第二阶段 （有条件转移）
    Register #(.N(32*2)) reg_latches_1_1(
        .clk(clk),.clear(flush),.hold(hold),
        .in({period1_npc,period1_command}),.out({period2_npc,period2_command})
    );

    // 第二阶段
    // 例化指令译码
    Decode Decode1(
        .period2_npc(period2_npc),.period2_command(period2_command),
        .period2_opcode(period2_opcode),.period2_rs(period2_rs),.period2_rt(period2_rt),.period2_rd(period2_rd),
        .period2_imm(period2_imm),.period2_jaddr(period2_jaddr)
    );
    // 例化控制指令
    Control Control1(
        .period2_opcode(period2_opcode),.period2_imm(period2_imm),.period2_rs(period2_rs),.period2_rt(period2_rt),.period2_rd(period2_rd),
        .period2_if_imm(period2_if_imm),.period2_if_branch(period2_if_branch),.period2_if_jump(period2_if_jump),
        .period2_memr(period2_memr),.period2_memw(period2_memw),.period2_wb(period2_wb),
        .period2_rs_fact(period2_rs_fact),.period2_rt_fact(period2_rt_fact)
    );
    // 例化寄存器堆
    Regfile Regfile1(
       .clk(clk),.reset(reset),.period5_wb(period5_wb),
       .period2_rs(period2_rs_fact),.period2_rt(period2_rt_fact),.period5_rd(period5_rd),.wbdata(period5_wbdata),
       .period2_rsdata(period2_rsdata),.period2_rtdata(period2_rtdata)
    );
    // 转移数据
   // 控制信号一定会传下去 或者停一次(lw sw连续时)
   Register #(.N(6+6)) Register_2_1(
        .clk(clk),.clear(hold | flush),.hold(1'b0),
        .in({period2_opcode,period2_if_imm,period2_if_branch,period2_if_jump,period2_memr,period2_memw,period2_wb}),
        .out({period3_opcode,period3_if_imm,period3_if_branch,period3_if_jump,period3_memr,period3_memw,period3_wb})
    );
   // 数据不变 或者清除
   Register #(.N(5*3+16+32*2+32*2)) Register_2_2(
        .clk(clk),.clear(flush),.hold(hold),
        .in({period2_rs_fact,period2_rt_fact,period2_rd,period2_imm,period2_jaddr,period2_baddr,period2_rsdata,period2_rtdata}),
        .out({period3_rs_fact,period3_rt_fact,period3_rd,period3_imm,period3_jaddr,period3_baddr,period3_rsdata,period3_rtdata})
    );
    
    // 第三阶段
    // 获得alu两边的操作数
    always @(*) begin
        // 只会存在由于写回问题而短链，访问mem直接停一次
        case(forward_a)
            2'd1: period3_exe_data1 = period4_exe_result;
            2'd2: period3_exe_data1 = period5_wbdata;
            default: period3_exe_data1 = period3_rsdata;
        endcase
        if(period3_if_imm) begin
            // 这里解决弄得一个addiu 早知道不弄这个指令了
            if(period3_opcode==6'd3) period3_exe_data2 = { {16{1'b0}},period3_imm};
            else period3_exe_data2 = { {16{period3_imm[15]}},period3_imm};
        end else begin 
            case(forward_b)
                2'd1: period3_exe_data2 = period4_exe_result;
                2'd2: period3_exe_data2 = period5_wbdata;
                default: period3_exe_data2 = period3_rtdata;
            endcase
        end
    end
    // 例化alu
    EXE EXE1(
        .period3_exe_op(period3_opcode),.period3_exe_data1(period3_exe_data1),.period3_exe_data2(period3_exe_data2),
        .period3_exe_result(period3_exe_result)
    );
    // 单独计算一下访问内存时的访问多少位
    always @(*) begin
        if(period3_memr|period3_memw==1'b1) begin
            case(period3_opcode)
                // 8位 lb sb
                6'd24,6'd27: period3_rw_bits <= 2'd1;
                // 16位 lh sh
                6'd25,6'd28: period3_rw_bits <= 2'd2;
                // 32位
                default:period3_rw_bits <= 2'd0;
            endcase
        end
    end
    // 传递
    Register #(.N(5+32*2+6 + 5 + 32+2+32)) Register_3_1(
        .clk(clk),.clear(flush),.hold(1'b0),
        .in({   period3_rd,period3_jaddr,period3_baddr,period3_opcode,
                period3_if_branch,period3_if_jump,period3_memr,period3_memw,period3_wb,
                period3_exe_result,period3_rw_bits,period3_exe_data1
         }),
        .out({  period4_rd,period4_jaddr,period4_baddr,period4_opcode,
                period4_if_branch,period4_if_jump,period4_memr,period4_memw,period4_wb,
                period4_exe_result,period4_rw_bits,period4_wdata
         })
    );
    
    // 第四阶段 mem
    // 例化datamem 访存
    Memory #(.MEM_NUM(MEM_DATA_NUM)) Memory1(
        .clk(clk),.period4_exe_result(period4_exe_result),.period4_memr(period4_memr),.period4_memw(period4_memw),
        .period4_wdata(period4_wdata),.period4_rw_bits(period4_rw_bits),
        .period4_rdata(period4_rdata)
    );
    // jump branch处理
    always @(*) begin
        // default
        period1_pcway <= 2'b01;
        flush <= 1'b0;
        period1_baddr <= period4_baddr;
        period1_jaddr <= period4_jaddr;
		case (1'b1)
			period4_if_branch: begin
			     if(period4_exe_result==32'b1)begin
			          period1_pcway <= 2'b10;
			          flush <= 1'b1;
			      end
			end
			period4_if_jump: begin
			     case(period4_opcode)
			         6'd23: period1_jaddr <= period4_exe_result;
			     endcase
			     period1_pcway <= 2'b11;
			     flush <= 1'b1;
			end
		endcase
	end
	//传递
	Register #(.N(5+2+32*2)) Register_4_1(
        .clk(clk),.clear(1'b0),.hold(1'b0),
        .in({   period4_rd,period4_wb,period4_exe_result,period4_memr,period4_rdata }),
        .out({  period5_rd,period5_wb,alu_out_s5,period5_memr,mem_read_data_s5 })
    );
    
	// 第五阶段
    // 计算回写数据
    assign period5_wbdata = period5_memr ? mem_read_data_s5:alu_out_s5;
    
    // 解决冲突
    // 提前 短接入上一指令
    always @(*) begin
		if ((period4_wb == 1'b1) && (period4_rd == period3_rs_fact)) begin
			forward_a <= 2'd1;
		end else if ((period5_wb == 1'b1) && (period5_rd == period3_rs_fact)) begin
			forward_a <= 2'd2;
		end else
			forward_a <= 2'd0;
		if ((period4_wb == 1'b1) & (period4_rd == period3_rt_fact)) begin
			forward_b <= 2'd1;
		end else if ((period5_wb == 1'b1) && (period5_rd == period3_rt_fact)) begin
			forward_b <= 2'd2;
		end else
			forward_b <= 2'd0;
	end
    // 如果要读内存
    always @(*) begin
		if (period3_memr == 1'b1 && ((period2_rs_fact == period3_rd) || (period2_rt_fact == period3_rd)) ) begin
			hold <= 1'b1;
		end else
			hold <= 1'b0;
	   if(hold) period1_pcway <= 2'b00;
	end
endmodule

//`endif
