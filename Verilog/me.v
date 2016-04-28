`define ON 1
`define OFF 0

module me(
    input wire [64-1:0] a,
    input wire [64-1:0] m,
    input wire [64-1:0] N,
    input wire clk,
    input wire rst_n,
    output reg [64-1:0] S,
    output reg ready_n);

    reg [64-1:0] a_reg, m_reg, N_reg;
    reg [64-1:0] Sora;
    reg rst_n_mul, rst_n_div;
    wire ready_n_mul, ready_n_div;
    wire [128-1:0] res_mul;
    wire [64-1:0] S_wire, q;
    reg Istate, Cstate, Mstate, Dstate; // Idle, Check, Multiple, Divide
    reg finish_calc;
    reg [8-1:0] j; // mの桁数
    
    mul_6464 mul_6464(S, Sora, clk, rst_n_mul, res_mul, ready_n_mul);
    div_binary div_binary(res_mul[64-1:0], N, clk, rst_n_div, q, S_wire, ready_n_div);

    always @ (posedge clk) begin
        if (!rst_n) begin
            a_reg <= a;
            m_reg <= m;
            N_reg <= N;
            S <= 0;
            ready_n <= 0;
            Sora <= S;
            rst_n_mul <= 0;
            rst_n_div <= 0;
            finish_calc <= 0;
            j <= 0;
            Istate <= `ON;
            Cstate <= `OFF;
            Mstate <= `OFF;
            Dstate <= `OFF;
        end else begin
            if (Istate) begin
                if (!finish_calc) begin
                    Istate <= `OFF;
                    Cstate <= `ON;
                end else begin
                    Istate <= `ON;
                end 
            end else if (Cstate) begin
                if ((m_reg >> j)) begin 
                    j <= j + 1;
                end else begin
                    j <= j - 1;
                    Cstate <= `OFF;
                    Mstate <= `ON;
                end
            end else if (Mstate) begin
            end else if (Dstate) begin
            end else begin
            end
            
        end
    end 
endmodule
