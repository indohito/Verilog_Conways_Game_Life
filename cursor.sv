module cursor (clk, reset, SW_pause, KEY, LEDR, LEDR_out);
	input logic 	clk, reset, SW_pause;
	// LEDR[0] = LEFT, LEDR[1] = RIGHT
	// KEY[0] corresponds to KEY0, KEY[1] corresponds to KEY3.
	input logic [3:0]		KEY;
	input logic [7:0]		LEDR;
	output logic			LEDR_out;
	enum { led_off, led_on} ps, ns;
	always_comb begin
			case (ps)
				led_off: 		
								if 	((LEDR[6] & KEY[0]) | (LEDR[2] & KEY[1]) | (LEDR[0] & KEY[2]) | (LEDR[4] & KEY[3]))	   ns = 	led_on;
								else	ns = 	led_off;
				
				
				led_on:		if 	  (KEY[0] | KEY[1] | KEY[2] | KEY[3] | SW_pause) ns = led_off;
								else  ns = led_on;
				default: ns = led_off;				
			endcase
		end
	assign LEDR_out =  (ps == led_on);
	// DFFs
	always_ff @(posedge clk) begin
		if (reset)
			ps <= led_on;
		else
			ps <= ns;
	end
endmodule
