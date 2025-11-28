`timescale 1ns/1ps

`define START_TESTBENCH error_o = 0; pass_o = 0; #10;
`define FINISH_WITH_FAIL error_o = 1; pass_o = 0; #10; $finish();
`define FINISH_WITH_PASS pass_o = 1; error_o = 0; #10; $finish();
module testbench
  (output logic error_o = 1'bx
  ,output logic pass_o = 1'bx);

   logic [0:0] error;
   
   logic clk_i;
   logic reset_i;
   logic up_i;
   logic down_i;
   logic [3:0] count_o;

   nonsynth_clock_gen
     #(.cycle_time_p(10))
   cg
     (.clk_o(clk_i));

   nonsynth_reset_gen
     #(.reset_cycles_lo_p(1)
      ,.reset_cycles_hi_p(10))
   rg
     (.clk_i(clk_i)
     ,.async_reset_o(reset_i));

   counter
     #()
   counter_i
     (.clk_i(clk_i)
     ,.reset_i(reset_i)
     ,.up_i(up_i)
     ,.down_i(down_i)
     ,.count_o(count_o)
     );

  logic [3:0] count_correct;
  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      count_correct <= '0;
    end
    else if (up_i & ~down_i) begin
      count_correct <= count_correct + 1;
    end
    else if (down_i & ~up_i) begin
      count_correct <= count_correct - 1;
    end
    else if (down_i & up_i) begin
      count_correct <= count_correct;
    end
  end

  initial begin
  `START_TESTBENCH

  up_i = 0;
  down_i = 0;

  @(negedge reset_i);
  repeat(2) @(posedge clk_i);

  for (int i = 0; i < 20; i++) begin
    up_i = 1; down_i = 0;
    @(posedge clk_i);
    if (count_o !== count_correct) begin
      $display("FAIL at time %t: expected %0d got %0d", $time, count_correct, count_o);
      `FINISH_WITH_FAIL;
    end
  end

  for (int i = 0; i < 20; i++) begin
    up_i = 0; down_i = 1;
    @(posedge clk_i);
    if (count_o !== count_correct) begin
      $display("FAIL at time %t: expected %0d got %0d", $time, count_correct, count_o);
      `FINISH_WITH_FAIL;
    end
  end

  for (int i = 0; i < 20; i++) begin
    up_i = 1; down_i = 1;
    @(posedge clk_i);
    if (count_o !== count_correct) begin
      $display("FAIL at time %t: expected %0d got %0d", $time, count_correct, count_o);
      `FINISH_WITH_FAIL;
    end
  end

  `FINISH_WITH_PASS;
  end

   // This block executes after $finish() has been called.
   final begin
      $display("Simulation time is %t", $time);
      if(error_o === 1) begin
	 $display("\033[0;31m    ______                    \033[0m");
	 $display("\033[0;31m   / ____/_____________  _____\033[0m");
	 $display("\033[0;31m  / __/ / ___/ ___/ __ \\/ ___/\033[0m");
	 $display("\033[0;31m / /___/ /  / /  / /_/ / /    \033[0m");
	 $display("\033[0;31m/_____/_/  /_/   \\____/_/     \033[0m");
	 $display("Simulation Failed");
     end else if (pass_o === 1) begin
	 $display("\033[0;32m    ____  ___   __________\033[0m");
	 $display("\033[0;32m   / __ \\/   | / ___/ ___/\033[0m");
	 $display("\033[0;32m  / /_/ / /| | \\__ \\\__ \ \033[0m");
	 $display("\033[0;32m / ____/ ___ |___/ /__/ / \033[0m");
	 $display("\033[0;32m/_/   /_/  |_/____/____/  \033[0m");
	 $display();
	 $display("Simulation Succeeded!");
     end else begin
        $display("   __  ___   ____ __ _   ______ _       ___   __");
        $display("  / / / / | / / //_// | / / __ \\ |     / / | / /");
        $display(" / / / /  |/ / ,<  /  |/ / / / / | /| / /  |/ / ");
        $display("/ /_/ / /|  / /| |/ /|  / /_/ /| |/ |/ / /|  /  ");
        $display("\\____/_/ |_/_/ |_/_/ |_/\\____/ |__/|__/_/ |_/   ");
	$display("Please set error_o or pass_o!");
     end
   end

endmodule
