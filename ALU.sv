module ALU (
    input logic [9:0] OP ,
    input logic [3:0] FN ,
    input logic Ain , Gin , Gout , CLKb ,
    output logic [9:0] Q
);

    logic [9:0] A, B;

    always_ff @(negedge CLKb) begin
        if (Ain) begin
            A <= OP;
        end
        if (Gin) begin
            B <= OP;
        end
    end


    always_ff @(negedge CLKb) begin
        if (Gout) begin
            case (FN)
                4'b0010: Q = A + B; // add
                4'b0011: Q = A - B; // sub
                4'b0100: Q = -B; // inv
                4'b0101: Q = ~B; // flp
                4'b0110: Q = A & B; // and
                4'b0111: Q = A | B; // or
                4'b1000: Q = A ^ B; // xor
                4'b1001: Q = A << B; // lsl
                4'b1010: Q = A >> B; // lsr
                4'b1011: Q = A >>> B; // asr
                default: Q = 10'b0;
            endcase
        end
    end

endmodule