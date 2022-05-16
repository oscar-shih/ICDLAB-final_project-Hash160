`include "./RIPEMD160/ripemd160.v"
`include "./RIPEMD160/ripemd160_2.v"

module ripemd_final(
                   input wire            clk,
                   input wire            rst_n,
                   input wire            i_valid,
                   input wire [511 : 0]  block,

                   output wire           o_valid,
                   output wire [159 : 0] ans
                  );

wire [31:0] a1, b1, c1, d1, e1;
wire [31:0] a2, b2, c2, d2, e2;
wire [31:0] h0_w, h1_w, h2_w, h3_w, h4_w;
reg [31:0] h0_r, h1_r, h2_r, h3_r, h4_r;

reg done_r;
wire done;

assign o_valid = done_r;

RIPEMD160_stage_1_core ripemd160_right(
    .clk(clk),
    .rst_n(rst_n),
    .i_valid(i_valid),
    .block({block}),
    .o_valid(done),
    .ans({a1,b1,c1,d1,e1})
);

RIPEMD160_stage_2_core ripemd160_left(
    .clk(clk),
    .rst_n(rst_n),
    .i_valid(i_valid),
    .block({block}),
    .o_valid(), //done
    .ans({a2,b2,c2,d2,e2})
);

///////// Answer Calculation ////////
localparam RIPEMD160_H0 = 32'h67452301;
localparam RIPEMD160_H1 = 32'hefcdab89;
localparam RIPEMD160_H2 = 32'h98badcfe;
localparam RIPEMD160_H3 = 32'h10325476;
localparam RIPEMD160_H4 = 32'hc3d2e1f0;

assign h0_w = RIPEMD160_H1 + c1 + d2;
assign h1_w = RIPEMD160_H2 + d1 + e2;
assign h2_w = RIPEMD160_H3 + e1 + a2;
assign h3_w = RIPEMD160_H4 + a1 + b2;
assign h4_w = RIPEMD160_H0 + b1 + c2;
assign ans = {h0_r[7:0],h0_r[15:8],h0_r[23:16],h0_r[31:24],h1_r[7:0],h1_r[15:8],h1_r[23:16],h1_r[31:24]
,h2_r[7:0],h2_r[15:8],h2_r[23:16],h2_r[31:24],h3_r[7:0],h3_r[15:8],h3_r[23:16],h3_r[31:24]
,h4_r[7:0],h4_r[15:8],h4_r[23:16],h4_r[31:24]};



always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        h0_r <= 32'b0;
        h1_r <= 32'b0;
        h2_r <= 32'b0; 
        h3_r <= 32'b0; 
        h4_r <= 32'b0;
        done_r <= 0;
    end
    else begin
        h0_r <= h0_w;
        h1_r <= h1_w;
        h2_r <= h2_w; 
        h3_r <= h3_w; 
        h4_r <= h4_w;
        done_r <= done;
    end
end
endmodule
