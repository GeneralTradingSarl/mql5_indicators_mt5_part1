//+------------------------------------------------------------------+
//|                                                   Didi_Index.mq5 |
//|                                                Rudinei Felipetto |
//|                                         http://www.conttinua.com |
//+------------------------------------------------------------------+
#property copyright "Rudinei Felipetto"
#property link      "http://www.conttinua.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot Curta
#property indicator_label1  "Curta"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Media
#property indicator_label2  "Media"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrWhite
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Longa
#property indicator_label3  "Longa"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrYellow
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input int      Curta=3;
input int      Media=8;
input int      Longa=20;
//--- indicator buffers
double         CurtaBuffer[];
double         MediaBuffer[];
double         LongaBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping
   SetIndexBuffer(0,CurtaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,MediaBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,LongaBuffer,INDICATOR_DATA);
   
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
	if(rates_total<Longa-1+begin) return 0;
	
	if(prev_calculated == 0) {
		ArrayInitialize(CurtaBuffer, 0);
		ArrayInitialize(MediaBuffer, 0);
		ArrayInitialize(LongaBuffer, 0);
	}
	
	CalculateDidiIndex();
	
	return(rates_total);
}
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result) {
//---

}
//+------------------------------------------------------------------+
void CalculateDidiIndex() {
	int short_handle, average_handle, long_handle;
	int short_bars, average_bars, long_bars;

	short_handle   = iMA(Symbol(), PERIOD_CURRENT, Curta, 0, MODE_SMA, PRICE_CLOSE);
	average_handle = iMA(Symbol(), PERIOD_CURRENT, Media, 0, MODE_SMA, PRICE_CLOSE);
	long_handle    = iMA(Symbol(), PERIOD_CURRENT, Longa, 0, MODE_SMA, PRICE_CLOSE);

	short_bars =   BarsCalculated(short_handle);
	average_bars = BarsCalculated(average_handle);
	long_bars =    BarsCalculated(long_handle);

	CopyBuffer(short_handle,   0, 0, short_bars,   CurtaBuffer);
	CopyBuffer(average_handle, 0, 0, average_bars, MediaBuffer);
	CopyBuffer(long_handle,    0, 0, long_bars,    LongaBuffer);
	
	for(int i=0;i<short_bars;i++) {
  if(!MediaBuffer[i]) MediaBuffer[i]=EMPTY_VALUE;
		if(i>=Media) {
			CurtaBuffer[i] /= MediaBuffer[i];
			if(i>=Longa) {
				LongaBuffer[i] /= MediaBuffer[i];
			}
			else {
				LongaBuffer[i] = 1;
			}
		}
		else {
			CurtaBuffer[i] = 1;
		}
		MediaBuffer[i] = 1;
	}
}
