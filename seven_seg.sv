module seven_seg (
	input logic [3:0] a,
	output logic [6:0] result
);


always_comb begin
      case (a)
            4'h0: result = 7'b100_0000; // 0
            4'h1: result = 7'b111_1001; // 1
            4'h2: result = 7'b010_0100; // 2
            4'h3: result = 7'b011_0000; // 3
            4'h4: result = 7'b001_1001; // 4
            4'h5: result = 7'b001_0010; // 5
            4'h6: result = 7'b000_0010; // 6
            4'h7: result = 7'b111_1000; // 7
            4'h8: result = 7'b000_0000; // 8
            4'h9: result = 7'b001_0000; // 9
            4'hA: result = 7'b000_1000; // A
            4'hB: result = 7'b000_0011; // B
            4'hC: result = 7'b100_0110; // C
            4'hD: result = 7'b010_0001; // D
            4'hE: result = 7'b000_0110; // E
            4'hF: result = 7'b000_1110; // F
            default: result = 7'b111_1111; // Blank display
      endcase
 end


endmodule