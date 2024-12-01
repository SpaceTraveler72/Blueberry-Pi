module upcount2 (
input logic CLR , CLKb ,
output logic [1:0] CNT
);

always_ff @(negedge CLKb) begin
    if (CLR) begin
        CNT <= 2'b00;
    end else begin
        CNT <= CNT + 2'd1;
    end
end

endmodule