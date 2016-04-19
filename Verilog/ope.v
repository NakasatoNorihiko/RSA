// 32bitと32bitの加算器
module add_32(
    input  [32-1:0] ina, inb,
    input  clk,
    input  rst_n,
    output [64-1:0] result);
    
    reg [2-1:0] count;
    wire [9-1:0] res;
    wire [8-1:0] a,b;
    wire carry;

    assign res = a + b + carry;
    assign carry = res[9-1];

    always @(posedge clk) begin
        if (!rst_n) begin
            count <= 0;
            result [64-1:0] <= 0;
            carry <= 0;
            a = ina[8-1:0];
            b = inb[8-1:0];
            //reset operations
        end else begin
            // RT operations
            case (count)
                2'b00 : begin
                    a = ina[16-1:8];
                    b = inb[16-1:8];
                end
                2'b01 : begin
                    a = ina[24-1:16];
                    b = inb[24-1:16];
                end
                2'b10 : begin
                    a = ina[32-1:24];
                    b = inb[32-1:24];
                end


        end
    end
endmodule
    
