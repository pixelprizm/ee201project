`timescale 1ns / 1ps



module Board(reset, clk, // basic inputs
			  readX, readY, // read inputs
			  writeEn, writeX, writeY, writeValue, // write inputs
	          readValue); // outputs
	parameter width = 8, height = 8, busWidth = 8;
	
	input reset, clk;
	input [$clog2(width)-1 : 0] readX;
	input [$clog2(height)-1 : 0] readY;
	input writeEn;
	input [$clog2(width)-1 : 0] writeX;
	input [$clog2(height)-1 : 0] writeY;
	input [busWidth-1 : 0] writeValue;
	output [busWidth-1 : 0] readValue;
	
	reg [busWidth-1 : 0] board[width*height-1 : 0];
	
	wire readI, writeI;
	assign readI = readY*width + readX;
	assign readValue = board[readI];
	assign writeI = writeY*width + writeX;
	
	integer i = 0; // for the below for-loop
	
	always @(posedge reset)
	begin : reset_block
		for(i = 0; i < width*height; i = i+1)
		begin
			board[i] = 'b0;
		end
	end
	
	always @(posedge clk)
	begin : write_on_clock_block
		if(writeEn)
		begin
			board[writeI] <= writeValue;
		end
	end
	
endmodule