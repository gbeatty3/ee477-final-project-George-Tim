/**
* Conway's Game of Life Cell
*
* data_i[7:0] is status of 8 neighbor cells
* data_o is status this cell
* 1: alive, 0: death
*
* when en_i==1:
*   simulate the cell transition with 8 given neighors
* else when update_i==1:
*   update the cell status to update_val_i
* else:
*   cell status remains unchanged
**/

module bsg_cgol_cell (
    input clk_i

    ,input en_i          
    ,input [7:0] data_i

    ,input update_i     
    ,input update_val_i

    ,output logic data_o
  );

	logic [7:0] data_n;
	logic[3:0] count;

  bsg_popcount countOnes(data_i), .o(count));
	defparam countOnes.width_p = 8;
  
  always_comb begin
		
		if(en_i) begin
			
			if ( count < 2 || count > 3 ) data_n = 0;

			else if ( count == 2 ) data_n = data_o;

			else data_n = 1;


		end
	end

	always_ff @(posedge clk) begin
		
		data_o = (update_i) ? update_val_i : ((en_i) ? data_n : data_o);

	end




endmodule
