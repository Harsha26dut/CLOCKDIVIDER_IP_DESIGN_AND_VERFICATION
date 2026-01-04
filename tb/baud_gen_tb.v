// SYSTEM VERILOG TESTBENCH FOR BAUD RATE GENERATOR
// Using Event-Based Synchronization
localparam SYS_CLK_FREQ = 100_000_000;
localparam SLOWEST_BAUD = 4800;
localparam int WAIT = (SYS_CLK_FREQ / SLOWEST_BAUD) * 3;
localparam real SYS_CLK_PERIOD = 1_000_000_000.0 / SYS_CLK_FREQ;
////////////////////////////////////////////////////////////////////////
// Transaction Class
////////////////////////////////////////////////////////////////////////

class transaction;
 
  rand bit [16:0] baud;      // Randomized baud rate
  bit rst;                    // Reset signal
  real period;                // Measured period of tx_clk
  real expected_period;       // Expected period for verification
 
  // Constraint to select from standard baud rates
  constraint baud_ctrl {  
    baud inside {4800, 9600, 14400, 19200, 38400, 57600};
  }
 
  function new();
  endfunction
 
endclass

////////////////////////////////////////////////////////////////////////
// Generator Class
////////////////////////////////////////////////////////////////////////

class generator;
 
  transaction tr;
  mailbox #(transaction) mbx;
  int count = 0;
  int i = 0;
 
  event next;
  event done;
   
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
    tr = new();
  endfunction;

  task run();
    repeat (count) begin
      assert (tr.randomize) else $error("Randomization failed");
      i++;
      mbx.put(tr);
      $display("[GEN] : Baud Rate : %0d | Iteration : %0d", tr.baud, i);
      @(next);
    end 
    -> done;
  endtask
 
endclass

////////////////////////////////////////////////////////////////////////
// Driver Class
////////////////////////////////////////////////////////////////////////

class driver;
 
  virtual clk_if cif;
  mailbox #(transaction) mbx;
  transaction datac;
  
  event baud_applied;  // Event to signal monitor

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction;

  // Reset the DUT
  task reset();
    cif.rst <= 1'b1;
    cif.baud <= 17'd9600;
    repeat (5) @(posedge cif.clk);
    cif.rst <= 1'b0;
    repeat (2) @(posedge cif.clk);
    $display("[DRV] : DUT Reset Done");
    $display("------------------------------------------");
  endtask
   
  // Apply baud rate to DUT
  task apply_baud();
    @(posedge cif.clk);
    cif.rst <= 1'b0;
    cif.baud <= datac.baud;
    $display("[DRV] : Baud Rate Applied : %0d", datac.baud);
    
    // Wait for DUT to process new baud rate and tx_clk to stabilize
    // Need at least 2 full periods of the slowest baud (4800)
    repeat (WAIT) @(posedge cif.clk);  // ~0.5ms at 50MHz
    
    $display("[DRV] : Baud Rate Stabilized, signaling monitor...");
    -> baud_applied;  // Signal monitor that it's safe to measure
  endtask
 
  // Main driver task
  task run();
    forever begin
      mbx.get(datac);  
      apply_baud();
    end
  endtask
 
endclass

////////////////////////////////////////////////////////////////////////
// Monitor Class - EVENT SYNCHRONIZED
////////////////////////////////////////////////////////////////////////

class monitor;

  virtual clk_if cif;
  mailbox #(transaction) mbx;
  transaction tr;
  
  real ton  = 0;
  real toff = 0;
  
  event baud_applied;  // Event from driver

  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;    
  endfunction;

  task run();
    tr = new();
   
    forever begin
      // WAIT FOR DRIVER TO SIGNAL THAT BAUD IS STABLE
      @(baud_applied);
      $display("[MON] : Baud stabilization event received");
      
      // Now sample baud - guaranteed to be correct!
      tr.baud = cif.baud;
      tr.rst = cif.rst;
      
      // Measure period of tx_clk (time between consecutive rising edges)
      ton = 0;
      toff = 0;
      @(posedge cif.tx_clk);
      ton = $realtime;
      @(posedge cif.tx_clk);
      toff = $realtime;
      
      tr.period = toff - ton;
      
      mbx.put(tr);
      $display("[MON] : Baud:%0d | Measured Period:%0f ns", tr.baud, tr.period);
    end
   
  endtask
 
endclass

