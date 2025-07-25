`include "defines.sv"
class alu_monitor;
        //PROPERTIES
        //alu transaction class handle
        alu_transaction mon_trans;
        //Mailbox for monitor to scoreboard connection
        mailbox #(alu_transaction) mbx_ms;
        //Virtual interface with monitor modport and instance
        virtual alu_if.MON vif;

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

        //Methods
        //Explicitly overriding the constructor to make mailbox connection form monitor to scoreboard
        //to make the connection from monitor to scoreboard
        //to connect the virtual interface from monitor to environment
        function new(mailbox #(alu_transaction) mbx_ms,
                    virtual alu_if.MON vif);
                        this.mbx_ms = mbx_ms;
                        this.vif = vif;
                        //creating object for covergroup
                        mon_cg = new();
        endfunction

        //Task to collect the output from the interface
        task start();

                for(int i=0; i<`no_of_trans;i++) begin
                        mon_trans = new();
                        repeat(1) @(vif.mon_cb);
                        begin
                                mon_trans.RES = vif.mon_cb.RES;
                                mon_trans.COUT = vif.mon_cb.COUT;
                                mon_trans.OFLOW = vif.mon_cb.OFLOW;
                                mon_trans.ERR = vif.mon_cb.ERR;
                                mon_trans.E = vif.mon_cb.E;
                                mon_trans.L = vif.mon_cb.L;
                                mon_trans.G = vif.mon_cb.G;
                        end
                        $display("MONITOR PASSING THE DATA TO SCOREBOARD RES=%0d, COUT=%0d, OFLOW=%0d, ERR=%0b, E=%0b, G=%0b, L=%0b",mon_trans.RES,mon_trans.COUT,mon_trans.OFLOW,mon_trans.ERR,mon_trans.E,mon_trans.G,mon_trans.L,$time);
                        //Putting the collected outputs to mailbox
                        mbx_ms.put(mon_trans);
                        //sampling the covergroup
                        mon_cg.sample();
                        $display("OUTPUT FUNCTIONAL COVERAGE = %0d", mon_cg.get_coverage());
                        repeat(1) @(vif.mon_cb);
                end
        endtask
endclass
