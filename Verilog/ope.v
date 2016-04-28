`define ON 1
`define OFF 0
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
    output reg ready_n);

    reg [64-1:0] rega;
    reg rst_n_add;
    wire ready_n_add;
    reg [2-1:0] status;

    add_64 add_64(~rega, 64'd1, clk, rst_n_add, result, ready_n_add);
    always @(posedge clk) begin
        if (!rst_n) begin
            rega <= ina;
            rst_n_add <= 0;
            ready_n <= 1;
            status <= 0;
        end else begin
            if (status == 0) begin
                if (!rst_n_add) begin
                    rst_n_add <= 1;
                    status <= 1;
                end
            end else if (status == 1) begin
                if (!ready_n_add) begin
                    status <= 2;
                end
            end else begin
                ready_n <= 0;
            end
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
    output reg ready_n);
    
    reg  [2-1:0] status;
    reg [64-1:0] rega, regb;
    wire [64-1:0] compb;
    reg rst_n_comp, rst_n_add;
    wire ready_n_comp, ready_n_add;

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
            ready_n <= 1;
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
		        default : begin
                    ready_n <= 0;
                end
	        endcase
        end
    end
endmodule

module mul_648(
    input wire [64-1:0] ina,
    input wire [8-1:0]  inb,
    input wire clk,
    input wire rst_n,
    output reg [72-1:0] result,
    output reg ready_n);

    reg [64-1:0] rega;
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
            if (count >= 4'd9) begin
                ready_n <= 0;
            end else begin
                calca <= (ina >> 8*(count+1));
                result <= result + ((calca*regb) << 8*count);
                count  <= count + 1;
            end
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
// 64bit * 64bitで128bitを作り出す
//module mul_6464(
//    input wire [64-1:0] ina, inb,
//    input wire clk,
//    input wire rst_n,
//    output reg [128-1:0] result,
//    output reg ready_n);
//    
//    reg [64-1:0] rega, regb, comp_in;
//    reg [8-1:0]  calcb;
//    reg [4-1:0]  count;
//    wire ready_n_648, ready_n_comp; 
//    reg rst_n_648, rst_n_comp;
//    reg sign; // 0なら答えが正、１なら負
//    reg waiting_n;
//    reg Istate, S1state, S2state, Mstate, Fstate; // Initial, Signed1, Signed2, Multiple, Final
//    wire [72-1:0] res_648;
//    wire [64-1:0] comp_out;
//
//    comp_64 comp_64(comp_in, clk, rst_n_comp, comp_out, ready_n_comp);
//    mul_648 mul_648(rega, calcb, clk, rst_n_648, res_648, ready_n_648);
//
//    always @(posedge clk) begin
//        if (!rst_n) begin
//            result <= 0;
//            rega <= ina;
//            regb <= inb;
//            calcb <= inb;
//            ready_n <= 1;
//            comp_in <= 0;
//            rst_n_648 <= 0;
//            rst_n_comp <= 0;
//            count <= 0;
//            waiting_n <= 1;
//            sign <= 0;
//            Istate <= `ON;
//            S1state <= `OFF;
//            S2state <= `OFF;
//            Mstate <= `OFF;
//            Fstate <= `OFF;
//        end else if (Istate) begin
//            Istate <= `OFF;
//            if (rega[63] == 1) begin // かけられる数がマイナスだったら
//                S1state <= `ON;
//                sign <= ~sign;
//                comp_in <= rega;
//            end else if (regb[63] == 1) begin // かける数がマイナスだったら
//                S2state <= `ON;
//                comp_in <= regb;
//                rst_n_comp <= 1;
//                waiting_n <= 0;
//                sign <= ~sign;
//            end else begin
//                Mstate <= `ON;
//                waiting_n <= 0;
//            end
//        end else if (S1state) begin
//            if (waiting_n) begin
//            //    comp_in <= rega;
//                waiting_n <= 0;
//                rst_n_comp <= 1;
//            end else begin
//                if (!ready_n_comp) begin
//                    rst_n_comp <= 0;
//                    S1state <= `OFF;
//                    rega <= comp_out;
//                    waiting_n <= 1;
//                    if (regb[63] == 1) begin
//                        S2state <= `ON;
//                        rst_n_comp <= 0;
//                        sign <= ~sign;
//                        comp_in <= regb;
//                    end else begin
//                        Mstate <= `ON;
//                    end
//                end
//            end
//        end else if (S2state) begin
//            if (waiting_n) begin
//            //    comp_in <= rega;
//                waiting_n <= 0;
//                rst_n_comp <= 1;
//            end else begin
//                if (!ready_n_comp) begin
//                    rst_n_comp <= 0;
//                    S2state <= `OFF;
//                    regb <= comp_out;
//                    waiting_n <= 1;
//                    Mstate <= `ON;
//                end
//            end
////             if (!ready_n_comp) begin
////                 rst_n_comp <= 0;
////                 S2state <= `OFF;
////                 regb <= comp_out;
////                 Mstate <= `ON;
////             end
////             if (!rst_n_comp) begin
////                 rst_n_comp <= 1;
////             end
//        end else if (Mstate) begin
//           if (count > 4'd8) begin
//               kkkkkkkkkkk
//        end else if (Fstate) begin
//            ready_n <= 0;
//        end else begin
//            Istate <= `OFF;
//            S1state <= `OFF;
//            S2state <= `OFF;
//            Mstate <= `OFF;
//            Fstate <= `OFF;
//        end
//    end
//endmodule
//
//
////         end else begin
////             if (count >= 4'd8) begin
////                 ready_n <= 0;
////             end else begin
////                 if (finish_648) begin // mul_648の計算が終わったなら
////                     result <= result + (res_648 << 8*(count));
////                     count <= count + 1;
////                     calcb <= (regb >> 8*(count+1));
////                     rst_n_648 <= 0;
////                     finish_648 <= 0;
////                 end else begin // mul_648の計算がおわってないなら
////                     rst_n_648 <= 1;
////                     if (!ready_n_648 & rst_n_648) begin
////                         finish_648 <= 1;
////                     end
////                 end
////             end
////         end

// 64bit * 64bitで128bitを作り出す
module mul_6464(
    input wire [64-1:0] ina, inb,
    input wire clk,
    input wire rst_n,
    output reg [128-1:0] result,
    output reg ready_n);
    
    reg [64-1:0] rega, regb;
    reg [8-1:0]  calcb;
    reg [4-1:0]  count;
    wire ready_n_648; 
    reg  finish_648; // mul_648が終わったかどうか
    reg rst_n_648;
    wire [72-1:0] res_648;

    mul_648 mul_648(rega, calcb, clk, rst_n_648, res_648, ready_n_648);
    always @(posedge clk) begin
        if (!rst_n) begin
            result <= 0;
            rega <= ina;
            regb <= inb;
            calcb <= inb;
            ready_n <= 1;
            rst_n_648 <= 0;
            count <= 0;
            finish_648 <= 0;
        end else begin
            if (count >= 4'd8) begin
                ready_n <= 0;
            end else begin
                if (finish_648) begin // mul_648の計算が終わったなら
                    result <= result + (res_648 << 8*(count));
                    count <= count + 1;
                    calcb <= (regb >> 8*(count+1));
                    rst_n_648 <= 0;
                    finish_648 <= 0;
                end else begin // mul_648の計算がおわってないなら
                    rst_n_648 <= 1;
                    if (!ready_n_648 & rst_n_648) begin
                        finish_648 <= 1;
                    end
                end
            end
        end
    end 
endmodule

module div_binary(
    input wire [64-1:0] a,b,
    input wire clk,
    input wire rst_n,
    output reg [64-1:0] q, r,
    output reg ready_n);

    reg [64-1:0] rega, regb;
    wire [8-1:0] sizea, sizeb;
    reg [2-1:0] status;
    reg rst_n_sizea, rst_n_sizeb, rst_n_sub;
    reg run_module;
    reg [8-1:0] i;
    wire [64-1:0] res_sub;
    wire ready_n_sizea, ready_n_sizeb, ready_n_sub;
    wire [64-1:0] regbshift;

    assign regbshift = regb << (i-sizeb);

    size_64 sizea_64(rega, clk, rst_n_sizea, sizea, ready_n_sizea);
    size_64 sizeb_64(regb, clk, rst_n_sizea, sizeb, ready_n_sizeb);
    sub_64  sub_64(rega, regbshift,clk, rst_n_sub, res_sub, ready_n_sub);

    always @(posedge clk) begin
        if (!rst_n) begin
            rega <= a;
            regb <= b;
            status <= 0;
            run_module <= 0;
            rst_n_sizea <= 0;
            rst_n_sizeb <= 0;
            rst_n_sub <= 0;
            ready_n <= 1;
            q <= 0;
            r <= 0;
            i <= 0;
        end else begin
            if (status == 0) begin
                if (run_module == 0) begin
                    rst_n_sizea <= 1;
                    rst_n_sizeb <= 1;
                    run_module <= 1;
                end else if (!ready_n_sizea & !ready_n_sizeb) begin
                    if (sizea >= sizeb) begin
                        status <= 1;
                        run_module <= 0;
                        i <= sizea;
                    end else begin
                        status <= 2;
                        q <= 0;
                        r <= rega;
                        run_module <= 0;
                    end
                end else begin end
            end else if (status == 1) begin
                if (run_module == 0) begin
                    rst_n_sub <= 1;
                    run_module <= 1;
                    q <= q << 1;
                end else if (!ready_n_sub) begin
                    run_module <= 0;
                    i <= i - 1;
                    if (i <= sizeb) begin
                        status <= 2;
                    end else begin 
                        status <= 1;
                        rst_n_sub <= 0;
                    end
                    if (res_sub[63] == 0) begin
                        rega <= res_sub;
                        q   <= q + 1;
                        r   <= res_sub;
                    end else begin end
                end else begin end
            end else begin
               ready_n <= 0;  
            end
        end
    end
endmodule
// 64bit / 64bitの除算機
// module div_6464(
//     input wire [64-1:0] a, b,
//     input wire clk,
//     input wire rst_n,
//     output reg [64-1:0] q, r,
//     output reg ready_n);
// 
//     reg [64-1:0] rega, regb;
// 
//     always @(posedge clk) begin
//         if (!rst_n) begin
//             rega <= a;
//             regb <= b;
//             q <= 0;
//             r <= 0;
//             ready_n <= 1;
//         end else begin
//             
//         end
//     end
// endmodule
// 
// // 64bit（n+1桁、16進数） / 64bitの除算機（n桁、16進数）
// module div_6464_n(
//     input wire [64-1:0] a, b,
//     input wire [8-1:0] n,
//     input wire clk,
//     input wire rst_n,
//     output reg [64-1:0] q, r,
//     output reg ready_n);
//     
//     reg [64-1:0] rega, regb;
//     reg [4-1:0] status;
//     reg [8-1:0] qq;
//     wire [8-1:0] shiftrega, shiftregb;
// //    wire [64-1:0] shiftregabuf, shiftregbbuf;
// 
//     assign shiftrega = (rega >> 4*n);
//     assign shiftregb = (regb >> 4*(n-1));
//     
//     mul
// 
// //    assign shiftrega = shiftregabuf[8-1:0];
// //    assign shiftregb = shiftregbbuf[8-1:0];
// 
//     always @(posedge clk) begin
//         if (!rst_n) begin
//             // reset operations
//             rega <= a;
//             regb <= b;
//             q <= 0;
//             qq <= 0;
//             r <= 0;
//             ready_n <= 1;
//             status <= 0;
//         end else begin
//             if (status == 0) begin
//                 if (rega == 0) begin
//                     status <= 4'd6;
//                     ready_n <= 0;
//                 end
//                 if ((regb >> (4*n-1)) == 0) begin
//                     rega <= rega << 1;
//                     regb <= regb << 1;
//                 end
//                 status <= 4'd1;
//             end else if (status == 1) begin
//                 if ((rega >> (4*n)) > (regb >> (4*(n-1)))) begin
//                     qq <= shiftrega / shiftregb;
//                 end
//                 status <= 2;
//             end else if (status == 2) begin
//                 if () begin
//                     qq <= qq - 1;
//                 end else begin
//                     status <= 3;
//                 end
//             end else if (status == 3) begin
//                 q <= qq;
//                 r <= 
//                 rega <= 
//             end
//         end
//     end 
// endmodule

module size_64(
    input wire [64-1:0] a,
    input wire clk,
    input wire rst_n,
    output reg [8-1:0] size, // 0-64を想定、w進数での桁数を示す
    output reg ready_n);

    reg [2-1:0] status;

    always @(posedge clk) begin
        if (!rst_n) begin
            // reset operation
            size <= 0;
            ready_n <= 1;
        end else begin
            // RT operation
            if ((a >> size) != 0) begin 
                size <= size + 1;
            end else begin
                ready_n <= 0;
            end
        end
    end
endmodule
