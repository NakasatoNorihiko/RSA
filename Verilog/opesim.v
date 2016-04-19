module add_32sim();
    reg [32-1:0] ina, inb;
    reg clk, rst_n;
    wire [64-1:0] result;
    wire [64-1:0] inab;

    assign inab = ina + inb;

    add_32 add_32(ina, inb, clk, rst_n, result);

    initial begin
	$dumpfile("add_32sim.vcd");
	$dumpvars;
        $monitor("%t: %h + %h => %h(%h)", $time, ina, inb, result, inab);
	clk <= 0;
	rst_n <= 0;
    end

    initial begin
        #100 
	    ina <= 32'h00000001;
	    inb <= 32'h00000001;
	#20
	    rst_n <= 1;
	#100
	    rst_n <= 0;
	#100
	    ina <= 32'h03fd0010;
	    inb <= 32'h01da0100;
	#20
	    rst_n <= 1;
	#200
	    $finish;
    end

    always #10 clk <= ~clk;
endmodule
