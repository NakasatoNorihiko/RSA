`define ON 1
`define OFF 0

module xorshift_32(
    input wire clk,
    input wire rst_n,
    input wire start_n,
    output reg [32-1:0] random,
    output reg ready_n);

    reg [32-1:0] seed;
    reg Istate, Sstate;
    reg [2-1:0] Sstatecount;

    always @(posedge clk) begin
        if (!rst_n) begin
            seed <= 32'd2463534242;
            ready_n <= 0;
            Istate <= `ON;
            Sstate <= `OFF;
            random <= seed;
        end else if (Istate) begin
            if (!start_n) begin
                Istate <= `OFF;
                Sstate <= `ON;
                Sstatecount <= 0;
                ready_n <= 1;
            end
        end else if (Sstate) begin
            Sstatecount <= Sstatecount + 1;
            case (Sstatecount)
                2'd0 : seed <= seed ^ (seed << 13);
                2'd1 : seed <= seed ^ (seed >> 17);
                2'd2 : begin
                    seed <= seed ^ (seed << 5);
                    random <= seed ^ (seed << 5);
                    Istate <= `ON;
                    Sstate <= `OFF;
                    ready_n <= 0;
                end
                default : begin
                    Istate <= `ON;
                    Sstate <= `OFF;
                    ready_n <= 1;
                end
            endcase
        end else begin
            Istate <= `OFF;
            Sstate <= `OFF;
            ready_n <= 1;
        end
    end
endmodule
            
