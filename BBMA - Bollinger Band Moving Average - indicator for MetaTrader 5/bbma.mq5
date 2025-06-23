#property copyright "BestForexScript.Com"
#property link      "https://bestforexscript.com"
#property version   "1.00"
#property description "Download Expert Advisors and Indicator for FREE!"
#property description "Want an EA with Indicator, contact me on telegram: @sopheak_khmer_trader"

#property strict

#property indicator_chart_window
#property indicator_buffers 16
#property indicator_plots 16

#property indicator_color1 clrBlack
#property indicator_width1 1
#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_label1 "Upper Band"

#property indicator_color2 clrGreen
#property indicator_width2 2
#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_label2 "Base"

#property indicator_color3 clrBlack
#property indicator_width3 1
#property indicator_type3 DRAW_LINE
#property indicator_style3 STYLE_SOLID
#property indicator_label3 "Lower Band"

#property indicator_color4 clrRed
#property indicator_width4 2
#property indicator_type4 DRAW_LINE
#property indicator_style4 STYLE_SOLID
#property indicator_label4 "MA50"

#property indicator_color5 clrRed
#property indicator_width5 1
#property indicator_type5 DRAW_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_label5 "MH5"

#property indicator_color6 clrRed
#property indicator_width6 1
#property indicator_type6 DRAW_LINE
#property indicator_style6 STYLE_DOT
#property indicator_label6 "MH6"

#property indicator_color7 clrRed
#property indicator_width7 1
#property indicator_type7 DRAW_LINE
#property indicator_style7 STYLE_DOT
#property indicator_label7 "MH7"

#property indicator_color8 clrRed
#property indicator_width8 1
#property indicator_type8 DRAW_LINE
#property indicator_style8 STYLE_DOT
#property indicator_label8 "MH8"

#property indicator_color9 clrRed
#property indicator_width9 1
#property indicator_type9 DRAW_LINE
#property indicator_style9 STYLE_DOT
#property indicator_label9 "MH9"

#property indicator_color10 clrRed
#property indicator_width10 1
#property indicator_type10 DRAW_LINE
#property indicator_style10 STYLE_SOLID
#property indicator_label10 "MH10"

#property indicator_color11 clrBlue
#property indicator_width11 1
#property indicator_type11 DRAW_LINE
#property indicator_style11 STYLE_SOLID
#property indicator_label11 "ML5"

#property indicator_color12 clrBlue
#property indicator_width12 1
#property indicator_type12 DRAW_LINE
#property indicator_style12 STYLE_DOT
#property indicator_label12 "ML6"

#property indicator_color13 clrBlue
#property indicator_width13 1
#property indicator_type13 DRAW_LINE
#property indicator_style13 STYLE_DOT
#property indicator_label13 "ML7"

#property indicator_color14 clrBlue
#property indicator_width14 1
#property indicator_type14 DRAW_LINE
#property indicator_style14 STYLE_DOT
#property indicator_label14 "ML8"

#property indicator_color15 clrBlue
#property indicator_width15 1
#property indicator_type15 DRAW_LINE
#property indicator_style15 STYLE_DOT
#property indicator_label15 "ML9"

#property indicator_color16 clrBlue
#property indicator_width16 1
#property indicator_type16 DRAW_LINE
#property indicator_style16 STYLE_SOLID
#property indicator_label16 "ML10"

double UpperBandBuffer[];
double BaseBuffer[];
double LowerBandBuffer[];
double MA50Buffer[];

double MH5Buffer[];
double MH6Buffer[];
double MH7Buffer[];
double MH8Buffer[];
double MH9Buffer[];
double MH10Buffer[];


double ML5Buffer[];
double ML6Buffer[];
double ML7Buffer[];
double ML8Buffer[];
double ML9Buffer[];
double ML10Buffer[];

