`include "defines.sv"


class alu_scoreboard;

  // Properties
  mailbox #(alu_transaction) mbx_rs; // from reference model
  mailbox #(alu_transaction) mbx_ms; // from monitor

  int match_count = 0;
  int mismatch_count = 0;

  // Constructor
  function new(mailbox #(alu_transaction) mbx_rs,
               mailbox #(alu_transaction) mbx_ms);
    this.mbx_rs = mbx_rs;
    this.mbx_ms = mbx_ms;
  endfunction

  // Compare logic
  function bit compare(alu_transaction mon, alu_transaction ref_txn);
    return (mon.RES   == ref_txn.RES   &&
            mon.COUT  == ref_txn.COUT  &&
            mon.OFLOW == ref_txn.OFLOW &&
            mon.ERR   == ref_txn.ERR   &&
            mon.E     == ref_txn.E     &&
            mon.G     == ref_txn.G     &&
            mon.L     == ref_txn.L);
  endfunction

  // Main scoreboard thread: waits on both mailboxes and matches
  task start();
    alu_transaction mon_data, ref_data;
    for (int i = 0; i < `no_of_trans; i++) begin
      mbx_rs.get(ref_data);
      mbx_ms.get(mon_data);

      if (compare(mon_data, ref_data)) begin
        $display("SCOREBOARD MATCH[%0t]: SUCCESS", $time);
        $display("  RES[mon]=%0d, RES[ref]=%0d", mon_data.RES, ref_data.RES);
        $display("  COUT[mon]=%0d, COUT[ref]=%0d", mon_data.COUT, ref_data.COUT);
        $display("  OFLOW[mon]=%0d, OFLOW[ref]=%0d", mon_data.OFLOW, ref_data.OFLOW);
        $display("  ERR[mon]=%0d, ERR[ref]=%0d", mon_data.ERR, ref_data.ERR);
        $display("  E[mon]=%0d, E[ref]=%0d", mon_data.E, ref_data.E);
        $display("  G[mon]=%0d, G[ref]=%0d", mon_data.G, ref_data.G);
        $display("  L[mon]=%0d, L[ref]=%0d", mon_data.L, ref_data.L);
        match_count++;
      end else begin
        $display("SCOREBOARD MISMATCH[%0t]: FAILURE", $time);
        $display("  RES[mon]=%0d, RES[ref]=%0d", mon_data.RES, ref_data.RES);
        $display("  COUT[mon]=%0d, COUT[ref]=%0d", mon_data.COUT, ref_data.COUT);
        $display("  OFLOW[mon]=%0d, OFLOW[ref]=%0d", mon_data.OFLOW, ref_data.OFLOW);
        $display("  ERR[mon]=%0d, ERR[ref]=%0d", mon_data.ERR, ref_data.ERR);
        $display("  E[mon]=%0d, E[ref]=%0d", mon_data.E, ref_data.E);
        $display("  G[mon]=%0d, G[ref]=%0d", mon_data.G, ref_data.G);
        $display("  L[mon]=%0d, L[ref]=%0d", mon_data.L, ref_data.L);
        mismatch_count++;
      end
    end
  endtask

  // Final report
  task compare_report();
    $display("\n========== SCOREBOARD REPORT ==========");
    $display("Total Matches   = %0d", match_count);
    $display("Total Mismatches= %0d", mismatch_count);
    $display("========================================\n");
  endtask

endclass
