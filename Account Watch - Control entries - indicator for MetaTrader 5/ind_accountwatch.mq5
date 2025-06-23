//+------------------------------------------------------------------+
//|                                             IND_AccountWatch.mq5 |
//|                                    Copyright 2018, Mario Gharib. |
//|                                         mario.gharib@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Mario Gharib. mario.gharib@hotmail.com"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

#include <Functions.mqh>               // MIGRATING FUNCTIONS FROM MQL4 TO MQL5
#include <CreateObjects.mqh>           // DRAW RECTANGLES AND LABELS

// *********************************** //
// ************** INPUT ************** //
// *********************************** //

input color cFontClr = C'255,166,36';                    // Font Color
input datetime dStartingDate = D'2020.08.01 00:00:00';   // Start Date
input double dTarget = 10;                               // Daily Target in %

// *********************************** //
// ************ VARIABLES ************ //
// *********************************** //

int iTotalDeals; // NUMBER OF DEALS (i.e. CLOSED ORDERS)
int iWins;           // NUMBER OF WINNERS
int iLoss;           // NUMBER OF LOSSERS

double dProfit;      //OVERALL NET PROFIT
double dProfitWon;   //NET PROFIT WON INCLUDING COMMISSION
double dProfitLoss;  //NET PROFIT LOSS INCLUDING COMMISSION

double dPips;        // OVERAL PIPS
double dPipsWon;     // NUMBER OF PIPS WON
double dPipsLost;    // NUMBER OF PIPS LOST

double dAvgWon;      //AVERAGE WON
double dAvgLoss;     //AVERAGE LOSS

double dExpectancy;
double dAmtWon;      //AMOUNT WON
double dAmtLoss;     //AMOUNT LOSS

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {

	dProfit=0.0;
  	iWins=0;
  	iLoss=0;

  	dPips=0.0;
  	dPipsWon=0.0;
  	dPipsLost=0.0;
  	
  	dAvgWon=0.0;
  	dAvgLoss=0.0;
   dAmtWon=0.0;
 	dAmtLoss=0.0;

   //****************************************//
	//************* CLOSED DEALS *************//
	//****************************************//
   
   datetime yesterday = (datetime)StringToTime("2020.07.31");
   HistorySelect(dStartingDate,TimeCurrent());
   
   ulong ticket;
   int total = HistoryDealsTotal();
   //--- for all deals
   for(int i=0;i<total;i++) {
         
      if((ticket=HistoryDealGetTicket(i))>0) {
      
         double price      = HistoryDealGetDouble(ticket,DEAL_PRICE);
         datetime dtime    = (datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
         string symbol     = HistoryDealGetString(ticket,DEAL_SYMBOL);
         long type         = HistoryDealGetInteger(ticket,DEAL_TYPE);
         long entry        = HistoryDealGetInteger(ticket,DEAL_ENTRY);
         double profit     = HistoryDealGetDouble(ticket,DEAL_PROFIT);
         double commission = HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         double swap       = HistoryDealGetDouble(ticket,DEAL_SWAP);
         long direction    = HistoryDealGetInteger(ticket,DEAL_ENTRY);
         
         if(price && dtime && direction==DEAL_ENTRY_OUT) {

            ulong DealTicket=HistoryDealGetTicket(i);
				double pipPos = StringFind(HistoryDealGetString(DealTicket,DEAL_SYMBOL),"JPY")<0 ? 0.01 : 0.0001;
              					
				if(HistoryDealGetDouble(DealTicket,DEAL_PROFIT)>=0){
					iWins++;
					dAmtWon=dAmtWon+profit+commission+swap;
					dPipsWon=dPipsWon+NormalizeDouble(HistoryDealGetDouble(DealTicket,DEAL_PROFIT)/pipPos,1);

				} else {
					iLoss++;
					dAmtLoss=dAmtLoss+profit+commission+swap;
					dPipsLost=dPipsLost+NormalizeDouble(HistoryDealGetDouble(DealTicket,DEAL_PROFIT)/pipPos,1);
				}
				
				dProfit=dProfit+profit+commission+swap;
				dPips=NormalizeDouble(dPipsWon+dPipsLost,1);

         }

			//Total number of Orders
			iTotalDeals=iWins+iLoss;
       }
    }                                                                                                                      
	
	//Expectancy
 	dExpectancy=0.0;
   dProfitWon=0.0;
  	dProfitLoss=0.0;

	if (iWins==0)
	   dProfitWon=0;
	else
	   dProfitWon=NormalizeDouble((iWins*100)/(iWins+iLoss),2);
	
	if (dAmtWon==0.0)
	   dAvgWon=0.0;
	else
	   dAvgWon=NormalizeDouble(dAmtWon/iWins,2);
	
	if (iLoss==0)
	   dProfitLoss=0;
	else
	   dProfitLoss=NormalizeDouble((iLoss*100)/(iWins+iLoss),2);
	
	if (dAmtLoss==0.0)
	   dAvgLoss=0;
	else
	   dAvgLoss=NormalizeDouble(dAmtLoss/iLoss,2);
	
	dExpectancy=NormalizeDouble(((dProfitWon*dAvgWon)+(dProfitLoss*dAvgLoss))/100,2);

   string DepositCurrency=AccountInfoString(ACCOUNT_CURRENCY);

   vSetRectangle("rect",0,0,0,(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0),(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0),clrBlack,cFontClr,1);
   vSetLabel("Obj1",0,25,20,cFontClr,10,"MONEY MANAGEMENT PROFILE & BEHAVIOR");
   vSetLabel("Obj2",0,45,20,cFontClr,10,"====================================");

   vSetLabel("DateRange", 0,65,20,cFontClr,10,"Date Range: "+(string)dStartingDate+" and "+(string)TimeCurrent());
   vSetLabel("Target",0,85,20,cFontClr,10,"Target: "+(string)dTarget+"% i.e. ["+DoubleToString((AccountInfoDouble(ACCOUNT_BALANCE)-dProfit)*dTarget/100,2)+" "+DepositCurrency+"] of "+DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE)-dProfit,2)+" "+DepositCurrency);
   vSetLabel("Expectancy",0,105,20,cFontClr,10,"Expectancy: "+DoubleToString(dExpectancy,1));

   vSetLabel("ClosedPositionTitle",0,145,20,cFontClr,10,"CLOSED POSITIONS ("+IntegerToString(iTotalDeals)+")");
   vSetLabel("NetProfit",0,165,20,cFontClr,10,"Net Profit:        "+DoubleToString(dProfit,2)+" "+DepositCurrency+"   ["+DoubleToString(dAmtWon,1)+" "+DepositCurrency+" / "+DoubleToString(dAmtLoss,1)+" "+DepositCurrency+"]");
   vSetLabel("%WinLoss",0,185,20,cFontClr,10,"% win/loss: "+"     ["+IntegerToString(iWins)+" win / "+IntegerToString(iLoss)+" loss]"+"   ["+DoubleToString(dProfitWon,0)+"% win / "+DoubleToString(dProfitLoss,0)+"% loss]");
   vSetLabel("AvgWinLoss",0,205,20,cFontClr,10,"Avg win/loss: "+"   ["+DoubleToString(dAvgWon,1)+" "+DepositCurrency+" avg win / "+DoubleToString(dAvgLoss,1)+" "+DepositCurrency+" avg loss]");

   return(rates_total);
}
//+------------------------------------------------------------------+
