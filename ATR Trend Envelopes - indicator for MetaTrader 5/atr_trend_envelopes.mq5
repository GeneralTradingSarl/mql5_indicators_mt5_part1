//------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "ATR Trend envelopes"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
#property indicator_label1  "Trend envelope up trend line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2
#property indicator_label2  "Trend envelope down trend line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrCrimson
#property indicator_width2  2
#property indicator_label3  "Trend envelope up trend start"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDodgerBlue
#property indicator_width3  2
#property indicator_label4  "Trend envelope down trend start"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrCrimson
#property indicator_width4  2

//
//--- input parameters
//

input int     inpAtrPeriod = 14;   // ATR period
input double  inpDeviation = 1.5;  // ATR multilication factor


//
//--- indicator buffers
//

double lineup[],linedn[],arrowup[],arrowdn[];

//
//--- custom structures
//

struct sTrendEnvelope
{
   double upline;
   double downline;
   int    trend;
   bool   trendChange;
};

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,lineup,INDICATOR_DATA);
   SetIndexBuffer(1,linedn,INDICATOR_DATA);
   SetIndexBuffer(2,arrowup,INDICATOR_DATA); PlotIndexGetInteger(2,PLOT_ARROW,159);
   SetIndexBuffer(3,arrowdn,INDICATOR_DATA); PlotIndexGetInteger(3,PLOT_ARROW,159);
   return(INIT_SUCCEEDED);
}
//------------------------------------------------------------------
// Custom indicator de-initialization function
//------------------------------------------------------------------
void OnDeinit(const int reason) { return; }
//------------------------------------------------------------------
// Custom iteration function
//------------------------------------------------------------------
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{                
   if (Bars(_Symbol,_Period)<rates_total) return(-1);
   
   //
   //---
   //

   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !_StopFlag; i++)
   {
      double _atr = 0; for (int k=0; k<inpAtrPeriod && (i-k-1)>=0; k++) _atr += MathMax(high[i-k],close[i-k-1])-MathMin(low[i-k],close[i-k-1]); _atr /= inpAtrPeriod;
      sTrendEnvelope _result = iTrendEnvelope(high[i],low[i],close[i],_atr*inpDeviation,i,rates_total);
         lineup[i]  = _result.upline;
         linedn[i]  = _result.downline;
         arrowup[i] = (_result.trendChange && _result.trend== 1) ? lineup[i] : EMPTY_VALUE;
         arrowdn[i] = (_result.trendChange && _result.trend==-1) ? linedn[i] : EMPTY_VALUE;
   }          
   return(rates_total);
}
//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
#define _trendEnvelopesInstances 1
#define _trendEnvelopesInstancesSize 3
double workTrendEnvelopes[][_trendEnvelopesInstances*_trendEnvelopesInstancesSize];
#define _teSmin  0
#define _teSmax  1 
#define _teTrend 2

//
//---
//

sTrendEnvelope iTrendEnvelope(double valueh, double valuel, double value, double deviation, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workTrendEnvelopes,0)!=bars) ArrayResize(workTrendEnvelopes,bars); instanceNo*=_trendEnvelopesInstancesSize;
   
   //
   //---
   //
   
   workTrendEnvelopes[i][instanceNo+_teSmax]  = valueh+deviation;
   workTrendEnvelopes[i][instanceNo+_teSmin]  = valuel-deviation;
	workTrendEnvelopes[i][instanceNo+_teTrend] = (i>0) ? (value>workTrendEnvelopes[i-1][instanceNo+_teSmax]) ? 1 : (value<workTrendEnvelopes[i-1][instanceNo+_teSmin]) ? -1 : workTrendEnvelopes[i-1][instanceNo+_teTrend] : 0;
   	if (i>0 && workTrendEnvelopes[i][instanceNo+_teTrend]>0 && workTrendEnvelopes[i][instanceNo+_teSmin]<workTrendEnvelopes[i-1][instanceNo+_teSmin]) workTrendEnvelopes[i][instanceNo+_teSmin] = workTrendEnvelopes[i-1][instanceNo+_teSmin];
	   if (i>0 && workTrendEnvelopes[i][instanceNo+_teTrend]<0 && workTrendEnvelopes[i][instanceNo+_teSmax]>workTrendEnvelopes[i-1][instanceNo+_teSmax]) workTrendEnvelopes[i][instanceNo+_teSmax] = workTrendEnvelopes[i-1][instanceNo+_teSmax];
   
      //
      //---
      //
      
      sTrendEnvelope _result;
	                  _result.trend       = (int)workTrendEnvelopes[i][instanceNo+_teTrend];
                     _result.trendChange = (i>0) ? ( workTrendEnvelopes[i][instanceNo+_teTrend]!=workTrendEnvelopes[i-1][instanceNo+_teTrend]) : false;
                     _result.upline      = (workTrendEnvelopes[i][instanceNo+_teTrend]== 1) ? workTrendEnvelopes[i][instanceNo+_teSmin] : EMPTY_VALUE;
                     _result.downline    = (workTrendEnvelopes[i][instanceNo+_teTrend]==-1) ? workTrendEnvelopes[i][instanceNo+_teSmax] : EMPTY_VALUE;
      return(_result);                  
};