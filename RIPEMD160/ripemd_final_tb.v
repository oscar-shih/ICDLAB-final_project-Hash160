`timescale 1ns/10ps
`define CYCLE    10          	         // Modify your clock period here
`define SDFFILE    "./stage_2_test.sdf"	      // Modify your sdf file name

module ripemd160_tb;

	//pins
    reg [511:0] inputt;
    wire [159:0] ans;

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
		$display("Testbench Start.");
        rst_n = 1;
        clk = 0;
        init = 0;
        next = 0;
        inputt = 512'h0000000000000058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080676e61592072657473614d;
        #10 rst_n = 0;
        #10 rst_n = 1;
		init = 1;
		@(posedge done);
			
			//check answer
        // if(ans != 160'h3b7b334f_d5da9f29_b0f102a1_7c1e16db_ee997931) $display("error!!! out =  %h;", ans);
        // else $display("Success!!");
        // if(ans !== 160'h4dc9d8f5_7a10181a_0c78d60c_a2e95122_cc4fbacc) $display("error!!! out =  %h;", ans);
        // else $display("Success!!");
        if(ans !== 160'hfedcd200dc0f8b4c51ad7ae734282ff2008bbb12) $display("error!!! out =  %h;", ans);
        else $display("Success!!");
			//end
        #50;
		
		$display("Testbench End.");
		$finish;
	end

    initial begin
        # 10000 $display("Time Exceed.") ;
        $finish;
    end
endmodule