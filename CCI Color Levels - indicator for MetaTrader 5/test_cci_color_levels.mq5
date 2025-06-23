//+------------------------------------------------------------------+
//|                                        Test CCI Color Levels.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property description "The adviser shows an example of obtaining values of the CCI Color Levels indicator"
//--- input parameters
input int      Inp_CCI_ma_period = 14;    // Averaging period 
input double   Inp_CCI_LevelUP   = 90;    // Level UP
input double   Inp_CCI_LevelDOWN =-90;    // Level DOWN
//---
int            handle_iCustom;            // variable for storing the handle of the iCustom indicator 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create handle of the indicator iCCI
   handle_iCustom=iCustom(Symbol(),Period(),"CCI Color Levels",Inp_CCI_ma_period,Inp_CCI_LevelUP,Inp_CCI_LevelDOWN);
//--- if the handle is not created 
   if(handle_iCustom==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCCI indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double level_up   = iCustomGet(handle_iCustom,0,0);   // buffer #0 -> BufferUpHigh
   double cci        = iCustomGet(handle_iCustom,2,0);   // buffer #2 -> BufferCCI
   double level_down = iCustomGet(handle_iCustom,4,0);   // buffer #4 -> BufferDownLow
   string text="Lelev UP #0: "+DoubleToString(level_up,2)+"\n"+
               "CCI #0: "+DoubleToString(cci,2)+"\n"+
               "Lelev DOWN #0: "+DoubleToString(level_down,2);
   Comment(text);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iCustom                             |
//|  the buffer numbers are the following:                           |
//+------------------------------------------------------------------+
double iCustomGet(int handle,const int buffer,const int index)
  {
   double Custom[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCustom array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle,buffer,index,1,Custom)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCustom indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Custom[0]);
  }
//+------------------------------------------------------------------+
