`timescale 1ns / 1ps

module PlaceMines(reset, clk, start, ack, // basic inputs
				   totalMinesIn, // set the total mines to add
				   x, y, // dimension outputs for reading and writing
				   mineBoardReadValue, // read inputs
				   placeMineEn, // write enable outputs
				   init, placeMine, changeXY, almostDone, done // indicators of states
		);
	parameter boardWidth = 8, boardHeight = 8;
	localparam maxBoardCountWidth = 6; // $clog2(boardWidth * boardHeight); //later, maybe add this
	
	// Basic inputs:
	input reset, clk, start, ack;
	
	// Counting mines:
	input [maxBoardCountWidth-1 : 0] totalMinesIn;
	reg [maxBoardCountWidth-1 : 0] totalMines;
	reg [maxBoardCountWidth-1 : 0] count;
	
	// Reading value from the board:
	output reg [$clog2(boardWidth)-1 : 0] x;
	output reg [$clog2(boardHeight)-1 : 0] y;
	input mineBoardReadValue;
	
	// Writing values to the board:
	// (use the same x and y for writeX and writeY)
	output reg placeMineEn;
	
	// State:
	reg[4:0] state;
	localparam INIT=5'b00001, PLACE_MINE=5'b00010, CHANGE_XY=5'b00100, ALMOST_DONE=5'b01000, DONE=5'b10000;
	
	// Done indicator:
	output wire init, placeMine, changeXY, almostDone, done;
	assign init = state == INIT;
	assign placeMine = state == PLACE_MINE;
	assign changeXY = state == CHANGE_XY;
	assign almostDone = state == ALMOST_DONE;
	assign done = state == DONE;
	
	always @ (posedge clk, posedge reset) 
	begin
		if(reset)
		begin
			state <= INIT;
			
			// Initializing x and y to be certain values
			x <= 0;
			y <= boardHeight/2;
		end
		
		else
		begin
			case (state)
				INIT:
				begin
					// ST
					if(start) state <= PLACE_MINE;
					// RTL
					// purposely not resetting x and y so that they will be different next time
					count <= 0;
					totalMines <= totalMinesIn;
					placeMineEn <= 0;
				end
				
				PLACE_MINE:
				begin
					//ST
					if(count==totalMines-1 && mineBoardReadValue==1'b0)
						state <= ALMOST_DONE;
					else 
						state <= CHANGE_XY;
					//RTL
					if(mineBoardReadValue == 1'b0)
					begin
						placeMineEn <= 1;
						count<=count+1;
					end
					else
					begin
						// To prevent infinite loop due to non-random number changes to x and y 
						// (ie if x and y are stuck in a pattern)
						x <= x + 1;
						y <= y + 2;
					end
				end
				
				CHANGE_XY:
				begin
					//ST
					state <= PLACE_MINE;
					//RTL
					// Using Linear Congruential Generator for kinda-random numbers.
					// note: the values chosen for a and b in (a*x + b) % m are chosen based on boardWidth == 8 and boardHeight == 8
					x <= (x + boardWidth/2 + 1) % boardWidth;
					y <= ((boardHeight/2 + 1)*y + (boardHeight/2 + 1)) % boardHeight;
					placeMineEn <= 0;
				end
				
				ALMOST_DONE:
				begin
					//ST
					state <= DONE;
					placeMineEn <= 0;
				end
				
				DONE:
				begin
					//ST
					if (ack) state <= INIT;
				end
			endcase
		end
	end
endmodule