
`include "./ripemd_final.v"
`include "./sha256.v"

module top(
    input clk,
    input rst_n,
    input i_valid,
    input [7:0]  i_text,
    output   o_valid,
    output [15:0] o_answer
);

wire ripemd_valid_w;
wire done_calculation;
wire [255:0] H_0_256, H_out;
reg [6:0] i_data_counter_r, i_data_counter_w;
reg [2:0] state_r, state_w;
reg start_calc_r, start_calc_w;
wire [31:0] a1, b1, c1, d1, e1;
wire [31:0] a2, b2, c2, d2, e2;
wire [31:0] h0_w, h1_w, h2_w, h3_w, h4_w;
reg [31:0] h0_r, h1_r, h2_r, h3_r, h4_r;

reg [3:0] output_ctr, output_ctr_w;
// wire [2:0] output_ctr_w;
reg [7:0] i_text_r;
reg  [511:0] input_512_w;
reg  [511:0] input_512_r;

wire [159:0] answer_w;
reg [159:0] shift_ans_w,shift_ans_r;
reg [159:0] answer_r;
reg [31:0] o_answer_r, o_answer_w;

///////// Module instantiation ////////

sha256 sha(
    .clk(clk),
    .rst_n(rst_n),
    .M_in(input_512_r),
    .input_valid(start_calc_r),
    .H_out(H_out),
    .output_valid(ripemd_valid_w)
);

