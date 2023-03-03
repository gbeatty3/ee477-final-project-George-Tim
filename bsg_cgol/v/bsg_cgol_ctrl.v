module bsg_cgol_ctrl #(
   parameter `BSG_INV_PARAM(max_game_length_p)
  ,localparam game_len_width_lp=`BSG_SAFE_CLOG2(max_game_length_p + 1)
) (
   input clk_i
  ,input reset_i

  ,input en_i

  // Input Data Channel
  ,input  [game_len_width_lp-1:0] frames_i
  ,input  v_i
  ,output logic ready_o

  // Output Data Channel
  ,input yumi_i
  ,output logic v_o

  // Cell Array
  ,output logic update_o
  ,output logic en_o
);

  wire unused = en_i; // for clock gating, unused
  
  // TODO: Design your control logic

	enum logic [1:0] {START, BUSY, DONE} ps, ns;	

	logic [game_len_width_lp - 1 : 0] count, frames_r; 
	logic overflow;

	bsg_counter_dynamic_limit_en counter (.clk_i, .reset_i(reset_i || v_o), .en_i(en_o), 
																				.limit_i(frames_r), .counter_o(count),
																				.overflowed_o(overflow));
	defparam counter.width_p = (game_len_width_lp);

	
	always_comb begin
		case (ps)

			START : begin
				if (ready_o && v_i) begin
					ns <= BUSY; 
					frames_r <= frames_i;
				end

				else ns <= START;

			end

			BUSY : begin
				if (overflow) ns <= DONE; //count == (frames_r - 1)
				else ns <= BUSY;

			end

			DONE : begin
				if (yumi_i && v_o) ns <= START;
				else ns <= DONE;
			end

		endcase
	end

	assign update_o = (ready_o & v_i);

	always_ff @(posedge clk_i) begin
	
		if (reset_i) begin
				ready_o <= 0;
				v_o <= 0;
				en_o <= 0;
		end

		else if (ps == START) begin
			v_o <= 0;
			ready_o <= 1;
		end

		else if (ps == BUSY) begin
			en_o <= 1;
			ready_o <= 0;
		end

		else if (ps == DONE) begin
			en_o <= 0;
			v_o <= 1;
		end
	end

	always_ff @(posedge clk_i) begin
		if (reset_i) ps <= START;

		else ps <= ns;

	end

endmodule
