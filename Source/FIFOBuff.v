//////////////////////////////////////////////////////////////////////////////////
// Company: UT Austin
// Engineer: AudiTT
// 
// Create Date: 11/7/2019 01:42:40 AM
// Design Name: 
// Module Name: TxFIFO
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


module FIFOBuff(
    input PSEL,
    input PWRITE,
    input [`SSP_WORD_SIZE-1:0] DATA_IN,
    input CLEAR_B,
    input PCLK,
    input read,
    output [`SSP_WORD_SIZE-1:0] DATA_OUT,
    output reg FIFOFULL,
    output reg FIFOAFULL,
    output reg FIFOEMPTY,
    output reg FIFOAEMPTY
    );
    
    
    
    
    /*******************************************FSM State Definitions******************************************/
    localparam Reset    = 0;
    localparam wIdle    = 1;
    localparam wRead1   = 2;
    localparam wRead2   = 3;
    /**********************************************************************************************************/



    
    
    /********************************************Variable Declarations****************************************/
    reg [`SSP_WORD_SIZE-1:0] FIFOBuffer [`FIFO_BUFFER_DEPTH-1:0];
    
    integer readPointer;
    integer writePointer;
    integer clockCount;
    integer stateWrite;
    /**********************************************************************************************************/

    
    
    
    
    /********************************************FIFO Buffer Write Sequential Logic****************************/
    always @ (posedge PCLK)
     
        if(CLEAR_B)
            case(stateWrite)
            
                Reset:      stateWrite <= wIdle;
                
                wIdle:      stateWrite <= ((PWRITE && PSEL && ~FIFOFULL)? wRead1 : wIdle);
                
                wRead1:     stateWrite <= ((PWRITE && PSEL && ~FIFOFULL)? wRead2 : wIdle);
                
                wRead2:     stateWrite <= ((PWRITE && PSEL && ~FIFOFULL)? wRead1 : wIdle);
                
                default:    stateWrite <= wIdle;
                
            endcase
            
        else
            stateWrite <= wIdle;
    /**********************************************************************************************************/
    
    
    
    
    
    /*******************************************ReadPointer update********************************************/
    always @ (posedge PCLK)
        
        readPointer <= (CLEAR_B ? (read == 1'b1 ? (FIFOEMPTY? readPointer : (readPointer + 1) % `FIFO_BUFFER_DEPTH ) : readPointer) : 0);       
    /**********************************************************************************************************/
            
            
            
            
            
    /*******************************************FIFO Buffer Write Combinational Logic*************************/    
    always @ (stateWrite)
      
        case(stateWrite)
        
            wIdle:      writePointer = (~CLEAR_B? 0 : writePointer);
            
            wRead1:
                        begin
                            FIFOBuffer[writePointer] = DATA_IN;
                            writePointer = (writePointer + 1) % `FIFO_BUFFER_DEPTH;
                        end
                
            wRead2:
                        begin
                            FIFOBuffer[writePointer] = DATA_IN;
                            writePointer = (writePointer + 1) % `FIFO_BUFFER_DEPTH;
                        end
                        
            default:    ;
            
        endcase
    /**********************************************************************************************************/
    
        
        
        
    
    /********************************************FIFO Buffer Status Update************************************/
    always @ (writePointer or readPointer)
      
        begin                                  
            FIFOFULL = (writePointer == readPointer) && (~CLEAR_B? 1'b0 : FIFOAFULL);
                              
            FIFOAFULL = (~CLEAR_B ? 1'b0 : ((writePointer + 1) % `FIFO_BUFFER_DEPTH == readPointer));
          
                                                                                       
                                                   
            FIFOEMPTY = (writePointer == readPointer) && (~CLEAR_B? 1'b1 : FIFOAEMPTY);
          
            FIFOAEMPTY = (~CLEAR_B ? 1'b1 : ((readPointer + 1) % `FIFO_BUFFER_DEPTH == writePointer));                    
        end
    /**********************************************************************************************************/
 
    
    
    
    
    /**********************************************Continuous Combinational Assignments************************/
     assign DATA_OUT = (FIFOEMPTY == 1? `SSP_WORD_SIZE'bz : FIFOBuffer[readPointer]);
    /**********************************************************************************************************/

    
endmodule
