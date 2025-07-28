`include"defines.sv"

import alu_pkg::*;
interface alu_if(input bit CLK, RST);
        //Declaring signals with width
        logic[`width-1:0] OPA,OPB;
        logic[`cwidth-1:0] CMD;
        logic MODE,CIN,CE;
        logic[1:0] INP_VALID;

        logic[`width+1:0] RES;
        logic COUT,OFLOW,E,G,L,ERR;

        clocking drv_cb @(posedge CLK);
                default input #0 output #0;
                input output OPA, OPB, CE, CIN, MODE, INP_VALID, CMD;
                input RST;
        endclocking


        /*Clocking block for driver
        clocking drv_cb@(posedge CLK);
                //Specifying the values for input and output skews
        default input #0 output #0;
        //Declaring signals without widths, but specifying the direction
        output OPA,OPB,CE,CIN,MODE,INP_VALID,CMD;
        input RST;
        endclocking*/

        //Clocking block for monitor
        clocking mon_cb@(posedge CLK);
        //Specifying the values for input and output skews
        default input #0 output #0;
        //Declaring signals without widths, but specifying the direction
         input RES,COUT,OFLOW,E,G,L,ERR;
         endclocking


        //clocking block for reference model
        clocking ref_cb@(posedge CLK);
        //Specifying the values for input and output skews
        default input #0 output #0;
        endclocking

        //modports for driver, monitor and reference model
        modport DRV(clocking drv_cb, input CLK, RST);
	modport MON(clocking mon_cb, input CLK, RST,input CE, INP_VALID);
        modport REF_SB(clocking ref_cb, input CLK, RST);

endinterface
