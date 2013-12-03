`timescale 1ns / 1ps



module Board(width, height, busWidth, // inputs
	          reset, clk, // basic inputs
			  readX, readY, // read inputs
			  writeEn, writeX, writeY, writeValue, // write inputs
	          readValue); // outputs
	
	input integer width, height, busWidth;
	input reset, clk;
	input readX[log2(width)-1 : 0], readY[log2(height)-1 : 0];
	input writeEn, writeX[log2(width)-1 : 0], writeY[log2(height)-1 : 0], writeValue[busWidth-1 : 0];
	output readValue[busWidth-1 : 0];
	
	reg [width*height-1 : 0] board[busWidth-1 : 0];
	
	wire readI, writeI;
	assign readI = readY*width + readX;
	assign readValue = board[readI];
	assign writeI = writeY*width + writeX;
	
	always @(posedge reset)
	begin : reset_block
		integer i = 0;
		for(i = 0; i < width*height; i = i+1)
		begin
			board[i] = busWidth'b0;
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