module main(
    input logic [9:0] switches,
    input logic clkButton, realClk, PKb, // display ALU output or newest register
    output logic [9:0] leds,
    output logic [6:0] hexes [2:0], // 3 hex displays
    output logic [6:0] timeStepHex,
    output logic doneSignalDP
);

    logic cleanClk, cleanPKb;

    debouncer (.A_noisy(clkButton), .CLK50M(realClk), .A(cleanClk));
    debouncer (.A_noisy(PKb), .CLK50M(realClk), .A(cleanPKb));

    logic [9:0] inst; 
    wire [9:0] bus;
    logic holdInst, extrn;

    reg10 (.D(bus), .EN(holdInst), .CLKb(clkButton), .Q(inst));

    logic [1:0] timestep;
    logic clkClear;

    upcount2(.CLR(clkClear), .CLKb(cleanClk), .CNT(timestep));

    logic [1:0] enableReadIn, enableReadOut;
    logic regWrite, regRead, writeALUfirst, writeALUsecond, readALU; 
    logic [3:0] aluOp;

    // Processor controller
    processorController (
        .IR(inst),
        .timestep(timestep),
        .IMM(bus),
        .Rin(enableReadIn),
        .Rout(enableReadOut),
        .ENW(regWrite),
        .ENR(regRead),
        .Ain(writeALUsecond),
        .Gin(writeALUfirst),
        .Gout(readALU),
        .ALUcont(aluOp),
        .Ext(extrn),
        .IRin(holdInst),
        .Clr(clkClear)
    );

    always_ff @(negedge cleanClk) begin
        if (extrn) begin
            bus <= switches;
        end else begin
            bus <= 10'bzzzzzzzzzz;
        end
    end

    logic [9:0] regOut0, regOut1;
    // Register file
    registerFile (
        .D(bus),
        .ENW(enableReadOut),
        .ENR0(enableReadIn),
        .ENR1(1'b1),
        .CLKb(cleanClk),
        .WRA(regWrite),
        .RDA0(regRead),
        .RDA1(switches[9:8]),
        .Q0(regOut0),
        .Q1(regOut1)
    );

    // ALU
    ALU (
        .OP(bus),
        .FN(aluOp),
        .Ain(writeALUsecond),
        .Gin(writeALUfirst),
        .Gout(readALU),
        .CLKb(cleanClk),
        .Q(bus)
    );
     
    outputLogic(
        .Bus(bus), 
        .Reg(regOut1),
        .Time(timestep),
        .Peekb(cleanPKb), 
        .done(clkClear),
        .Led_B(leds), 
        .DHEX0(hexes[0]), 
        .DHEX1(hexes[1]), 
        .DHEX2(hexes[2]), 
        .THEX(timeStepHex),
        .Led_D(doneSignalDP)
    );

endmodule