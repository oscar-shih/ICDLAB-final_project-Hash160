//======================================================================
// RIPEMD160_stage_1.v
// Author: Jimmy Yang
// -------------
// Verilog 2022 implementation of the RIPEMD-160 hash function.
//======================================================================

`default_nettype none

module RIPEMD160_stage_1(
                   input wire            clk,
                   input wire            reset_n,
                   input wire            init,
                   input wire            next,
                   input wire [511 : 0]  block,

                   output wire           ready,
                   output wire [159 : 0] digest,
                   output wire           digest_valid
                  );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------

  localparam RIPEMD160_H0_0 = 32'h67452301;
  localparam RIPEMD160_H0_1 = 32'hefcdab89;
  localparam RIPEMD160_H0_2 = 32'h98badcfe;
  localparam RIPEMD160_H0_3 = 32'h10325476;
  localparam RIPEMD160_H0_4 = 32'hc3d2e1f0;

  localparam RIPEMD160_ROUNDS = 16;

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
  reg          a_h_we;

  reg [31 : 0] H0_reg;
  reg [31 : 0] H0_new;
  reg [31 : 0] H1_reg;
  reg [31 : 0] H1_new;
  reg [31 : 0] H2_reg;
  reg [31 : 0] H2_new;
  reg [31 : 0] H3_reg;
  reg [31 : 0] H3_new;
  reg [31 : 0] H4_reg;
  reg [31 : 0] H4_new;
  reg          H_we;

  reg [31 : 0] t;
  reg [ 5 : 0] t_ctr_reg;
  reg [ 5 : 0] t_ctr_new;
  reg          t_ctr_we;
  reg          t_ctr_inc;
  reg          t_ctr_rst;

  reg digest_valid_reg;
  reg digest_valid_new;
  reg digest_valid_we;

  reg [ 1 : 0] RIPEMD160_ctrl_reg;
  reg [ 1 : 0] RIPEMD160_ctrl_new;
  reg          RIPEMD160_ctrl_we;

  reg [3:0] s [0:15];

  reg [31:0] k;

  initial begin
      s[0] = 4'd11;
      s[1] = 4'd14;
      s[2] = 4'd15;
      s[3] = 4'd12;
      s[4] = 4'd5;
      s[5] = 4'd8;
      s[6] = 4'd7;
      s[7] = 4'd9;
      s[8] = 4'd11;
      s[9] = 4'd13;
      s[10] = 4'd14;
      s[11] = 4'd15;
      s[12] = 4'd6;
      s[13] = 4'd7;
      s[14] = 4'd9;
      s[15] = 4'd8;

      k = 32'h00000000;
  end
 

  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg digest_init;
  reg digest_update;

  reg state_init;
  reg state_update;

  reg first_block;

  reg ready_flag;

  reg [31 : 0] t1;
  reg [31 : 0] t2;

  wire [31 : 0] k_data;

  reg           w_init;
  reg           w_next;
  wire [31 : 0] w_data;


  //----------------------------------------------------------------
  // Module instantiantions.
  //----------------------------------------------------------------
  // ripemd160_k_constants k_constants_inst(
  //                                     .round(t_ctr_reg),
  //                                     .K(k_data)
  //                                    );


  RIPEMD160_w_mem w_mem_inst(
                          .clk(clk),
                          .reset_n(reset_n),

                          .block(block),

                          .init(w_init),
                          .next(w_next),
                          .w(w_data)
                         );


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign ready = ready_flag;

  assign digest = {H0_reg, H1_reg, H2_reg, H3_reg,
                   H4_reg};

  assign digest_valid = digest_valid_reg;


  //----------------------------------------------------------------
  // reg_update
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with asynchronous
  // active low reset. All registers have write enable.
  //----------------------------------------------------------------
  always @ (posedge clk or negedge reset_n)
    begin : reg_update
      if (!reset_n)
        begin
          a_reg            <= 32'h0;
          b_reg            <= 32'h0;
          c_reg            <= 32'h0;
          d_reg            <= 32'h0;
          e_reg            <= 32'h0;
        
          H0_reg           <= 32'h0;
          H1_reg           <= 32'h0;
          H2_reg           <= 32'h0;
          H3_reg           <= 32'h0;
          H4_reg           <= 32'h0;
        
          digest_valid_reg <= 0;
          t_ctr_reg        <= 6'h0;
          RIPEMD160_ctrl_reg  <= CTRL_IDLE;
        end
      else
        begin

          if (a_h_we)
            begin
              a_reg <= a_new;
              b_reg <= b_new;
              c_reg <= c_new;
              d_reg <= d_new;
              e_reg <= e_new;
            end

          if (H_we)
            begin
              H0_reg <= H0_new;
              H1_reg <= H1_new;
              H2_reg <= H2_new;
              H3_reg <= H3_new;
              H4_reg <= H4_new;
            end

          if (t_ctr_we)
            t_ctr_reg <= t_ctr_new;

          if (digest_valid_we)
            digest_valid_reg <= digest_valid_new;

          if (RIPEMD160_ctrl_we)
            RIPEMD160_ctrl_reg <= RIPEMD160_ctrl_new;
        end
    end // reg_update


  //----------------------------------------------------------------
  // digest_logic
  //
  // The logic needed to init as well as update the digest.
  //----------------------------------------------------------------
  always @*
    begin : digest_logic
      H0_new = 32'h0;
      H1_new = 32'h0;
      H2_new = 32'h0;
      H3_new = 32'h0;
      H4_new = 32'h0;

      H_we = 0;

        if (digest_init)
        begin
            H_we = 1;
            H0_new = RIPEMD160_H0_0;
            H1_new = RIPEMD160_H0_1;
            H2_new = RIPEMD160_H0_2;
            H3_new = RIPEMD160_H0_3;
            H4_new = RIPEMD160_H0_4;
        end

      if (digest_update)
        begin
          H0_new = H0_reg + a_reg;
          H1_new = H1_reg + b_reg;
          H2_new = H2_reg + c_reg;
          H3_new = H3_reg + d_reg;
          H4_new = H4_reg + e_reg;
          H_we = 1;
        end
    end // digest_logic


  //----------------------------------------------------------------
  // t_logic
  //
  // The logic for the T function.
  //----------------------------------------------------------------
  always @*
    begin : t_logic
        reg [31 : 0] f;
        reg [31 : 0] roll;
        reg [31:0] ss;
        f = b_reg ^ c_reg ^ d_reg;
        roll = a_reg + f + w_data + k;
        // rol = roll[31 : 0];
        ss = { roll[31 : 0] << s[ t_ctr_reg ] | roll[31 : 0] >> (16 - s[t_ctr_reg])};
        t = ss + e_reg;
    end // t1_logic

  //----------------------------------------------------------------
  // state_logic
  //
  // *** update A B C D E
  // The logic needed to init as well as update the state during
  // round processing.
  //----------------------------------------------------------------
  always @*
    begin : state_logic
      a_new  = 32'h0;
      b_new  = 32'h0;
      c_new  = 32'h0;
      d_new  = 32'h0;
      e_new  = 32'h0;

      a_h_we = 0;

    if (state_init) begin
        a_h_we = 1;
        if (first_block) begin
                a_new  = RIPEMD160_H0_0;
                b_new  = RIPEMD160_H0_1;
                c_new  = RIPEMD160_H0_2;
                d_new  = RIPEMD160_H0_3;
                e_new  = RIPEMD160_H0_4;
        end
        else begin
            a_new  = H0_reg;
            b_new  = H1_reg;
            c_new  = H2_reg;
            d_new  = H3_reg;
            e_new  = H4_reg;
        end
    end

      if (state_update)
        begin
          a_new  = e_reg;
          b_new  = t; //
          c_new  = b_reg;
          d_new  = {c_reg<<10 | c_reg>>22}; //
          e_new  = d_reg;
          a_h_we = 1;
        end
    end // state_logic


  //----------------------------------------------------------------
  // t_ctr
  // count rounds 
  // Update logic for the round counter, a monotonically
  // increasing counter with reset.
  //----------------------------------------------------------------
  always @*
    begin : t_ctr
      t_ctr_new = 0;
      t_ctr_we  = 0;

      if (t_ctr_rst)
        begin
          t_ctr_new = 0;
          t_ctr_we  = 1;
        end

      if (t_ctr_inc)
        begin
          t_ctr_new = t_ctr_reg + 1'b1;
          t_ctr_we  = 1;
        end
    end // t_ctr


  //----------------------------------------------------------------
  // RIPEMD160_ctrl_fsm
  //
  // Logic for the state machine controlling the core behaviour.
  //----------------------------------------------------------------
  always @*
    begin : RIPEMD160_ctrl_fsm
      digest_init      = 0;
      digest_update    = 0;

      state_init       = 0;
      state_update     = 0;

      first_block      = 0;
      ready_flag       = 0;

      w_init           = 0;
      w_next           = 0;

      t_ctr_inc        = 0;
      t_ctr_rst        = 0;

      digest_valid_new = 0;
      digest_valid_we  = 0;

      RIPEMD160_ctrl_new  = CTRL_IDLE;
      RIPEMD160_ctrl_we   = 0;


      case (RIPEMD160_ctrl_reg)
        CTRL_IDLE:
          begin
            $display("1");
            ready_flag = 1;

            if (init)
              begin
                digest_init      = 1;
                w_init           = 1;
                state_init       = 1;
                first_block      = 1;
                t_ctr_rst        = 1;
                digest_valid_new = 0;
                digest_valid_we  = 1;
                RIPEMD160_ctrl_new  = CTRL_ROUNDS;
                RIPEMD160_ctrl_we   = 1;
              end

            if (next)
              begin
                t_ctr_rst        = 1;
                w_init           = 1;
                state_init       = 1;
                digest_valid_new = 0;
                digest_valid_we  = 1;
                RIPEMD160_ctrl_new  = CTRL_ROUNDS;
                RIPEMD160_ctrl_we   = 1;
              end
          end

        CTRL_ROUNDS:
          begin
            $display("1");
            w_next       = 1;
            state_update = 1;
            t_ctr_inc    = 1;

            if (t_ctr_reg == RIPEMD160_ROUNDS)
              begin
                RIPEMD160_ctrl_new = CTRL_DONE;
                RIPEMD160_ctrl_we  = 1;
              end
          end

        CTRL_DONE:
          begin
            $display("a = %h, b = %h, c = %h", a_reg, b_reg, c_reg);
            digest_update    = 1;
            digest_valid_new = 1;
            digest_valid_we  = 1;

            RIPEMD160_ctrl_new  = CTRL_IDLE;
            RIPEMD160_ctrl_we   = 1;
          end
      endcase // case (RIPEMD160_ctrl_reg)
    end // RIPEMD160_ctrl_fsm

endmodule // RIPEMD160_core

//======================================================================
// EOF RIPEMD160_core.v
//======================================================================