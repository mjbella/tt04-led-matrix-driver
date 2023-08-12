`default_nettype none

module tt_um_seven_segment_seconds #( parameter MAX_COUNT = 24'd10_000_000 ) (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire reset = ! rst_n;
    //wire [6:0] led_out;
    //assign uo_out[6:0] = led_out;
    //assign uo_out[7] = 1'b0;

    // use bidirectionals as outputs
    assign uio_oe = 8'b11111111;

    // make optimizer happy
    assign uio_out = 8'b00000000;
	assign uo_out[7:1] = 7'b0000000;

	// MEMORY (kinda)
	reg [255:0] chain;

	// Clock data in
	always@(posedge clk) begin
		chain[0] <= ui_in[0];
	end
	// Clock data out at the end
	assign uo_out[0] = chain[255];

	genvar k;
	generate 
	  for (k = 0; k < 255; k++) begin
		always@(posedge clk) begin
		  //val[k] = a[k] & b[k];
		  chain[k+1] <= chain[k];
		end
	  end
	endgenerate

endmodule
