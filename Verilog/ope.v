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
    output reg  g,
    output reg  e);

    reg [3-1:0] count;
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
        end else begin
            if (g8 == 1) begin // 大きかったらそこで止める
                g <= 1;
                e <= 0;
            end else if (!e8) begin // 等しくなかったらそこでやめる
                g <= 0;
                e <= 0;
            end else begin 
                case (count)
                    3'b000 : begin
                        a <= rega[24-1:16];
                        b <= regb[24-1:16];
                        count <= count + 1;
                    end
                    3'b001 : begin
                        a <= rega[16-1:8];
                        b <= regb[16-1:8];
                        count <= count + 1;
                    end
                    3'b010 : begin
                        a <= rega[8-1:0];
                        b <= regb[8-1:0];
                        count <= count + 1;
                    end
                    default : begin
                        g <= 0;
                        e <= 1;
                    end
                endcase
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
