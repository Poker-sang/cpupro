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
   
    // ��һ�׶�
    // ���ڶ�pc��ѡ��
    reg [1:0] period1_pcway;
    // ��ת�ĵ�ַ pc��ַ
    reg [31:0] period1_baddr,period1_jaddr;
    reg hold,flush;
    wire [31:0] period1_npc;
    // ��һ�׶λ�ȡ����ָ��
    wire [31:0] period1_command;
    
    // �ڶ��׶�
    // ���ݵ��ڶ��׶ε�npc_s2�����ݵ��ڶ��׶ε�im_data_s2
    wire [31:0] period2_npc,period2_command;
    // �������
    wire [5:0] period2_opcode;
    wire [4:0] period2_rs,period2_rt,period2_rd;
    wire [15:0] period2_imm;
    wire [31:0] period2_jaddr;
    // b �ĵ�ַ
    wire [31:0] period2_baddr = period2_npc + { {14{period2_imm[15]}},period2_imm, 2'b0 };
    // ����������Ŀ����ź�
    wire period2_if_imm,period2_if_branch,period2_if_jump,period2_memr,period2_memw,period2_wb;
    wire [4:0] period2_rs_fact,period2_rt_fact;
    // �Ĵ�����õ�ֵ
    wire [31:0] period2_rsdata,period2_rtdata;
    
    // �����׶�
    // ����
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
    // ������һ�׶��õ�����
    
    // ���Ľ׶�
    // ����
    // д��Ŀ��
    wire [5:0] period4_opcode;
    wire [4:0] period4_rd;
    wire [31:0] period4_jaddr,period4_baddr;
    wire period4_if_branch,period4_if_jump,period4_memr,period4_memw,period4_wb;
    // ���Ҫ��/д�ڴ� ��ôдmem�ĵ�ַΪperiod_exe_result
    // ���Ҫ��д����ô��д����Ϊperiod_exe_result
    wire [31:0] period4_exe_result;
    // ��/д�ڴ�ʱ����д����λ Ĭ��Ϊ00 32λ    
    wire [1:0] period4_rw_bits;
    // ���ڴ�Ľ��    // д�ڴ������
    wire [31:0] period4_rdata,period4_wdata;
    // ��д����
    wire [31:0] period4_wbdata;
    
    // ����׶�
    // ����
    wire period5_wb,period5_memr;
    wire [4:0] period5_rd;
    wire [31:0] period5_wbdata,alu_out_s5,mem_read_data_s5;

    // ���� ����4��5�׶��޸�reg���� ֱ�Ӷ������׶εļĴ���
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
    // ��һ�׶�
    //����pc
    PC PC1(
        .clk(clk),.reset(reset),
        .period1_pcway(period1_pcway),.period1_baddr(period1_baddr),.period1_jaddr(period1_jaddr),
        .period1_pc(period1_npc),.period1_npc(period1_npc)
    );
    // ����ָ���ȡ
    IM #(.MEM_NUM(MEM_NUM),.IM_DATA_FILENAME(IM_DATA_FILENAME)) IM1(
        .clk(clk),.period1_npc(period1_npc),.period1_command(period1_command)
    );
    // �ѵ�һ�׶ε�ָ��ת���ڶ��׶� ��������ת�ƣ�
    Register #(.N(32*2)) reg_latches_1_1(
        .clk(clk),.clear(flush),.hold(hold),
        .in({period1_npc,period1_command}),.out({period2_npc,period2_command})
    );

    // �ڶ��׶�
    // ����ָ������
    Decode Decode1(
        .period2_npc(period2_npc),.period2_command(period2_command),
        .period2_opcode(period2_opcode),.period2_rs(period2_rs),.period2_rt(period2_rt),.period2_rd(period2_rd),
        .period2_imm(period2_imm),.period2_jaddr(period2_jaddr)
    );
    // ��������ָ��
    Control Control1(
        .period2_opcode(period2_opcode),.period2_imm(period2_imm),.period2_rs(period2_rs),.period2_rt(period2_rt),.period2_rd(period2_rd),
        .period2_if_imm(period2_if_imm),.period2_if_branch(period2_if_branch),.period2_if_jump(period2_if_jump),
        .period2_memr(period2_memr),.period2_memw(period2_memw),.period2_wb(period2_wb),
        .period2_rs_fact(period2_rs_fact),.period2_rt_fact(period2_rt_fact)
    );
    // �����Ĵ�����
    Regfile Regfile1(
       .clk(clk),.reset(reset),.period5_wb(period5_wb),
       .period2_rs(period2_rs_fact),.period2_rt(period2_rt_fact),.period5_rd(period5_rd),.wbdata(period5_wbdata),
       .period2_rsdata(period2_rsdata),.period2_rtdata(period2_rtdata)
    );
    // ת������
   // �����ź�һ���ᴫ��ȥ ����ͣһ��(lw sw����ʱ)
   Register #(.N(6+6)) Register_2_1(
        .clk(clk),.clear(hold | flush),.hold(1'b0),
        .in({period2_opcode,period2_if_imm,period2_if_branch,period2_if_jump,period2_memr,period2_memw,period2_wb}),
        .out({period3_opcode,period3_if_imm,period3_if_branch,period3_if_jump,period3_memr,period3_memw,period3_wb})
    );
   // ���ݲ��� �������
   Register #(.N(5*3+16+32*2+32*2)) Register_2_2(
        .clk(clk),.clear(flush),.hold(hold),
        .in({period2_rs_fact,period2_rt_fact,period2_rd,period2_imm,period2_jaddr,period2_baddr,period2_rsdata,period2_rtdata}),
        .out({period3_rs_fact,period3_rt_fact,period3_rd,period3_imm,period3_jaddr,period3_baddr,period3_rsdata,period3_rtdata})
    );
    
    // �����׶�
    // ���alu���ߵĲ�����
    always @(*) begin
        // ֻ���������д�����������������memֱ��ͣһ��
        case(forward_a)
            2'd1: period3_exe_data1 = period4_exe_result;
            2'd2: period3_exe_data1 = period5_wbdata;
            default: period3_exe_data1 = period3_rsdata;
        endcase
        if(period3_if_imm) begin
            // ������Ū��һ��addiu ��֪����Ū���ָ����
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
    // ����alu
    EXE EXE1(
        .period3_exe_op(period3_opcode),.period3_exe_data1(period3_exe_data1),.period3_exe_data2(period3_exe_data2),
        .period3_exe_result(period3_exe_result)
    );
    // ��������һ�·����ڴ�ʱ�ķ��ʶ���λ
    always @(*) begin
        if(period3_memr|period3_memw==1'b1) begin
            case(period3_opcode)
                // 8λ lb sb
                6'd24,6'd27: period3_rw_bits <= 2'd1;
                // 16λ lh sh
                6'd25,6'd28: period3_rw_bits <= 2'd2;
                // 32λ
                default:period3_rw_bits <= 2'd0;
            endcase
        end
    end
    // ����
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
    
    // ���Ľ׶� mem
    // ����datamem �ô�
    Memory #(.MEM_NUM(MEM_DATA_NUM)) Memory1(
        .clk(clk),.period4_exe_result(period4_exe_result),.period4_memr(period4_memr),.period4_memw(period4_memw),
        .period4_wdata(period4_wdata),.period4_rw_bits(period4_rw_bits),
        .period4_rdata(period4_rdata)
    );
    // jump branch����
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
	//����
	Register #(.N(5+2+32*2)) Register_4_1(
        .clk(clk),.clear(1'b0),.hold(1'b0),
        .in({   period4_rd,period4_wb,period4_exe_result,period4_memr,period4_rdata }),
        .out({  period5_rd,period5_wb,alu_out_s5,period5_memr,mem_read_data_s5 })
    );
    
	// ����׶�
    // �����д����
    assign period5_wbdata = period5_memr ? mem_read_data_s5:alu_out_s5;
    
    // �����ͻ
    // ��ǰ �̽�����һָ��
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
    // ���Ҫ���ڴ�
    always @(*) begin
		if (period3_memr == 1'b1 && ((period2_rs_fact == period3_rd) || (period2_rt_fact == period3_rd)) ) begin
			hold <= 1'b1;
		end else
			hold <= 1'b0;
	   if(hold) period1_pcway <= 2'b00;
	end
endmodule

//`endif
