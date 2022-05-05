`include "./ripemd160.v"
`include "./ripemd160_2.v"
`include "./sha256.v"

module top(
    input clk,
    input rst_n,
    input [7:0]  i_text,
    output [159:0] o_answer
);

wire ripemd_valid_w;
wire done;
wire [255:0] H_0_256, H_out;
reg [7:0] i_data_counter_r, i_data_counter_w;
reg [1:0] state_r, state_w;
reg start_calc_r, start_calc_w;
wire [31:0] a1, b1, c1, d1, e1;
wire [31:0] a2, b2, c2, d2, e2;
wire [31:0] h0_w, h1_w, h2_w, h3_w, h4_w;
reg [31:0] h0_r, h1_r, h2_r, h3_r, h4_r;
reg [7:0] input_8x64b[0:63];


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
    .M_in({input_8x64b[0], input_8x64b[1], input_8x64b[2], input_8x64b[3], input_8x64b[4], input_8x64b[5], input_8x64b[6], input_8x64b[7],
           input_8x64b[8], input_8x64b[9], input_8x64b[10], input_8x64b[11], input_8x64b[12], input_8x64b[13], input_8x64b[14], input_8x64b[15],
           input_8x64b[16], input_8x64b[17], input_8x64b[18], input_8x64b[19], input_8x64b[20], input_8x64b[21], input_8x64b[22], input_8x64b[23], 
           input_8x64b[24], input_8x64b[25], input_8x64b[26], input_8x64b[27], input_8x64b[28], input_8x64b[29], input_8x64b[30], input_8x64b[31], 
           input_8x64b[32], input_8x64b[33], input_8x64b[34], input_8x64b[35], input_8x64b[36], input_8x64b[37], input_8x64b[38], input_8x64b[39],
           input_8x64b[40], input_8x64b[41], input_8x64b[42], input_8x64b[43], input_8x64b[44], input_8x64b[45], input_8x64b[46], input_8x64b[47],
           input_8x64b[48], input_8x64b[49], input_8x64b[50], input_8x64b[51], input_8x64b[52], input_8x64b[53], input_8x64b[54], input_8x64b[55],
           input_8x64b[56], input_8x64b[57], input_8x64b[58], input_8x64b[59], input_8x64b[60], input_8x64b[61], input_8x64b[62], input_8x64b[63]}),
    .input_valid(start_calc_r),
    .H_out(H_out),
    .output_valid(ripemd_valid_w)
);

RIPEMD160_stage_1_core ripemd160_right(
    .clk_p_i(clk),
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

always @(*) begin
    start_calc_w = start_calc_r;
    i_data_counter_w = i_data_counter_r;

    case(state_r)
        INIT : begin
            if(i_text != 8'b0) begin
                state_w = GET_DATA;
                start_calc_w = start_calc_r;
                i_data_counter_w = 9'b0;
            end
            else begin
                state_w = state_r;
                start_calc_w = start_calc_r;
            end
        end
        GET_DATA: begin
            if(i_data_counter_r[7] == 1'b1) begin
                state_w = CALCULATION;
                start_calc_w = 1'b1;
            end 
            else begin
                state_w = state_r;
                start_calc_w = start_calc_r;
                i_data_counter_w = i_data_counter_r + 9'b1;
            end
        end
        CALCULATION: begin
            if(done) begin
                state_w = END;
                start_calc_w = start_calc_r;
            end
            else begin
                state_w = state_r;
                start_calc_w = start_calc_r;
            end
        end
        END: begin
            state_w = INIT;
            start_calc_w = start_calc_r;
        end
    endcase
end

////////////////// input(i_text) Logic ///////////////////
always @(*) begin
    if(state_r == GET_DATA && i_data_counter_r[7] != 1'b1) begin
        input_8x64b[i_data_counter_r] = i_text;
    end
end


////////////////// Sequential Part ///////////////////
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state_r <= INIT;
        i_data_counter_r <= 7'b0;
        start_calc_r <= 1'b0;
        h0_r <= 32'b0;
        h1_r <= 32'b0;
        h2_r <= 32'b0; 
        h3_r <= 32'b0; 
        h4_r <= 32'b0;
    end
    else begin
        state_r <= state_w;
        i_data_counter_r <= i_data_counter_w;
        start_calc_r <= start_calc_w;
        h0_r <= h0_w;
        h1_r <= h1_w;
        h2_r <= h2_w; 
        h3_r <= h3_w; 
        h4_r <= h4_w;
    end
end


endmodule