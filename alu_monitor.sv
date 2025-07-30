// FILE: alu_monitor.sv
class alu_monitor;

  // PROPERTIES
  virtual alu_if.MON vif;
  mailbox #(alu_transaction) mbx_ms;
  alu_transaction mon_trans;


bit mult_check =0;
 // Declare early
    bit is_mult;
    bit is_16cyc;

bit [3:0] cmd;
bit mode;
bit inp_v;

//FUNCTIONAL COVERAGE for outputs
         covergroup mon_cg;
                option.per_instance = 1;
                cp_res: coverpoint mon_trans.RES {
                        bins res_vals[] = {[-255:$]};
                        }
                cp_cout: coverpoint mon_trans.COUT {
                        bins cout_0 = {0};
                        bins cout_1 = {1};
                        }
                cp_oflow: coverpoint mon_trans.OFLOW{
                        bins oflow_0 = {0};
                        bins oflow_1 = {1};
                        }
                cp_err: coverpoint mon_trans.ERR {
                        bins err_0 = {0};
                        bins err_1 = {1};
                        }
                cp_e: coverpoint mon_trans.E {
                        bins e_0 = {0};
                        bins e_1 = {1};
                        }
                cp_g: coverpoint mon_trans.G {
                        bins g_0 = {0};
                        bins g_1 = {1};
                        }
                cp_l: coverpoint mon_trans.L {
                        bins l_0 = {0};
                        bins l_1 = {1};
                        }
        endgroup
 function bit multiplication_check();
        if( vif.mon_cb.CMD inside { 'd9, 'd10 } && vif.mon_cb.MODE ) return 1;
    else
        return 0;
 endfunction


  // Constructor
  function new(mailbox #(alu_transaction) mbx_ms, virtual alu_if.MON vif);
    this.mbx_ms = mbx_ms;
    this.vif = vif;
    mon_cg = new();
  endfunction


task start();


  //@(negedge vif.RST);             // wait for reset deassertion
  repeat(3) @(vif.mon_cb);   // wait some extra setup time

  for (int i = 0; i < `no_of_trans; i++) begin
    mon_trans = new();
        repeat(1)@(vif.mon_cb);
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

        else
                #0;
                begin

        //repeat(2) @(posedge vif.CLK);

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
        //valid_count++;
        //$display("MONITOR: valid transactions sent = %0d", valid_count);
        repeat(1)@(vif.mon_cb);
        mon_cg.sample();
        $display("OUTPUT FUNCTIONAL COVERAGE = %0.2f", mon_cg.get_coverage());
        end

        $display("monitor task done");
endtask




endclass
