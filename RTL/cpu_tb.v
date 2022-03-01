module cpu_tb;


reg       	 clk;
reg          arst_n;
reg  [63:0]  addr_ext;
reg          wen_ext;
reg          ren_ext;
reg  [31:0]  wdata_ext;
reg  [63:0]  addr_ext_2;
reg          wen_ext_2;
reg          ren_ext_2;
reg  [63:0]  wdata_ext_2;
wire [31:0]  rdata_ext;
wire [63:0]  rdata_ext_2;
reg          enable;

integer half_clock_period_ns = 50;
integer imem_cnt, dmem_cnt;
parameter integer IMEM_SIZE = 2**9;
parameter integer DMEM_SIZE = 2**10;

reg [31:0] instr_mem [0:IMEM_SIZE-1];
reg [63:0] data_mem [0:DMEM_SIZE-1];
integer counter;

initial begin
   clk    = 1'b0;
   arst_n = 1'b0;
   enable = 1'b0;
   addr_ext = 'b0;
   wen_ext  = 1'b0;
   ren_ext  = 1'b0;
   addr_ext = 'b0;
   wdata_ext = 'b0;
   wen_ext_2  = 1'b0;
   ren_ext_2  = 1'b0;
   addr_ext_2 = 'b0;
   wdata_ext_2 = 'b0;
   cnt_and_wait(10);
   arst_n = 1'b1;
   
   load_dmem();
   load_imem();
   
   cnt_and_wait(1);
   enable = 1'b1;
   counter = 0;

   wait_for_STOP_instruction();
end



always@(posedge clk) begin
  counter <= counter+1;
end


always #half_clock_period_ns begin
   clk = ~clk;
end

cpu dut(
   .clk         (clk        ),
   .enable      (enable     ),
   .arst_n      (arst_n     ),
   .addr_ext    (addr_ext   ),
   .wen_ext     (wen_ext    ),
   .ren_ext     (ren_ext    ),
   .wdata_ext   (wdata_ext  ),
   .addr_ext_2  (addr_ext_2 ),
   .wen_ext_2   (wen_ext_2  ),
   .ren_ext_2   (ren_ext_2  ),
   .wdata_ext_2 (wdata_ext_2),
   .rdata_ext   (rdata_ext  ),
   .rdata_ext_2 (rdata_ext_2)
);



