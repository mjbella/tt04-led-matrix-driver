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

	localparam nleds = 64;

    wire reset = ! rst_n;
	wire [7:0] col_out;
    assign uo_out = col_out;
	wire [7:0] col_select;
	assign uio_out = col_select;

	// Strobe input on ui in zero
	wire strobe = ui_in[0];

    // use bidirectionals as outputs
    assign uio_oe = 8'b11111111;

	// Input MEMORY
	reg [nleds-1:0] chain;
	// output buffer
	reg [nleds-1:0] vbuf;
	// Clock data in
	always@(posedge clk) begin
		chain[0] <= ui_in[0];
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
		
	reg [2:0] col_count;	
	always@(posedge clk) begin
		col_count <= col_count + 1;
	end

	reg [7:0] mux_out;
	assign col_out = mux_out;
	always@(col_count) begin
		case(col_count)
			3'b000 : mux_out <= vbuf[7:0];
			3'b001 : mux_out <= vbuf[15:8];
			3'b010 : mux_out <= vbuf[23:16];
			3'b011 : mux_out <= vbuf[31:24];
			3'b100 : mux_out <= vbuf[39:32];
			3'b101 : mux_out <= vbuf[47:40];
			3'b110 : mux_out <= vbuf[55:48];
			3'b111 : mux_out <= vbuf[63:56];
		endcase
	end

	reg [7:0] decode_out;
	assign col_select = decode_out;
	always@(col_count) begin
		case(col_count)
			3'b000 : decode_out <= 8'b00000001;
			3'b001 : decode_out <= 8'b00000010;
			3'b010 : decode_out <= 8'b00000100;
			3'b011 : decode_out <= 8'b00001000;
			3'b100 : decode_out <= 8'b00010000;
			3'b101 : decode_out <= 8'b00100000;
			3'b110 : decode_out <= 8'b01000000;
			3'b111 : decode_out <= 8'b10000000;
		endcase
	end
endmodule
