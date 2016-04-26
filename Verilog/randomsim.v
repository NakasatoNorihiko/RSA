module random_32sim();
    reg clk, rst_n, start_n;
    wire [32-1:0] random;
    wire ready_n;

    xorshift_32 xorshift_32(clk, rst_n, start_n, random, ready_n);
    
    initial begin
	$dumpfile("xorshift_32sim.vcd");
	$dumpvars;
        $monitor("%t: %h", $time, random);
	clk <= 0;
	rst_n <= 0;
    start_n <= 0;
    end

    initial begin
        #100 
        rst_n <= 1;
	#20
	    start_n <= 1;
	#100
	    start_n <= 0;
	#20
        start_n <= 1;
	#100
	    start_n <= 0;
    #20
        start_n <= 1;
    #100
        start_n <= 0;
    #20 start_n <= 1;
	#200
	    $finish;
    end

    always #10 clk <= ~clk;
endmodule
