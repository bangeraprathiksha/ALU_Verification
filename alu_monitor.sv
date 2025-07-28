// FILE: alu_monitor.sv
class alu_monitor;

  // PROPERTIES
  virtual alu_if.MON vif;
  mailbox #(alu_transaction) mbx_ms;
  alu_transaction mon_trans;
  alu_output_cov mon_cg;

  // Constructor
  function new(mailbox #(alu_transaction) mbx_ms, virtual alu_if.MON vif);
    this.mbx_ms = mbx_ms;
    this.vif = vif;
    mon_cg = new(vif);
  endfunction


task start();
  for (int i = 0; i < `no_of_trans; i++) begin
    mon_trans = new();

    repeat(2)@(posedge vif.CLK);
    // Wait until DUT starts driving valid output
    wait(^vif.mon_cb.RES !== 1'bx && ^vif.mon_cb.RES !== 1'bz);

    repeat(1)@(posedge vif.CLK); // One more cycle to stabilize

    $display("MONITOR DEBUG @%0t: RES=%0d", $time, vif.mon_cb.RES);

    mon_trans.RES   = vif.mon_cb.RES;
    mon_trans.COUT  = vif.mon_cb.COUT;
    mon_trans.OFLOW = vif.mon_cb.OFLOW;
    mon_trans.ERR   = vif.mon_cb.ERR;
    mon_trans.E     = vif.mon_cb.E;
    mon_trans.G     = vif.mon_cb.G;
    mon_trans.L     = vif.mon_cb.L;

    $display("time[%0t] MONITOR PASSING TO SCOREBOARD: RES=%0d, COUT=%0d, OFLOW=%0d, ERR=%b, E=%b, G=%b, L=%b ",$time,mon_trans.RES, mon_trans.COUT, mon_trans.OFLOW, mon_trans.ERR, mon_trans.E, mon_trans.G, mon_trans.L);

    mbx_ms.put(mon_trans);
    mon_cg.sample();
    $display("OUTPUT FUNCTIONAL COVERAGE = %0.2f", mon_cg.get_coverage());
  end
endtask

endclass
