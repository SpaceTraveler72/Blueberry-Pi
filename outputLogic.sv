module outputLogic(
    input logic [9:0] Bus, Reg,
    input logic [1:0] Time,
    input logic Peekb, done,
    output logic [9:0] Led_B,
    output logic [6:0] DHEX0, DHEX1, DHEX2, THEX,
    output logic Led_D
);

assign Led_B = Bus;


endmodule