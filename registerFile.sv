module registerFile (
	input logic [9:0] D ,
	input logic ENW , ENR0 , ENR1 , CLKb ,
	input logic [1:0] WRA , RDA0 , RDA1 ,
	output logic [9:0] Q0 , Q1
);

logic [9:0] registers [3:0];

always_ff @(posedge CLKb) begin
	if (ENW) begin
		registers[WRA] <= D;
	end
end

always_comb begin
	if (ENR0) begin
		Q0 = registers[RDA0];
	end else begin
		Q0 = 10'b0;
	end

	if (ENR1) begin
		Q1 = registers[RDA1];
	end else begin
		Q1 = 10'b0;
	end
end

endmodule 