`timescale 1ns/10ps
`define CYCLE    15          	         // Modify your clock period here
`define SDFFILE    "./stage_1_test_syn.sdf"	      // Modify your sdf file name

module stage_1_tb;

	//pins
    reg [511:0] inputt;
    wire [159:0] ans;

    reg clk, rst_n, next, init;
    wire ready, done;
    // wire [159:0] ans;
	//module instantiation
	RIPEMD160_stage_1_core r0(
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

    always #20 clk = ~clk;


	//initial block
	initial begin
		$display("Testbench Start.");
        rst_n = 1;
        clk = 0;
        init = 0;
        next = 0;
        //inputt = 512'h7473614d_59207265_80676e61_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
        inputt = 512'h00000000_00000058_0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000_80676e61_59207265_7473614d;
        // inputt = 0;
        #10 rst_n = 0;
        #10 rst_n = 1;
        // @(posedge ready);
		// #50;

        
        // inputt = 512'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080676e61592072657473614d;
		init = 1;
		@(posedge done);
			
			//check answer
        if(ans != 160'hcc137364_61c2d89e_e2a640c4_1edf7248_3712052e) $display("error!!! out =  %h;", ans);
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