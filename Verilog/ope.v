// 8bit比較器 a > b -> g:1 e:0, a == b -> 01, a < b -> 00
module comp_8(
    input wire [8-1:0] ina, inb,
    output wire g, 
    output wire e);
    
    assign g = (ina > inb);
    assign e = (ina == inb);
endmodule 

// 32bit比較器
// a > b -> 10, a < b -> 00, a == b -> 01を返す
module comp_32(
    input  wire [32-1:0] ina, inb,
    input  wire clk,
    input  wire rst_n, 
    output reg  g, // a > b
    output reg  e, // a = b
    output reg  ready_n); // 終了信号(1だと動作中)

    reg [2-1:0] count;
    reg [32-1:0] rega, regb;
    reg [8-1:0] a,b;
    wire g8, e8;

    comp_8 comp_8(a, b, g8, e8); 

    always @(posedge clk) begin
        if (!rst_n) begin
            count <= 0;
            g <= 0;
            e <= 0;
            rega <= ina;
            regb <= inb;
            a <= ina[32-1:24];
            b <= inb[32-1:24];
            ready_n <= 1;
        end else begin
            if (g8 == 1) begin // 大きかったらそこで止める
                g <= 1;
                e <= 0;
                ready_n <= 0;
            end else if (!e8) begin // 等しくなかったらそこでやめる
                g <= 0;
                e <= 0;
                ready_n <= 0;
            end else begin 
                if (count == 2'b11) begin
                    g <= 0;
                    e <= 1;
                    ready_n <= 0;
                end else begin
                    a <= (rega >> 8*(2-count));
                    b <= (regb >> 8*(2-count));
                    count <= count + 1;
                end
            end
        end
    end
endmodule

// 32bitと32bitの加算器
module add_32(
    input  wire [32-1:0] ina, inb,
    input  wire clk,
    input  wire rst_n,
    output reg [64-1:0] result);
    
    reg  [3-1:0] count;
    reg [32-1:0] rega, regb;
    wire [9-1:0] res;
    reg  [8-1:0] a,b;
    reg carry;

    assign res = a + b + carry;

    always @(posedge clk) begin
        //reset operations
        if (!rst_n) begin
            count <= 0;
            result [64-1:0] <= 0;
            carry <= 0;
	    rega <= ina;
	    regb <= inb;
            a <= ina[8-1:0];
            b <= inb[8-1:0];
        end else begin
            // RT operations
            case (count)
                3'b000 : begin
                    a <= rega[16-1:8];
                    b <= regb[16-1:8];
		    carry <= res[9-1];
		    result[8-1:0] <= res[8-1:0];
		    count <= count + 1;
                end
                3'b001 : begin
                    a <= rega[24-1:16];
                    b <= regb[24-1:16];
		    result[16-1:8] <= res[8-1:0];
		    carry <= res[9-1];
		    count <= count + 1;
                end
                3'b010 : begin
                    a <= rega[32-1:24];
                    b <= regb[32-1:24];
		    result[24-1:16] <= res[8-1:0];
		    carry <= res[9-1];
		    count <= count + 1;
                end
		3'b011 : begin
		    result[32-1:24] <= res[8-1:0];
		    count <= count + 1;
		    carry <= res[9-1];
		end
		default : begin
		end
	    endcase
        end
    end
endmodule 

// 32bit減算器
module sub_32(
    input  wire [32-1:0] ina, inb,
    input  wire clk,
    input  wire rst_n,
    output reg [64-1:0] result);
    
    reg  [3-1:0] count;
    reg [32-1:0] rega, regb;
    wire [9-1:0] res;
    reg  [8-1:0] a,b;
    reg carry;

    assign res = a + b + carry;

    always @(posedge clk) begin
        //reset operations
        if (!rst_n) begin
            count <= 0;
            result [64-1:0] <= 0;
            carry <= 0;
	        rega <= ina;
	        regb <= inb;
            a <= ina[8-1:0];
            b <= inb[8-1:0];
        end else begin
            // RT operations
            case (count)
                3'b000 : begin
                    a <= rega[16-1:8];
                    b <= regb[16-1:8];
		            carry <= res[9-1];
		            result[8-1:0] <= res[8-1:0];
		            count <= count + 1;
                end
                3'b001 : begin
                    a <= rega[24-1:16];
                    b <= regb[24-1:16];
		            result[16-1:8] <= res[8-1:0];
		            carry <= res[9-1];
		            count <= count + 1;
                end
                3'b010 : begin
                    a <= rega[32-1:24];
                    b <= regb[32-1:24];
		            result[24-1:16] <= res[8-1:0];
		            carry <= res[9-1];
		            count <= count + 1;
                end
		        3'b011 : begin
		            result[32-1:24] <= res[8-1:0];
		            count <= count + 1;
		            carry <= res[9-1];
		        end
		        default : begin
		        end
	        endcase
        end
    end
endmodule

module mul_328(
    input wire [32-1:0] ina,
    input wire [8-1:0]  inb,
    input wire clk,
    input wire rst_n,
    output reg [40-1:0] result,
    output reg ready_n);

    reg [32-1:0] rega;
    reg [8-1:0]  regb;
    reg [4-1:0]  count;
    reg [8-1:0]  calca;
    
    always @(posedge clk) begin
        if (!rst_n) begin
            // reset operations
            result <= 0;
            count <= 0;
            rega <= ina;
            regb <= inb;
            ready_n <= 1;
            calca <= ina;
        end else begin
            // RT operations
            if (count >= 4'd5) begin
                ready_n <= 0;
            end else begin
                calca <= (ina >> 8*(count+1));
                result <= result + ((calca*regb) << 8*count);
                count  <= count + 1;
            end
        end
    end
endmodule
// 32bit * 32bitで64bitを作り出す
module mul_3232(
    input wire [32-1:0] ina, inb,
    input wire clk,
    input wire rst_n,
    output reg [64-1:0] result,
    output reg ready_n);
    
    reg [32-1:0] rega, regb;
    reg [8-1:0]  calcb;
    reg [4-1:0]  count;
    wire ready_n_328; 
    reg  finish_328; // mul_328が終わったかどうか
    reg rst_n_328;
    wire [40-1:0] res_328;

    mul_328 mul_328(rega, calcb, clk, rst_n_328, res_328, ready_n_328);
    always @(posedge clk) begin
        if (!rst_n) begin
            result <= 0;
            rega <= ina;
            regb <= inb;
            calcb <= inb;
            ready_n <= 1;
            rst_n_328 <= 0;
            count <= 0;
            finish_328 <= 0;
        end else begin
            if (count >= 4'd4) begin
                ready_n <= 0;
            end else begin
                if (finish_328) begin // mul_328の計算が終わったなら
                    result <= result + (res_328 << 8*(count));
                    count <= count + 1;
                    calcb <= (regb >> 8*(count+1));
                    rst_n_328 <= 0;
                    finish_328 <= 0;
                end else begin // mul_328の計算がおわってないなら
                    rst_n_328 <= 1;
                    if (!ready_n_328 & rst_n_328) begin
                        finish_328 <= 1;
                    end
                end
            end
        end
    end 
endmodule
