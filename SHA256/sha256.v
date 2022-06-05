module sha256(
    input clk,
    input rst_n,
    //input [255:0] H_in,
    input [511:0] M_in,
    input input_valid,
    output [255:0] H_out,
    output output_valid
    );

reg [6:0] round;
reg [6:0] round_w;
reg input_ready_r;
reg input_ready_w;
reg output_valid_r;

wire [31:0] a_in,b_in,c_in,d_in,e_in,f_in,g_in,h_in;
wire [255:0] H_in;

assign H_in = {
        32'h6A09E667, 32'hBB67AE85, 32'h3C6EF372, 32'hA54FF53A,
        32'h510E527F, 32'h9B05688C, 32'h1F83D9AB, 32'h5BE0CD19
};
assign a_in = H_in[255:224];
assign b_in = H_in[223:192];
assign c_in = H_in[191:160];
assign d_in = H_in[159:128];
assign e_in = H_in[127:96 ];
assign f_in = H_in[95 :64 ];
assign g_in = H_in[63 :32 ];
assign h_in = H_in[31 :0  ];
reg  [31:0] a_q, b_q, c_q, d_q, e_q, f_q, g_q, h_q;
wire [31:0] a_d, b_d, c_d, d_d, e_d, f_d, g_d, h_d;
wire [31:0] W_tm2, W_tm15, s1_Wtm2, s0_Wtm15, Wj, Kj;
reg [32:0] a,b,c,d,e,f,g,h;
assign H_out = {a[31:0], b[31:0], c[31:0], d[31:0], e[31:0], f[31:0], g[31:0], h[31:0]};
assign output_valid = output_valid_r;
sha256_s0 sha256_s0 (.x(W_tm15), .s0(s0_Wtm15));
sha256_s1 sha256_s1 (.x(W_tm2), .s1(s1_Wtm2));
//64 k constants output by sequence ->Kj
sha256_K sha256_K (.clk(clk), .rst_n(rst_n), .input_valid(input_ready_r), .K(Kj));
//Wj
sha256_W sha256_W(
    .clk(clk),
    .rst_n(rst_n),
    .M(M_in), .M_valid(input_ready_r),
    .W_tm2(W_tm2), .W_tm15(W_tm15),
    .s1_Wtm2(s1_Wtm2), .s0_Wtm15(s0_Wtm15),
    .W(Wj)
);
//main block
sha256_main sha256_main (
    .Kj(Kj), .Wj(Wj),
    .a_in(a_q), .b_in(b_q), .c_in(c_q), .d_in(d_q),
    .e_in(e_q), .f_in(f_q), .g_in(g_q), .h_in(h_q),
    .a_out(a_d), .b_out(b_d), .c_out(c_d), .d_out(d_d),
    .e_out(e_d), .f_out(f_d), .g_out(g_d), .h_out(h_d)
);
always @(*) begin 
    round_w = round + 9'b1;
    if(round==65) output_valid_r=1;
    else output_valid_r=0;
end


always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n) begin
            a_q <= 0; b_q <= 0; c_q <= 0; d_q <= 0;
            e_q <= 0; f_q <= 0; g_q <= 0; h_q <= 0;
            round <= 7'b0;
        end
        else begin
            if (!input_ready_r) begin
                a_q <= a_in; b_q <= b_in; c_q <= c_in; d_q <= d_in;
                e_q <= e_in; f_q <= f_in; g_q <= g_in; h_q <= h_in;
                round <= 7'b0;
            end 
            else begin
                a_q <= a_d; b_q <= b_d; c_q <= c_d; d_q <= d_d;
                e_q <= e_d; f_q <= f_d; g_q <= g_d; h_q <= h_d;
                round <= round_w;
            end
        end
