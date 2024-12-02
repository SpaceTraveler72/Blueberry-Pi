// handles the registers for the processor
module registerFile (
    input logic [9:0] D,
    input logic ENW, ENR0, ENR1, CLKb,
    input logic [1:0] WRA, RDA0, RDA1,
    output logic [9:0] Q0, Q1
);

logic [9:0] registers [3:0];

initial begin
	registers[0] = 10'b0;
	registers[1] = 10'b0;
	registers[2] = 10'b0;
	registers[3] = 10'b0;

end

always_ff @(negedge CLKb) begin
    if (ENW) begin
        registers[WRA] <= D;
    end
end

always_ff @(negedge CLKb) begin
    if (ENR0) begin
        Q0 <= registers[RDA0];
    end else begin
        Q0 <= 10'bz;
    end
end

always_comb begin
    if (ENR1) begin
        Q1 = registers[RDA1];
    end else begin
        Q1 = 10'bz;
    end
end

endmodule