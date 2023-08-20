

module colsel (
	input wire [2:0] col_counter,
	output reg [7:0] decode_out
);
	always@(col_counter) begin
		case(col_counter)
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

module cvmux(
	input wire [2:0] col_counter,
	input wire [63:0] vbuf,
	output reg [7:0] mux_out
);
	always@(col_counter) begin
		case(col_counter)
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
endmodule

