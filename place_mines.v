//place_Mines
`timescale 1ns / 1ps

module place_mines(clk, reset
		);
	
	reg[3:0] state;
	localparam INIT=4'b0001, PLACE_MINE=4'b0010, CHANGE_XY=4'b0100, DONE=4'b1000;
	
	always @ (posedge clk, posedge reset) 
	begin
		if(reset)
		begin 
			state <= INIT;
		end
		
		else
		begin
			case (state)
				INIT:
				begin
					if(start)
					// ST
					state <= PLACE_MINE;
					// RTL
					x <= 0; 
					y <= 0;
					c <= 0;
					totalMines <= 10;
				end
				
				PLACE_MINE:
				begin
					//ST
					if(c==totalMines-1 && mineBoardReadValue==1'b0)
					state <= DONE;
					else 
					state <= CHANGE_XY;
					//RTL
					if(mineBoardReadValue==1'b0)
					begin
						mineBoardWriteValue <= 1;
						mineBoardWriteEn <= 1;
						numBoardIncAdjacent <= 1;
						c<=c+1;
					end
					else
					begin	
						// To prevent infinite loop due to non-random number changes to x and y 
						// (ie if x and y are stuck in a pattern)
						x <= x+1;
						y <= y+1; 
					end
				end
				
				CHANGE_XY:
				begin
					//ST
					state<=placeMine;
					//RTL
					x <= newx;
					y <= newy;
					mineBoardWriteEn <= 0;
					numBoardIncAdjacent <= 0;
				end
				DONE:
				begin
					//ST
					if (ack)
					state <= INIT;
				end
			endcase
		end
	end
	
	
endmodule