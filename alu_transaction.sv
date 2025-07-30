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


        //constraint m{ INP_VALID == 2'b11      ;}
        //constraint m1{CE == 1;}
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

class alu_transaction1 extends alu_transaction;
        constraint mode_c {MODE == 0;}
        constraint cmd_c {CMD inside {[6:11]};}
        constraint inp_valid_c {INP_VALID == 2'b11;}

        virtual function alu_transaction1 copy();
                copy = new();
                copy.CE = this.CE;
                copy.MODE = this.MODE;
                copy.CMD = this.CMD;
                copy.INP_VALID = this.INP_VALID;
                copy.OPA = this.OPA;
                copy.OPB = this.OPB;
                copy.CIN = this.CIN;
                return copy;
        endfunction
endclass

//arithmetic operation with single inputs
class alu_transaction2 extends alu_transaction;
        constraint mode_c {MODE == 1;}
        constraint cmd_c {CMD inside {[4:7]};}
        constraint inp_valid_c {INP_VALID == 2'b11;}

        virtual function alu_transaction2 copy();
                copy = new();
                copy.CE = this.CE;
                copy.MODE = this.MODE;
                copy.CMD = this.CMD;
                copy.INP_VALID = this.INP_VALID;
                copy.OPA = this.OPA;
                copy.OPB = this.OPB;
                copy.CIN= this.CIN;
                return copy;
        endfunction
endclass

//logical operation with two operands
class alu_transaction3 extends alu_transaction;
        constraint mode_c{MODE == 0;}
        constraint cmd_c {CMD inside {[0:6],12,13};}
        constraint inp_valid_c {INP_VALID == 2'b11;}

        virtual function alu_transaction3 copy();
                copy = new();
                copy.CE = this.CE;
                copy.MODE = this.MODE;
                copy.CMD = this.CMD;
                copy.INP_VALID = this.INP_VALID;
                copy.OPA = this.OPA;
                copy.OPB = this.OPB;
                copy.CIN = this.CIN;
                return copy;
        endfunction
endclass

//arithmetic operation with two operands
class alu_transaction4 extends alu_transaction;
        constraint mode_c{MODE == 1;}
        constraint cmd_c {CMD inside {[0:3], [8:10]};}
        constraint inp_valid_c {INP_VALID == 2'b11;}

        virtual function alu_transaction4 copy();
                copy = new();
                copy.CE = this.CE;
                copy.MODE = this.MODE;
                copy.CMD = this.CMD;
                copy.INP_VALID = this.INP_VALID;
                copy.OPA = this.OPA;
                copy.OPB = this.OPB;
                copy.CIN = this.CIN;
                return copy;
        endfunction
endclass
