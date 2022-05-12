`include "./ripemd160.v"
`include "./ripemd160_2.v"
`include "./sha256.v"

module top(
    input clk,
    input rst_n,
    input [7:0]  i_text,
    output   o_valid,
    output [159:0] o_answer
);

wire ripemd_valid_w;
reg ripemd_valid_r;
wire done;
wire [255:0] H_0_256, H_out;
reg [7:0] i_data_counter_r, i_data_counter_w;
reg [1:0] state_r, state_w;
reg start_calc_r, start_calc_w;
wire [31:0] a1, b1, c1, d1, e1;
wire [31:0] a2, b2, c2, d2, e2;
wire [31:0] h0_w, h1_w, h2_w, h3_w, h4_w;
reg [31:0] h0_r, h1_r, h2_r, h3_r, h4_r;
reg [7:0] input_8x64b_r[0:63];
reg [7:0] input_8x64b_w[0:63];

reg [7:0] i_text_r;
reg [10:0] counter_r, counter_w;

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
assign o_answer = {h0_r, h1_r, h2_r, h3_r, h4_r};



///////// Module instantiation ////////
sha256_H_0 sha256_H_0 (.H_0(H_0_256));

sha256 sha(
    .clk(clk),
    .H_in(H_0_256),
    .M_in({input_8x64b_r[0], input_8x64b_r[1], input_8x64b_r[2], input_8x64b_r[3], input_8x64b_r[4], input_8x64b_r[5], input_8x64b_r[6], input_8x64b_r[7],
           input_8x64b_r[8], input_8x64b_r[9], input_8x64b_r[10], input_8x64b_r[11], input_8x64b_r[12], input_8x64b_r[13], input_8x64b_r[14], input_8x64b_r[15],
           input_8x64b_r[16], input_8x64b_r[17], input_8x64b_r[18], input_8x64b_r[19], input_8x64b_r[20], input_8x64b_r[21], input_8x64b_r[22], input_8x64b_r[23], 
           input_8x64b_r[24], input_8x64b_r[25], input_8x64b_r[26], input_8x64b_r[27], input_8x64b_r[28], input_8x64b_r[29], input_8x64b_r[30], input_8x64b_r[31], 
           input_8x64b_r[32], input_8x64b_r[33], input_8x64b_r[34], input_8x64b_r[35], input_8x64b_r[36], input_8x64b_r[37], input_8x64b_r[38], input_8x64b_r[39],
           input_8x64b_r[40], input_8x64b_r[41], input_8x64b_r[42], input_8x64b_r[43], input_8x64b_r[44], input_8x64b_r[45], input_8x64b_r[46], input_8x64b_r[47],
           input_8x64b_r[48], input_8x64b_r[49], input_8x64b_r[50], input_8x64b_r[51], input_8x64b_r[52], input_8x64b_r[53], input_8x64b_r[54], input_8x64b_r[55],
           input_8x64b_r[56], input_8x64b_r[57], input_8x64b_r[58], input_8x64b_r[59], input_8x64b_r[60], input_8x64b_r[61], input_8x64b_r[62], input_8x64b_r[63]}),
    .input_valid(start_calc_r),
    .H_out(H_out),
    .output_valid(ripemd_valid_w)
);

RIPEMD160_stage_1_core ripemd160_right(
    .clk(clk),
    .rst_n(rst_n),
    .i_valid(ripemd_valid_w),
    .block({256'b0,H_out}),
    .o_valid(done),
    .ans({a1,b1,c1,d1,e1})
);

RIPEMD160_stage_2_core ripemd160_left(
    .clk(clk),
    .rst_n(rst_n),
    .i_valid(ripemd_valid_w),
    .block({256'b0,H_out}),
    .o_valid(), //done
    .ans({a2,b2,c2,d2,e2})
);


////////////////// FSM LOGIC ///////////////////
parameter INIT = 2'b00;
parameter GET_DATA = 2'b01;
parameter CALCULATION = 2'b10;
parameter END = 2'b11;

assign o_valid = (state_r == END) ? 1'b1 : 1'b0;

always @(*) begin
    start_calc_w = start_calc_r;
    i_data_counter_w = i_data_counter_r;
    counter_w = counter_r;

    case(state_r)
        INIT : begin
            if(i_text_r != 8'b0) begin
                state_w = GET_DATA;
                start_calc_w = start_calc_r;
                i_data_counter_w = 9'b0;
                $display("Start input.");
            end
            else begin
                state_w = state_r;
                start_calc_w = start_calc_r;
            end
        end
        GET_DATA: begin
            if(i_data_counter_r[6] == 1 && i_data_counter_r[0] == 1) begin
                state_w = CALCULATION;
                start_calc_w = 1'b1;
                $display("Start Calculation.");
            end 
            else begin
                state_w = state_r;
                start_calc_w = start_calc_r;
                i_data_counter_w = i_data_counter_r + 9'b1;
            end
        end
        CALCULATION: begin
            counter_w = counter_r + 1;
            if(done) begin
                state_w = END;
                start_calc_w = 1'b0;
                $display("DONE.");
            end
            else begin
                state_w = state_r;
                start_calc_w = 1'b0;
                // $display("ripemd_valid_w = ", ripemd_valid_w);
            end
        end
        END: begin
            state_w = END;
            // $display("H0 = %h", H_out);
            start_calc_w = start_calc_r;
        end
    endcase
end

////////////////// input(i_text) Logic ///////////////////
always @(*) begin
        input_8x64b_w[ 0] = input_8x64b_r[ 0];
        input_8x64b_w[ 1] = input_8x64b_r[ 1];
        input_8x64b_w[ 2] = input_8x64b_r[ 2];
        input_8x64b_w[ 3] = input_8x64b_r[ 3];
        input_8x64b_w[ 4] = input_8x64b_r[ 4];
        input_8x64b_w[ 5] = input_8x64b_r[ 5];
        input_8x64b_w[ 6] = input_8x64b_r[ 6];
        input_8x64b_w[ 7] = input_8x64b_r[ 7];
        input_8x64b_w[ 8] = input_8x64b_r[ 8];
        input_8x64b_w[ 9] = input_8x64b_r[ 9];
        input_8x64b_w[10] = input_8x64b_r[10];
        input_8x64b_w[11] = input_8x64b_r[11];
        input_8x64b_w[12] = input_8x64b_r[12];
        input_8x64b_w[13] = input_8x64b_r[13];
        input_8x64b_w[14] = input_8x64b_r[14];
        input_8x64b_w[15] = input_8x64b_r[15];
        input_8x64b_w[16] = input_8x64b_r[16];
        input_8x64b_w[17] = input_8x64b_r[17];
        input_8x64b_w[18] = input_8x64b_r[18];
        input_8x64b_w[19] = input_8x64b_r[19];
        input_8x64b_w[20] = input_8x64b_r[20];
        input_8x64b_w[21] = input_8x64b_r[21];
        input_8x64b_w[22] = input_8x64b_r[22];
        input_8x64b_w[23] = input_8x64b_r[23];
        input_8x64b_w[24] = input_8x64b_r[24];
        input_8x64b_w[25] = input_8x64b_r[25];
        input_8x64b_w[26] = input_8x64b_r[26];
        input_8x64b_w[27] = input_8x64b_r[27];
        input_8x64b_w[28] = input_8x64b_r[28];
        input_8x64b_w[29] = input_8x64b_r[29];
        input_8x64b_w[30] = input_8x64b_r[30];
        input_8x64b_w[31] = input_8x64b_r[31];
        input_8x64b_w[32] = input_8x64b_r[32];
        input_8x64b_w[33] = input_8x64b_r[33];
        input_8x64b_w[34] = input_8x64b_r[34];
        input_8x64b_w[35] = input_8x64b_r[35];
        input_8x64b_w[36] = input_8x64b_r[36];
        input_8x64b_w[37] = input_8x64b_r[37];
        input_8x64b_w[38] = input_8x64b_r[38];
        input_8x64b_w[39] = input_8x64b_r[39];
        input_8x64b_w[40] = input_8x64b_r[40];
        input_8x64b_w[41] = input_8x64b_r[41];
        input_8x64b_w[42] = input_8x64b_r[42];
        input_8x64b_w[43] = input_8x64b_r[43];
        input_8x64b_w[44] = input_8x64b_r[44];
        input_8x64b_w[45] = input_8x64b_r[45];
        input_8x64b_w[46] = input_8x64b_r[46];
        input_8x64b_w[47] = input_8x64b_r[47];
        input_8x64b_w[48] = input_8x64b_r[48];
        input_8x64b_w[49] = input_8x64b_r[49];
        input_8x64b_w[50] = input_8x64b_r[50];
        input_8x64b_w[51] = input_8x64b_r[51];
        input_8x64b_w[52] = input_8x64b_r[52];
        input_8x64b_w[53] = input_8x64b_r[53];
        input_8x64b_w[54] = input_8x64b_r[54];
        input_8x64b_w[55] = input_8x64b_r[55];
        input_8x64b_w[56] = input_8x64b_r[56];
        input_8x64b_w[57] = input_8x64b_r[57];
        input_8x64b_w[58] = input_8x64b_r[58];
        input_8x64b_w[59] = input_8x64b_r[59];
        input_8x64b_w[60] = input_8x64b_r[60];
        input_8x64b_w[61] = input_8x64b_r[61];
        input_8x64b_w[62] = input_8x64b_r[62];
        input_8x64b_w[63] = input_8x64b_r[63];

    if(state_r == GET_DATA && i_data_counter_r < 65) begin
        input_8x64b_w[i_data_counter_r] = i_text_r;
        // $display(i_text);
    end
end


////////////////// Sequential Part ///////////////////
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        i_text_r <= 0;
        counter_r <= 0;
        state_r <= INIT;
        // ripemd_valid_r <= 0;
        i_data_counter_r <= 7'b0;
        start_calc_r <= 1'b0;
        h0_r <= 32'b0;
        h1_r <= 32'b0;
        h2_r <= 32'b0; 
        h3_r <= 32'b0; 
        h4_r <= 32'b0;
        input_8x64b_r[0] <= 8'b0;
        input_8x64b_r[1] <= 8'b0;
        input_8x64b_r[2] <= 8'b0;
        input_8x64b_r[3] <= 8'b0;
        input_8x64b_r[4] <= 8'b0;
        input_8x64b_r[5] <= 8'b0;
        input_8x64b_r[6] <= 8'b0;
        input_8x64b_r[7] <= 8'b0;
        input_8x64b_r[8] <= 8'b0;
        input_8x64b_r[9] <= 8'b0;
        input_8x64b_r[10] <= 8'b0;
        input_8x64b_r[11] <= 8'b0;
        input_8x64b_r[12] <= 8'b0;
        input_8x64b_r[13] <= 8'b0;
        input_8x64b_r[14] <= 8'b0;
        input_8x64b_r[15] <= 8'b0;
        input_8x64b_r[16] <= 8'b0;
        input_8x64b_r[17] <= 8'b0;
        input_8x64b_r[18] <= 8'b0;
        input_8x64b_r[19] <= 8'b0;
        input_8x64b_r[20] <= 8'b0;
        input_8x64b_r[21] <= 8'b0;
        input_8x64b_r[22] <= 8'b0;
        input_8x64b_r[23] <= 8'b0;
        input_8x64b_r[24] <= 8'b0;
        input_8x64b_r[25] <= 8'b0;
        input_8x64b_r[26] <= 8'b0;
        input_8x64b_r[27] <= 8'b0;
        input_8x64b_r[28] <= 8'b0;
        input_8x64b_r[29] <= 8'b0;
        input_8x64b_r[30] <= 8'b0;
        input_8x64b_r[31] <= 8'b0;
        input_8x64b_r[32] <= 8'b0;
        input_8x64b_r[33] <= 8'b0;
        input_8x64b_r[34] <= 8'b0;
        input_8x64b_r[35] <= 8'b0;
        input_8x64b_r[36] <= 8'b0;
        input_8x64b_r[37] <= 8'b0;
        input_8x64b_r[38] <= 8'b0;
        input_8x64b_r[39] <= 8'b0;
        input_8x64b_r[40] <= 8'b0;
        input_8x64b_r[41] <= 8'b0;
        input_8x64b_r[42] <= 8'b0;
        input_8x64b_r[43] <= 8'b0;
        input_8x64b_r[44] <= 8'b0;
        input_8x64b_r[45] <= 8'b0;
        input_8x64b_r[46] <= 8'b0;
        input_8x64b_r[47] <= 8'b0;
        input_8x64b_r[48] <= 8'b0;
        input_8x64b_r[49] <= 8'b0;
        input_8x64b_r[50] <= 8'b0;
        input_8x64b_r[51] <= 8'b0;
        input_8x64b_r[52] <= 8'b0;
        input_8x64b_r[53] <= 8'b0;
        input_8x64b_r[54] <= 8'b0;
        input_8x64b_r[55] <= 8'b0;
        input_8x64b_r[56] <= 8'b0;
        input_8x64b_r[57] <= 8'b0;
        input_8x64b_r[58] <= 8'b0;
        input_8x64b_r[59] <= 8'b0;
        input_8x64b_r[60] <= 8'b0;
        input_8x64b_r[61] <= 8'b0;
        input_8x64b_r[62] <= 8'b0;
        input_8x64b_r[63] <= 8'b0;
    end
    else begin
        i_text_r <= i_text;
        counter_r <= counter_w;
        state_r <= state_w;
        // ripemd_valid_r <= ripemd_valid_w;
        i_data_counter_r <= i_data_counter_w;
        start_calc_r <= start_calc_w;
        h0_r <= h0_w;
        h1_r <= h1_w;
        h2_r <= h2_w; 
        h3_r <= h3_w; 
        h4_r <= h4_w;
        input_8x64b_r[0] <= input_8x64b_w[0];
        input_8x64b_r[1] <= input_8x64b_w[1];
        input_8x64b_r[2] <= input_8x64b_w[2];
        input_8x64b_r[3] <= input_8x64b_w[3];
        input_8x64b_r[4] <= input_8x64b_w[4];
        input_8x64b_r[5] <= input_8x64b_w[5];
        input_8x64b_r[6] <= input_8x64b_w[6];
        input_8x64b_r[7] <= input_8x64b_w[7];
        input_8x64b_r[8] <= input_8x64b_w[8];
        input_8x64b_r[9] <= input_8x64b_w[9];
        input_8x64b_r[10] <= input_8x64b_w[10];
        input_8x64b_r[11] <= input_8x64b_w[11];
        input_8x64b_r[12] <= input_8x64b_w[12];
        input_8x64b_r[13] <= input_8x64b_w[13];
        input_8x64b_r[14] <= input_8x64b_w[14];
        input_8x64b_r[15] <= input_8x64b_w[15];
        input_8x64b_r[16] <= input_8x64b_w[16];
        input_8x64b_r[17] <= input_8x64b_w[17];
        input_8x64b_r[18] <= input_8x64b_w[18];
        input_8x64b_r[19] <= input_8x64b_w[19];
        input_8x64b_r[20] <= input_8x64b_w[20];
        input_8x64b_r[21] <= input_8x64b_w[21];
        input_8x64b_r[22] <= input_8x64b_w[22];
        input_8x64b_r[23] <= input_8x64b_w[23];
        input_8x64b_r[24] <= input_8x64b_w[24];
        input_8x64b_r[25] <= input_8x64b_w[25];
        input_8x64b_r[26] <= input_8x64b_w[26];
        input_8x64b_r[27] <= input_8x64b_w[27];
        input_8x64b_r[28] <= input_8x64b_w[28];
        input_8x64b_r[29] <= input_8x64b_w[29];
        input_8x64b_r[30] <= input_8x64b_w[30];
        input_8x64b_r[31] <= input_8x64b_w[31];
        input_8x64b_r[32] <= input_8x64b_w[32];
        input_8x64b_r[33] <= input_8x64b_w[33];
        input_8x64b_r[34] <= input_8x64b_w[34];
        input_8x64b_r[35] <= input_8x64b_w[35];
        input_8x64b_r[36] <= input_8x64b_w[36];
        input_8x64b_r[37] <= input_8x64b_w[37];
        input_8x64b_r[38] <= input_8x64b_w[38];
        input_8x64b_r[39] <= input_8x64b_w[39];
        input_8x64b_r[40] <= input_8x64b_w[40];
        input_8x64b_r[41] <= input_8x64b_w[41];
        input_8x64b_r[42] <= input_8x64b_w[42];
        input_8x64b_r[43] <= input_8x64b_w[43];
        input_8x64b_r[44] <= input_8x64b_w[44];
        input_8x64b_r[45] <= input_8x64b_w[45];
        input_8x64b_r[46] <= input_8x64b_w[46];
        input_8x64b_r[47] <= input_8x64b_w[47];
        input_8x64b_r[48] <= input_8x64b_w[48];
        input_8x64b_r[49] <= input_8x64b_w[49];
        input_8x64b_r[50] <= input_8x64b_w[50];
        input_8x64b_r[51] <= input_8x64b_w[51];
        input_8x64b_r[52] <= input_8x64b_w[52];
        input_8x64b_r[53] <= input_8x64b_w[53];
        input_8x64b_r[54] <= input_8x64b_w[54];
        input_8x64b_r[55] <= input_8x64b_w[55];
        input_8x64b_r[56] <= input_8x64b_w[56];
        input_8x64b_r[57] <= input_8x64b_w[57];
        input_8x64b_r[58] <= input_8x64b_w[58];
        input_8x64b_r[59] <= input_8x64b_w[59];
        input_8x64b_r[60] <= input_8x64b_w[60];
        input_8x64b_r[61] <= input_8x64b_w[61];
        input_8x64b_r[62] <= input_8x64b_w[62];
        input_8x64b_r[63] <= input_8x64b_w[63];
    end
end


endmodule