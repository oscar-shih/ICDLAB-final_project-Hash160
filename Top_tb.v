`timescale 1ns/10ps
`define CYCLE    10          	         // Modify your clock period here
`define SDFFILE    "./stage_1_test_syn.sdf"	      // Modify your sdf file name
`define NULL 0  

module Top_tb;

	//pins
    reg [7:0] input_test;
    wire [159:0] ans;

    reg clk, rst_n, next, init;
    wire ready, done;
    reg [159:0] gold_ans;

    integer i,j;
    parameter num = 1; //number of answer data
	//module instantiation
    top r0(
                   .clk(clk),
                   .rst_n(rst_n),
                   .i_text(input_test),
                   .o_answer(ans),
                   .o_valid(done)
                  );
					  
    `ifdef SDF
        initial $sdf_annotate(`SDFFILE, r0);
    `endif   

    always #(`CYCLE/2) clk = ~clk;

    //File Handler
    integer data_in, gold_out, cnt1, cnt2;

    initial begin
        data_in = $fopen("top_input.txt","r");
        gold_out = $fopen("top_output.txt","r");
        if (data_in == `NULL) begin
            $display("input_file handle was NULL.");
            $finish;
        end
        if (gold_out == `NULL) begin
            $display("golden_output handle was NULL.");
            $finish;
        end
    end

	//initial block
	initial begin
        $fsdbDumpfile("top.fsdb");
	    $fsdbDumpvars(0, "+mda");
		$display("Testbench Start.");
        rst_n = 1;
        clk = 0;
        init = 0;
        input_test = 8'b0;
        #10 rst_n = 0;
        #10 rst_n = 1;
        // @(posedge ready);
		// #50;
        @(posedge clk);
        #(`CYCLE/2);
        for (i=0; i<num; i=i+1) begin
            input_test = 8'b0;
            rst_n = 0; 
            #5; 
            rst_n = 1;

            input_test = 8'b10101010; //start signal

            for (j=0; j<64; j=j+1) begin
                @(posedge clk); // #(`CYCLE)
                cnt1 = $fscanf(data_in, "%b\n", input_test);
            end
            $display("Input done.");
            input_test = 8'b0;


            @(posedge done);
			$display("Calculation done.");
			//check answer
            cnt2 = $fscanf(gold_out, "%h\n", gold_ans);
            if(gold_ans != ans) $display("error!!! gold_out =  %h; out = %h", gold_ans, ans);
            else $display("Success!!");
        end
        #50;
		
		$display("Testbench End.");
		$finish;
	end

    initial begin
        # 50000 $display("Time Exceed.") ;
        $finish;
    end
endmodule