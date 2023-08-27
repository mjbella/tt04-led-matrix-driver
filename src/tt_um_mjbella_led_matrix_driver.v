`default_nettype none

module tt_um_mjbella_led_matrix_driver #( parameter MAX_COUNT = 24'd10_000_000 ) (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

	localparam nleds = 64;

    wire reset = ! rst_n;
	wire [7:0] col_out;
    assign uo_out = col_out;
	wire [7:0] col_select;
	// Replace this with 8 and gates to enable the blanking period.
	//assign uio_out = col_select;
	genvar l;
	generate
	  for (l=0; l<7; l++) begin
		assign uio_out [l] = blank & col_select [l];
	  end
	endgenerate

	// Data input is on ui_in[0]
	wire din = ui_in[0];

	// Data clock input
	wire dclk = ui_in[1];

	// Strobe input
	wire strobe = ui_in[2];

    // use bidirectionals as outputs
    assign uio_oe = 8'b11111111;

	// Input MEMORY
	reg [nleds-1:0] chain;
	// output buffer
	reg [nleds-1:0] vbuf;
	// Clock data in
	always@(posedge dclk) begin
		chain[0] <= din;
	end

	genvar k;
	generate 
	  for (k = 0; k < nleds-1; k++) begin
		always@(posedge clk) begin
		  chain[k+1] <= chain[k];
		end
	  end
	endgenerate

	// Latch data from input chain to display buffer
	genvar j;
	generate 
	  for (j = 0; j < nleds; j++) begin
		always@(posedge strobe) begin
		  vbuf[j] <= chain[j];
		end
	  end
	endgenerate
		
	reg [7:0] col_count;
	always@(posedge clk) begin
		col_count <= col_count + 1;
	end

	// Divide down the column counter rate by taking the top 3 bits
	wire act_col[2:0] = col_count[7:5]
	// de-ghosting / blanking timer
	
	reg blank;
	// TODO: Add blanking time logic
	assign blank = 1'b1;

	cvmux cmux(.col_counter(col_count), .mux_out(col_out), .vbuf(vbuf));
	colsel cdec(.col_counter(col_count), .decode_out(col_select));

endmodule
