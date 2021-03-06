`timescale 1ns/10ps
`define CYCLE    10         	         // Modify your clock period here
`define SDFFILE    "./CHIP.sdf"

module Top_tb;

	//pins
    reg [7:0] input_test;
    wire [15:0] ans;

    reg clk, rst_n, next, init;
    wire ready, done;
    reg [15:0] gold_ans;
    reg Valid;

    integer i,j;
    parameter num = 10; //number of answer data
	//module instantiation
    CHIP top(
                   .clk(clk),
                   .rst_n(rst_n),
                   .i_valid(Valid),
                   .i_text(input_test),
                   .o_answer(ans),
                   .o_valid(done)
                  );
					  
    `ifdef SDF
        initial $sdf_annotate(`SDFFILE, top);
    `endif   

    always #(`CYCLE/2) clk = ~clk;

    //File Handler
    integer data_in, gold_out, cnt1, cnt2;

    initial begin
        data_in = $fopen("top_input_split.txt","r");
        gold_out = $fopen("top_output_split.txt","r");
        if (data_in == 0) begin
            $display("input_file handle was NULL.");
            $finish;
        end
        if (gold_out == 0) begin
            $display("golden_output handle was NULL.");
            $finish;
        end
    end

	//initial block
	initial begin
        $fsdbDumpfile("top.fsdb");
	    $fsdbDumpvars(0, "+mda");
		$display("Testbench Start.");
        cnt2 = $fscanf(gold_out, "%h\n", gold_ans);
        rst_n = 1;
        clk = 0;
        init = 0;
        input_test = 8'b0;
        //#10 rst_n = 0;
        //#10 rst_n = 1;
        // @(posedge ready);
		// #50;
        @(posedge clk);
        #(`CYCLE/2);
        for (i=0; i<num; i=i+1) begin
            input_test = 8'b0;
            Valid = 0;
            rst_n = 0; 
            #5; 
            rst_n = 1;
            @(posedge clk); // #(`CYCLE)
            @(posedge clk); // #(`CYCLE)
            //input_test = 8'b10101010; //start signal
            @(posedge clk); // #(`CYCLE)
            Valid = 1;
            for (j=0; j<64; j=j+1) begin
                cnt1 = $fscanf(data_in, "%b\n", input_test);
		        // $display("input%d = %h", j, input_test);
                @(posedge clk); // #(`CYCLE)
            end
            input_test = 8'b0;  Valid = 0;
            $display("Input done.");

            @(posedge done);
            $display("Calculation done."); 
            for(j=0; j<10; j=j+1) begin
                @(negedge clk);
                if(gold_ans !== ans) $display("%derror!!! gold_out =  %h; out = %h",i, gold_ans, ans);
                else $display("%dSuccess!!  gold_out =  %h; out = %h",i, gold_ans, ans);
                cnt2 = $fscanf(gold_out, "%h\n", gold_ans);
            end

			//check answer
            //cnt2 = $fscanf(gold_out, "%h\n", gold_ans);
            //if(gold_ans !== ans) $display("%derror!!! gold_out =  %h; out = %h",i, gold_ans, ans);
            //else $display("%dSuccess!!  gold_out =  %h; out = %h",i, gold_ans, ans);
            #10;
        end
        #50;
		
		$display("Testbench End.");
		$finish;
	end

    initial begin
        #100000 $display("Time Exceed.") ;
        $finish;
    end
endmodule