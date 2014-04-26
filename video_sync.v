`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// RGB/VGA/SCART Sync Signal Generator
// Developed by Michael Swan
//
// Current parameters produce a signal with the following characteristics:
// 	Resolution: 320x240
// 	Horizontal Sync Frequency: 15.5 Khz
// 	Vertical Sync Frequency: 60 Hz
//////////////////////////////////////////////////////////////////////////////////

module VideoSync(
			input CLOCK,
			// Output to the DAC
			output PIXEL_CLOCK,
			output V_SYNC,
			output H_SYNC,
			output C_SYNC, // Connect to GPIO
			output VGA_BLANK,
			// Output to other logic
			output reg [8:0] H_COUNTER,
			output reg [8:0] V_COUNTER);
	
	// HSYNC PARAMETERS //
		// Visible pixel count
		parameter H_PIXELS = 320;
		// Duration
		parameter H_FP_DURATION   = 4;
		parameter H_SYNC_DURATION = 48;
		parameter H_BP_DURATION   = 28;
	
	// VSYNC PARAMETERS //
		// Visible pixel count
		parameter V_PIXELS = 240;
		// Duration
		parameter V_FP_DURATION   = 1;
		parameter V_SYNC_DURATION = 15;
		parameter V_BP_DURATION   = 4;

	// HSYNC/VSYNC HELPER PARAMETERS //
		// Edge offset
		parameter H_FP_EDGE = H_FP_DURATION;
		parameter H_SYNC_EDGE = H_FP_EDGE + H_SYNC_DURATION;
		parameter H_BP_EDGE = H_SYNC_EDGE + H_BP_DURATION;
		// Signal period
		parameter H_PERIOD = H_BP_EDGE + H_PIXELS;
		// Edge offset
		parameter V_FP_EDGE = V_FP_DURATION;
		parameter V_SYNC_EDGE = V_FP_EDGE + V_SYNC_DURATION;
		parameter V_BP_EDGE = V_SYNC_EDGE + V_BP_DURATION;
		// Signal period
		parameter V_PERIOD = V_BP_EDGE + V_PIXELS;
  
	// Pixel Clock Generator //
		reg [3:0] clock_divider = 0;
		// Divide the 100MHz clock by 16 to get a 6.25 MHz clock.
		always @(posedge CLOCK) begin
			clock_divider <= clock_divider + 1;
		end
		// Output the 4th bit of the counter to the Pixel Clock.
		assign PIXEL_CLOCK = clock_divider[3];
	// End Pixel Clock Generator //
	
	// Scan Location Tracker //
		always @(posedge PIXEL_CLOCK) begin
			H_COUNTER <= H_COUNTER + 1;
			if(H_COUNTER == H_PERIOD - 1) begin
				H_COUNTER <= 0;
				V_COUNTER <= V_COUNTER + 1;
			end
			if(V_COUNTER == V_PERIOD - 1) begin
				// TODO: Make sure that the edges of the signals properly line up.
				V_COUNTER <= 0;
				H_COUNTER <= 0;
			end
		end
	// End Scan Location Tracker //
	
	// Output synchronization signals
	assign V_SYNC = (V_COUNTER < V_FP_EDGE || V_COUNTER > V_SYNC_EDGE);
	assign H_SYNC = (H_COUNTER < H_FP_EDGE || H_COUNTER > H_SYNC_EDGE);
	assign C_SYNC = !(H_SYNC ^ V_SYNC);
	assign VGA_BLANK = 1; // Disable VGA output blanking.
endmodule
