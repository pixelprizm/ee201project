`timescale 1ns / 1ps



module Board_tb;
	
	reg reset_tb, clk_tb;
	
	parameter CLK_PERIOD = 20;
	localparam boardWidth_tb = 8, boardHeight_tb = 8;
	
	// Place mines:
	reg [$clog2(boardWidth_tb)-1 : 0] placeMineX_tb;
	reg [$clog2(boardHeight_tb)-1 : 0] placeMineY_tb;
	reg placeMineEn_tb;
	
	// Board Reading:
	reg [$clog2(boardWidth_tb)-1 : 0] readBoardX_tb;
	reg [$clog2(boardHeight_tb)-1 : 0] readBoardY_tb;
	wire [3:0] adjBoardReadValue_tb;
	
	
	
	Board #(.width(boardWidth_tb), .height(boardHeight_tb), .busWidth(1)) mineBoard (
			.reset(reset_tb), .clk(clk_tb),
			.readX(readBoardX_tb), .readY(readBoardY_tb),
			.readValue(mineBoardReadValue_tb),
			.writeEn(placeMineEn_tb), .writeX(placeMineX_tb), .writeY(placeMineY_tb),
			.writeValue(placeMineEn_tb), .incAdjacent(1'b0)
			);
			
	Board #(.width(boardWidth_tb), .height(boardHeight_tb), .busWidth(4)) adjBoard (
			.reset(reset_tb), .clk(clk_tb),
			.readX(readBoardX_tb), .readY(readBoardY_tb),
			.readValue(adjBoardReadValue_tb),
			.writeEn(1'b0), .writeX(placeMineX_tb), .writeY(placeMineY_tb),
			.writeValue(4'bx), .incAdjacent(placeMineEn_tb)
			);
	
	
	
	initial
	begin : reset_generator
		reset_tb = 1;
		#(2*CLK_PERIOD)
		reset_tb = 0;
	end
	
	initial
	begin : clk_generator
		clk_tb = 0;
		forever
		begin
			#(CLK_PERIOD/2)
			clk_tb = ~clk_tb;
		end
	end
	
	integer x_i, y_i;
	task display_combined_board;
	begin
		for(y_i = 0; y_i < boardHeight_tb; y_i = y_i + 1)
		begin
			for(x_i = 0; x_i < boardWidth_tb; x_i = x_i + 1)
			begin
				readBoardX_tb = x_i;
				readBoardY_tb = y_i;
				#0.001; // must be non-zero
				
				if(mineBoardReadValue_tb == 1'b1) $write("*");
				else $write(adjBoardReadValue_tb);
			end
			$write ("\n");
		end
	end
	endtask
	
	
	
	initial
	begin : stimulus
		@(negedge reset_tb);
		@(posedge clk_tb);
		#2;
		
		placeMineEn_tb = 0;
		
		display_combined_board;
	end
	
endmodule