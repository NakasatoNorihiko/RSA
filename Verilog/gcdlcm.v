module gcd_32(
    input wire [32-1:0] ina, inb,
    input wire clk,
    input wire rst_n,
    output wire [32-1:0] result,
    output reg ready_n);

    reg [32-1:0] rega, regb, regg;
    reg [2-1:0]  status;
    reg rst_n_mul;
    wire ready_n_mul;
    wire [64-1:0] result_mul;
    assign result = result_mul[32-1:0];

    mul_3232 mul_3232(regb, regg, clk, rst_n_mul, result_mul, ready_n_mul);

    always @(posedge clk) begin
        if (!rst_n) begin
            regg <= 1;
            status <= 2'd0;
            rega   <= ina;
            regb   <= inb;
            ready_n <= 1;
            rst_n_mul <= 0;
        end else begin
            if (status >= 2'd2) begin
                ready_n <= 0;
            end else if (status >= 2'd1) begin
                if (!rst_n_mul) begin 
                    rst_n_mul <= 1;
                end else if (!ready_n_mul & rst_n_mul) begin
                    status <= status + 1;
                end
            end else begin
                if (rega == 32'd0) begin // aが0なら終了
                    status <= status + 1;
                end else begin // aが0以外なら計算を続ける
                    if (rega[0] == 1'b0 & regb[0] == 1'b0) begin
                        rega <= rega >> 1;
                        regb <= regb >> 1;
                        regg <= regg << 1;
                    end else if (rega[0] == 1'b0 & regb[0] == 1'b1) begin
                        rega <= rega >> 1;
                    end else if (rega[0] == 1'b1 & regb[0] == 1'b0) begin
                        regb <= regb >> 1;
                    end else begin
                        if (rega >= regb) begin
                            rega <= ((rega-regb) >> 1);
                        end else begin
                            regb <= ((regb-rega) >> 1);
                        end
                    end
                end
            end
        end
    end
endmodule 
