module reg10 (
input logic [9:0] D ,
input logic EN , CLKb ,
output logic [9:0] Q
);

always_ff @(posedge CLKb) begin
    if (EN) begin
        Q <= D;
    end
end

endmodule