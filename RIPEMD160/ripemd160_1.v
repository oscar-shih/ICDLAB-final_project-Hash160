//======================================================================
// RIPEMD160_stage_1.v
// Author: Jimmy Yang
// -------------
// Verilog 2022 implementation of the RIPEMD-160 hash function.
//======================================================================
`timescale 1ns/10ps

module RIPEMD160_stage_1_core(
                   input wire            clk,
                   input wire            rst_n,
                   input wire            i_valid,
                   input wire [511 : 0]  block,

                   output wire           o_valid,
                   output wire [159 : 0] ans
                  );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------

  localparam RIPEMD160_H0_0 = 32'h67452301;
  localparam RIPEMD160_H0_1 = 32'hefcdab89;
  localparam RIPEMD160_H0_2 = 32'h98badcfe;
  localparam RIPEMD160_H0_3 = 32'h10325476;
  localparam RIPEMD160_H0_4 = 32'hc3d2e1f0;

  localparam RIPEMD160_ROUNDS = 80;

  localparam CTRL_IDLE   = 0;
  localparam CTRL_ROUNDS = 1;
  localparam CTRL_DONE   = 2;


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg [31 : 0] a_reg;
  reg [31 : 0] a_new;
  reg [31 : 0] b_reg;
  reg [31 : 0] b_new;
  reg [31 : 0] c_reg;
  reg [31 : 0] c_new;
  reg [31 : 0] d_reg;
  reg [31 : 0] d_new;
  reg [31 : 0] e_reg;
  reg [31 : 0] e_new;

  reg [ 6 : 0] t_ctr_r;
  reg [ 6 : 0] t_ctr_w;
  wire [2:0] round;

  reg [ 1 : 0] state_r;
  reg [ 1 : 0] state_w;

  reg [31:0] w_data   [0:15];
  reg [31:0] w_data_w [0:15];

  wire [3:0]  s [0:79];
  wire [3:0]  r [0:79];
  wire [31:0] k [0:4];

  reg o_valid_r, o_valid_w;

  assign {s[0],s[1],s[2],s[3],s[4],s[5],s[6],s[7],s[8],s[9],s[10],s[11],s[12],s[13],s[14],s[15]} = 
  {4'd11,4'd14,4'd15,4'd12,4'd5,4'd8,4'd7,4'd9,4'd11,4'd13,4'd14,4'd15,4'd6,4'd7,4'd9,4'd8};
  assign {s[16],s[17],s[18],s[19],s[20],s[21],s[22],s[23],s[24],s[25],s[26],s[27],s[28],s[29],s[30],s[31]} = 
  {4'd7,4'd6,4'd8,4'd13,4'd11,4'd9,4'd7,4'd15,4'd7,4'd12,4'd15,4'd9,4'd11,4'd7,4'd13,4'd12};
  assign {s[32],s[33],s[34],s[35],s[36],s[37],s[38],s[39],s[40],s[41],s[42],s[43],s[44],s[45],s[46],s[47]} = 
  {4'd11,4'd13,4'd6,4'd7,4'd14,4'd9,4'd13,4'd15,4'd14,4'd8,4'd13,4'd6,4'd5,4'd12,4'd7,4'd5};
  assign {s[48],s[49],s[50],s[51],s[52],s[53],s[54],s[55],s[56],s[57],s[58],s[59],s[60],s[61],s[62],s[63]} = 
  {4'd11,4'd12,4'd14,4'd15,4'd14,4'd15,4'd9,4'd8,4'd9,4'd14,4'd5,4'd6,4'd8,4'd6,4'd5,4'd12};
  assign {s[64],s[65],s[66],s[67],s[68],s[69],s[70],s[71],s[72],s[73],s[74],s[75],s[76],s[77],s[78],s[79]} = 
  {4'd9,4'd15,4'd5,4'd11,4'd6,4'd8,4'd13,4'd12,4'd5,4'd12,4'd13,4'd14,4'd11,4'd8,4'd5,4'd6};

  assign {r[0],r[1],r[2],r[3],r[4],r[5],r[6],r[7],r[8],r[9],r[10],r[11],r[12],r[13],r[14],r[15]} = 
  {4'd0,4'd1,4'd2,4'd3,4'd4,4'd5,4'd6,4'd7,4'd8,4'd9,4'd10,4'd11,4'd12,4'd13,4'd14,4'd15};
  assign {r[16],r[17],r[18],r[19],r[20],r[21],r[22],r[23],r[24],r[25],r[26],r[27],r[28],r[29],r[30],r[31]} = 
  {4'd7,4'd4,4'd13,4'd1,4'd10,4'd6,4'd15,4'd3,4'd12,4'd0,4'd9,4'd5,4'd2,4'd14,4'd11,4'd8};
  assign {r[32],r[33],r[34],r[35],r[36],r[37],r[38],r[39],r[40],r[41],r[42],r[43],r[44],r[45],r[46],r[47]} = 
  {4'd3,4'd10,4'd14,4'd4,4'd9,4'd15,4'd8,4'd1,4'd2,4'd7,4'd0,4'd6,4'd13,4'd11,4'd5,4'd12};
  assign {r[48],r[49],r[50],r[51],r[52],r[53],r[54],r[55],r[56],r[57],r[58],r[59],r[60],r[61],r[62],r[63]} = 
  {4'd1,4'd9,4'd11,4'd10,4'd0,4'd8,4'd12,4'd4,4'd13,4'd3,4'd7,4'd15,4'd14,4'd5,4'd6,4'd2};
  assign {r[64],r[65],r[66],r[67],r[68],r[69],r[70],r[71],r[72],r[73],r[74],r[75],r[76],r[77],r[78],r[79]} = 
  {4'd4,4'd0,4'd5,4'd9,4'd7,4'd12,4'd2,4'd10,4'd14,4'd1,4'd3,4'd8,4'd11,4'd6,4'd15,4'd13};

  assign k[0] = 32'h00000000;
  assign k[1] = 32'h5A827999; 
  assign k[2] = 32'h6ED9EBA1;
  assign k[3] = 32'h8F1BBCDC;
  assign k[4] = 32'hA953FD4E;

  assign round = t_ctr_r>>4;
  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [31 : 0] f;
  reg [31 : 0] roll;
  reg [31 : 0] roll_s;
  reg [5  : 0] rot;

  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------

  assign ans = {a_reg, b_reg, c_reg, d_reg, e_reg};

  assign o_valid = o_valid_w;

  //----------------------------------------------------------------
  // state_logic
  //
  // *** update A B C D E
  // The logic needed to init as well as update the state during
  // round processing.
  //----------------------------------------------------------------
  always @(*) begin
    f = f;
    roll = roll;
    rot = rot;
    roll_s = roll_s; 

    case (state_r)
        CTRL_IDLE: begin
            a_new  = RIPEMD160_H0_0;
            b_new  = RIPEMD160_H0_1;
            c_new  = RIPEMD160_H0_2;
            d_new  = RIPEMD160_H0_3;
            e_new  = RIPEMD160_H0_4;
        end
        CTRL_ROUNDS: begin
            //$display("round = ", t_ctr_r);
            case (round)
                3'd0:begin
                    f = b_reg ^ c_reg ^ d_reg;
                end
                3'd1:begin
                    f = (b_reg & c_reg) | (~b_reg & d_reg);
                end
                3'd2:begin
                    f = (b_reg | ~c_reg) ^ d_reg;
                end
                3'd3:begin
                    f = (b_reg & d_reg) | (c_reg & ~d_reg);
                end
                3'd4:begin
                    f = b_reg ^ (c_reg | ~d_reg);
                end
                default:f = 0;
            endcase
            //$display("f = %h", f);
            roll = a_reg + f + w_data[r[t_ctr_r]] + k[round];
            //$display("roll = %h, w_data = %h, a_reg = %h", roll[31:0], w_data[t_ctr_r], a_reg);
            rot = (6'd32 - s[t_ctr_r]);
            roll_s = { roll[31 : 0] << s[t_ctr_r] | roll[31 : 0] >> (rot)};
            // $display("roll_s = %h", roll_s);
            a_new  = e_reg;
            b_new  = roll_s + e_reg;
            c_new  = b_reg;
            d_new  = {c_reg<<10 | c_reg>>22};
            e_new  = d_reg;
            //$display("a = %h, b = %h, c = %h, d=%h, e=%h", a_new, b_new, c_new, d_new, e_new);
        end
        default: begin
          a_new  = a_reg;
          b_new  = b_reg;
          c_new  = c_reg;
          d_new  = d_reg; 
          e_new  = e_reg;
        end
    endcase
  end
  //----------------------------------------------------------------
  // RIPEMD160_ctrl_fsm
  //
  // Logic for the state machine controlling the core behaviour.
  //----------------------------------------------------------------
  always @(*) begin
      state_w  = CTRL_IDLE;
      o_valid_w = o_valid_r;
      t_ctr_w = t_ctr_r;

      w_data_w[0] = w_data[0];
      w_data_w[1] = w_data[1];
      w_data_w[2] = w_data[2];
      w_data_w[3] = w_data[3];
      w_data_w[4] = w_data[4];
      w_data_w[5] = w_data[5];
      w_data_w[6] = w_data[6];
      w_data_w[7] = w_data[7];
      w_data_w[8] = w_data[8];
      w_data_w[9] = w_data[9];
      w_data_w[10] = w_data[10];
      w_data_w[11] = w_data[11];
      w_data_w[12] = w_data[12];
      w_data_w[13] = w_data[13];
      w_data_w[14] = w_data[14];
      w_data_w[15] = w_data[15];

      case (state_r)
        CTRL_IDLE: 
          begin
            //$display("1");
            if (i_valid) begin
                t_ctr_w = 6'b0;
                state_w  = CTRL_ROUNDS;
                w_data_w[0] = block[32*1-1:0];
                w_data_w[1] = block[32*2-1:32*1];
                w_data_w[2] = block[32*3-1:32*2];
                w_data_w[3] = block[32*4-1:32*3];
                w_data_w[4] = block[32*5-1:32*4];
                w_data_w[5] = block[32*6-1:32*5];
                w_data_w[6] = block[32*7-1:32*6];
                w_data_w[7] = block[32*8-1:32*7];
                w_data_w[8] = block[32*9-1:32*8];
                w_data_w[9] = block[32*10-1:32*9];
                w_data_w[10] = block[32*11-1:32*10];
                w_data_w[11] = block[32*12-1:32*11];
                w_data_w[12] = block[32*13-1:32*12];
                w_data_w[13] = block[32*14-1:32*13];
                w_data_w[14] = block[32*15-1:32*14];
                w_data_w[15] = block[32*16-1:32*15];
                // $display("w_data = %h", w_data);
                // $display("H0 : %h, H1 : %h, H2 : %h, H3 : %h, H4 : %h",H0_reg, H1_reg, H2_reg, H3_reg, H4_reg);
            end
          end

        CTRL_ROUNDS:
          begin
            //$display("2");
            if (t_ctr_r == RIPEMD160_ROUNDS - 1) begin
                state_w = CTRL_DONE;
            end
            else begin
                t_ctr_w = t_ctr_r + 6'b1;
                state_w = CTRL_ROUNDS;
            end
          end

        CTRL_DONE:
          begin
            state_w  = CTRL_IDLE;
            o_valid_w   = 1;
          end
      endcase
    end // RIPEMD160_ctrl_fsm

  //----------------------------------------------------------------
  // reg_update
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with asynchronous
  // active low reset. All registers have write enable.
  //----------------------------------------------------------------
  always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
          a_reg  <= 32'h0;
          b_reg  <= 32'h0;
          c_reg  <= 32'h0;
          d_reg  <= 32'h0;
          e_reg  <= 32'h0;
          t_ctr_r   <= 7'h0;
          state_r   <= CTRL_IDLE;
          o_valid_r <= 1'b0;
          w_data[0] <= 0;
          w_data[1] <= 0;
          w_data[2] <= 0;
          w_data[3] <= 0;
          w_data[4] <= 0;
          w_data[5] <= 0;
          w_data[6] <= 0;
          w_data[7] <= 0;
          w_data[8] <= 0;
          w_data[9] <= 0;
          w_data[10] <= 0;
          w_data[11] <= 0;
          w_data[12] <= 0;
          w_data[13] <= 0;
          w_data[14] <= 0;
          w_data[15] <= 0;
      end
      else begin
          a_reg  <= a_new;
          b_reg  <= b_new;
          c_reg  <= c_new;
          d_reg  <= d_new;
          e_reg  <= e_new;
          t_ctr_r   <= t_ctr_w;
          state_r   <= state_w;
          o_valid_r <= o_valid_w;
          w_data[0] <= w_data_w[0];
          w_data[1] <= w_data_w[1];
          w_data[2] <= w_data_w[2];
          w_data[3] <= w_data_w[3];
          w_data[4] <= w_data_w[4];
          w_data[5] <= w_data_w[5];
          w_data[6] <= w_data_w[6];
          w_data[7] <= w_data_w[7];
          w_data[8] <= w_data_w[8];
          w_data[9] <= w_data_w[9];
          w_data[10] <= w_data_w[10];
          w_data[11] <= w_data_w[11];
          w_data[12] <= w_data_w[12];
          w_data[13] <= w_data_w[13];
          w_data[14] <= w_data_w[14];
          w_data[15] <= w_data_w[15];
    end // reg_update
  end
endmodule // RIPEMD160_core