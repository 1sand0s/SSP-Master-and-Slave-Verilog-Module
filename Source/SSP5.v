//////////////////////////////////////////////////////////////////////////////////
// Company: UT Austin
// Engineer: AudiTT
// 
// Create Date: 11/06/2019 06:08:20 AM
// Design Name: 
// Module Name: SSP5
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

module SSP5(
    input PSEL,
    input PWRITE,
    input [`SSP_WORD_SIZE-1:0] PWDATA,
    input PCLK,
    input CLEAR_B,
    input SSPCLKIN,
    input SSPFSSIN,
    input SSPRXD,
    output reg [`SSP_WORD_SIZE-1:0] PRDATA,
    output SSPOE_B,
    output SSPTXD,
    output SSPCLKOUT,
    output SSPFSSOUT,
    output SSPTXINTR,
    output SSPRXINTR
    );
    
    
    
    /********************************************Variable Declarations*****************************************/
    wire [`SSP_WORD_SIZE-1:0] TxData;
    wire [`SSP_WORD_SIZE-1:0] RxData;
    wire [`SSP_WORD_SIZE-1:0] PRDATA1;
    wire txRead,TxFIFOAFULL,TxFIFOEMPTY,TxFIFOAEMPTY,rxWrite,RxFIFOAFULL,RxFIFOEMPTY,RxFIFOAEMPTY;
    reg rxRead;
    /**********************************************************************************************************/

    
    
    
    /********************************************Transmit Logic************************************************/
    FIFOBuff txFifo(PSEL,PWRITE,PWDATA,CLEAR_B,PCLK,txRead,TxData,SSPTXINTR,TxFIFOAFULL,TxFIFOEMPTY,TxFIFOAEMPTY);
    
    TxLogic txL(TxData,PCLK,CLEAR_B,TxFIFOEMPTY,TxFIFOAEMPTY,SSPFSSOUT,SSPTXD,SSPOE_B,SSPCLKOUT,txRead);
    /**********************************************************************************************************/

    
    
    /********************************************Receive Logic*************************************************/
    FIFOBuff rxFifo(rxWrite,rxWrite,RxData,CLEAR_B,PCLK,~PWRITE&PSEL,PRDATA1,SSPRXINTR,RxFIFOAFULL,RxFIFOEMPTY,RxFIFOAEMPTY);

    RxLogic rxL(SSPCLKIN,SSPRXD,SSPFSSIN,PCLK,CLEAR_B,SSPRXINTR,RxData,rxWrite);

    always @ (posedge PCLK)
    
        PRDATA <= (~PWRITE? PRDATA1 : `ABS_SSP_WORD_SIZE'bz);
    /**********************************************************************************************************/

endmodule
