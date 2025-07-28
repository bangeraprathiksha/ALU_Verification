     mailbox #(alu_transaction) mbx_dr;
        //Virtual interface with driver modport and it's instance
        virtual alu_if.DRV vif;


        bit [3:0] cmd_fixed;
        bit ce_fixed;
        bit mode_fixed;

        //FUNCTIONAL COVERAGE for inputs
        covergroup drv_cg;
                option.per_instance = 1;
                // OPA Coverpoint
                cp_opa: coverpoint drv_trans.OPA {
                        bins opa_bins[10] = {[0:255]};
                }
                // OPB Coverpoint
                cp_opb: coverpoint drv_trans.OPB {
                        bins opb_bins[10] = {[0:255]};
                }
                // CE Coverpoint
                cp_ce: coverpoint drv_trans.CE {
                        bins ce_0 = {0};
                        bins ce_1 = {1};
                }
                // CIN Coverpoint
                cp_cin: coverpoint drv_trans.CIN {
                        bins cin_0 = {0};
                        bins cin_1 = {1};
                }

                // MODE Coverpoint
                cp_mode: coverpoint drv_trans.MODE {
                        bins mode_0 = {0};
                        bins mode_1 = {1};
                }

                // INP_VALID Coverpoint
                cp_inp_valid: coverpoint drv_trans.INP_VALID {
                        bins no_valid   = {2'b00};
                        bins only_a     = {2'b01};
                        bins only_b     = {2'b10};
                        bins both_valid = {2'b11};
                }
                // CMD Coverpoint
                cp_cmd: coverpoint drv_trans.CMD {
                        bins add_and          = {0};
                        bins sub_nand         = {1};
                        bins add_cin_or       = {2};
                        bins sub_cin_nor      = {3};
                        bins inc_a_xor        = {4};
                        bins dec_a_xnor       = {5};
                        bins inc_b_not_a      = {6};
                        bins dec_b_not_b      = {7};
                        bins cmp_shr1_a       = {8};
                        bins inc_mul_shl1_a   = {9};
                        bins shift_mul_shr1_b = {10};
                        bins shl1_            = {11};
                        bins rol_a_b          = {12};
                        bins ror_a_b          = {13};
                }

                // Cross Coverages
                cross cp_inp_valid, cp_cmd;
                cross cp_cmd, cp_mode;
                cross cp_mode, cp_inp_valid;

        endgroup


        //METHODS
        //Explicitly overriding the constructor to make the connection form driver to generator
        //to make mailbox connection from driver to reference model and
        //to connect the virtual interface from driver to environment
        function new(mailbox #(alu_transaction) mbx_gd,
                        mailbox #(alu_transaction) mbx_dr,
                        virtual alu_if.DRV vif);
                this.mbx_gd = mbx_gd;
                this.mbx_dr = mbx_dr;
                this.vif  = vif;
                //Creating a object for covergroup
                drv_cg = new();
        endfunction

        //Task to drive the stimuli to the interface
        task start();
         $display(" dRIVER : [ %0t ] ", $time);
        repeat(1) @(vif.drv_cb);
            $display(" dRIVER : [ %0t ] ", $time);
                for(int i=0; i<`no_of_trans;i++) begin
                        drv_trans = new();
                        //getting transaction from generator
                        mbx_gd.get(drv_trans);
                        $display("%0t got",$time);
                        /*if(vif.drv_cb.RST == 0) begin

                                        vif.drv_cb.OPA <= 0;
                                        vif.drv_cb.OPB <= 0;
                                        vif.drv_cb.CMD <= 0;
                                        vif.drv_cb.INP_VALID <=0;
                                        vif.drv_cb.MODE <= 0;
                                        vif.drv_cb.CE <= 0;
                                        vif.drv_cb.CIN <= 0;
                                        mbx_dr.put(drv_trans);

                                        $display("Time[%0t ]DRIVER DRIVING DATA TO THE INTERFACE OPA=%0d,OPB=%0d,INP_VALID=%0d,CMD=%0d,MODE=%0d,CE=%0b,CIN=%0b",$time,vif.drv_cb.OPA,vif.drv_cb.OPB,vif.drv_cb.INP_VALID,vif.drv_cb.CMD,vif.drv_cb.MODE,vif.drv_cb.CE,vif.drv_cb.CIN);
                                end*/
                        if (((drv_trans.INP_VALID == 2'b01 || drv_trans.INP_VALID == 2'b10) && drv_trans.CE && (drv_trans.MODE && drv_trans.CMD inside {0, 1, 2, 3, 8, 9, 10})) || ((drv_trans.INP_VALID == 2'b01 || drv_trans.INP_VALID == 2'b10) && (!drv_trans.MODE && drv_trans.CMD inside {0, 1, 2, 3, 4, 5, 12, 13}))) begin


                                        cmd_fixed <= drv_trans.CMD;
                                        ce_fixed  <= drv_trans.CE;
                                        mode_fixed <= drv_trans.MODE;


                                        for (int j = 0; j < 16; j++)
                                        begin
                                                @(vif.drv_cb);
                                                if(drv_trans.randomize() with {CMD == cmd_fixed; MODE == mode_fixed; CE == ce_fixed; })begin
                                                        vif.drv_cb.OPA       <= drv_trans.OPA;
                                                        vif.drv_cb.OPB       <= drv_trans.OPB;
                                                        vif.drv_cb.CMD       <= drv_trans.CMD;
                                                        vif.drv_cb.INP_VALID <= drv_trans.INP_VALID;
                                                        vif.drv_cb.MODE      <= drv_trans.MODE;
                                                        vif.drv_cb.CE        <= drv_trans.CE;
                                                        vif.drv_cb.CIN       <= drv_trans.CIN;

                                                        mbx_dr.put(drv_trans);
                                                        if (drv_trans.INP_VALID == 2'b11) begin                                                                                                                         break;
                                                        end
                                                end
                                                else
                                                        $display("Randomization Failed!!");
                                        end
                                         $display("time[%0t] DRIVER DRIVING DATA TO THE INTERFACE OPA=%0d,OPB=%0d,INP_VALID=%0d,CMD=%0d,MODE=%0d,CE=%0b,CIN=%0b",$time,vif.drv_cb.OPA,vif.drv_cb.OPB,vif.drv_cb.INP_VALID,vif.drv_cb.CMD,vif.drv_cb.MODE,vif.drv_cb.CE,vif.drv_cb.CIN);
                                         mbx_dr.put(drv_trans);
                                        $display("INPUT FUNCTIONAL COVERAGE = %0d",drv_cg.get_coverage());
                        end
                        else  begin

                                        vif.drv_cb.OPA <= drv_trans.OPA;
                                        vif.drv_cb.OPB <= drv_trans.OPB;
                                        vif.drv_cb.CMD <= drv_trans.CMD;
                                        vif.drv_cb.INP_VALID <= drv_trans.INP_VALID;
                                        vif.drv_cb.MODE <= drv_trans.MODE;
                                        vif.drv_cb.CE <= drv_trans.CE;
                                        vif.drv_cb.CIN <= drv_trans.CIN;

                                        $display("time[%0t] DRIVER WRITE OPERATION DRIVING DATA TO THE INTERFACE  OPA=%0d,OPB=%0d,INP_VALID=%0d,CMD=%0d,MODE=%0d,CE=%0b,CIN=%0b",$time,vif.drv_cb.OPA,vif.drv_cb.OPB,vif.drv_cb.INP_VALID,vif.drv_cb.CMD,vif.drv_cb.MODE,vif.drv_cb.CE,vif.drv_cb.CIN);
                                        //Putting the randmized inputs to maibox
                                        mbx_dr.put(drv_trans);
                                        //$display("INPUT FUNCTIONAL COVERAGE = %0d",drv_cg.get_coverage());
                                end
                        drv_cg.sample();
                         $display("INPUT FUNCTIONAL COVERAGE = %0d",drv_cg.get_coverage());
                end
        endtask
endclass
