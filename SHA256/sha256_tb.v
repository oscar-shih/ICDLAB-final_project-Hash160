`timescale  1ns / 100ps
`define CLCYE_TIME 10.0
`define SDFFILE    "./sha256.sdf"	      // Modify your sdf file name
module sha256_tb;

reg input_valid = 0;

wire output_valid_256;
integer idx=0;
wire [255:0] H_0_256, H_out_256;
sha256_H_0 sha256_H_0 (.H_0(H_0_256));
reg [511:0] M_sha256_abc_r  [0:99];
reg [255:0] test            [0:99];
reg [511:0] M_sha256_abc  ;
reg rst_n;
reg clk ;
sha256 sha256 (
    .clk(clk),
    .rst_n(rst_n),
    .H_in(H_0_256), .M_in(M_sha256_abc),
    .input_valid(input_valid),
    .H_out(H_out_256),
    .output_valid(output_valid_256)
);
`ifdef SDF
initial $sdf_annotate(`SDFFILE, sha256);
`endif   

always #10 clk = ~clk;

initial begin
  $fsdbDumpfile("sha256.fsdb");
  $fsdbDumpvars(0, "+mda");
  $readmemb("256input.txt",M_sha256_abc_r);
  $readmemh("256output.txt",test);
  $display("starting");

  repeat(100)  begin 
    rst_n = 1;
    clk = 0;
    input_valid= 0;
    #10 rst_n = 0;
    #10 rst_n = 1;
    input_valid= 1;
    M_sha256_abc=M_sha256_abc_r[idx];
    @(posedge output_valid_256);
    if(H_out_256 !== test[idx]) $display("error!!!%d out =  %h;",idx,H_out_256);
    else $display("Success%d %h!!",idx,H_out_256);
    idx=idx+1;
    end

  $display("done");
  $finish;
end

endmodule
