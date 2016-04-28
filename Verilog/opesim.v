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
// module comp_64sim();
//     reg [64-1:0] ina;
//     reg clk, rst_n;
//     wire [64-1:0] result;
//     wire ready_n;
// 
//     wire [64-1:0] ans;
// 
//     assign ans = ~ina + 1;
// 
//     comp_64 comp_64(ina, clk, rst_n, result, ready_n);
// 
//     initial begin
// 	    $dumpfile("comp_64sim.vcd");
// 	    $dumpvars;
//         $monitor("%t: %h => %h (%h)", $time, ina, result, ans);
// 	    clk <= 0;
// 	    rst_n <= 0;
//     end
// 
//     initial begin
//         #100 
// 	        ina <= 32'h00000001;
// 	    #20
// 	        rst_n <= 1;
// 	    #1000
// 	        rst_n <= 0;
// 	    #20
// 	        ina <= 32'h00000010;
// 	    #100
// 	        rst_n <= 1;
//         #1000
//             rst_n <= 0;
//         #20
//             ina <= 32'h001fda13;
//         #100 rst_n <= 1;
// 	    #200
// 	        $finish;
//     end
// 
//     always #5 clk <= ~clk;
// endmodule

// module add_32sim();
//     reg [64-1:0] ina, inb;
//     reg clk, rst_n;
//     wire [64-1:0] result;
//     wire [64-1:0] inab;
//     wire g, e, ready_n;
// 
//     assign inab = ina + inb;
// 
//     add_64 add_64(ina, inb, clk, rst_n, result, ready_n);
// //    comp_8 comp_8(ina, inb, clk, rst_n, g, e);
// 
//     initial begin
// 	$dumpfile("add_64sim.vcd");
// 	$dumpvars;
//         $monitor("%t: %h + %h => %h(%h)", $time, ina, inb, result, inab);
// 	clk <= 0;
// 	rst_n <= 0;
//     end
// 
//     initial begin
//         #100 
// 	    ina <= 64'h00000001;
// 	    inb <= 64'h00000001;
// 	#20
// 	    rst_n <= 1;
// 	#100
// 	    rst_n <= 0;
// 	#100
// 	    ina <= 64'h03fd0010;
// 	    inb <= 64'h01da0100;
// 	#20
// 	    rst_n <= 1;
// 	#200
// 	    $finish;
//     end
// 
//     always #10 clk <= ~clk;
// endmodule

// module sub_64sim();
//     reg [64-1:0] ina, inb;
//     reg clk, rst_n;
//     wire [64-1:0] result;
//     wire [64-1:0] inab;
//     wire g, e, ready_n;
// 
//     assign inab = ina + (~inb+1);
// 
//     sub_64 sub_64(ina, inb, clk, rst_n, result, ready_n);
// 
//     initial begin
// 	$dumpfile("sub_64sim.vcd");
// 	$dumpvars;
//         $monitor("%t: %h - %h => %h(%h)", $time, ina, inb, result, inab);
// 	clk <= 0;
// 	rst_n <= 0;
//     end
// 
//     initial begin
//         #100 
// 	    ina <= 64'h00000001;
// 	    inb <= 64'h00000001;
// 	#20
// 	    rst_n <= 1;
// 	#1000
// 	    rst_n <= 0;
// 	#100
// 	    inb <= 64'h03fd0010;
// 	    ina <= 64'h01da0100;
// 	#20
// 	    rst_n <= 1;
// 	#1000
// 	    $finish;
//     end
// 
//     always #5 clk <= ~clk;
// endmodule

