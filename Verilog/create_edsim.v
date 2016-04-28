// module create_edsim();
//     reg [64-1:0] L;
//     reg clk, rst_n, start_n;
//     wire [64-1:0] E;
//     wire ready_n;
// 
//     create_e create_e(L, clk, rst_n,start_n, E, ready_n);
//     
//     initial begin
// 	    $dumpfile("create_edsim.vcd");
// 	    $dumpvars;
//         $monitor("%t: %h", $time, E);
//         L <= 64'he91293da9dae91;
// 	    clk <= 0;
// 	    rst_n <= 0;
//     end
// 
//     initial begin
//         #100 
//         rst_n <= 1;
//  	#40
//  	    start_n <= 1;
// // 	#100
// // 	    start_n <= 0;
// // 	#20
// //         start_n <= 1;
// // 	#100
// // 	    start_n <= 0;
// //     #20
// //         start_n <= 1;
// //     #100
// //         start_n <= 0;
// //     #20 start_n <= 1;
// 	#100000
// 	    $finish;
//     end
// 
//     always #10 clk <= ~clk;
// endmodule

module create_dsim();
    reg [64-1:0] e, L;
    reg clk, rst_n;
    wire [64-1:0] D;
    wire ready_n;

    create_d create_d(e, L, clk, rst_n, D, ready_n);
    
    initial begin
	    $dumpfile("create_d.vcd");
	    $dumpvars;
        $monitor("%t: %h", $time, D);
        L <= 64'd176;
        e <= 65'd79;
	    clk <= 0;
	    rst_n <= 0;
    end

    initial begin
        #100 
        rst_n <= 1;
// 	#100
// 	    start_n <= 0;
// 	#20
//         start_n <= 1;
// 	#100
// 	    start_n <= 0;
//     #20
//         start_n <= 1;
//     #100
//         start_n <= 0;
//     #20 start_n <= 1;
	#100000
	    $finish;
    end

    always #10 clk <= ~clk;
endmodule
