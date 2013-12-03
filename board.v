`timescale 1ns / 1ps



module Board(width, height, busWidth, x, y, reset, // inputs
	          value); // outputs
	
	input integer width, height, busWidth;
	input x[log2(width)-1 : 0];
	input y[log2(height)-1 : 0];
	input reset;
	
	output value[busWidth-1 : 0];
	
	reg [width*height-1 : 0] board [busWidth-1 : 0];
	
	always @(posedge reset)
	begin
		integer i = 0;
		for(i = 0; i < width*height; i = i+1)
		begin
			board[i] = busWidth'b0;
		end
	end
	
endmodule