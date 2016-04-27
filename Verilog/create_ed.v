`define ON 1
`define OFF 0

module create_e(
    input wire [64-1:0] L,
    input wire clk,
    input wire rst_n,
    input wire start_n,
    output reg [64-1:0] E,
    output reg ready_n);

    reg Istate, Rstate, Gstate; // Idle, Random, gcd
    reg waiting_n;
    reg [2-1:0] RstateCount;
    reg seedInitial_n;
    reg rst_n_xs;
    reg start_n_xs;
    wire ready_n_xs;
    wire [32-1:0] random_xs;
    reg [32-1:0] random1, random2;
    wire [64-1:0] random;
    assign random = {random1, random2};

    xorshift_32 xorshift_32(clk, rst_n_xs, start_n_xs, random_xs, ready_n_xs);

    always @(posedge clk) begin
        if (!rst_n | !start_n) begin
            Istate <= `ON;
            Rstate <= `OFF;
            Gstate <= `OFF;
            RstateCount <= 0;
            start_n_xs <= 1;
            waiting_n <= 1;
            if (!rst_n) begin
                rst_n_xs <= 0;
            end else begin
                rst_n_xs <= 1;
            end
        end else if (Istate) begin
            Istate <= `OFF;
            Rstate <= `ON;
            ready_n <= 1;
            rst_n_xs <= 1;
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
                    Gstate <= `ON;
                end else begin // illigal state
                    start_n_xs <= 1;
                    Rstate <= `OFF;
                    Gstate <= `OFF;
                end
            end else begin
                start_n_xs <= 1;
                if (!ready_n_xs) begin
                    waiting_n <= 1;
                end else begin
                end
            end
        end else if (Gstate) begin
        end else begin
            Istate <= `OFF;
            Rstate <= `OFF;
            Gstate <= `OFF;
            ready_n <= 1;
        end
    end
endmodule
    
