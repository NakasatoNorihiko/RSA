// // 8bit比較器 a > b -> g:1 e:0, a == b -> 01, a < b -> 00
// module comp_8(
//     input wire [8-1:0] ina, inb,
//     output wire g, 
//     output wire e);
//     
//     assign g = (ina > inb);
//     assign e = (ina == inb);
// endmodule 
// 
// // 32bit比較器
// // a > b -> 10, a < b -> 00, a == b -> 01を返す
// module comp_32(
//     input  wire [32-1:0] ina, inb,
//     input  wire clk,
//     input  wire rst_n, 
//     output reg  g, // a > b
//     output reg  e, // a = b
//     output reg  ready_n); // 終了信号(1だと動作中)
// 
//     reg [2-1:0] count;
//     reg [32-1:0] rega, regb;
//     reg [8-1:0] a,b;
//     wire g8, e8;
// 
//     comp_8 comp_8(a, b, g8, e8); 
// 
//     always @(posedge clk) begin
//         if (!rst_n) begin
//             count <= 0;
//             g <= 0;
//             e <= 0;
//             rega <= ina;
//             regb <= inb;
//             a <= ina[32-1:24];
//             b <= inb[32-1:24];
//             ready_n <= 1;
//         end else begin
//             if (g8 == 1) begin // 大きかったらそこで止める
//                 g <= 1;
//                 e <= 0;
//                 ready_n <= 0;
//             end else if (!e8) begin // 等しくなかったらそこでやめる
//                 g <= 0;
//                 e <= 0;
//                 ready_n <= 0;
//             end else begin 
//                 if (count == 2'b11) begin
//                     g <= 0;
//                     e <= 1;
//                     ready_n <= 0;
//                 end else begin
//                     a <= (rega >> 8*(2-count));
//                     b <= (regb >> 8*(2-count));
//                     count <= count + 1;
//                 end
//             end
//         end
//     end
// endmodule

// 2の補数を計算する
module comp_64(
    input wire [64-1:0] ina,
    input wire clk,
    input wire rst_n,
    output wire [64-1:0] result,
    output wire ready_n);

    reg [64-1:0] rega;

    add_64 add_64(~rega, 64'd1, clk, rst_n, result, ready_n);
    always @(posedge clk) begin
        if (!rst_n) begin
            rega <= ina;
        end
    end
endmodule

// 符号つき64bitと64bitの加算器
module add_64(
    input  wire [64-1:0] ina, inb,
    input  wire clk,
    input  wire rst_n,
    output reg [64-1:0] result,
    output reg ready_n);
    
    reg  [4-1:0] count;
    reg  status;
    reg [64-1:0] rega, regb;
    wire [9-1:0] res;
    reg  [8-1:0] a,b;
    reg carry;

    assign res = a + b + carry;

    always @(posedge clk) begin
        //reset operations
        if (!rst_n) begin
            count  <= 0;
            status <= 0;
            result <= 0;
            carry  <= 0;
	        rega   <= ina;
	        regb   <= inb;
            a      <= ina[8-1:0];
            b      <= inb[8-1:0];
            ready_n <= 1;
        end else begin
            if (status >= 1'd1) begin
                ready_n <= 0;
            end else if (status >= 1'd0) begin
                if (count <= 4'd7) begin
                    a <= (rega >> (8*(count+1)));
                    b <= (regb >> (8*(count+1)));
                    carry <= res[9-1];
                    count <= count + 1;
                    case (count)
                        4'd0 : result[8-1:0]   <= res[8-1:0];
                        4'd1 : result[16-1:8]  <= res[8-1:0];
                        4'd2 : result[24-1:16] <= res[8-1:0];
                        4'd3 : result[32-1:24] <= res[8-1:0];
                        4'd4 : result[40-1:32] <= res[8-1:0];
                        4'd5 : result[48-1:40] <= res[8-1:0];
                        4'd6 : result[56-1:48] <= res[8-1:0];
                        4'd7 : begin 
                            result[64-1:56] <= res[8-1:0];
                            status <= status + 1;
                        end
                        default : begin end
                    endcase
                end else begin
                end
            end
        end
    end
endmodule

// 64bit減算器
module sub_64(
    input  wire [64-1:0] ina, inb,
    input  wire clk,
    input  wire rst_n,
    output wire [64-1:0] result,
    output wire ready_n);
    
    reg  [2-1:0] status;
    reg [64-1:0] rega, regb;
    wire [64-1:0] compb;
    reg rst_n_comp, rst_n_add;
    wire ready_n_comp, ready_n_add;

    assign ready_n = ready_n_add;

    comp_64 comp_64(regb, clk, rst_n_comp, compb, ready_n_comp);
    add_64  add_64(rega, compb, clk, rst_n_add, result, ready_n_add);
    always @(posedge clk) begin
        //reset operations
        if (!rst_n) begin
            rst_n_comp <= 0;
            rst_n_add <= 0;
            status <= 0;
	        rega <= ina;
	        regb <= inb;
        end else begin
            // RT operations
            case (status)
                2'd0 : begin
                    if (!rst_n_comp) begin
                        rst_n_comp <= 1;
                        status <= status + 1;
                    end
                end
                2'd1 : begin
                    if (!ready_n_comp) begin
                        rst_n_add <= 1;
                        status <= status + 1;
                    end 
                end
                2'd2 : begin
                    if (!ready_n_add) begin
                        status <= status + 1;
                    end
                end
		        default : begin end
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

// 
