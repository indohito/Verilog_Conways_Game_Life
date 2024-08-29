module green (clk, reset, SW_pause, SW_activate, KEY, red_led, LEDR, LEDR_out);
	input logic 	clk, reset, SW_pause, SW_activate, red_led;
	input logic [3:0]		KEY;
	input logic [7:0]		LEDR;
	output logic			LEDR_out;
	enum { led_off, led_on} ps, ns;
	logic 	[2:0] sum;
	
	logic [9:0] count;
	logic count_clk;
	
	assign sum = LEDR[0] + LEDR[1] + LEDR[2] + LEDR[3] + LEDR[4] + LEDR[5] + LEDR[6] + LEDR[7];
	always_comb begin
			// RULES FOR CONWAYS GAME OF LIFE CHECK WIKI PAGE
			case (ps)
				led_on:		if 	  ((sum > 3 | sum < 2 ) & SW_pause)	ns = led_off;
								else 		ns = led_on;
								
				led_off:		if 	  ((sum == 3 & SW_pause) | (red_led & ~SW_pause & SW_activate)) ns = led_on;
								else		ns = led_off;
				default: ns = led_off;				
			endcase
		end
	assign LEDR_out = (ps == led_on);
	
	
	always_ff @(posedge clk) begin
		if (reset)
			ps <= led_off;
		else
			ps <= ns;
	end
endmodule