task load_imem();
begin
   for (imem_cnt = 0; imem_cnt < IMEM_SIZE; imem_cnt = imem_cnt+1)  begin
      instr_mem[imem_cnt] = 'b0;
   end
    $readmemh("../SIM/data/imem_content.txt",instr_mem);
   cnt_and_wait(10);
   
   for (imem_cnt = 0; imem_cnt < IMEM_SIZE; imem_cnt = imem_cnt+1)  begin
      wait(clk==1'b0);
      wen_ext   = 1'b1;
      ren_ext   = 1'b0;
      wdata_ext = instr_mem[imem_cnt];
      addr_ext  = imem_cnt<<2;
      wait(clk==1'b1);      
   end

   wen_ext   = 1'b0;
   ren_ext   = 1'b0;
   wdata_ext = 'b0;
   addr_ext  = 'b0;
end
endtask 


task load_dmem();
begin
   for (dmem_cnt = 0; dmem_cnt < DMEM_SIZE; dmem_cnt = dmem_cnt+1)  begin
      data_mem[dmem_cnt] = 'b0;
   end
    $readmemh("../SIM/data/dmem_content.txt",data_mem);
   cnt_and_wait(10);
   
   for (dmem_cnt = 0; dmem_cnt < DMEM_SIZE; dmem_cnt = dmem_cnt+1)  begin
      wait(clk==1'b0);
      wen_ext_2   = 1'b1;
      ren_ext_2   = 1'b0;
      wdata_ext_2 = data_mem[dmem_cnt];
      addr_ext_2  = dmem_cnt<<3;
      wait(clk==1'b1);
   end

   wen_ext_2   = 1'b0;
   ren_ext_2   = 1'b0;
   wdata_ext_2 = 'b0;
   addr_ext_2  = 'b0;
end
endtask 

// To print the entire register file values.
task debug_regfile;
integer i;
begin
   for(i=0; i<32; i=i+1) $display("Debug info, reg_array[%d]: %h", i, dut.register_file.reg_array[i]);
end
endtask

parameter integer CASE_N_MAX = 128;
reg signed [63:0] ref_reg [CASE_N_MAX]; // Correct answer of the probed register.
reg [8*32:1] ref_str [CASE_N_MAX];      // The test case name reference.

task test_basic;
integer i,j;                            // i: the loop index; j: the test case index;
integer ref_reg_idx [CASE_N_MAX];       // The register index to be probed.
begin   
   j = 0;
   ref_reg_idx[j] = 8;                  // To check the value of reg[8].
   ref_reg[j] = $signed(64'h7);         // Reference value of this register.
   ref_str[j] = "ADDI(x8)";             // The case name string.
   j = j+1;
   ref_reg_idx[j] = 9;
   ref_reg[j] = $signed(64'h9);
   ref_str[j] = "ADDI(x9)";
   j = j+1;
   ref_reg_idx[j] = 17;
   ref_reg[j] = $signed(64'h9);
   ref_str[j] = "SD";
   j = j+1;
   ref_reg_idx[j] = 18;
   ref_reg[j] = $signed(64'h123456789a);
   ref_str[j] = "LD";
   j = j+1;
   ref_reg_idx[j] = 19;
   ref_reg[j] = $signed(64'h12345678a3);
   ref_str[j] = "ADD";
   j = j+1;
   ref_reg_idx[j] = 20;
   ref_reg[j] = $signed(64'h2468acf13d);
   ref_str[j] = "BEQ";
   j = j+1;
   ref_reg_idx[j] = 21;
   ref_reg[j] = $signed(64'h91a2b3c4d00);
   ref_str[j] = "SLL";
   j = j+1;

   for(i=0; i<j; i=i+1)begin
      if(dut.register_file.reg_array[ref_reg_idx[i]] == ref_reg[i])begin
         $display("%c[1;34m",27);
         $display("Working Correctly: %s", ref_str[i]);
         $display("%c[0m",27);
      end else begin
         $display("%c[1;31m",27);
         $display("Error in test case: %s", ref_str[i]);
         $display("Debug info, value:    %b", dut.register_file.reg_array[ref_reg_idx[i]]);
         $display("Debug info, expected: %b", ref_reg[i]);
         $display("%c[0m",27);
         debug_regfile();
      end 
   end
end   
endtask

task test_mult_1;
   if(dut.register_file.reg_array[9] == 64'hBE)begin
      $display("%c[1;34m",27);
      $display("Mult1 Working Correctly");
      $display("%c[0m",27);
   end else begin
      $display("%c[1;31m",27);
      $display("Error in Mult1 function");
      $display("%c[0m",27);
      debug_regfile();
   end   
endtask


task test_mult_2;
   if(dut.register_file.reg_array[23] == 64'hBE)begin
      $display("%c[1;34m",27);
      $display("Mult2 Working Correctly");
      $display("%c[0m",27);
   end else begin
      $display("%c[1;31m",27);
      $display("Error in Mult2 function");
      $display("%c[0m",27);
      debug_regfile();
   end   
endtask

task test_mult_3;
   if(dut.register_file.reg_array[23] == 64'hBE)begin
      $display("%c[1;34m",27);
      $display("Mult3 Working Correctly");
      $display("%c[0m",27);
   end else begin
      $display("%c[1;31m",27);
      $display("Error in Mult3 function");
      $display("%c[0m",27);
      debug_regfile();
   end   
endtask

task test_mult_4;
integer i, j;
reg error_flag;
reg [63:0] result_mem_mult4 [0:46]; // data memory index: I-matrix 0-19; W-matrix 20-34; O-Matrix 35-46;
   // MULT4 answers
   ref_reg[0] = 64'h258;
   ref_reg[1] = 64'h2B2;
   ref_reg[2] = 64'h30C;
   ref_reg[3] = 64'h1A9;
   ref_reg[4] = 64'h1EA;
   ref_reg[5] = 64'h22B;
   ref_reg[6] = 64'hFA;
   ref_reg[7] = 64'h122;
   ref_reg[8] = 64'h14A;
   ref_reg[9] = 64'h4B;
   ref_reg[10] = 64'h5A;
   ref_reg[11] = 64'h69;

   for(i=0; i<47; i=i+1)begin // send read request to the cpu dmem module.
      wait(clk==1'b0);
      wen_ext_2   = 1'b0;
      ren_ext_2   = 1'b1;
      addr_ext_2  = i<<3;    
      wait(clk==1'b1);
      result_mem_mult4[i] = rdata_ext_2;
   end

   // result check
   error_flag = 1'b0;
   for(i=0; i<12; i=i+1)begin
      if(result_mem_mult4[i+35] != ref_reg[i])begin
         error_flag = 1'b1;
         $display("%c[1;31m",27);
         $display("Error in Mult4[%d] function", i);
         $display("Debug info, value:    %b", result_mem_mult4[i+35]);
         $display("Debug info, expected: %b", ref_reg[i]);
         $display("%c[0m",27);
      end
   end

   // debug the entire dmem if error occurred
   if(error_flag == 1'b1)begin
      for(i=0; i<47; i=i+1)begin
         $display("=== Data Memory Status ===");
         $display("Debug info, dmem[%d]: %d", i, result_mem_mult4[i]);
      end
   end
   else begin
      $display("%c[1;34m",27);
      $display("Mult4 Working Correctly");
      $display("%c[0m",27);
   end

endtask


task cnt_and_wait;
input [31:0] stop_counter;
integer cnt_cycles;
begin
   for(cnt_cycles = 0; cnt_cycles < stop_counter; cnt_cycles = cnt_cycles+1) begin
      wait(clk==1'b1);
      wait(clk==1'b0);
   end
end
endtask


task wait_for_STOP_instruction;
begin
   // the customized STOP instruction: 
   // [31:28] to distinguish test cases; 
   // [6:0]   a fake Opcode just for the wait();
   wait (dut.instruction[6:0]==7'b1111110);

   case(dut.instruction[31:28])
      4'h0: test_basic();
      4'h1: test_mult_1();
      4'h2: test_mult_2();
      4'h3: test_mult_3();
      4'h4: test_mult_4();
      default: $display("### undefined test ###");
   endcase

   $display("%d cycles", counter);
   $finish;
end
endtask

initial 
  begin
  $dumpfile("vcd_dump.vcd");
  $dumpvars(0);
  end

endmodule
