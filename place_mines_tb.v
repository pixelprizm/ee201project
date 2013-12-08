`timescale 1ns / 1ps



module PlaceMines_tb;
	
	reg reset_tb, clk_tb, start_tb, ack_tb;
	reg [5:0] totalMines_tb;
	wire [$clog2(boardWidth_tb)-1 : 0] placeMineX_tb;
	wire [$clog2(boardHeight_tb)-1 : 0] placeMineY_tb;
	wire mineBoardReadValue_tb;
	wire placeMineEn_tb;
	
	wire qInit_tb, qPlaceMine_tb, qChangeXY_tb, qAlmostDone_tb, done_tb;
	reg [4*8-1 : 0] stateString;
	
	parameter CLK_PERIOD = 20;
	localparam boardWidth_tb = 8, boardHeight_tb = 8;
	
	
	
	// Board Reading and Writing:
	reg boardReset_tb;
	reg [$clog2(boardWidth_tb)-1 : 0] readBoardX_tb;
	reg [$clog2(boardHeight_tb)-1 : 0] readBoardY_tb;
	// (mineBoardReadValue_tb is declared above)
	wire [3:0] adjBoardReadValue_tb;
	
	Board #(.width(boardWidth_tb), .height(boardHeight_tb), .busWidth(1)) mineBoard (
			.reset(boardReset_tb), .clk(clk_tb),
			.readX(readBoardX_tb), .readY(readBoardY_tb),
			.readValue(mineBoardReadValue_tb),
			.writeEn(placeMineEn_tb), .writeX(placeMineX_tb), .writeY(placeMineY_tb),
			.writeValue(placeMineEn_tb), .incAdjacent(1'b0)
			);
			
	Board #(.width(boardWidth_tb), .height(boardHeight_tb), .busWidth(4)) adjBoard (
			.reset(boardReset_tb), .clk(clk_tb),
			.readX(readBoardX_tb), .readY(readBoardY_tb),
			.readValue(adjBoardReadValue_tb),
			.writeEn(1'b0), .writeX(placeMineX_tb), .writeY(placeMineY_tb),
			.writeValue(4'bx), .incAdjacent(placeMineEn_tb)
			);
	
	
	
	PlaceMines #(.boardWidth(boardWidth_tb), .boardHeight(boardHeight_tb)) UUT (
			.reset(reset_tb), .clk(clk_tb), .start(start_tb), .ack(ack_tb),
			.totalMinesIn(totalMines_tb),
			.x(placeMineX_tb), .y(placeMineY_tb),
			.mineBoardReadValue(mineBoardReadValue_tb),
			.placeMineEn(placeMineEn_tb),
			.init(qInit_tb), .placeMine(qPlaceMine_tb), .changeXY(qChangeXY_tb), .almostDone(qAlmostDone_tb), .done(done_tb)
			);
	
	
	
	always @(*)
	begin
		case({qInit_tb, qPlaceMine_tb, qChangeXY_tb, qAlmostDone_tb, done_tb})
			5'b10000: stateString = "INIT";
			5'b01000: stateString = "PM  ";
			5'b00100: stateString = "CXY ";
			5'b00010: stateString = "ALDN";
			5'b00001: stateString = "DONE";
			default: stateString = "UNKN";
		endcase
	end
	
	initial
	begin : reset_generator
		reset_tb = 1;
		boardReset_tb = 1;
		#(2*CLK_PERIOD)
		reset_tb = 0;
		boardReset_tb = 0;
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
		readBoardX_tb = 0;
		readBoardY_tb = 0;
		for(y_i = 0; y_i < boardHeight_tb; y_i = y_i + 1)
		begin
			for(x_i = 0; x_i < boardWidth_tb; x_i = x_i + 1)
			begin
				#0.001; // must be non-zero
				
				// Uncomment for specific coordinates:
				// $write("["); $write(x_i); $write(y_i); $write("]");
				
				if(mineBoardReadValue_tb == 1'b1) $write(" *");
				else $write(adjBoardReadValue_tb);
				
				readBoardX_tb = readBoardX_tb + 1;
			end
			$write("\n");
			
			readBoardY_tb = readBoardY_tb + 1;
		end
		$write("\n");
	end
	endtask
	
	
	
	task generate_board;
	input [5:0] totalMines;
	begin
		@(posedge clk_tb);
		#2;
		boardReset_tb = 1;
		@(posedge clk_tb);
		#2;
		boardReset_tb = 0;
		
		assign readBoardX_tb = placeMineX_tb;
		assign readBoardY_tb = placeMineY_tb;
		
		// Start pulse:
		@(posedge clk_tb);
		#2;
		totalMines_tb = totalMines;
		start_tb = 1;
		@(posedge clk_tb);
		#2;
		start_tb = 0;
		
		// Wait for algorithm to complete:
		@(posedge done_tb);
		
		// Ack pulse:
		#2;
		ack_tb = 1;
		@(posedge clk_tb);
		#2;
		ack_tb = 0;
		
		deassign readBoardX_tb;
		deassign readBoardY_tb;
		display_combined_board;
		#1; // to make sure that display_combined_board completes
	end
	endtask
	
	
	
	initial
	begin : stimulus
		@(negedge reset_tb);
		@(posedge clk_tb);
		#2;
		
		// Initial (all 0's) board
		display_combined_board;
		#1;
		
		// Tests:
		generate_board(10);
		generate_board(12);
		generate_board(6);
		generate_board(20);
	end
	
endmodule