//module size_64sim();
//    reg [64-1:0] a;
//    reg clk, rst_n;
//    wire [8-1:0] size;
//    wire ready_n;
//
//    size_64 size_64(a, clk, rst_n, size, ready_n);
//
//    initial begin
//	$dumpfile("size_64sim.vcd");
//	$dumpvars;
//        $monitor("%t: %d %h => %d", $time, a, a, size);
//	clk <= 0;
//	rst_n <= 0;
//    end
//
//    initial begin
//    #100 
//	    a <= $unsigned($random);
//	#20
//	    rst_n <= 1;
//	#1000
//	    rst_n <= 0;
//	#100
//	    a <= $unsigned($random);
//	#20
//	    rst_n <= 1;
//	#1000
//	    rst_n <= 0;
//	#100
//	    a <= $unsigned($random);
//	#20
//	    rst_n <= 1;
//	#1000
//	    rst_n <= 0;
//	#100
//	    a <= $unsigned($random);
//	#20
//	    rst_n <= 1;
//	#1000
//	    rst_n <= 0;
//	#100
//	    a <= $unsigned($random);
//	#20
//	    rst_n <= 1;
//	#1000
//	    rst_n <= 0;
//	#1000
//	    $finish;
//    end
//
//    always #5 clk <= ~clk;
//endmodule
// module div_binarysim();
//     reg [64-1:0] a, b;
//     reg clk, rst_n_div;
//     wire [8-1:0] size;
//     wire [64-1:0] q,r;
//     wire ready_n_size, ready_n_div;
//     wire [64-1:0] correctq, correctr;
// 
//     assign correctq = a / b;
//     assign correctr = a % b;
// 
//     div_binary div_binary(a, b, clk, rst_n_div, q, r, ready_n_div);
// 
//     initial begin
// 	$dumpfile("div_binary.vcd");
// 	$dumpvars;
//         $monitor("%t: %d = %d * %d + %d(%d = %d * %d + %d)", $time, a, b, q, r, a, b, correctq, correctr);
// 	clk <= 0; 
//     rst_n_div <= 0;
//     end
// 
//     initial begin
//     #100 
// 	    a <= $unsigned($random) % 100000;
//         b <= $unsigned($random) % 50000 + 1;
// 	#20
//         rst_n_div <= 1;
// 	#2000
//         rst_n_div <= 0;
// 	#10
// 	    a <= $unsigned($random) % 100000;
//         b <= $unsigned($random) % 50000 + 1;
// 	#20
//         rst_n_div <= 1;
// 	#2000
//         rst_n_div <= 0;
// 	#100
// 	    a <= $unsigned($random) % 100000;
//         b <= $unsigned($random) % 50000 + 1;
// 	#20
//         rst_n_div <= 1;
// 	#2000
//         rst_n_div <= 0;
// 	#100
// 	    a <= $unsigned($random) % 100000;
//         b <= $unsigned($random) % 50000 + 1;
// 	#20
//         rst_n_div <= 1;
// 	#2000
//         rst_n_div <= 0;
// 	#100
// 	    a <= $unsigned($random) % 100000;
//         b <= $unsigned($random) % 50000 + 1;
// 	#20
//         rst_n_div <= 1;
// 	#2000
// 	    $finish;
//     end
// 
//     always #5 clk <= ~clk;
// endmodule



// module mul_3232sim();
//     reg [32-1:0] ina;
//     reg [32-1:0]  inb;
//     reg clk, rst_n;
//     wire [64-1:0] result;
//     wire ready_n;
//     wire [64-1:0] inab;
// 
//     mul_3232 mul_3232(ina, inb, clk, rst_n, result, ready_n);
// 
//     assign inab = ina * inb;
// 
//     initial begin
// 	$dumpfile("mul_3232sim.vcd");
// 	$dumpvars;
//         $monitor("%t: %h *  %h => %h (%h) %b", $time, ina, inb, result, inab, ready_n);
// 	clk <= 0;
// 	rst_n <= 0;
//     end
// 
//     initial begin
//         #100 
// 	    ina <= 32'h00000001;
// 	    inb <= 32'h00000001;
// 	#10
// 	    rst_n <= 1;
// 	#2000
// 	    rst_n <= 0;
// 	#10
// 	    ina <= 32'h00000010;
// 	    inb <= 32'h00000100;
// 	#10
// 	    rst_n <= 1;
//     #2000
//         rst_n <= 0;
//     #100
//         ina <= 32'hf81fda13;
//         inb <= 32'he301dedd;
//     #20 rst_n <= 1;
// 	#2000
// 	    $finish;
//     end
// 
//     always #5 clk <= ~clk;
// endmodule
module mul_6464sim();
    reg [64-1:0] ina;
    reg [64-1:0]  inb;
    reg clk, rst_n;
    wire [128-1:0] result;
    wire ready_n;
    wire [128-1:0] inab;

    mul_6464 mul_6464(ina, inb, clk, rst_n, result, ready_n);

    assign inab = (~ina + 1) * (~inb + 1);

    initial begin
	$dumpfile("mul_6464sim.vcd");
	$dumpvars;
        $monitor("%t: %h *  %h => %h (%h) %b", $time, ina, inb, result, inab, ready_n);
	clk <= 0;
	rst_n <= 0;
    end

    initial begin
        #100 
	    ina <= 64'h00000001;
	    inb <= 64'h00000001;
	#10
	    rst_n <= 1;
	#2000
	    rst_n <= 0;
	#10
	    ina <= 64'h00000010;
	    inb <= 64'h00000100;
	#10
	    rst_n <= 1;
    #2000
        rst_n <= 0;
    #100
        ina <= 64'he792ed91f81fda13;
        inb <= 64'he923d91ae301dedd;
    #20 rst_n <= 1;
	#2000
	    $finish;
    end

    always #5 clk <= ~clk;
endmodule
