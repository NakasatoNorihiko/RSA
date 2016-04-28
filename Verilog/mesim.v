module mesim();
    reg [64-1:0] a, m, N;
    reg clk, rst_n;
    wire [64-1:0] S;
    wire ready_n;

    me me(a, m, N, clk, rst_n, S, ready_n);
    
    initial begin
	    $dumpfile("me.vcd");
	    $dumpvars;
        $monitor("%t: %d", $time, S);
        a <= 64'd5;
        m <= 64'd3;
        N <= 64'd13;
	    clk <= 0;
	    rst_n <= 0;
    end

    initial begin
        #100 
        rst_n <= 1;
	#100000
	    $finish;
    end

    always #10 clk <= ~clk;
endmodule
