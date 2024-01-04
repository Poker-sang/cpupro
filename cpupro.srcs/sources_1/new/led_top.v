module led_top(
    output  reg    [7:0]    seg,	// 数码管的公共段选信号
    output  reg    [3:0]    an,		// 作为4个数码管的位选信号
    
    input   wire            clk,
    input   wire            rst,
    input   wire    [3:0]   in3, in2, in1, in0
    );
    	// EGo1数码管是共阴极的，需要连接高电平，对应位置被点亮
	   parameter   _0 = ~8'hc0;
	   parameter   _1 = ~8'hf9;
	   parameter   _2 = ~8'ha4;
	   parameter   _3 = ~8'hb0;
	   parameter   _4 = ~8'h99;
	   parameter   _5 = ~8'h92;
	   parameter   _6 = ~8'h82;
	   parameter   _7 = ~8'hf8;
	   parameter   _8 = ~8'h80;
	   parameter   _9 = ~8'h90;
	   parameter   _a = ~8'h88;
	   parameter   _b = ~8'h83;
	   parameter   _c = ~8'hc6;
	   parameter   _d = ~8'ha1;
	   parameter   _e = ~8'h86;
	   parameter   _f = ~8'h8e;
	   parameter   _err = ~8'hcf;
	   
	   parameter   N = 18;
    
       
    reg     [N-1 : 0]  regN; 
    reg     [3:0]       hex_in;
    
    always @ (posedge clk or posedge rst)   begin
        if (rst == 1'b0)    begin
            regN    <=  0;
        end else    begin
            regN    <=  regN + 1;
        end
    end
    // regN实现对100MHz的系统时钟的2^16分频
    always @ (*)    begin
        case (regN[N-1: N-2])
            2'b00:  begin
                an  <=  4'b0001;
                hex_in  <=  in0;
            end
            2'b01:  begin
                an  <=  4'b0010;
                hex_in  <=  in1;
            end
            2'b10:  begin
                an  <=  4'b0100;
                hex_in  <=  in2;
            end
            2'b11:  begin
                an  <=  4'b1000;
                hex_in  <=  in3;
            end
            default:    begin
                an  <=  4'b1111;
                hex_in  <=  in3;
            end
        endcase
    end
    
    always @ (*)    begin
        case (hex_in)
            4'h0:   seg <=  _0;
            4'h1:   seg <=  _1;
            4'h2:   seg <=  _2;
            4'h3:   seg <=  _3;
            4'h4:   seg <=  _4;
            4'h5:   seg <=  _5;
            4'h6:   seg <=  _6;
            4'h7:   seg <=  _7;
            4'h8:   seg <=  _8;
            4'h9:   seg <=  _9;
            4'ha:   seg <=  _a;
            4'hb:   seg <=  _b;
            4'hc:   seg <=  _c;
            4'hd:   seg <=  _d;
            4'he:   seg <=  _e;
            4'hf:   seg <=  _f;
            default:seg <=  _err;
        endcase
    end
            
endmodule
