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

parameter 
    LOAD = 4'b0000,             // Load data from the instruction register to Rx: Rx←[Rx]
    COPY = 4'b0001;             // Copy the value from Ry and store to Rx: Rx←[Ry]

always_comb begin
    // Initialize all enable signals to default values
    ENR = 1'b0;
    Ain = 1'b0;
    Rout = 2'b00;
    Gin = 1'b0;
    Gout = 1'b0;
    ENW = 1'b0;
    Rin = 2'b00;
    IRin = 1'b0;
    Ext = 1'b0;
    Clr = 1'b0;

    // Default values for IMM and ALUcont
    ALUcont = 4'bzzzz;
    IMM = 10'bzzzzzzzzzz;

    // At timestep 00, read the instruction register
    if (timestep == 2'b00) begin
        IRin = 1'b1;
        Ext = 1'b1;
    end else begin
        case (IR[1:0])
            2'b00: begin
                case (IR[5:2])
                    LOAD: handleLoad();
                    COPY: handleCopy();
                    default: begin
                        // Check if the instruction is an ALU operation
                        if (IR[5:2] >= 4'b0010 && IR[5:2] <= 4'b1011) begin
                            handleALU();
                        end else begin
                            Clr = 1'b1;
                        end
                    end
                endcase
            end
            2'b01: immediateOp(1);
            2'b11: immediateOp(0);
            default: Clr = 1'b1;
        endcase
    end
end

function void handleLoad();
    case (timestep)
        2'b01: begin
            Ext = 1'b1;
            ENW = 1'b1;
            Rin = IR[9:8];
            Clr = 1'b1;
        end
		default: Clr = 1'b1;
    endcase
endfunction

function void handleCopy();
    case (timestep)
        2'b01: begin
            ENR = 1'b1;
            Rout = IR[7:6];
            ENW = 1'b1;
            Rin = IR[9:8];
            Clr = 1'b1;
        end
		default: Clr = 1'b1;
    endcase
endfunction

function void handleALU();
    case (timestep)
        2'b01: begin
            ENR = 1'b1;
            Ain = 1'b1;
            Rout = IR[7:6];
        end
        2'b10: begin
            ENR = 1'b1;
            Gin = 1'b1;
            Rout = IR[9:8];
        end
        2'b11: begin
            ALUcont = IR[5:2];
            ENW = 1'b1;
            Gout = 1'b1;
            Rin = IR[9:8];
            Clr = 1'b1;
        end
		default: Clr = 1'b1;
    endcase
endfunction

function void immediateOp(logic isAdd);
    case (timestep)
        2'b01: begin
            if (isAdd) begin
                IMM = {4'b0000, IR[7:2]};
            end else begin
                IMM = {4'b1111, IR[7:2]};
            end
            Ain = 1'b1;
        end
        2'b10: begin
            ENR = 1'b1;
            Gin = 1'b1;
            Rout = IR[9:8];
        end
        2'b11: begin
            if (isAdd) begin
                ALUcont = 4'b0010;
            end else begin
                ALUcont = 4'b0011;
            end
            ENW = 1'b1;
            Rin = IR[9:8];
            Clr = 1'b1;
        end
		default: Clr = 1'b1;
    endcase
endfunction

endmodule