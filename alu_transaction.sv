`include "defines.sv"
class alu_transaction;
        //PROPERTIES
        //INPUTS declare as rand variables
        rand bit[`width-1:0] OPA, OPB;
        rand bit MODE, CIN,CE;
        rand bit[1:0] INP_VALID;
        rand bit[`cwidth-1:0] CMD;


        //OUTPUTS daclare as non-rand variables
        bit[`width +1 :0] RES;
        bit OFLOW, COUT, E, G, L, ERR;

        //constraints
        constraint mode_constraint{ if(MODE==1){ CMD inside {[0:10]}}; else { CMD inside {[0:13]} ;} }

        //constraint err_constriant{ if(MODE && (CMD == 12 || CMD == 13)) if(OPB[4:7] == 1) { ERR ==1};}

        //METHODS
        //Copying objects for blueprint This is a deep copy function
        virtual function alu_transaction copy();
                copy=new();
                copy.OPA = this.OPA;
                copy.OPB = this.OPB;
                copy.MODE = this.MODE;
                copy.CE = this.CE;
                copy.CIN = this.CIN;
                copy.INP_VALID = this.INP_VALID;
                copy.CMD = this.CMD;
                return copy;
        endfunction
endclass
