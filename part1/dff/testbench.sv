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
   logic en_i;
   logic d_i;
   logic q_o;

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

   dff
     #()
   dut
     (.clk_i(clk_i)
     ,.reset_i(reset_i)
     ,.en_i(en_i)
     ,.d_i(d_i)
     ,.q_o(q_o)
     );

  logic q_correct;

  // Behavioral Model
  always_ff @(posedge clk_i) begin
    if (reset_i) begin
      q_correct <= '0;
    end
    else if (en_i) begin
      q_correct <= d_i;
    end
  end

  // Checker
  always @(posedge clk_i) begin
    if (q_o !== q_correct) begin
      $display("ERROR, q_o: %b, q_correct: %b", q_o, q_correct);
      error = 1;
    end
  end

  initial begin
    `START_TESTBENCH
    error = 0;
    en_i = 0;
    d_i  = 0;

    @(negedge reset_i);
    
    repeat (20) begin  
    @(negedge clk_i);
    en_i = $urandom_range(0,1);
    d_i  = $urandom_range(0,1);
    end

    #5;

    if (error > 0) begin
    `FINISH_WITH_FAIL;
    end
    else begin
    `FINISH_WITH_PASS;
    end
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
