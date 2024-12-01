/*
Opcode Mnemonic Instruction
XX UU 000000 ld Rx Load data into Rx from the slide switches (external
data input): Rx ← Data
XX YY 000100 cp Rx, Ry Copy the value from Ry and store to Rx: Rx ← [Ry]
XX YY 001000 add Rx, Ry Add the values in Rx and Ry and store the result in
Rx: Rx ← [Rx] + [Ry]
XX YY 001100 sub Rx, Ry Subtract the value in Ry from Rx and store the result
in Rx: Rx ← [Rx]−[Ry]
XX YY 010000 inv Rx, Ry Take the twos-complement of the value in Ry and store
to Rx: Rx ← −[Ry]
XX YY 010100 flp Rx, Ry Flip the bits of the value in Ry and store to Rx: Rx
←∼ [Ry]
XX YY 011000 and Rx, Ry Bit-wise AND the values in Rx and Ry and store the
result in Rx: Rx ← [Rx] & [Ry]
XX YY 011100 or Rx, Ry Bit-wise OR the values in Rx and Ry and store the
result in Rx: Rx ← [Rx] | [Ry]
XX YY 100000 xor Rx, Ry Bit-wise XOR the values in Rx and Ry and stroe the
result in Rx: ← [Rx] ∧ [Ry]
XX YY 100100 lsl Rx, Ry Logical shift left the value in Rx by Ry and store the
result in Rx: Rx ← [Rx] <<[Ry]
XX YY 101000 lsr Rx, Ry Logical shift right the value in Rx by Ry and store the
result in Rx: Rx ← [Rx] >>[Ry]
XX YY 101100 asr Rx, Ry Arithmatic shift right the value of Rx by Ry and store
the result in Rx: ← [Rx] >>>[Ry]
XX IIIIII 01 addi Rx, 6’bIIIIII Add the 6-bit immediate value 10’b0000IIIIII (left-
padded with zeros) to the value in Rx and store in
Rx: Rx ← [Rx] + 10’b0000IIIIII
XX IIIIII 11 subi Rx, 6’bIIIIII Subtract the 6-bit immediate value 10’b0000IIIIII
(left-padded with zeros) from the value in Rx and store
in Rx: Rx ← [Rx] - 10’b0000IIIIII
*/

module processorController (
    input logic [9:0] IR, // Instruction register
    input logic [1:0] timestep, // Timestep counter
    output logic [9:0] IMM, // Immediate value to be used for the two immediate instructions
    output logic [1:0] Rin, // Address for the register to be written to, from the shared data bus
    output logic [1:0] Rout, // Address for the register to be read from, to the shared data bus
    output logic ENW, // Enable signal to write data to the register file
    output logic ENR, // Enable signal to read data from the register file
    output logic Ain, // Enable signal to save data to the intermediate ALU input “A”
    output logic Gin, // Enable signal to save data to the intermediate ALU output “G”
    output logic Gout, // Enable signal to write data from the ALU intermediate output “G” to the shared data bus
    output logic [3:0] ALUcont, // Signal to control which arithmetic or logic operation the ALU should perform
    output logic Ext, // Enable signal to drive the shared data bus from the external “data” signal
    output logic IRin, // Enable signal to save data to the instruction register
    output logic Clr // Clear signal for the timestep counter
);

initial begin
    IRin = 1'b1;
end

always_comb begin
    // Initialize all signals to default values
    ENR = 1'b0;
    Ain = 1'b0;
    Rout = 2'b00;
    Gin = 1'b0;
    Gout = 1'b0;
    ENW = 1'b0;
    Rin = 2'b00;
    Ext = 1'b0;

    // Default values for reset signals
    Clr = 1'b0;
    IRin = 1'b0;

    // Default values for IMM and ALUcont
    ALUcont = 4'bzzzz;
    IMM = 10'bzzzzzzzzzz;


    case (IR[1:0])
        2'b00: begin
            case (IR[5:2])
                4'b0000: handleLoad();
                4'b0001: handleCopy();
                4'b0010: handleALU();
                4'b0011: handleALU();
                4'b0100: handleALU();
                4'b0101: handleALU();
                4'b0110: handleALU();
                4'b0111: handleALU();
                4'b1000: handleALU();
                4'b1001: handleALU();
                4'b1010: handleALU();
                4'b1011: handleALU();

                default: begin
                    Clr = 1'b1;
                    IRin = 1'b1;
                end
            endcase
        end
        2'b01: immediateAdd();
        2'b11: immediateSub();
        default: begin
            Clr = 1'b1;
            IRin = 1'b1;
        end
    endcase
end

function void handleLoad();
    case (timestep)
        2'b00: begin
            Ext = 1'b1;
            ENW = 1'b1;
            Rin = IR[9:8];
        end
        2'b01: begin
            Clr = 1'b1;
            IRin = 1'b1;
            Ext = 1'b1;
        end
    endcase
endfunction

function void handleCopy();
    case (timestep)
        2'b00: begin
            ENR = 1'b1;
            Rout = IR[7:6];
        end
        2'b01: begin
            ENW = 1'b1;
            Rin = IR[9:8];
        end
        2'b10: begin
            Clr = 1'b1;
            IRin = 1'b1;
        end
    endcase
endfunction

function void handleALU();
    case (timestep)
        2'b00: begin
            ENR = 1'b1;
            Ain = 1'b1;
            Rout = IR[7:6];
        end
        2'b01: begin
            ENR = 1'b1;
            Gin = 1'b1;
            Rout = IR[9:8];
        end
        2'b10: begin
            ALUcont = IR[5:2];
            ENW = 1'b1;
            Gout = 1'b1;
            Rin = IR[9:8];
        end
        2'b11: begin
            Clr = 1'b1;
            IRin = 1'b1;
        end
    endcase
endfunction

function void immediateAdd();
    case (timestep)
        2'b00: begin
            IMM = {4'b0000, IR[7:2]};
            Ain = 1'b1;
        end
        2'b01: begin
            ENR = 1'b1;
            Gin = 1'b1;
            Rout = IR[9:8];
        end
        2'b10: begin
            ALUcont = IR[5:2];
            ENW = 1'b1;
            Rin = IR[9:8];
        end
        2'b11: begin
            Clr = 1'b1;
            IRin = 1'b1;
        end
    endcase
endfunction

function void immediateSub();
    case (timestep)
        2'b00: begin
            IMM = {4'b1111, IR[7:2]};
            Ain = 1'b1;
        end
        2'b01: begin
            ENR = 1'b1;
            Gin = 1'b1;
            Rout = IR[9:8];
        end
        2'b10: begin
            ALUcont = IR[5:2];
            ENW = 1'b1;
            Rin = IR[9:8];
        end
        2'b11: begin
            Clr = 1'b1;
            IRin = 1'b1;
        end
    endcase
endfunction

endmodule