int bbandhandler, ma50handler;
int mh5handler, mh6handler, mh7handler, mh8handler, mh9handler, mh10handler;
int ml5handler, ml6handler, ml7handler, ml8handler, ml9handler, ml10handler;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   SetIndexBuffer(0,UpperBandBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,BaseBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,LowerBandBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,MA50Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,MH5Buffer,INDICATOR_DATA);
   SetIndexBuffer(5,MH6Buffer,INDICATOR_DATA);
   SetIndexBuffer(6,MH7Buffer,INDICATOR_DATA);
   SetIndexBuffer(7,MH8Buffer,INDICATOR_DATA);
   SetIndexBuffer(8,MH9Buffer,INDICATOR_DATA);
   SetIndexBuffer(9,MH10Buffer,INDICATOR_DATA);
   SetIndexBuffer(10,ML5Buffer,INDICATOR_DATA);
   SetIndexBuffer(11,ML6Buffer,INDICATOR_DATA);
   SetIndexBuffer(12,ML7Buffer,INDICATOR_DATA);
   SetIndexBuffer(13,ML8Buffer,INDICATOR_DATA);
   SetIndexBuffer(14,ML9Buffer,INDICATOR_DATA);
   SetIndexBuffer(15,ML10Buffer,INDICATOR_DATA);
   
   PlotIndexGetInteger(0,PLOT_DRAW_BEGIN,50);
   PlotIndexGetInteger(1,PLOT_DRAW_BEGIN,50);
   PlotIndexGetInteger(2,PLOT_DRAW_BEGIN,50);
   PlotIndexGetInteger(3,PLOT_DRAW_BEGIN,50);
   PlotIndexGetInteger(4,PLOT_DRAW_BEGIN,50);
   PlotIndexGetInteger(5,PLOT_DRAW_BEGIN,50);
   PlotIndexGetInteger(6,PLOT_DRAW_BEGIN,50);
   PlotIndexGetInteger(7,PLOT_DRAW_BEGIN,50);
   PlotIndexGetInteger(8,PLOT_DRAW_BEGIN,50);
   PlotIndexGetInteger(9,PLOT_DRAW_BEGIN,50);
   PlotIndexGetInteger(10,PLOT_DRAW_BEGIN,50);
   PlotIndexGetInteger(11,PLOT_DRAW_BEGIN,50);
   PlotIndexGetInteger(12,PLOT_DRAW_BEGIN,50);
   PlotIndexGetInteger(13,PLOT_DRAW_BEGIN,50);
   PlotIndexGetInteger(14,PLOT_DRAW_BEGIN,50);
   PlotIndexGetInteger(15,PLOT_DRAW_BEGIN,50);
   
   ArraySetAsSeries(BaseBuffer,true);
   ArraySetAsSeries(UpperBandBuffer,true);
   ArraySetAsSeries(LowerBandBuffer,true);
   ArraySetAsSeries(MA50Buffer,true);
   ArraySetAsSeries(MH5Buffer,true);
   ArraySetAsSeries(MH6Buffer,true);
   ArraySetAsSeries(MH7Buffer,true);
   ArraySetAsSeries(MH8Buffer,true);
   ArraySetAsSeries(MH9Buffer,true);
   ArraySetAsSeries(MH10Buffer,true);
   
   ArraySetAsSeries(ML5Buffer,true);
   ArraySetAsSeries(ML6Buffer,true);
   ArraySetAsSeries(ML7Buffer,true);
   ArraySetAsSeries(ML8Buffer,true);
   ArraySetAsSeries(ML9Buffer,true);
   ArraySetAsSeries(ML10Buffer,true);
       
   IndicatorSetString(INDICATOR_SHORTNAME,"BBMA Indicator");
  
   bbandhandler = iBands(_Symbol,PERIOD_CURRENT,20,0,2,PRICE_CLOSE);
   ma50handler = iMA(_Symbol,PERIOD_CURRENT,50,0,MODE_EMA,PRICE_CLOSE);
   
   mh5handler = iMA(_Symbol,PERIOD_CURRENT,5,0,MODE_LWMA,PRICE_HIGH);
   mh6handler = iMA(_Symbol,PERIOD_CURRENT,6,0,MODE_LWMA,PRICE_HIGH);
   mh7handler = iMA(_Symbol,PERIOD_CURRENT,7,0,MODE_LWMA,PRICE_HIGH);
   mh8handler = iMA(_Symbol,PERIOD_CURRENT,8,0,MODE_LWMA,PRICE_HIGH);
   mh9handler = iMA(_Symbol,PERIOD_CURRENT,9,0,MODE_LWMA,PRICE_HIGH);
   mh10handler = iMA(_Symbol,PERIOD_CURRENT,10,0,MODE_LWMA,PRICE_HIGH);
   
   ml5handler = iMA(_Symbol,PERIOD_CURRENT,5,0,MODE_LWMA,PRICE_LOW);
   ml6handler = iMA(_Symbol,PERIOD_CURRENT,6,0,MODE_LWMA,PRICE_LOW);
   ml7handler = iMA(_Symbol,PERIOD_CURRENT,7,0,MODE_LWMA,PRICE_LOW);
   ml8handler = iMA(_Symbol,PERIOD_CURRENT,8,0,MODE_LWMA,PRICE_LOW);
   ml9handler = iMA(_Symbol,PERIOD_CURRENT,9,0,MODE_LWMA,PRICE_LOW);
   ml10handler = iMA(_Symbol,PERIOD_CURRENT,10,0,MODE_LWMA,PRICE_LOW);
   
   if(bbandhandler < 0 || ma50handler < 0 || mh5handler < 0 || mh6handler < 0 || mh7handler < 0 || mh8handler < 0 || mh9handler < 0 || mh10handler < 0 ||
      ml5handler < 0 || ml6handler < 0 || ml7handler < 0 || ml8handler < 0 || ml9handler < 0 || ml10handler < 0   
   )
   {
      return(INIT_FAILED);
   }
  
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   IndicatorRelease(bbandhandler);
   IndicatorRelease(ma50handler);
   IndicatorRelease(mh5handler);
   IndicatorRelease(mh6handler);
   IndicatorRelease(mh7handler);
   IndicatorRelease(mh8handler);
   IndicatorRelease(mh9handler);
   IndicatorRelease(mh10handler);
   
   IndicatorRelease(ml5handler);
   IndicatorRelease(ml6handler);
   IndicatorRelease(ml7handler);
   IndicatorRelease(ml8handler);
   IndicatorRelease(ml9handler);
   IndicatorRelease(ml10handler);
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
                const int &spread[])
{

   if(rates_total < 50)return(0);
   int limit = fmin(rates_total-1,rates_total-prev_calculated);
   for(int i= limit; i>=0; i--)
   {
      if(CopyBuffer(bbandhandler,BASE_LINE,i,1,BaseBuffer)<=0)return(0);
      if(CopyBuffer(bbandhandler,UPPER_BAND,i,1,UpperBandBuffer)<=0)return(0);
      if(CopyBuffer(bbandhandler,LOWER_BAND,i,1,LowerBandBuffer)<=0)return(0);
      if(CopyBuffer(ma50handler,0,i,1,MA50Buffer)<=0)return(0);
      if(CopyBuffer(mh5handler,0,i,1,MH5Buffer)<=0)return(0);
      if(CopyBuffer(mh6handler,0,i,1,MH6Buffer)<=0)return(0);
      if(CopyBuffer(mh7handler,0,i,1,MH7Buffer)<=0)return(0);
      if(CopyBuffer(mh8handler,0,i,1,MH8Buffer)<=0)return(0);
      if(CopyBuffer(mh9handler,0,i,1,MH9Buffer)<=0)return(0);
      if(CopyBuffer(mh10handler,0,i,1,MH10Buffer)<=0)return(0);
      if(CopyBuffer(ml5handler,0,i,1,ML5Buffer)<=0)return(0);
      if(CopyBuffer(ml6handler,0,i,1,ML6Buffer)<=0)return(0);
      if(CopyBuffer(ml7handler,0,i,1,ML7Buffer)<=0)return(0);
      if(CopyBuffer(ml8handler,0,i,1,ML8Buffer)<=0)return(0);
      if(CopyBuffer(ml9handler,0,i,1,ML9Buffer)<=0)return(0);
      if(CopyBuffer(ml10handler,0,i,1,ML10Buffer)<=0)return(0);
   } 
   return(rates_total);
}
//+------------------------------------------------------------------+


