`timescale 1ns / 1ps



module PlaceMines_tb;
	
	reg reset_tb, clk_tb, start_tb, ack_tb;
	reg [5:0] totalMines_tb;
	wire [2:0] placeMineX_tb; wire [2:0] placeMineY_tb;
	reg mineBoardReadValue_tb;
	wire placeMineEn_tb;
	
	wire qInit_tb, qPlaceMine_tb, qChangeXY_tb, done_tb;
	reg [4*8-1 : 0] stateString;
	
	parameter CLK_PERIOD = 20;
	localparam boardWidth_tb = 8, boardHeight_tb = 8;
	
	
	
	// Board Reading and Writing:
	reg boardReset_tb;
	reg [2:0] readBoardX_tb; reg [2:0] readBoardY_tb;
	wire mineBoardReadValue_tb;
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
			.writeValue(1'bx), .incAdjacent(placeMineEn_tb)
			);
	
	
	
	PlaceMines #(.boardWidth(boardWidth_tb), .boardHeight(boardHeight_tb)) UUT (
			.reset(reset_tb), .clk(clk_tb), .start(start_tb), .ack(ack_tb),
			.totalMinesIn(totalMines_tb),
			.x(placeMineX_tb), .y(placeMineY_tb),
			.mineBoardReadValue(mineBoardReadValue_tb),
			.placeMineEn(placeMineEn_tb),
			.init(qInit_tb), .placeMine(qPlaceMine_tb), .changeXY(qChangeXY_tb), .done(done_tb)
			);
	
	
	
	always @(*)
	begin
		case {qInit_tb, qPlaceMine_tb, qChangeXY_tb, done_tb};
			4'b1000: stateString = "INIT";
			4'b0100: stateString = "PM  ";
			4'b0010: stateString = "CXY ";
			4'b0001: stateString = "DONE";
			default: stateString = "UNKN";
		endcase
	end
	
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
		@(posedge clk_tb);
		#2;
		for(y_i = 0; y_i < boardHeight_tb; y_i = y_i + 1)
		begin
			for(x_i = 0; x_i < boardWidth_tb; x_i = x_i + 1)
			begin
				readBoardX_tb = x_i;
				readBoardY_tb = y_i;
				#1; //not completely sure if we need this
				
				$display(" ");
				if(mineBoardReadValue_tb == 1'b1) $display("*");
				else $display(adjBoardReadValue_tb);
			end
			$display ("\n");
		end
	end
	endtask
	
	
	
	initial
	begin : stimulus
		
	end
	
endmodule