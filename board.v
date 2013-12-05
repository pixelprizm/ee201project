`timescale 1ns / 1ps



module Board(reset, clk, // basic inputs
			  readX, readY, // read inputs
			  writeEn, writeX, writeY, writeValue, incAdjacent, // write inputs
	          readValue); // outputs
	parameter width = 8, height = 8, busWidth = 1;
	
	input reset, clk;
	input [$clog2(width)-1 : 0] readX;
	input [$clog2(height)-1 : 0] readY;
	input writeEn;
	input incAdjacent;
	input [$clog2(width)-1 : 0] writeX;
	input [$clog2(height)-1 : 0] writeY;
	input [busWidth-1 : 0] writeValue;
	output [busWidth-1 : 0] readValue;
	
	reg [busWidth-1 : 0] board[width*height-1 : 0];
	
	assign readValue = board[index(readX, readY)];
	
	integer i = 0; // for the reset for-loop
	
	always @(posedge reset, posedge clk)
	begin
		if(reset)
		begin : reset_board
			for(i = 0; i < width*height; i = i+1)
			begin
				board[i] = 'b0;
			end
		end
		else if(writeEn)
		begin : write_value
			board[index(writeX, writeY)] <= writeValue;
		end
		else if(incAdjacent)
		begin : increment_adjacent_cells
			if(writeY > 0)
			begin : cell_north
				// note: now we know that there's a cell north of (writeX, writeY)
				board[index(writeX, writeY-1)] <= board[index(writeX, writeY-1)] + 1;
				if(writeX > 0)
				begin : cell_northwest
					board[index(writeX-1, writeY-1)] <= board[index(writeX-1, writeY-1)] + 1;
				end
				if(writeX < width - 1)
				begin : cell_northeast
					board[index(writeX+1, writeY-1)] <= board[index(writeX+1, writeY-1)] + 1;
				end
			end
			if(writeY < height - 1)
			begin : cell_south
				board[index(writeX, writeY+1)] <= board[index(writeX, writeY+1)] + 1;
				if(writeX > 0)
				begin : cell_southwest
					board[index(writeX-1, writeY+1)] <= board[index(writeX-1, writeY+1)] + 1;
				end
				if(writeX < width - 1)
				begin : cell_southeast
					board[index(writeX+1, writeY+1)] <= board[index(writeX+1, writeY+1)] + 1;
				end
			end
			if(writeX > 0)
			begin : cell_west
				board[index(writeX-1, writeY)] <= board[index(writeX-1, writeY)] + 1;
			end
			if(writeX < width - 1)
			begin : cell_east
				board[index(writeX+1, writeY)] <= board[index(writeX+1, writeY)] + 1;
			end
		end
	end
	
	// Helper function to get the index of the board array from a given x and y
	function index;
	input x, y;
		index = y*width + x;
	endfunction
	
endmodule