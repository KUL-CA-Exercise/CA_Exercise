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
      addr_ext_2  = dmem_cnt<<2;
      wait(clk==1'b1);
   end

   wen_ext_2   = 1'b0;
   ren_ext_2   = 1'b0;
   wdata_ext_2 = 'b0;
   addr_ext_2  = 'b0;
end
endtask 


parameter integer CASE_N_MAX = 128;
reg signed [63:0] ref_reg [CASE_N_MAX];
reg [8*32:1] ref_str [CASE_N_MAX];

task test_basic;
integer i,j;
integer ref_reg_idx [CASE_N_MAX];
begin   
   j = 0;
   ref_reg_idx[j] = 8;
   ref_reg[j] = $signed(64'd7);
   ref_str[j] = "ADDI";
   j = j+1;
   ref_reg_idx[j] = 9;
   ref_reg[j] = $signed(64'd9);
   ref_str[j] = "ADDI";
   j = j+1;
   ref_reg_idx[j] = 18;
   ref_reg[j] = $signed(64'd9);
   ref_str[j] = "SW and LW";
   j = j+1;
   ref_reg_idx[j] = 19;
   ref_reg[j] = $signed(64'd16);
   ref_str[j] = "ADD";
   j = j+1;
   ref_reg_idx[j] = 20;
   ref_reg[j] = $signed(64'd25);
   ref_str[j] = "BEQ";
   j = j+1;
   ref_reg_idx[j] = 21;
   ref_reg[j] = $signed(64'd1152);
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

task debug_regfile;
integer i;
begin
   for(i=1; i<32; i=i+1) $display("Debug info, reg_array[%d]: %h", i, dut.register_file.reg_array[i]);
end
endtask

task test_mult;
   if(dut.register_file.reg_array[9] == 32'hBE)begin
      $display("%c[1;34m",27);
      $display("Multiplication Working Correctly");
      $display("%c[0m",27);
   end else begin
      $display("%c[1;31m",27);
      $display("Error in Mult function");
      $display("%c[0m",27);
      debug_regfile();
   end   
endtask


task test_mult_2;
   if(dut.register_file.reg_array[23] == 32'hBE)begin
      $display("%c[1;34m",27);
      $display("Multiplication Working Correctly");
      $display("%c[0m",27);
   end else begin
      $display("%c[1;31m",27);
      $display("Error in Mult function");
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
   //stop instruction
   wait (dut.instruction[6:0]==7'b1111110);

   if(dut.instruction[31:28]==4'h0) 
      test_basic();
   else 
      if(dut.instruction[31:28]==4'h1) 
         test_mult();
   else 
      if(dut.instruction[31:28]==4'h2) 
         test_mult_2();
      
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
