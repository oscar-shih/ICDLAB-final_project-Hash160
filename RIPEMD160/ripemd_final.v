 `include "./ripemd160_1.v"
 `include "./ripemd160_2.v"

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
reg [31:0] a1_r, b1_r, c1_r, d1_r, e1_r;
reg [31:0] a2_r, b2_r, c2_r, d2_r, e2_r;

wire [31:0] h0_w, h1_w, h2_w, h3_w, h4_w;
reg [31:0] h0_r, h1_r, h2_r, h3_r, h4_r;
wire [31:0] h0_1_w, h1_1_w, h2_1_w, h3_1_w, h4_1_w;
wire [31:0] h0_2_w, h1_2_w, h2_2_w, h3_2_w, h4_2_w;
reg [31:0] h0_2_r, h1_2_r, h2_2_r, h3_2_r, h4_2_r;
reg done_r,done_1_r,done_2_r;
wire done_w,done_1_w,done_2_w;
wire done;
reg [159:0]ans_r;
reg [1:0] round;
assign o_valid = done_2_r;

//-------------- Module Instantiation ------------------//
RIPEMD160_stage_1_core ripemd160_right(
    .clk(clk),
    .rst_n(rst_n),
    .i_valid(i_valid),
    .block(block),
    .o_valid(done),
    .ans({a1,b1,c1,d1,e1})
);
RIPEMD160_stage_2_core ripemd160_left(
    .clk(clk),
    .rst_n(rst_n),
    .i_valid(i_valid),
    .block(block),
    .o_valid(done2), //done
    .ans({a2,b2,c2,d2,e2})
);
//-------------- Answer Calculation ------------------//
localparam RIPEMD160_H0 = 32'h67452301;
localparam RIPEMD160_H1 = 32'hefcdab89;
localparam RIPEMD160_H2 = 32'h98badcfe;
localparam RIPEMD160_H3 = 32'h10325476;
localparam RIPEMD160_H4 = 32'hc3d2e1f0;
// assign h0_w  = RIPEMD160_H1 + c1 + d2;
// assign h1_w  = RIPEMD160_H2 + d1 + e2;
// assign h2_w  = RIPEMD160_H3 + e1 + a2;
// assign h3_w  = RIPEMD160_H4 + a1 + b2;
// assign h4_w  = RIPEMD160_H0 + b1 + c2;

//-------------- PIPELINE 1 ------------------//
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        a1_r <=  0;
        b1_r <=  0;
        c1_r <=  0; 
        d1_r <=  0; 
        e1_r <=  0;
        a2_r <=  0;
        b2_r <=  0;
        c2_r <=  0; 
        d2_r <=  0; 
        e2_r <=  0;
        done_r <= 0;
    end
    else begin
            a1_r <=  a1;
            b1_r <=  b1;
            c1_r <=  c1; 
            d1_r <=  d1; 
            e1_r <=  e1;
            a2_r <=  a2;
            b2_r <=  b2;
            c2_r <=  c2; 
            d2_r <=  d2; 
            e2_r <=  e2;
            done_r <= done;
    end
end
//-------------- PIPELINE 2 ------------------//
assign h0_1_w =   c1_r + d2_r;
assign h1_1_w =   d1_r + e2_r;
assign h2_1_w =   e1_r + a2_r;
assign h3_1_w =   a1_r + b2_r;
assign h4_1_w =   b1_r + c2_r;

assign done_1_w = done_r;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        h0_2_r <= 32'b0;
        h1_2_r <= 32'b0;
        h2_2_r <= 32'b0; 
        h3_2_r <= 32'b0; 
        h4_2_r <= 32'b0;
        done_1_r <= 1'b0;
    end
    else begin
        h0_2_r <= h0_1_w;
        h1_2_r <= h1_1_w;
        h2_2_r <= h2_1_w;
        h3_2_r <= h3_1_w;
        h4_2_r <= h4_1_w;
        done_1_r <= done_1_w;
    end
end

//-------------- PIPELINE 3 ------------------//
assign h0_2_w  = h0_2_r + RIPEMD160_H1;
assign h1_2_w  = h1_2_r + RIPEMD160_H2;
assign h2_2_w  = h2_2_r + RIPEMD160_H3;
assign h3_2_w  = h3_2_r + RIPEMD160_H4;
assign h4_2_w  = h4_2_r + RIPEMD160_H0;

assign done_2_w = done_1_r;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        h0_r   <= 32'b0;
        h1_r   <= 32'b0;
        h2_r   <= 32'b0; 
        h3_r   <= 32'b0; 
        h4_r   <= 32'b0;
        done_2_r <= 1'b0;
    end
    else begin
        h0_r <=  h0_2_w ;
        h1_r <=  h1_2_w ;
        h2_r <=  h2_2_w ;
        h3_r <=  h3_2_w ;
        h4_r <=  h4_2_w ;
        done_2_r <= done_2_w;
    end
end

assign ans= {h0_r[7:0],h0_r[15:8],h0_r[23:16],h0_r[31:24],h1_r[7:0],h1_r[15:8],h1_r[23:16],h1_r[31:24]
                ,h2_r[7:0],h2_r[15:8],h2_r[23:16],h2_r[31:24],h3_r[7:0],h3_r[15:8],h3_r[23:16],h3_r[31:24]
                ,h4_r[7:0],h4_r[15:8],h4_r[23:16],h4_r[31:24]};

endmodule