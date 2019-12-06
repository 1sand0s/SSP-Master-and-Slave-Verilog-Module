//////////////////////////////////////////////////////////////////////////////////
// Company: UT Austin
// Engineer: AudiTT
// 
// Create Date: 11/07/2019 03:54:55 AM
// Design Name: 
// Module Name: TxLogic
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "SSP_Defines.v"

module TxLogic(
    input [`SSP_WORD_SIZE-1:0] TxData,
    input PCLK,
    input CLEAR_B,
    input FIFOEmpty,
    input FIFOAEmpty,
    output SSPFSSOUT,
    output SSPTXD,
    output SSPOE_B,
    output SSPCLKOUT,
    output read
    );
    
    
    
   
    /****************************************FSM State Definition**********************************************/
    
    /*
        State Bit Encoding
        
        0th Bit = SSPFSSOUT
        1st Bit = SSPOE
        3rd Bit = read from FIFO active high
    */
    
    localparam rIdle     = 4'b0010;
    localparam rSignal1  = 4'b0011;
    localparam rShift1   = 4'b0100;
    localparam rShift2   = 4'b0000;
    localparam rShift3   = 4'b1100; 
    localparam rShift4   = 4'b1001;
    /**********************************************************************************************************/

    
    
    
   /*****************************************Variable Declarations*********************************************/
    reg SSPCLKIN;
    reg [`SSP_WORD_SIZE-1:0] DATAIN;
    integer clockCount;
    reg [3:0] stateRead;
   /***********************************************************************************************************/
   
   
   
   
   /**********************************************Serial Comm Clock Generation*********************************/
    always @ (posedge PCLK)
    
        SSPCLKIN <= (CLEAR_B? ~SSPCLKIN : 1'b0);
   /**********************************************************************************************************/
   
          
          
   
   /**********************************************Transmit FSM Sequential Logic******************************/         
    always @ (posedge SSPCLKIN)
   
        if(CLEAR_B)
            case(stateRead)
         
                rIdle:      stateRead <= (~FIFOEmpty? rSignal1 : rIdle);
            
                rSignal1:   stateRead <= rShift1;
            
                rShift1:    stateRead <= (clockCount == (`SSP_WORD_SIZE-2)? (~FIFOAEmpty ? rShift4 : rShift3) : rShift2);
                              
                rShift2:    stateRead <= rShift1;
            
                rShift3:    stateRead <= rIdle;
                
                rShift4:    stateRead <= rShift1;
            
                default:    stateRead <= rIdle;
            
            endcase
         
        else
            stateRead <= rIdle;
    /**********************************************************************************************************/

    
    
    
    /*******************************************Transmit FSM Combinational Logic*******************************/
     always @ (stateRead)
    
        case(stateRead)   
           
            rSignal1:    clockCount = -1;
               
            rShift1:     
                         begin
                            DATAIN = TxData;
                            clockCount = (clockCount == (`SSP_WORD_SIZE-1)? 0 : clockCount + 1);
                         end
               
            rShift2:     clockCount = clockCount + 1;
            
            rShift3:     clockCount = clockCount + 1;
            
            rShift4:     clockCount = clockCount + 1;
                
            default:     ;
           
        endcase
    /**********************************************************************************************************/
         
         
         
    
    /***************************************Continous Combinational Assignments********************************/
    assign SSPOE_B = stateRead[1] & (stateRead == rSignal1 ? SSPCLKIN : 1'b1);
    //assign SSPTXD = (stateRead[1] == 0 ? |((DATAIN << clockCount) & ({1'b1, `ABS_SSP_WORD_SIZE'b0})) : 1'bz);
    assign SSPTXD = (stateRead[1] == 0 ? DATAIN[`SSP_WORD_SIZE - 1 - clockCount] : 1'bz);
    assign SSPCLKOUT = SSPCLKIN;
    assign SSPFSSOUT = stateRead[0];
    assign read = stateRead[3] & SSPCLKIN & PCLK;
    /*********************************************************************************************************/  
         
           
endmodule
