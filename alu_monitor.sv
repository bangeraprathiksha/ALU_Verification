// FILE: alu_monitor.sv
class alu_monitor;

  // PROPERTIES
  virtual alu_if.MON vif;
  mailbox #(alu_transaction) mbx_ms;
  alu_transaction mon_trans;
  alu_output_cov mon_cg;

bit mult_check =0;
 // Declare early
    bit is_mult;
    bit is_16cyc;

bit [3:0] cmd;
bit mode;

bit inp_v;
int txns_captured = 0;



 function bit multiplication_check();
    if( vif.mon_cb.CMD inside { 'd9, 'd10 } && vif.mon_cb.MODE ) return 1;
    else
        return 0;
 endfunction


  // Constructor
  function new(mailbox #(alu_transaction) mbx_ms, virtual alu_if.MON vif);
    this.mbx_ms = mbx_ms;
    this.vif = vif;
    mon_cg = new(vif);
  endfunction


task start();
  alu_transaction mon_trans;

  @(negedge vif.RST);             // wait for reset deassertion
  repeat(3) @(vif.mon_cb);   // wait some extra setup time

  for (int i = 0; i < `no_of_trans; i++) begin
    mon_trans = new();
        //repeat(1)@(vif.mon_cb);
        if (multiplication_check())begin
          repeat(2) @(vif.mon_cb)
             #0;
            begin

                mon_trans.RES   = vif.mon_cb.RES;
                mon_trans.OFLOW = vif.mon_cb.OFLOW;
                mon_trans.COUT  = vif.mon_cb.COUT;
                mon_trans.G     = vif.mon_cb.G;
                mon_trans.L     = vif.mon_cb.L;
                mon_trans.E     = vif.mon_cb.E;
                mon_trans.ERR   = vif.mon_cb.ERR;

                $display("time[%0t] MONITOR PASSING THE DATA TO SCOREBOARD res = %d | oflow = %0d | cout = %0d | g = %0d | l = %0d | e = %0d | err = %0d ",$time,  mon_trans.RES, mon_trans.OFLOW, mon_trans.COUT, mon_trans.G, mon_trans.L, mon_trans.E, mon_trans.ERR);
          end
        end

        else if(((mon_trans.INP_VALID == 2'b01 || mon_trans.INP_VALID == 2'b10) && mon_trans.CE && (mon_trans.MODE && mon_trans.CMD inside {0, 1, 2, 3, 8, 9, 10})) || ((mon_trans.INP_VALID == 2'b01 || mon_trans.INP_VALID == 2'b10) && (!mon_trans.MODE && mon_trans.CMD inside {0, 1, 2, 3, 4, 5, 12, 13}))) begin
        repeat(2) @(vif.mon_cb);
        do @(vif.mon_cb);
    while (!(mon_trans.INP_VALID == 2'b11 && mon_trans.CE == 1));

    // Now wait 2 more cycles for result to stabilize
    repeat(2) @(vif.mon_cb);

    // Sample output
    mon_trans.RES   = vif.mon_cb.RES;
    mon_trans.COUT  = vif.mon_cb.COUT;
    mon_trans.OFLOW = vif.mon_cb.OFLOW;
    mon_trans.ERR   = vif.mon_cb.ERR;
    mon_trans.E     = vif.mon_cb.E;
    mon_trans.G     = vif.mon_cb.G;
    mon_trans.L     = vif.mon_cb.L;

    $display("time[%0t] 16 cycle one MONITOR PASSING TO SCOREBOARD: RES=%0d, COUT=%0d, OFLOW=%0d, ERR=%b, E=%b, G=%b, L=%b",
              $time, mon_trans.RES, mon_trans.COUT, mon_trans.OFLOW, mon_trans.ERR,
              mon_trans.E, mon_trans.G, mon_trans.L);

        end
        else begin
        // Wait 2 cycles to let DUT compute the output (pipeline or registered logic)
                repeat(2) @(posedge vif.CLK);

                mon_trans.RES   = vif.mon_cb.RES;
                mon_trans.COUT  = vif.mon_cb.COUT;
                mon_trans.OFLOW = vif.mon_cb.OFLOW;
                mon_trans.ERR   = vif.mon_cb.ERR;
                mon_trans.E     = vif.mon_cb.E;
                mon_trans.G     = vif.mon_cb.G;
                mon_trans.L     = vif.mon_cb.L;

                $display("time[%0t] MONITOR PASSING TO SCOREBOARD: RES=%0d, COUT=%0d, OFLOW=%0d, ERR=%b, E=%b, G=%b, L=%b",
              $time, mon_trans.RES, mon_trans.COUT, mon_trans.OFLOW, mon_trans.ERR,
              mon_trans.E, mon_trans.G, mon_trans.L);
        end
        mbx_ms.put(mon_trans);
        //repeat(1)@(vif.mon_cb);
        mon_cg.sample();
        $display("OUTPUT FUNCTIONAL COVERAGE = %0.2f", mon_cg.get_coverage());
        end

        $display("monitor task done");
endtask



/*task start();
  alu_transaction mon_trans;

  @(negedge vif.RST);
  repeat(3) @(vif.mon_cb);

  for (int i = 0; i < `no_of_trans; i++) begin
    mon_trans = new();

    // Declare early
    //bit is_mult;
    //bit is_16cyc;

    // Wait for INP_VALID to be both valid
    do begin
      @(vif.mon_cb);
    end while (!(vif.mon_cb.INP_VALID == 2'b11 && vif.mon_cb.CE == 1));

    // Now set flags
    is_mult  = (vif.mon_cb.CMD inside {9, 10}) && (vif.mon_cb.MODE == 1);
    is_16cyc = ((vif.mon_cb.INP_VALID == 2'b01 || vif.mon_cb.INP_VALID == 2'b10) &&
               ((vif.mon_cb.MODE && vif.mon_cb.CMD inside {0,1,2,3,8,9,10}) ||
                (!vif.mon_cb.MODE && vif.mon_cb.CMD inside {0,1,2,3,4,5,12,13})));

    if (is_mult) begin
      repeat(2) @(vif.mon_cb);
    end else if (is_16cyc) begin
      repeat(2) @(vif.mon_cb);
    end else begin
      repeat(2) @(vif.mon_cb);
    end

    // Sample output
    mon_trans.RES   = vif.mon_cb.RES;
    mon_trans.COUT  = vif.mon_cb.COUT;
    mon_trans.OFLOW = vif.mon_cb.OFLOW;
    mon_trans.ERR   = vif.mon_cb.ERR;
    mon_trans.E     = vif.mon_cb.E;
    mon_trans.G     = vif.mon_cb.G;
    mon_trans.L     = vif.mon_cb.L;

    $display("time[%0t] MONITOR: RES=%0d, COUT=%0d, OFLOW=%0d, ERR=%b, E=%b, G=%b, L=%b",
              $time, mon_trans.RES, mon_trans.COUT, mon_trans.OFLOW, mon_trans.ERR,
              mon_trans.E, mon_trans.G, mon_trans.L);

    mbx_ms.put(mon_trans);
    mon_cg.sample();
    $display("OUTPUT FUNCTIONAL COVERAGE = %0.2f", mon_cg.get_coverage());
  end

  $display("monitor task done");
endtask



task start();
  alu_transaction mon_trans;

  @(negedge vif.RST);
  repeat(3) @(posedge vif.CLK);



  forever begin
    @(posedge vif.CLK);

    if (vif.mon_cb.INP_VALID == 2'b11 && vif.mon_cb.CE == 1) begin
      // Capture inputs at this moment
      cmd    = vif.mon_cb.CMD;
             mode   = vif.mon_cb.MODE;
       inp_v  = vif.mon_cb.INP_VALID;

      $display("MONITOR captured inputs at time[%0t]: INP_VALID=%b CMD=%0d MODE=%0b CE=%b",
                $time, inp_v, cmd, mode, vif.mon_cb.CE);

      // Check for multiplication or special cases
       is_mult  = (cmd inside {9, 10}) && mode;
       is_16cyc = ((inp_v == 2'b01 || inp_v == 2'b10) &&
                      ((mode && cmd inside {0,1,2,3,8,9,10}) ||
                      (!mode && cmd inside {0,1,2,3,4,5,12,13})));

      // Wait exactly 2 cycles (this delay is based on RTL pipeline)
      repeat(2) @(posedge vif.CLK);

      // Sample outputs
      mon_trans = new();
      mon_trans.RES   = vif.mon_cb.RES;
      mon_trans.COUT  = vif.mon_cb.COUT;
      mon_trans.OFLOW = vif.mon_cb.OFLOW;
      mon_trans.ERR   = vif.mon_cb.ERR;
      mon_trans.E     = vif.mon_cb.E;
      mon_trans.G     = vif.mon_cb.G;
      mon_trans.L     = vif.mon_cb.L;

      mbx_ms.put(mon_trans);
      mon_cg.sample();

      $display("time[%0t] MONITOR: RES=%0d, COUT=%0d, OFLOW=%0d, ERR=%b, E=%b, G=%b, L=%b",
                $time, mon_trans.RES, mon_trans.COUT, mon_trans.OFLOW, mon_trans.ERR,
                mon_trans.E, mon_trans.G, mon_trans.L);

      $display("OUTPUT FUNCTIONAL COVERAGE = %0.2f", mon_cg.get_coverage());

      txns_captured++;

      if (txns_captured == `no_of_trans)
        break;
    end
  end

  $display("monitor task done");
endtask*/


endclass
~                                                                                                            
