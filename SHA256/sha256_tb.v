module testbed;

reg input_valid = 0;

wire output_valid_256;
integer idx=0;
wire [255:0] H_0_256, H_out_256;
sha256_H_0 sha256_H_0 (.H_0(H_0_256));
reg [511:0] M_sha256_abc_r [0:99];
reg [511:0] M_sha256_abc  ;
sha256_block sha256_block (
    .clk(clk), .rst(rst),
    .H_in(H_0_256), .M_in(M_sha256_abc),
    .input_valid(input_valid),
    .H_out(H_out_256),
    .output_valid(output_valid_256)
);

// wire output_valid_512;
// wire [511:0] H_0_512, H_out_512;
// sha512_H_0 sha512_H_0 (.H_0(H_0_512));
// sha512_block sha512_block (
//     .clk(clk), .rst(rst),
//     .H_in(H_0_512), .M_in(M_sha512_abc),
//     .input_valid(input_valid),
//     .H_out(H_out_512),
//     .output_valid(output_valid_512)
//);


// the "abc" test vector, padded
// wire [511:0] M_sha256_abc = 
//   512'b00110001001100000011000000110000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000;
//  {
//   256'h6162638000000000000000000000000000000000000000000000000000000000,
//   256'h0000000000000000000000000000000000000000000000000000000000000018
// };

// the "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq" test vector, padded
// wire [1023:0] M_sha256_2block = {
//   256'h6162636462636465636465666465666765666768666768696768696A68696A6B,
//   256'h696A6B6C6A6B6C6D6B6C6D6E6C6D6E6F6D6E6F706E6F70718000000000000000,
//   256'h0000000000000000000000000000000000000000000000000000000000000000,
//   256'h00000000000000000000000000000000000000000000000000000000000001C0
// };
// wire [511:0] M_sha256_2block_a = M_sha256_2block[1023:512];
// wire [511:0] M_sha256_2block_b = M_sha256_2block[511:0];

// // a null message
// wire [511:0] M_sha256_null = {
//   256'h8000000000000000000000000000000000000000000000000000000000000000,
//   256'h0000000000000000000000000000000000000000000000000000000000000000
// };
// reg [255:0] temp[0:99];
// reg [255:0] temp[0:99];
reg [255:0]test[0:99];//=256'h6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b;
// wire [1023:0] M_sha512_null = {
//   256'h8000000000000000000000000000000000000000000000000000000000000000,
//   256'h0000000000000000000000000000000000000000000000000000000000000000,
//   256'h0000000000000000000000000000000000000000000000000000000000000000,
//   256'h0000000000000000000000000000000000000000000000000000000000000000
// };


// driver

reg [31:0] ticks = 0;
reg clk = 1'b0;
reg rst = 1'b0;

initial begin
  $readmemb("256input.txt",M_sha256_abc_r);
  $readmemh("256output.txt",test);
  $display("starting");
  repeat(100)  begin
  tick;
  input_valid = 1'b1;
  tick;
  input_valid = 1'b0;
  repeat (90) begin
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
  if(H_out_256===test[idx])
  begin
    $display("MASTER");
  end
  if(output_valid_256===1)
  begin
   //$display("%b %d %h", input_valid, ticks, ticks);
    //$display("SUCCESS");
    //$display("%h", M_sha256_abc_r[idx]);
    $display("%b %h", output_valid_256, H_out_256);
  end
  //$display("%b %h", output_valid_512, H_out_512);
end
endtask

endmodule