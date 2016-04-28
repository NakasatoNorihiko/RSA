`define ON 1
`define OFF 0

module create_e(
    input wire [64-1:0] L,
    input wire clk,
    input wire rst_n,
    input wire start_n,
    output reg [64-1:0] E,
    output reg ready_n);

    reg Istate, Rstate, Dstate, Gstate; // Idle, Random, delete, gcd
    reg waiting_n;
    reg [2-1:0] RstateCount;
    reg seedInitial_n;
    reg rst_n_xs, rst_n_g;
    reg start_n_xs;
    wire ready_n_xs, ready_n_g;
    wire [32-1:0] random_xs;
    reg [32-1:0] random1, random2;
    wire [64-1:0] random, gcd;
    assign random = {random1, random2};
    reg already_calc;

    xorshift_32 xorshift_32(clk, rst_n_xs, start_n_xs, random_xs, ready_n_xs);
    gcd_64 gcd_64(random, L, clk, rst_n_g, gcd, ready_n_g);

    always @(posedge clk) begin
        if (!rst_n | !start_n) begin
            Istate <= `ON;
            Rstate <= `OFF;
            Dstate <= `OFF;
            Gstate <= `OFF;
            RstateCount <= 0;
            start_n_xs <= 1;
            waiting_n <= 1;
            rst_n_g <= 0;
            already_calc <= 0;
            if (!rst_n) begin
                rst_n_xs <= 0;
            end else begin
                rst_n_xs <= 1;
            end
        end else if (Istate) begin
            if (!already_calc) begin
                Istate <= `OFF;
                Rstate <= `ON;
                ready_n <= 1;
                rst_n_xs <= 1;
            end
        end else if (Rstate) begin
            if (waiting_n) begin
                if (RstateCount == 0) begin
                    start_n_xs <= 0;
                    waiting_n <= 0;
                    RstateCount <= RstateCount + 1;
                end else if (RstateCount == 1) begin
                    random1 <= random_xs;
                    start_n_xs <= 0;
                    waiting_n <= 0;
                    RstateCount <= RstateCount + 1;
                end else if (RstateCount == 2) begin
                    random2 <= random_xs;
                    start_n_xs <= 1;
                    Rstate <= `OFF;
                    Dstate <= `ON;
                    rst_n_g <= 0;
                end else begin // illigal state
                    start_n_xs <= 1;
                    Rstate <= `OFF;
                    Dstate <= `OFF;
                end
            end else begin
                start_n_xs <= 1;
                if (!ready_n_xs) begin
                    waiting_n <= 1;
                end else begin
                end
            end
        end else if (Dstate) begin
            if (random > L) begin
                random1 <= (random1 >> 1);
            end else begin
                Dstate <= `OFF;
                Gstate <= `ON;
            end
        end else if (Gstate) begin
            if (waiting_n) begin
                rst_n_g <= 1;
                waiting_n <= 0;
            end else begin
                if (!ready_n_g) begin
                    waiting_n <= 1;
                    if (gcd == 64'd1) begin
                        Istate <= `ON;
                        Gstate <= `OFF;
                        ready_n <= 0;
                        already_calc <= 1;
                        E <= random;
                    end else begin
                        Rstate <= `ON;
                        Gstate <= `OFF;
                        RstateCount <= 0;
                    end 
                end 
            end
        end else begin
            Istate <= `OFF;
            Rstate <= `OFF;
            Gstate <= `OFF;
            ready_n <= 1;
        end
    end
endmodule
    
module create_d(
    input wire [64-1:0] e,
    input wire [64-1:0] L,
    input wire clk,
    input wire rst_n,
    output reg [64-1:0] D,
    output reg ready_n);

    reg [64-1:0] r, r_n, d, d_n;
    wire [64-1:0] q, r_nn, d_nn, dnq; // dnq = d_n * q;
    wire [128-1:0] dnq_128;

    assign dnq = dnq_128[64-1:0];
    
    reg end_calc, wait_n;
    reg rst_n_div, rst_n_mul, rst_n_sub;
    wire ready_n_div, ready_n_mul, ready_n_sub;

    reg Istate, Astate, Dstate, Mstate, Sstate; // アイドル状態、代入状態、割り算状態、掛け算状態、引き算状態

    reg first_step_n;

    div_binary div_binary(r, r_n, clk, rst_n_div, q, r_nn, ready_n_div);
    mul_6464 mul_6464(d_n, q, clk, rst_n_mul, dnq_128, ready_n_mul);
    sub_64 sub_64(d, dnq, clk, rst_n_sub, d_nn, ready_n_sub);

    always @(posedge clk) begin
        if (!rst_n) begin
            r <= 0;
            r_n <= 0;
            d <= 0;
            d_n <= 0;
            d <= 0;
            ready_n <= 0;
            end_calc <= 0;
            wait_n <= 1;
            rst_n_div <= 0;
            rst_n_mul <= 0;
            rst_n_sub <= 0;
            first_step_n <= 0;
            Istate <= `ON;
            Astate <= `OFF;
            Dstate <= `OFF;
            Mstate <= `OFF;
            Sstate <= `OFF;
        end else begin
            if (Istate) begin
                if (!end_calc) begin
                    Istate <= `OFF;
                    Astate <= `ON;
                end else begin
                    Istate <= `ON;
                end
            end else if (Astate) begin
                if (!first_step_n) begin
                    r <= e;
                    r_n <= L;
                    d <= 1;
                    d_n <= 0;
                    first_step_n <= 1;
                end else begin
                    r <= r_n;
                    r_n <= r_nn;
                    d <= d_n;
                    d_n <= d_nn;
                end
                Astate <= `OFF;
                Dstate <= `ON;
                rst_n_div <= 0;
            end else if (Dstate) begin
                if (wait_n) begin // 待ってないときは
                    rst_n_div <= 1;
                    wait_n <= 0;
                end else begin
                    if (!ready_n_div) begin
                    rst_n_mul <= 0;
                    Dstate <= `OFF;
                    Mstate <= `ON;
                    wait_n <= 1;
                    end
                end
            end else if (Mstate) begin
                if (wait_n) begin // 待ってないときは
                    rst_n_mul <= 1;
                    wait_n <= 0;
                end else begin
                    if (!ready_n_mul) begin
                    rst_n_sub <= 0;
                    Mstate <= `OFF;
                    Sstate <= `ON;
                    wait_n <= 1;
                    end
                end
            end else if (Sstate) begin
                if (wait_n) begin // 待ってないときは
                    rst_n_sub <= 1;
                    wait_n <= 0;
                end else begin
                    if (!ready_n_sub) begin
                        if (r_n == 0) begin
                            Sstate <= `OFF;
                            Istate <= `ON;
                            wait_n <= 1;
                            if (d[63] == 0) begin
                                D <= d;
                            end else begin
                                D <= d + L;
                            end
                        end else begin
                            Sstate <= `OFF;
                            Astate <= `ON;
                            wait_n <= 1;
                            end_calc <= 1;
                        end
                    end
                end
            end else begin // Istate, Astate, Dstate, Mstate, Sstate
                Istate <= `OFF;
                Astate <= `OFF;
                Dstate <= `OFF;
                Mstate <= `OFF;
                Sstate <= `OFF;
            end
        end
    end
endmodule

