//Branch Unit
//Function: Calculate the next pc in the case of a control instruction (branch or jump).
//Inputs:
//instruction: Instruction currently processed. The least significant bits are used for the calcualting the target pc in the case of a jump instruction. 
//branch_offset: Offset for a branch instruction. 
//updated_pc:  Current PC + 4.
//Outputs: 
//branch_pc: Target PC in the case of a branch instruction.
//jump_pc: Target PC in the case of a jump instruction.

module branch_unit#(
   parameter integer DATA_W     = 16
   )(
      input  wire signed [DATA_W-1:0]  updated_pc,
      input  wire signed [DATA_W-1:0]  immediate_extended,
      output reg  signed [DATA_W-1:0]  branch_pc,
      output reg  signed [DATA_W-1:0]  jump_pc
   );

   localparam  [DATA_W-1:0] PC_INCREASE= {{(DATA_W-3){1'b0}},3'd4};

   always@(*) branch_pc           = updated_pc + immediate_extended - PC_INCREASE;
   always@(*) jump_pc             = updated_pc + immediate_extended - PC_INCREASE;
  
endmodule



