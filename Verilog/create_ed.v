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
    