end
always @(*)
    begin
        if (input_valid==1'b1) begin
            input_ready_w = 1'b1;
        end 
        else begin
            input_ready_w = input_ready_r;
        end
end
always @(posedge clk or negedge rst_n)
    begin
    if(!rst_n) begin
        input_ready_r <= 0;
    end
    else begin
        input_ready_r <= input_ready_w;
    end
end

always @(posedge clk or negedge rst_n)
begin
if(!rst_n) begin
    a<=0;
    b<=0;
    c<=0;
    d<=0;
    e<=0;
    f<=0;
    g<=0;
    h<=0; 
end
else begin
    a<=a_in+a_q;
    b<=b_in+b_q;
    c<=c_in+c_q;
    d<=d_in+d_q;
    e<=e_in+e_q;
    f<=f_in+f_q;
    g<=g_in+g_q;
    h<=h_in+h_q; 
end
end


endmodule


// round compression function
module sha256_main (
    input [31:0] Kj, Wj,
    input [31:0] a_in, b_in, c_in, d_in, e_in, f_in, g_in, h_in,
    output [31:0] a_out, b_out, c_out, d_out, e_out, f_out, g_out, h_out
    );
    reg [31:0] a_out_r, b_out_r, c_out_r, d_out_r, e_out_r, f_out_r, g_out_r, h_out_r;
    wire [31:0] Ch_e_f_g, Maj_a_b_c, S0_a, S1_e;
    reg [32-1:0] T1;
    reg [32-1:0] T2 ;
//-----------------------main function---------------------------
//---------------------------------------------------------------
    Ch Ch (.x(e_in), .y(f_in), .z(g_in), .Ch(Ch_e_f_g));
    Maj  Maj (.x(a_in), .y(b_in), .z(c_in), .Maj(Maj_a_b_c));
    sha256_S0 S0 (.x(a_in), .S0(S0_a));
    sha256_S1 S1 (.x(e_in), .S1(S1_e));
    assign a_out=a_out_r;
    assign b_out=b_out_r;
    assign c_out=c_out_r;
    assign d_out=d_out_r;
    assign e_out=e_out_r;
    assign f_out=f_out_r;
    assign g_out=g_out_r;
    assign h_out=h_out_r;
    always @(*) begin
//----------------------------------------------------------------
    T1 = h_in + S1_e + Ch_e_f_g + Kj + Wj;
   T2= S0_a + Maj_a_b_c;
//-----------------------------------------------------------------
     a_out_r = T1 + T2;
     b_out_r = a_in;
     c_out_r = b_in;
     d_out_r = c_in;
     e_out_r = d_in + T1;
     f_out_r = e_in;
     g_out_r = f_in;
    h_out_r = g_in;
    end

endmodule
//--------------------sub model------------------------
//--------------------------------------------------------------------------------------
module sha256_S0 (input wire [31:0] x,output wire [31:0] S0);

    assign S0 = ({x[1:0], x[31:2]} ^ {x[12:0], x[31:13]} ^ {x[21:0], x[31:22]});

endmodule

module sha256_S1 (input wire [31:0] x,output wire [31:0] S1);

    assign S1 = ({x[5:0], x[31:6]} ^ {x[10:0], x[31:11]} ^ {x[24:0], x[31:25]});

endmodule

module sha256_s0 (input wire [31:0] x,output wire [31:0] s0);

    assign s0 = ({x[6:0], x[31:7]} ^ {x[17:0], x[31:18]} ^ (x >> 3));

endmodule


module sha256_s1 (input wire [31:0] x,output wire [31:0] s1);

    assign s1 = ({x[16:0], x[31:17]} ^ {x[18:0], x[31:19]} ^ (x >> 10));

endmodule
// Ch(x,y,z)
module Ch(input wire [32-1:0] x, y, z,output wire [32-1:0] Ch);

    assign Ch = ((x & y) ^ (~x & z));

endmodule
// Maj(x,y,z)
module Maj (input wire [32-1:0] x, y, z,output wire [32-1:0] Maj);

    assign Maj = (x & y) ^ (x & z) ^ (y & z);

endmodule
//----------------------------------------------------------------------------------------

//output one K by sequence
//---------------------------------------------------------------------------
module sha256_K (input clk , input rst_n, input input_valid ,output [31:0] K);
    reg [2047:0] rom_q;
    wire [2047:0] rom_d;
    reg  [31:0] K_p;
    assign rom_d = {rom_q[2015:0],32'b0};
    assign K =  K_p ;
    wire [2047:0] rom;
    assign rom= {
        32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5,
        32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
        32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3,
        32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
        32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc,
        32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
        32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7,
        32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
        32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13,
        32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
        32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3,
        32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
        32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5,
        32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
        32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208,
        32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2
    };

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n) begin
        rom_q <= 0;
        K_p   <= 0;
    end
    else begin
       if (input_valid) begin
            
            rom_q <= rom_d;
            K_p   <= rom_d[2047:2016];
        end 
        else begin
            rom_q <= rom;
            K_p   <= rom[2047:2016];
           
        end 
    end
end
endmodule
//------------------------------------------------------------------------------------------------

// module sha256_H_0(output [255:0] H_0);
//     assign H_0 = {
//         32'h6A09E667, 32'hBB67AE85, 32'h3C6EF372, 32'hA54FF53A,
//         32'h510E527F, 32'h9B05688C, 32'h1F83D9AB, 32'h5BE0CD19
//     };
// endmodule



//-=-=-=-=-=-=-=--=-=-=-=-=-==-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
// the message schedule: a machine that generates Wt values
module sha256_W(
    input clk,
    input rst_n,
    input [32*16-1:0] M,
    input M_valid,
    output [32-1:0] W_tm2, W_tm15,
    input [32-1:0] s1_Wtm2, s0_Wtm15,
    output [32-1:0] W
    );
    reg [31:0] W_r,W_tm2_r,W_tm15_r;
    reg [32*16-1:0] W_stack_q;
    reg [32-1:0] W_p;
    reg [32*16-1:0] W_stack_d ;
    reg valid;
    reg [32-1:0] Wt_next;
    reg [32-1:0] W_tm7;
    reg [32-1:0] W_tm16;
assign W=W_p;
assign W_tm2=W_tm2_r;
assign W_tm15=W_tm15_r;

always @(*) begin
    W_tm2_r = W_stack_q[32*2-1:32*1];
    W_tm7 = W_stack_q[32*7-1:32*6];
     W_tm15_r = W_stack_q[32*15-1:32*14];
    // Wt_next is the next Wt to be pushed to the queue, will be consumed in 16 rounds
    Wt_next = s1_Wtm2 + W_tm7 + s0_Wtm15 + W_stack_q[32*16-1:32*15];
    W_stack_d= {W_stack_q[32*15-1:0], Wt_next};

end
always @(posedge clk)
begin
    // if(!rst_n) begin
    //     W_stack_q <= 0;
    //     W_p <= 0;
    // end
    // else begin
        if (M_valid)
        begin  
            W_stack_q <= W_stack_d;
            W_p <= W_stack_d[32*16-1:32*15];
        end     
        else 
        begin
            W_stack_q <= M;
            W_p <= M [32*16-1:32*15];
            
        end
   // end
end
endmodule