// module comp_32sim();
//     reg [32-1:0] ina, inb;
//     reg clk, rst_n;
//     wire g, e, ready_n;
// 
//     comp_32 comp_32(ina, inb, clk, rst_n, g, e, ready_n);
// 
//     initial begin
// 	$dumpfile("comp_32sim.vcd");
// 	$dumpvars;
//         $monitor("%t: %h %h => %b %b", $time, ina, inb, g, e);
// 	clk <= 0;
// 	rst_n <= 0;
//     end
// 
//     initial begin
//         #100 
// 	    ina <= 32'h00000001;
// 	    inb <= 32'h00000001;
// 	#20
// 	    rst_n <= 1;
// 	#100
// 	    rst_n <= 0;
// 	#100
// 	    ina <= 32'h00000010;
// 	    inb <= 32'h00000100;
// 	#20
// 	    rst_n <= 1;
//     #100
//         rst_n <= 0;
//     #100
//         ina <= 32'h001fda13;
//         inb <= 32'h0001dedd;
//     #20 rst_n <= 1;
// 	#200
// 	    $finish;
//     end
// 
//     always #10 clk <= ~clk;
// endmodule

// module add_32sim();
//     reg [32-1:0] ina, inb;
//     reg clk, rst_n;
//     wire [64-1:0] result;
//     wire [64-1:0] inab;
//     wire g, e;
// 
//     assign inab = ina + inb;
// 
//     add_32 add_32(ina, inb, clk, rst_n, result);
// //    comp_8 comp_8(ina, inb, clk, rst_n, g, e);
// 
//     initial begin
// 	$dumpfile("add_32sim.vcd");
// 	$dumpvars;
//         $monitor("%t: %h + %h => %h(%h)", $time, ina, inb, result, inab);
// 	clk <= 0;
// 	rst_n <= 0;
//     end
// 
//     initial begin
//         #100 
// 	    ina <= 32'h00000001;
// 	    inb <= 32'h00000001;
// 	#20
// 	    rst_n <= 1;
// 	#100
// 	    rst_n <= 0;
// 	#100
// 	    ina <= 32'h03fd0010;
// 	    inb <= 32'h01da0100;
// 	#20
// 	    rst_n <= 1;
// 	#200
// 	    $finish;
//     end
// 
//     always #10 clk <= ~clk;
// endmodule

module gcdlcmsim();
    reg [32-1:0] ina;
    reg [32-1:0]  inb;
    reg clk, rst_n;
    wire [32-1:0] result;
    wire ready_n;
    wire [64-1:0] inab;

    gcd_32 gcd_32(ina, inb, clk, rst_n, result, ready_n);

    assign inab = ina * inb;

    initial begin
	$dumpfile("gcdlcmsim.vcd");
	$dumpvars;
        $monitor("%t: %d *  %d => %d (%h) %b", $time, ina, inb, result, inab, ready_n);
	clk <= 0;
	rst_n <= 0;
    end

    initial begin
        #100 
	    ina <= 32'd10;
	    inb <= 32'd20;
	#10
	    rst_n <= 1;
	#2000
	    rst_n <= 0;
	#10
	    ina <= 32'd640;
	    inb <= 32'd120;
	#10
	    rst_n <= 1;
    #2000
        rst_n <= 0;
    #100
        ina <= 32'd9919398;
        inb <= 32'd1993112;
    #20 rst_n <= 1;
	#2000
	    $finish;
    end

    always #5 clk <= ~clk;
endmodule
