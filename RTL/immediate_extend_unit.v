// Module: immediate extend unit

module immediate_extend_unit(
    input wire [31:0] instruction,
    output reg [63:0] immediate_extended
    );

    wire [31:7] instr;
    wire [6:0] opcode;
    reg [2:0] instr_type;

    assign instr = instruction[31:7];
    assign opcode = instruction[6:0];

    // RISC-V opcode[6:0] 
    parameter integer ALU_R      = 7'b0110011;
    parameter integer ALU_I      = 7'b0010011;
    parameter integer BRANCH_EQ  = 7'b1100011;
    parameter integer JUMP       = 7'b1101111;
    parameter integer LOAD_WORD  = 7'b0000011;
    parameter integer STORE_WORD = 7'b0100011;

    always@(*)begin
        case(opcode)
            ALU_I:begin // TYPE_I
                immediate_extended = {{53{instr[31]}}, instr[30:20]};
            end

            BRANCH_EQ:begin // TYPE_SB
                immediate_extended = {{52{instr[31]}}, instr[7], instr[30:25], instr[11:8],1'b0}; // RISC-V: {imm, 1'b0}
            end

            JUMP:begin // TYPE_UJ
            immediate_extended = {{44{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // RISC-V: {imm, 1'b0}
            end

            LOAD_WORD:begin // TYPE_I
                immediate_extended = {{53{instr[31]}}, instr[30:20]};
            end

            STORE_WORD:begin // TYPE_S
                immediate_extended = {{53{instr[31]}}, {instr[30:25], instr[11:7]}};
            end

            default:begin // other types
                immediate_extended = 64'hxxxxxxxx;
            end
        endcase
    end
endmodule