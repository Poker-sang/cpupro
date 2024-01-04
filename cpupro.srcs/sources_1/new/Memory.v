`ifndef _Memory
`define _Memory

module Memory(
    input clk,
    input [31:0] period4_exe_result, //执行阶段传来的结果
    input period4_memr, //是否进行读
    input period4_memw, //是否进行写
    input [31:0] period4_wdata,  //写要的数据
    input [1:0] period4_rw_bits,//读写方式确定
    output reg [31:0] period4_rdata //读出的数据
);
    parameter MEM_NUM = 127;
    // 32-bit memory with MEM_NUM entries
    // 实际的地址不能超过MEM_NUM * 4
    reg [31:0] mem [0:MEM_NUM];
    integer i = 0;
    initial begin
    	for (i = 0; i < MEM_NUM; i = i + 1) begin
			mem[i] <= 32'b0;
		end
    end

    always @(posedge clk) begin
        if (period4_memw) begin
            case(period4_rw_bits)
                // 8bits
                2'd1: begin
                    case(period4_exe_result[1:0])
                        2'b00:mem[period4_exe_result[31:2]][7:0] <= period4_wdata[7:0];
                        2'b01:mem[period4_exe_result[31:2]][15:8] <= period4_wdata[7:0];
                        2'b10:mem[period4_exe_result[31:2]][23:16] <= period4_wdata[7:0];
                        2'b11:mem[period4_exe_result[31:2]][31:24] <= period4_wdata[7:0];
                    endcase
                end
                // 16bits
                2'd2:begin
                    case(period4_exe_result[1])
                        1'b0:mem[period4_exe_result[31:2]][15:0] <= period4_wdata[15:0];
                        1'b1:mem[period4_exe_result[31:2]][31:16] <= period4_wdata[15:0];
                    endcase
                end
                // 32bits
                default:mem[period4_exe_result[31:2]] <= period4_wdata;
            endcase
        end
    end
    
    // read
    always @(*) begin
        if (period4_memr) begin
            if(period4_memw)begin
                period4_rdata <= period4_wdata;
            end else begin
                 case(period4_rw_bits)
                    // 8bits
                    2'd1:begin
                        case(period4_exe_result[1:0])
                            2'b00:period4_rdata<={24'b0,mem[period4_exe_result[31:2]][7:0]};
                            2'b01:period4_rdata<={24'b0,mem[period4_exe_result[31:2]][15:8]};
                            2'b10:period4_rdata<={24'b0,mem[period4_exe_result[31:2]][23:16]};
                            2'b11:period4_rdata<={24'b0,mem[period4_exe_result[31:2]][31:24]};
                        endcase
                    end
                    // 16bits
                    2'd2:begin
                        case(period4_exe_result[1])
                            1'b0:period4_rdata<={16'b0,mem[period4_exe_result[31:2]][15:0]};
                            1'b1:period4_rdata<={16'b0,mem[period4_exe_result[31:2]][31:16]};
                        endcase
                    end
                    default:period4_rdata <= mem[period4_exe_result[31:2]];
                endcase
            end
        end
    end

endmodule

`endif