`include"defines.sv"

interface alu_if(input bit CLK, RST);
        //Declaring signals with width
        logic[`width-1:0] OPA,OPB;
        logic[`cwidth-1:0] CMD;
        logic MODE,CIN,CE;
        logic[1:0] INP_VALID;

        logic[`width+1:0] RES;
        logic COUT,OFLOW,E,G,L,ERR;

        //Clocking block for driver
        clocking drv_cb@(posedge CLK);
                default input #0 output #0;
                output OPA,OPB,CE,CIN,MODE,INP_VALID,CMD;
                input RST;
        endclocking

        //Clocking block for monitor
        clocking mon_cb@(posedge CLK);
                default input #0 output #0;
                input RES,COUT,OFLOW,E,G,L,ERR;
                input CMD, MODE, CE, CIN, INP_VALID;
        endclocking


        //clocking block for reference model
        clocking ref_cb@(posedge CLK);
                default input #0 output #0;
        endclocking

        //modports for driver, monitor and reference model
        modport DRV(clocking drv_cb, input CLK, RST);
        modport MON(clocking mon_cb, input CLK, RST);
        modport REF_SB(clocking ref_cb, input CLK, RST,INP_VALID);

        //A Checking if signals are valid (not unknown)
      // 1.1
        assert property (@(posedge CLK) !$isunknown(OPA))
        else $error("OPA has unknown value at time %0t", $time);

        // 1.2
        assert property (@(posedge CLK) !$isunknown(OPB))
        else $error("OPB has unknown value at time %0t", $time);

        // 1.3
        assert property (@(posedge CLK) !$isunknown(CIN))
        else $error("CIN has unknown value at time %0t", $time);

        // 1.4
        assert property (@(posedge CLK) !$isunknown(CE))
        else $error("CE has unknown value at time %0t", $time);

        // 1.5
        assert property (@(posedge CLK) !$isunknown(MODE))
        else $error("MODE has unknown value at time %0t", $time);

        // 1.6
        assert property (@(posedge CLK) !$isunknown(INP_VALID))
        else $error("INP_VALID has unknown value at time %0t", $time);

        // 1.7
        assert property (@(posedge CLK) !$isunknown(CMD))
        else $error("CMD has unknown value at time %0t", $time);

     //B
        //1.1 Ensures OUTPUT is 0 when INP_VALID = 2'b00
     property ppt_1;
                @(posedge CLK)
                disable iff (RST)
                (INP_VALID == 2'b00) |=> (RES == 0 && COUT == 0 && OFLOW == 0 && ERR == 0 && G == 0 && L == 0 && E == 0);
        endproperty

        assert property (ppt_1)
        else $error("output is not 0 when INP_VALID = 2'b00", $time);

        //1.2 Operand wait timeout
        property ppt_2;
                @(posedge CLK)
                disable iff (RST)
                (INP_VALID inside {2'b01, 2'b10}) &&((MODE && CMD inside {0, 1, 2, 3, 8, 9, 10}) ||(!MODE && CMD inside {0, 1, 2, 3, 4, 5, 12, 13})) |-> (##[1:15] INP_VALID == 2'b11) or (##16 ERR == 1);
        endproperty

        assert property (ppt_2)
        else $error("ERR not raised at 17th cycle when second operand missing, time=%0t", $time);*/

        //1.3
        property ppt_3;
                @(posedge CLK)
                disable iff (RST)
                (INP_VALID == 2'b11 && MODE == 1) |-> (CMD inside {[0:10]});
        endproperty
        assert property (ppt_3)
        else $error("Invalid CMD=%0d in Arithmetic MODE at time %0t", CMD, $time);

        //1.3_1
        property ppt_3_1;
                @(posedge CLK)
                disable iff (RST)
                (INP_VALID == 2'b11 && MODE == 0) |-> (CMD inside {[0:13]});
        endproperty
        assert property (ppt_3_1)
        else $error("Invalid CMD=%0d in Logical MODE at time %0t", CMD, $time);

        //1.4
        property ppt_4;
                @(posedge CLK)
                disable iff (RST)
                (INP_VALID == 2'b11) |=> ($stable(OPA) && $stable(OPB) && $stable(CMD) && $stable(MODE) && $stable(CIN)) throughout (INP_VALID == 2'b11);
        endproperty

        assert property (ppt_4)
        else $error("Inputs changed during operation when INP_VALID == 2'b11 at time %0t", $time);*/

        //1.5
        property ppt_5;
                @(posedge CLK)
                disable iff (RST)
                (CIN && INP_VALID == 2'b11) |-> (CMD == 4'b0100 || CMD == 4'b0101);
        endproperty

        assert property (ppt_5)
        else $error("CIN is high for a CMD that is not ADD_CIN or SUB_CIN at time %0t", $time);

        //1.6
        property ppt_6;
                @(posedge CLK)
                disable iff (RST)
                (!CE) |=> (RES == 0 && COUT == 0 && OFLOW == 0 && ERR == 0 && G == 0 && L == 0 && E == 0);
        endproperty

        assert property (ppt_6)
        else $error("Outputs is not 0 when CE is low at time %0t", $time);

        //1.7
      property ppt_7;
                @(posedge CLK)
                disable iff (RST)
                (INP_VALID == 2'b11 && CE && MODE == 1 && (CMD == 9 || CMD == 10)) |=> ##2 $changed(RES);
        endproperty
        assert property (ppt_7)
        else $error("RES changed too early for multiplication (CMD=9/10), time=%0t", $time);*/

        //1.8
        property ppt_8;
                @(posedge CLK)
                disable iff (RST)
                (CMD == 12 || CMD == 13) && MODE == 0 && OPB[7:4] == 4'b1111 && INP_VALID == 2'b11 && CE |=> ERR == 1;
        endproperty

        assert property (ppt_8)
        else $error("ERR should be 1 when CMD=12/13, MODE=0, OPB[7:4]=1111");

        //1.9 COUT
        assert property (@(posedge CLK)
                (INP_VALID==2'b11 && MODE == 1 ) |=>
                (CIN ? {COUT, RES} == (OPA + OPB + 1) : {COUT, RES} == (OPA + OPB))
        );

        //2.0
        assert property (@(posedge CLK)
                (INP_VALID == 2'b11 && MODE == 1 && (CMD == 4'd12 || CMD == 4'd13)) |=> OFLOW
        );


        //2.1
        // Greater-than (G)
        assert property (@(posedge CLK)
                (INP_VALID && MODE == 1 && CMD == 8 && OPA > OPB) |=> (G == 1 && E == 0 && L == 0));

        // Equal (E)
        assert property (@(posedge CLK)
                (INP_VALID && MODE == 1 && CMD == 8 && OPA == OPB) |=> (G == 0 && E == 1 && L == 0));

        // Less-than (L)
        assert property (@(posedge CLK)
                (INP_VALID && MODE == 1 && CMD == 8 && OPA < OPB) |=> (G == 0 && E == 0 && L == 1));







endinterface
                                                                                                                               
