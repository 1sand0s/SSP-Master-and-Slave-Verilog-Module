//////////////////////////////////////////////////////////////////////////////////
// Company: UT Austin
// Engineer: AudiTT
// 
// Create Date: 11/07/2019 10:26:59 AM
// Design Name: 
// Module Name: RxLogic
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

module RxLogic(
    input SSPCLKIN,
    input SSPRXD,
    input SSPFSSIN,
    input PCLK,
    input CLEAR_B,
    input FIFOFULL,
    output [`SSP_WORD_SIZE-1:0] RxData,
    output write
    );
    
    
    
    
    /******************************************FSM State Definitions*******************************************/
    
    /*
        State Bit Encoding
            
        2nd Bit = write to FIFO active high
    */
        
    localparam rIdle            = 3'b000;
    localparam rClocking1       = 3'b001;
    localparam rClocking2       = 3'b011;
    localparam rWriting1        = 3'b101;
    localparam rWriting2        = 3'b100;
    /**********************************************************************************************************/

    
    
    
    
    /*****************************************Variable Declarations*******************************************/
    reg [2:0] stateRead;
    reg [`SSP_WORD_SIZE-1:0] sfr;
    integer clockCount;
    /*********************************************************************************************************/
    
    
    
    
    
    /*****************************************Receive FSM Sequential Logic***********************************/
    always @ (negedge SSPCLKIN)
    
        if(CLEAR_B)
            case(stateRead)
                
                rIdle:          stateRead <= (SSPFSSIN ? rClocking1 : rIdle);
                
                rClocking1:     stateRead <= rClocking2;
                
                rClocking2:     stateRead <= (clockCount == (`SSP_WORD_SIZE-1)? (SSPFSSIN? rWriting1 : rWriting2) : rClocking1);
                
                rWriting1:      stateRead <= rClocking2;
                
                default:        stateRead <= rIdle;
                
            endcase
            
         else
            stateRead <= rIdle; 
    /*********************************************************************************************************/
    
    
    
    
    
    /********************************************Shift Register***********************************************/
    always @ (posedge SSPCLKIN)
    
        begin
            sfr <= sfr << 1;
            sfr[0] <= SSPRXD;
        end  
    /*********************************************************************************************************/
  
            
    
    
    
    /****************************************Receive FSM Combinational Logic**********************************/
    always @ (stateRead)
    
        case(stateRead)
        
            rClocking1:     clockCount = clockCount + 1;
            
            rClocking2:     clockCount = clockCount + 1;
            
            rWriting1:      clockCount = 0;
            
            default:        clockCount = -1;
            
        endcase 
    /*********************************************************************************************************/

    
    
    
    /****************************************Continuous Combinational Assignment******************************/
    assign write = stateRead[2] & ~FIFOFULL & SSPCLKIN & PCLK;
    assign RxData = sfr;
    /*********************************************************************************************************/

    
endmodule