////////////////////////////////////////////////////////////////////////
// Scoreboard Class
////////////////////////////////////////////////////////////////////////

class scoreboard;
 
  mailbox #(transaction) mbx;
  transaction tr;
  event next;
  
  int err = 0;
  int pass = 0;
  
  real expected_period;
  real measured_count;
  real expected_count;
  real tolerance = 2.0; // Allow 2 clock cycle tolerance
 
  function new(mailbox #(transaction) mbx);
    this.mbx = mbx;    
  endfunction;

  task run();
    forever begin
      mbx.get(tr);
      
      // Calculate expected period based on baud rate
      // Period = (1 / baud_rate) in seconds, convert to ns
      expected_period = (1.0 / (tr.baud *16)) * 1_000_000_000;
      
      // Calculate counts (period / system_clk_period)
      // System clock period = 20ns for 50MHz
      measured_count = tr.period / SYS_CLK_PERIOD ;
      expected_count = expected_period / (SYS_CLK_PERIOD);
      
      $display("[SCO] : Baud:%0d | Expected Period:%0f ns | Measured Period:%0f ns", 
               tr.baud, expected_period, tr.period);
      $display("[SCO] : Expected Count:%0f | Measured Count:%0f", 
               expected_count, measured_count);
      
      // Check if measured period matches expected within tolerance
      if ((measured_count >= (expected_count - tolerance)) && 
          (measured_count <= (expected_count + tolerance))) begin
        $display("[SCO] : ✓ TEST PASSED - Period within tolerance");
        pass++;
      end
      else begin
        $error("[SCO] : ✗ TEST FAILED - Period mismatch!");
        $display("[SCO] : Difference: %0f counts", measured_count - expected_count);
        err++;
      end
      
      $display("--------------------------------------");
      -> next;
    end
  endtask
 
endclass

////////////////////////////////////////////////////////////////////////
// Environment Class
////////////////////////////////////////////////////////////////////////

class environment;

  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;
  
  mailbox #(transaction) gdmbx; // Generator + Driver mailbox
  mailbox #(transaction) msmbx; // Monitor + Scoreboard mailbox
  
  event nextgs;
  event baud_stable;  // Event for driver-monitor sync
  
  virtual clk_if cif;
 
  function new(virtual clk_if cif);
    gdmbx = new();
    gen = new(gdmbx);
    drv = new(gdmbx);
    
    msmbx = new();
    mon = new(msmbx);
    sco = new(msmbx);
    
    this.cif = cif;
    drv.cif = this.cif;
    mon.cif = this.cif;
    
    // Connect events for synchronization
    gen.next = nextgs;
    sco.next = nextgs;
    drv.baud_applied = baud_stable;  // Driver signals this
    mon.baud_applied = baud_stable;  // Monitor waits for this
  endfunction
 
  task pre_test();
    drv.reset();
  endtask
 
  task test();
    fork
      gen.run();
      drv.run();
      mon.run();
      sco.run();
    join_any
  endtask
 
  task post_test();
    wait(gen.done.triggered);  
    $display("=============================================");
    $display("        SIMULATION COMPLETED");
    $display("=============================================");
    $display("Total Tests Passed : %0d", sco.pass);
    $display("Total Tests Failed : %0d", sco.err);
    if(sco.err == 0) begin
      $display("STATUS: ALL TESTS PASSED ✓");
    end
    else begin
      $display("STATUS: SOME TESTS FAILED ✗");
    end
    $display("=============================================");
    $finish();
  endtask
 
  task run();
    pre_test();
    test();
    post_test();
  endtask
 
endclass

////////////////////////////////////////////////////////////////////////
// Testbench Top Module
////////////////////////////////////////////////////////////////////////

module tb;
   
  clk_if cif();
  
  // DUT Instantiation
  clk_gen dut (
    .clk(cif.clk), 
    .rst(cif.rst), 
    .baud(cif.baud), 
    .tx_clk(cif.tx_clk)
  );
   
  // Clock Generation - 50MHz (20ns period)
  //                  - SYS_CLK_FREQ Mhz ( SYS_CLK_PERIOD ns period)

  initial begin
    cif.clk <= 0;
  end
   
  always #(SYS_CLK_PERIOD/2) cif.clk <= ~cif.clk;
   
  environment env;
   
  initial begin
    env = new(cif);
    env.gen.count = 5; // Test 20 random baud rates
    env.run();
  end
   
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
   
endmodule