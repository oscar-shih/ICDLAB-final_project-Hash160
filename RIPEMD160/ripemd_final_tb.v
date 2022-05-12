`timescale 1ns/10ps
`define CYCLE    10          	         // Modify your clock period here
`define SDFFILE    "./stage_2_test.sdf"	      // Modify your sdf file name

module ripemd160_tb;

	//pins
    integer idx=0;
    reg [511:0] inputt_r[0:99];
    reg [511:0] inputt;
    wire [159:0] ans;
    reg [159:0]test[0:99];

    reg clk, rst_n, next, init;
    wire ready, done;
    // wire [159:0] ans;
	//module instantiation
	ripemd_final r0(
                   .clk(clk),
                   .rst_n(rst_n),
                   .i_valid(init),
                   // .next(next),
                   .block(inputt),
                   // .ready(ready),
                   .ans(ans),
                   .o_valid(done)
                  );
					  
    `ifdef SDF
        initial $sdf_annotate(`SDFFILE, r0);
    `endif   

    always #10 clk = ~clk;
	//initial block
	initial begin
        $fsdbDumpfile("ripemd160.fsdb");
	    $fsdbDumpvars(0, "+mda");
        $readmemh("ripemd_input.txt",inputt_r);
        $readmemh("ripemd_output.txt",test);
        $display("starting");
		$display("Testbench Start.");
        repeat(100)  begin 
        rst_n = 1;
        clk = 0;
        init = 0;
        next = 0;
        #10 rst_n = 0;
        #10 rst_n = 1;
		init = 1;
        inputt=inputt_r[idx];
		@(posedge done);
        if(ans !== test[idx]) $display("error!!!%d out =  %h;",idx, ans);
        else $display("Success%d %h!!",idx, ans);
        idx=idx+1;
        end
		$display("Testbench End.");
		$finish;
	end

    // initial begin
    //     # 10000 $display("Time Exceed.") ;
    //     $finish;
    // end
endmodule
