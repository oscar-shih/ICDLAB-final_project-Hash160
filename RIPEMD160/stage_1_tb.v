module stage_1_tb;

	//pins
    reg [511:0] inputt;
    wire [159:0] ans;

    reg clk, rst_n, next, init;
    wire ready, done;
    // wire [159:0] ans;
	//module instantiation
	RIPEMD160_stage_1 r0(
                   .clk(clk),
                   .reset_n(rst_n),
                   .init(init),
                   .next(next),
                   .block(inputt),
                   .ready(ready),
                   .digest(ans),
                   .digest_valid(done)
                  );
					  

    always #10 clk = ~clk;


	//initial block
	initial begin
		$display("Testbench Start.");
        rst_n = 1;
        clk = 0;
        init = 0;
        next = 0;
        inputt = 0;
        #10 rst_n = 0;
        #10 rst_n = 1;
        @(posedge ready);
		#50;

        
        inputt = 512'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080676e61592072657473614d;
		init = 1;
		@(posedge done);
			
			//check answer
        if(ans != 160'hfedcd200dc0f8b4c51ad7ae734282ff2008bbb12) $display("%d error!!! out =  ;", ans);
			//end
        #50;
		
		$display("Testbench End.");
		$finish;
	end
endmodule