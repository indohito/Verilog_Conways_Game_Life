module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, GPIO_1, CLOCK_50);
    output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	 output logic [9:0]  LEDR;
    input  logic [3:0]  KEY;
    input  logic [9:0]  SW;
    output logic [35:0] GPIO_1;
    input logic CLOCK_50;
	 
	 
	 assign LEDR[0] = SW[0];
	 assign LEDR[8] = SW[8];
	 assign LEDR[9] = SW[9]; 
	 assign RST = SW[8]; 
	 
	 logic [31:0] clk;
	 logic SYSTEM_CLOCK;
	 
	 // System Clock
	 
	 
	 clock_divider divider (.clock(CLOCK_50), .divided_clocks(clk));
	 
	 //assign SYSTEM_CLOCK = clk[14]; // board clock
	 assign SYSTEM_CLOCK = CLOCK_50; // simulation clock
	
	 logic [15:0][15:0]RedPixels;
    logic [15:0][15:0]GrnPixels; 
	 
	 
	 // set up GPIO board
	 LEDDriver Driver (.CLK(SYSTEM_CLOCK), .RST, .EnableCount(1'b1), .RedPixels, .GrnPixels, .GPIO_1);
	 
	 //input keys for player
	 player_input key0 (.clk(SYSTEM_CLOCK), .reset(RST), .KEY(KEY[0]), .KEY_out(key0_pulse));
	 player_input key1 (.clk(SYSTEM_CLOCK), .reset(RST), .KEY(KEY[1]), .KEY_out(key1_pulse));
	 player_input key2 (.clk(SYSTEM_CLOCK), .reset(RST), .KEY(KEY[2]), .KEY_out(key2_pulse));
	 player_input key3 (.clk(SYSTEM_CLOCK), .reset(RST), .KEY(KEY[3]), .KEY_out(key3_pulse));
	 
	 logic  [3:0] input_keys;
	 assign input_keys = {key0_pulse, key1_pulse, key3_pulse, key2_pulse};

	 
	 genvar x,y;
	 generate
		for (y = 1; y < 9; y++) begin: col
			for (x = 1; x < 8; x++) begin: row
				red red (.clk(SYSTEM_CLOCK), .reset(RST), .SW_pause(SW[9]), .KEY(input_keys),
									.LEDR({
									RedPixels[y-1][x-1], RedPixels[y-1][x],
									RedPixels[y-1][x+1], RedPixels[y][x+1],
									RedPixels[y+1][x+1], RedPixels[y+1][x], 
									RedPixels[y+1][x-1], RedPixels[y][x-1]
									}),
									.LEDR_out(RedPixels[y][x]));
									
				green green (.clk(SYSTEM_CLOCK), .reset(RST), .SW_pause(SW[9]), .SW_activate(SW[0]), 
									.red_led(RedPixels[y][x]), .KEY(input_keys),
									.LEDR({
									GrnPixels[y-1][x-1], GrnPixels[y-1][x],
									GrnPixels[y-1][x+1], GrnPixels[y][x+1],
									GrnPixels[y+1][x+1], GrnPixels[y+1][x], 
									GrnPixels[y+1][x-1], GrnPixels[y][x-1]
									}),
									.LEDR_out(GrnPixels[y][x]));
				end
		end
		
		for (y = 1; y < 8; y++) begin: lastCol
			red red (.clk(SYSTEM_CLOCK), .reset(RST), .SW_pause(SW[9]), .KEY(input_keys),
								.LEDR({
								RedPixels[y-1][7], RedPixels[y-1][8],
								RedPixels[y-1][9], RedPixels[y][9],
								RedPixels[y+1][9], RedPixels[y+1][8], 
								RedPixels[y+1][7], RedPixels[y][7]
								}),
								.LEDR_out(RedPixels[y][8]));
			green green (.clk(SYSTEM_CLOCK), .reset(RST), .SW_pause(SW[9]), .SW_activate(SW[0]), 
									.red_led(RedPixels[y][8]), .KEY(input_keys),
									.LEDR({
									GrnPixels[y-1][7], GrnPixels[y-1][8],
									GrnPixels[y-1][9], GrnPixels[y][9],
									GrnPixels[y+1][9], GrnPixels[y+1][8], 
									GrnPixels[y+1][7], GrnPixels[y][7]
									}),
									.LEDR_out(GrnPixels[y][8]));
		end

		cursor cursor (.clk(SYSTEM_CLOCK), .reset(RST), .SW_pause(SW[9]), .KEY(input_keys),
									.LEDR({
									RedPixels[7][7], RedPixels[7][8],
									RedPixels[7][9], RedPixels[8][9],
									RedPixels[9][9], RedPixels[9][8], 
									RedPixels[9][7], RedPixels[8][7]
									}),
									.LEDR_out(RedPixels[8][8]));
		green green (.clk(SYSTEM_CLOCK), .reset(RST), .SW_pause(SW[9]), .SW_activate(SW[0]), 
									.red_led(RedPixels[8][8]), .KEY(input_keys),
									.LEDR({
									GrnPixels[7][7], GrnPixels[7][8],
									GrnPixels[7][9], GrnPixels[8][9],
									GrnPixels[9][9], GrnPixels[9][8], 
									GrnPixels[9][7], GrnPixels[8][7]
									}),
									.LEDR_out(GrnPixels[8][8]));
	endgenerate 
endmodule


module DE1_SoC_testbench();
	 logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	 logic [9:0]  LEDR;
    logic [3:0]  KEY;
    logic [9:0]  SW;
    logic [35:0] GPIO_1;
    logic CLOCK_50;
	
	DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR, .SW, .GPIO_1, .CLOCK_50);
	// Set up a simulated clock.	
	parameter CLOCK_PERIOD=100;
	initial begin
	CLOCK_50 <= 0;
	forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
	end
	// Test the design.
	initial begin
	
	SW[0] <= 0; repeat(4) @(posedge CLOCK_50);
	SW[8] <= 0; repeat(4) @(posedge CLOCK_50);
	SW[9] <= 0; repeat(4) @(posedge CLOCK_50);
	KEY[0] <= 0; repeat(4) @(posedge CLOCK_50); 
	KEY[1] <= 0; repeat(4) @(posedge CLOCK_50);
	KEY[2] <= 0; repeat(4) @(posedge CLOCK_50);
	KEY[3] <= 0; repeat(4) @(posedge CLOCK_50);
	
	SW[8] <= 1; repeat(2) @(posedge CLOCK_50);
	SW[8] <= 0; repeat(2) @(posedge CLOCK_50);
	SW[0] <= 1; repeat(4) @(posedge CLOCK_50);
	KEY[0] <= 0; repeat(2) @(posedge CLOCK_50); 
	KEY[0] <= 1; repeat(2) @(posedge CLOCK_50);
	KEY[0] <= 0; repeat(2) @(posedge CLOCK_50); 
	KEY[0] <= 1; repeat(2) @(posedge CLOCK_50);
	KEY[3] <= 0; repeat(2) @(posedge CLOCK_50);
	KEY[3] <= 1; repeat(2) @(posedge CLOCK_50);
	KEY[3] <= 0; repeat(2) @(posedge CLOCK_50);
	KEY[3] <= 1; repeat(2) @(posedge CLOCK_50); 
   KEY[1] <= 0; repeat(2) @(posedge CLOCK_50);
	KEY[1] <= 1; repeat(2) @(posedge CLOCK_50); 
	KEY[1] <= 0; repeat(2) @(posedge CLOCK_50);
	KEY[1] <= 1; repeat(2) @(posedge CLOCK_50); 
	KEY[2] <= 0; repeat(2) @(posedge CLOCK_50);
	KEY[2] <= 1; repeat(2) @(posedge CLOCK_50);
	KEY[2] <= 0; repeat(2) @(posedge CLOCK_50);
	KEY[2] <= 1; repeat(2) @(posedge CLOCK_50); 
	
	
	SW[9] <= 1; repeat(4) @(posedge CLOCK_50);
	SW[9] <= 0; repeat(4) @(posedge CLOCK_50);
	SW[0] <= 0; repeat(4) @(posedge CLOCK_50);
	

	$stop; // End the simulation.
	end
endmodule
