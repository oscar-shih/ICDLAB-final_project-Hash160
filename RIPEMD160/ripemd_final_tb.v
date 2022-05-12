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
        // inputt = 512'h7473614d_59207265_80676e61_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
        //inputt = 512'h00000000_00000058_00000000000000000000000000000000000000000000000000000000000000000000000000000000_00000000_80676e61_59207265_7473614d;
        // inputt = 512'h00000000000000000000000000000000000000000000000000000000000000005feceb66ffc86f38d952786c6d696c79c2dbc239dd4e91b46729d73a27fb57e9;
        //inputt = 512'h80393837_36353433_3231307a_79787776_75747372_71706f6e_6d6c6b6a_69686766_65646362_615a5958_57565554_53525150_4f4e4d4c_4b4a4948_47464544_43424122;
        inputt = 512'h00000000_00000200_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
        #10 rst_n = 0;
        #10 rst_n = 1;
        // @(posedge ready);
		// #50;

        
        // inputt = 512'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080676e61592072657473614d;
		init = 1;
		@(posedge done);
			
			//check answer
        // if(ans != 160'h3b7b334f_d5da9f29_b0f102a1_7c1e16db_ee997931) $display("error!!! out =  %h;", ans);
        // else $display("Success!!");
        // if(ans !== 160'h4dc9d8f5_7a10181a_0c78d60c_a2e95122_cc4fbacc) $display("error!!! out =  %h;", ans);
        // else $display("Success!!");
        if(ans !== 160'hd633dc99fd96e011be0f018188e96a2afe2418b5) $display("error!!! out =  %h;", ans);
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