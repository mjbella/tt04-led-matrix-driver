`default_nettype none

module tt_um_mjbella_led_matrix_driver (
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

	genvar l;
	generate
	  for (l=0; l<=7; l++) begin
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
		if(reset)
			chain[0] <= 0;
		else
			chain[0] <= din;
	end

	genvar k;
	generate 
	  for (k = 0; k < nleds-1; k++) begin
		always@(posedge dclk) begin
            if(reset)
				chain[k+1] <= 0;
			else
				chain[k+1] <= chain[k];
		end
	  end
	endgenerate

	// Latch data from input chain to display buffer
	genvar j;
	generate 
	  for (j = 0; j < nleds; j++) begin
		always@(posedge strobe) begin
			if(reset)
				vbuf[j] <= 0;
			else
				vbuf[j] <= chain[j];
		end
	  end
	endgenerate
	
	reg [7:0] col_count;
	always@(posedge clk) begin
        if(reset)
            col_count <= 8'b00000000;
        else
		    col_count <= col_count + 1;
	end

	// Divide down the column counter rate by taking the top 3 bits
	wire [2:0] act_col = col_count[7:5];
	// de-ghosting / blanking timer
	reg blank;
	always@(col_count) begin
		if(col_count[4:0] == 5'b01111)
			blank <= 0;
		else if(col_count[4:0] == 5'b00000)
			blank <= 1;
	end

	cvmux cmux(.col_counter(act_col), .mux_out(col_out), .vbuf(vbuf));
	colsel cdec(.col_counter(act_col), .decode_out(col_select));

endmodule