ripemd_final ripemd160(
    .clk(clk),
    .rst_n(rst_n),
    .i_valid(ripemd_valid_w),
    .block({64'd256, 191'b0,1'b1,H_out}),
    .o_valid(done_calculation),
    .ans(answer_w)
);

////////////////// FSM LOGIC ///////////////////
parameter INIT = 3'b000;
parameter GET_DATA = 3'b001;
parameter CALCULATION = 3'b010;
parameter OUTPUT_DATA = 3'b011;
parameter END = 3'b100;

assign o_valid = (output_ctr > 0) ? 1'b1 : 1'b0;

always @(*) begin
    start_calc_w = start_calc_r;
    i_data_counter_w = i_data_counter_r;
    state_w = state_r;

    case(state_r)
        INIT : begin
            if(i_valid) begin
                state_w = GET_DATA;
                start_calc_w = start_calc_r;
                i_data_counter_w = 7'b0;
                $display("Start input.");
            end
            else begin
                state_w = state_r;
                start_calc_w = start_calc_r;
            end
        end
        GET_DATA: begin
            if(i_data_counter_r[6] == 1) begin
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
            if(done_calculation) begin
                state_w = OUTPUT_DATA;
                start_calc_w = 1'b0;
                $display("DONE.");
            end
            else begin
                state_w = state_r;
                start_calc_w = 1'b0;
                i_data_counter_w = 7'b0;
            end
        end
        OUTPUT_DATA: begin
            if(output_ctr == 9) begin
                state_w = END;
            end
            else begin
                state_w = state_r;
            end
        end
        END: begin
            state_w = END;
            start_calc_w = start_calc_r;
        end
    endcase
end

////////////////// input(i_text) Logic ///////////////////
always @(*) begin

    if(state_r == GET_DATA && i_data_counter_r[6] != 1) begin

        input_512_w [7:0]= i_text_r;
        input_512_w[511:8]  = input_512_r[511-8:0];
    end
    else begin
        input_512_w=input_512_r;
    end    
end

always @(*) begin
    if(state_r == OUTPUT_DATA) begin
        output_ctr_w = output_ctr + 3'b1;
    end
    else begin
        output_ctr_w = 0;
    end    
end

////////////////// output Logic ///////////////////
always @(*) begin
    o_answer_w =shift_ans_r[159:159-15] ;
    if(state_r ==  OUTPUT_DATA) begin
        shift_ans_w={shift_ans_r[159-16:0], 16'b0};
    end
    else begin
        shift_ans_w=answer_w;
    end    
end

assign o_answer = o_answer_r;
//assign shift_ans_w = (state_r ==  OUTPUT_DATA)  ?  {answer_r[159-16:0], 16'b0}:answer_w ;

////////////////// Sequential Part ///////////////////
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        i_text_r <= 0;
        state_r <= INIT;
        i_data_counter_r <= 7'b0;
        start_calc_r <= 1'b0;
        h0_r <= 32'b0;
        h1_r <= 32'b0;
        h2_r <= 32'b0; 
        h3_r <= 32'b0; 
        h4_r <= 32'b0;
        input_512_r <= 512'b0;
        answer_r <= 160'b0;
        shift_ans_r<=160'b0;
        o_answer_r <= 32'b0;
        output_ctr <= 3'b0;
    end
    else begin
        i_text_r <= i_text;
        state_r <= state_w;
        i_data_counter_r <= i_data_counter_w;
        start_calc_r <= start_calc_w;
        h0_r <= h0_w;
        h1_r <= h1_w;
        h2_r <= h2_w; 
        h3_r <= h3_w; 
        h4_r <= h4_w;
        
        input_512_r <=input_512_w;
        output_ctr <= output_ctr_w;
        answer_r <= answer_w;
        shift_ans_r<=shift_ans_w;
        o_answer_r <= o_answer_w;
        
    end
end
endmodule


module CHIP(
    input clk,
    input rst_n,
    input i_valid,
    input [7:0]  i_text,
    output   o_valid,
    output [15:0] o_answer
);
    
       wire [7:0] in_text;
       wire [15:0] out_ans;
       wire i_clk, i_rst_n, in_valid, out_valid;
       wire n_logic0, n_logic1;
       top top(.clk(i_clk),
               .rst_n(i_rst_n),
               .i_valid(in_valid),
               .i_text(in_text),
               .o_valid(out_valid),
               .o_answer(out_ans)
       );

       TIE0 ipad_n_logic0(.O(n_logic0));
       TIE1 ipad_n_logic1(.O(n_logic1));

       XMD ipad_clk (.O(i_clk), .I(clk), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
       XMD ipad_rst_n (.O(i_rst_n), .I(rst_n), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
       XMD ipad_i_valid  (.O(in_valid), .I(i_valid), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
       XMD ipad_i_text_0 (.O(in_text[0]), .I(i_text[0]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
       XMD ipad_i_text_1 (.O(in_text[1]), .I(i_text[1]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
       XMD ipad_i_text_2 (.O(in_text[2]), .I(i_text[2]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
       XMD ipad_i_text_3 (.O(in_text[3]), .I(i_text[3]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
       XMD ipad_i_text_4 (.O(in_text[4]), .I(i_text[4]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
       XMD ipad_i_text_5 (.O(in_text[5]), .I(i_text[5]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
       XMD ipad_i_text_6 (.O(in_text[6]), .I(i_text[6]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));
       XMD ipad_i_text_7 (.O(in_text[7]), .I(i_text[7]), .PU(n_logic0), .PD(n_logic0), .SMT(n_logic0));

       YA2GSD ipad_o_valid  (.O(o_valid), .I(out_valid), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));     
       YA2GSD ipad_o_answer_0 (.O(o_answer[0]), .I(out_ans[0]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
       YA2GSD ipad_o_answer_1 (.O(o_answer[1]), .I(out_ans[1]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
       YA2GSD ipad_o_answer_2 (.O(o_answer[2]), .I(out_ans[2]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
       YA2GSD ipad_o_answer_3 (.O(o_answer[3]), .I(out_ans[3]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
       YA2GSD ipad_o_answer_4 (.O(o_answer[4]), .I(out_ans[4]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
       YA2GSD ipad_o_answer_5 (.O(o_answer[5]), .I(out_ans[5]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
       YA2GSD ipad_o_answer_6 (.O(o_answer[6]), .I(out_ans[6]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
       YA2GSD ipad_o_answer_7 (.O(o_answer[7]), .I(out_ans[7]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
       YA2GSD ipad_o_answer_8 (.O(o_answer[8]), .I(out_ans[8]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
       YA2GSD ipad_o_answer_9 (.O(o_answer[9]), .I(out_ans[9]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
       YA2GSD ipad_o_answer_10 (.O(o_answer[10]), .I(out_ans[10]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
       YA2GSD ipad_o_answer_11 (.O(o_answer[11]), .I(out_ans[11]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
       YA2GSD ipad_o_answer_12 (.O(o_answer[12]), .I(out_ans[12]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
       YA2GSD ipad_o_answer_13 (.O(o_answer[13]), .I(out_ans[13]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
       YA2GSD ipad_o_answer_14 (.O(o_answer[14]), .I(out_ans[14]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));
       YA2GSD ipad_o_answer_15 (.O(o_answer[15]), .I(out_ans[15]), .E(n_logic1), .E2(n_logic0), .E4(n_logic0), .E8(n_logic0), .SR(n_logic0));

endmodule
