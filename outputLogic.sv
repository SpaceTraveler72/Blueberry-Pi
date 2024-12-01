module outputLogic(
    input logic [9:0] Bus, Reg,
    input logic [1:0] Time,
    input logic Peekb, done,
    output logic [9:0] Led_B,
    output logic [6:0] DHEX0, DHEX1, DHEX2, THEX,
    output logic Led_D
);

assign Led_B = Bus;
assign Led_D = done;

logic [3:0] seg0, seg1, seg2;
logic hexSwitch;

initial begin
    hexSwitch = 1'b0;
end

always_ff @(negedge Peekb) begin
    hexSwitch <= ~hexSwitch;
end

always_comb begin
    if (hexSwitch) begin
        seg0 = Bus[3:0];
        seg1 = Bus[7:4];
        seg2 = Bus[9:8];
    end else begin
        seg0 = Reg[3:0];
        seg1 = Reg[7:4];
        seg2 = Reg[9:8];
    end
end

seven_seg s0(.a(seg0), .result(DHEX0));
seven_seg s1(.a(seg1), .result(DHEX1));
seven_seg s2(.a(seg2), .result(DHEX2));
seven_seg s3(.a(Time), .result(THEX));

endmodule