`timescale  1ns / 100ps
`define CLCYE_TIME 10.0
module sha256_tb;

reg input_valid = 0;

wire output_valid_256;
integer idx=0;
wire [255:0] H_0_256, H_out_256;
reg [255:0]test[0:99];
reg [255:0]t;
reg [31:0] ticks = 0;
reg clk ;
sha256_H_0 sha256_H_0 (.H_0(H_0_256));
reg [511:0] M_sha256_abc_r [0:99];
reg [511:0] M_sha256_abc  ;
sha256 sha256 (
    .clk(clk),
    .H_in(H_0_256), .M_in(M_sha256_abc),
    .input_valid(input_valid),
    .H_out(H_out_256),
    .output_valid(output_valid_256)
);

initial begin
  $readmemb("256input.txt",M_sha256_abc_r);
  $readmemh("256output.txt",test);
  $display("starting");
  repeat(100)  begin
  tick;
  input_valid = 1'b1;
  tick;
  input_valid = 1'b0;
  tick;
  repeat (89) begin
      tick;
  end
  idx=idx+1;
  end
  $display("done");
  $finish;
end

task tick;
begin
  #1;
  ticks = ticks + 1;
  clk = 1;
  #1;
  clk = 0;
  dumpstate;
end
endtask

task dumpstate;
begin
  M_sha256_abc=M_sha256_abc_r[idx];
  if(output_valid_256===1'b1)
  begin
  if(H_out_256===test[idx])
  begin
    $display("MASTER %d" ,ticks/92);
    $display("output_valid %d",output_valid_256);
    $display("golden=%64h",  test[idx]);
    $display("-------------------------------------------------------------------------------------------");
  end
  else
  begin
    $display("FAIL %d" ,ticks/92);
    $display("output_valid %d",output_valid_256);
    $display("result=%h",  H_out_256);
    $display("golden=%64h",  test[idx]);
    t=test[idx] ^ H_out_256;
    $display(" wrong=%h",  t);
    $display("-------------------------------------------------------------------------------------------");
  end
end
 
end
endtask

endmodule
