module cpu_tb;


reg              clk;
reg          arst_n;
reg  [31:0]  addr_ext;
reg          wen_ext;
reg          ren_ext;
reg  [31:0]  wdata_ext;
reg  [31:0]  addr_ext_2;
reg          wen_ext_2;
reg          ren_ext_2;
reg  [31:0]  wdata_ext_2;
wire [31:0]  rdata_ext;
wire [31:0]  rdata_ext_2;
reg         enable;

integer half_clock_period_ns = 50;
integer imem_cnt, dmem_cnt;
parameter integer IMEM_SIZE = 2**9;
parameter integer DMEM_SIZE = 2**10;

reg [31:0] instr_mem [0:IMEM_SIZE-1];
reg [31:0] data_mem [0:DMEM_SIZE-1];
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



task test_basic;
   if(dut.register_file.reg_array[16] == 32'h7)begin
      $display("%c[1;34m",27);
      $display("Addi Working Correctly");
      $display("%c[0m",27);
   end else begin
      $display("%c[1;31m",27);
      $display("Error in ADDI function");
      $display("%c[0m",27);
   end
   if(dut.register_file.reg_array[18] == 32'h9)begin
      $display("%c[1;34m",27);
      $display("Load/Store Working Correctly");
      $display("%c[0m",27);
   end else begin
      $display("%c[1;31m",27);
      $display("Error in Load or Store instruction");
      $display("%c[0m",27);
   end
   if(dut.register_file.reg_array[19] == 32'h10)begin
      $display("%c[1;34m",27);
      $display("ADD working correctly");
      $display("%c[0m",27);
   end else begin
      $display("%c[1;31m",27);
      $display("Error in ALU instruction");
      $display("%c[0m",27);
   end
      if(dut.register_file.reg_array[20] == 32'h19)begin
      $display("%c[1;34m",27);
      $display("BRANCH working correctly");
      $display("%c[0m",27);
   end else begin
      $display("%c[1;31m",27);
      $display("Error in BRANCH instruction, Value is %h" ,dut.register_file.reg_array[20] );
      $display("%c[0m",27);
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
   end   
endtask


task test_mult_2;
   if(dut.register_file.reg_array[23] == 32'hBE)begin
      $display("%c[1;34m",27);
      $display("test_mult_2: Multiplication Working Correctly");
      $display("%c[0m",27);
   end else begin
      $display("%c[1;31m",27);
      $display("Error in Mult function");
      $display("%c[0m",27);
   end   
endtask


task test_optional;
   if(dut.register_file.reg_array[23] == 32'h383)begin
      $display("%c[1;34m",27);
      $display("test_optional: Accumulation Working Correctly");
      $display("%c[0m",27);
   end else begin
      $display("%c[1;31m",27);
      $display("Error in Loop Accumulationhex()");
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
   wait (dut.instruction[31:26]==6'b111110);
   if(dut.instruction[1:0]==2'b00) begin
      $display("test basic");
      test_basic();
      end
   else if(dut.instruction[1:0]==2'b01) begin
      $display("test mult_1");
      test_mult();
      end
   else if(dut.instruction[1:0]==2'b10) begin
      $display("test mult_2 or mult_3");
      test_mult_2();
      end
   else begin
      $display("test optional");
      test_optional();
      end
      
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
