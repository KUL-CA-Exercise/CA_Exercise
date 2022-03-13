// module: Control
// Function: Generates the control signals for each one of the datapath resources

module control_unit(
      input  wire [6:0] opcode,
      output reg  [1:0] alu_op,
      output reg        reg_dst,
      output reg        branch,
      output reg        mem_read,
      output reg        mem_2_reg,
      output reg        mem_write,
      output reg        alu_src,
      output reg        reg_write,
      output reg        jump
   );

   // RISC-V opcode[6:0] (see RISC-V greensheet)
   parameter integer ALU_R      = 7'b0110011;
   parameter integer ALU_I      = 7'b0010011;
   parameter integer BRANCH_EQ  = 7'b1100011;
   parameter integer JUMP       = 7'b1101111;
   parameter integer LOAD_WORD  = 7'b0000011;
   parameter integer STORE_WORD = 7'b0100011;

   // RISC-V ALUOp[1:0] (see book Figure 4.12)
   parameter [1:0] ADD_OPCODE     = 2'b00;
   parameter [1:0] SUB_OPCODE     = 2'b01;
   parameter [1:0] R_TYPE_OPCODE  = 2'b10;

   //The behavior of the control unit can be found in Chapter 4, Figure 4.18

   always@(*)begin

      case(opcode)
         ALU_R:begin
            alu_src   = 1'b0;
            mem_2_reg = 1'b0;
            reg_write = 1'b1;
            mem_read  = 1'b0;
            mem_write = 1'b0;
            branch    = 1'b0;
            alu_op    = R_TYPE_OPCODE;
            jump      = 1'b0;
         end

         ALU_I:begin
            alu_src   = 1'b1;
            mem_2_reg = 1'b0;
            reg_write = 1'b1;
            mem_read  = 1'b0;
            mem_write = 1'b0;
            branch    = 1'b0;
            alu_op    = ADD_OPCODE;
            jump      = 1'b0;
         end

         BRANCH_EQ:begin
            alu_src   = 1'b0;
            mem_2_reg = 1'b0;
            reg_write = 1'b0;
            mem_read  = 1'b0;
            mem_write = 1'b0;
            branch    = 1'b1;
            alu_op    = SUB_OPCODE;
            jump      = 1'b0;
         end

         JUMP:begin
            alu_src   = 1'b0;
            mem_2_reg = 1'b0;
            reg_write = 1'b0;
            mem_read  = 1'b0;
            mem_write = 1'b0;
            branch    = 1'b0;
            alu_op    = R_TYPE_OPCODE;
            jump      = 1'b1;
         end

         LOAD_WORD:begin
            alu_src   = 1'b0;
            mem_2_reg = 1'b1;
            reg_write = 1'b1;
            mem_read  = 1'b1;
            mem_write = 1'b0;
            branch    = 1'b0;
            alu_op    = R_TYPE_OPCODE;
            jump      = 1'b0;
         end

         STORE_WORD:begin
            alu_src   = 1'b0;
            mem_2_reg = 1'b0;
            reg_write = 1'b0;
            mem_read  = 1'b0;
            mem_write = 1'b1;
            branch    = 1'b0;
            alu_op    = R_TYPE_OPCODE;
            jump      = 1'b0;
         end

         // Declare the control signals for each one of the instructions here...
         
         default:begin
            alu_src   = 1'b0;
            mem_2_reg = 1'b0;
            reg_write = 1'b0;
            mem_read  = 1'b0;
            mem_write = 1'b0;
            branch    = 1'b0;
            alu_op    = R_TYPE_OPCODE;
            jump      = 1'b0;
         end
      endcase
   end

endmodule



