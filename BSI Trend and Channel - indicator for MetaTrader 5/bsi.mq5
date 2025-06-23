//+------------------------------------------------------------------+
//|                                                          BSI.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#property strict

#property indicator_chart_window
#property indicator_buffers 14
#property indicator_plots 8

#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE
#property indicator_type3 DRAW_LINE
#property indicator_type4 DRAW_LINE
#property indicator_type5 DRAW_LINE
#property indicator_type6 DRAW_ARROW
#property indicator_type7 DRAW_ARROW
#property indicator_type8 DRAW_LINE
//---
#property indicator_color1 Orange
#property indicator_color2 Gray
#property indicator_color3 Aqua
#property indicator_color4 DeepPink
#property indicator_color5 DarkViolet
#property indicator_color6 Red
#property indicator_color7 Blue
#property indicator_color8 Red

#property indicator_label1 "Trend High"
#property indicator_label2 "Trend Regr"
#property indicator_label3 "Trend Low"
#property indicator_label4 "Tango Line"
#property indicator_label5 "Tango MA"
#property indicator_label6 "Reversal Bar"
#property indicator_label7 "Reversal Bar"
#property indicator_label8 "BSI"

//---
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 2
#property indicator_width7 2
#property indicator_width8 1

#property indicator_style1 STYLE_DASH
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_DASH
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID
#property indicator_style8 STYLE_DOT

//--- input parameters
input  int InpChannelPeriod=30;  // Channel Period
input  int InpTrendPeriod=30;    // Trend Period
input  double InpReversalNoiseFilter=5;  // NoiseFilter (Minimam Reversal Spread)
input  bool InpUsingVolumeWeight=true;  // UseingVolumeWeight

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RevNoiseFilter=InpReversalNoiseFilter*Point();
//---
int min_rates_total;

//--- indicator buffers
double UpTrendBuffer[];
double LoTrendBuffer[];
double MdTrendBuffer[];
double TangoBuffer[];
double TangoMaBuffer[];
double TopBuffer[];
double BtmBuffer[];

//--- calc buffers
double SlopeBuffer[];
double BSIBuffer[];
double HighesBuffer[];
double LowesBuffer[];
double VolBuffer[];
double UpRangeBuffer[];
double DnRangeBuffer[];




//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

//---- Initialization of variables of data calculation starting point
   min_rates_total=1+MathMax(InpTrendPeriod,InpChannelPeriod)+1;

//--- indicator buffers mapping
//IndicatorBuffers(14);

//--- indicator buffers
   SetIndexBuffer(0,UpTrendBuffer);
   SetIndexBuffer(1,MdTrendBuffer);
   SetIndexBuffer(2,LoTrendBuffer);
   SetIndexBuffer(3,TangoBuffer);
   SetIndexBuffer(4,TangoMaBuffer);
   SetIndexBuffer(5,TopBuffer);
   SetIndexBuffer(6,BtmBuffer);
   SetIndexBuffer(7,BSIBuffer);

//--- calc buffers
   SetIndexBuffer(8,HighesBuffer);
   SetIndexBuffer(9,LowesBuffer);
   SetIndexBuffer(10,SlopeBuffer);
   SetIndexBuffer(11,UpRangeBuffer);
   SetIndexBuffer(12,DnRangeBuffer);
   SetIndexBuffer(13,VolBuffer);

   PlotIndexSetInteger(5, PLOT_ARROW, 159);
   PlotIndexSetInteger(6, PLOT_ARROW, 159);

   PlotIndexSetInteger(0, PLOT_SHIFT,1);
   PlotIndexSetInteger(1, PLOT_SHIFT,1);
   PlotIndexSetInteger(2, PLOT_SHIFT,1);
   PlotIndexSetInteger(3, PLOT_SHIFT,1);
   PlotIndexSetInteger(4, PLOT_SHIFT,1);
   PlotIndexSetInteger(7, PLOT_SHIFT,1);


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
                const int &spread[])
  {
//---
//---
   int i,j,k,first;
//--- check for bars count
   if(rates_total<=min_rates_total)
      return(0);

//--- indicator buffers
   ArraySetAsSeries(UpTrendBuffer,false);
   ArraySetAsSeries(MdTrendBuffer,false);
   ArraySetAsSeries(LoTrendBuffer,false);
   ArraySetAsSeries(TangoBuffer,false);
   ArraySetAsSeries(TangoMaBuffer,false);
   ArraySetAsSeries(TopBuffer,false);
   ArraySetAsSeries(BtmBuffer,false);
   ArraySetAsSeries(BSIBuffer,false);

//--- calc buffers
   ArraySetAsSeries(HighesBuffer,false);
   ArraySetAsSeries(LowesBuffer,false);
   ArraySetAsSeries(UpRangeBuffer,false);
   ArraySetAsSeries(DnRangeBuffer,false);
   ArraySetAsSeries(SlopeBuffer,false);
   ArraySetAsSeries(VolBuffer,false);

//--- rate data
   ArraySetAsSeries(time,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false);
   ArraySetAsSeries(tick_volume,false);


//+----------------------------------------------------+
//|Set High Low Buffeer                                |
//+----------------------------------------------------+
   first=InpChannelPeriod-1;
   if(first+1<prev_calculated)
      first=prev_calculated-2;
   else
     {
      for(i=0; i<first; i++)
        {
         LowesBuffer[i]=0.0;
         HighesBuffer[i]=0.0;
         VolBuffer[i]=0.0;
        }
     }

   for(i=first; i<rates_total && !IsStopped(); i++)
     {
      //--- calculate range spread
      double dmin=1000000.0;
      double dmax=-1000000.0;
      long volmax=0;
      //---
      for(k=i-InpChannelPeriod+1; k<=i; k++)
        {
         if(dmin>low[k])
            dmin=low[k];
         if(dmax<high[k])
            dmax=high[k];
         if(InpUsingVolumeWeight && volmax<tick_volume[k])
            volmax=tick_volume[k];
        }
      //---
      LowesBuffer[i]=dmin;
      HighesBuffer[i]=dmax;
      //---
      if(InpUsingVolumeWeight)
         VolBuffer[i]=(double)volmax;
     }

//+----------------------------------------------------+
//|Set Tango Line Buffeer                              |
//+----------------------------------------------------+
   first=InpChannelPeriod-1;
   if(first+1<prev_calculated)
      first=prev_calculated-2;
   for(i=first; i<rates_total && !IsStopped(); i++)
     {
      //---
      int btm_pos=NULL;
      int top_pos=NULL;
      //--- serach reversal bar
      for(j=i-1; j>1; j--)
        {
         if(LowesBuffer[j-2]-RevNoiseFilter*Point()>LowesBuffer[j-1]
            && LowesBuffer[j-1]==LowesBuffer[j])
           {
            //--- reversal of top
            btm_pos=j-1;
            BtmBuffer[btm_pos]=LowesBuffer[btm_pos];
            break;
           }
         //--- reversal of bottom
         if(HighesBuffer[j-2]+RevNoiseFilter*Point()<HighesBuffer[j-1]
            && HighesBuffer[j-1]==HighesBuffer[j])
           {
            top_pos=j-1;
            TopBuffer[top_pos]=HighesBuffer[top_pos];
            break;
           }
        }

      //--- turnning point
      int turn_pos=NULL;
      if(btm_pos!=NULL || top_pos!=NULL)
        {
         //---
         if(btm_pos!=NULL)
            turn_pos=btm_pos;
         else
            turn_pos=top_pos;
         //---
         double range_lo=1000000.0;
         double range_hi=-1000000.0;
         for(j=turn_pos; j<=i-1; j++)
           {
            if(range_hi<high[j])
               range_hi=high[j];
            if(range_lo>low[j])
               range_lo=low[j];
           }
         //--- set channel data
         double prev_high=MathMax(MathMax(MathMax(high[turn_pos-4],
                                          high[turn_pos-3]),high[turn_pos-2]),high[turn_pos-1]);
         double prev_low=MathMin(MathMin(MathMin(low[turn_pos-4],
                                                 low[turn_pos-3]),low[turn_pos-2]),low[turn_pos-1]);
         UpRangeBuffer[i]=MathMax(range_hi,prev_high);
         TangoBuffer[i]=(range_hi+range_lo)/2;
         DnRangeBuffer[i]=MathMin(range_lo,prev_low);
         //---
        }
     }

//+----------------------------------------------------+
//| Set Tango MA Buffeer & BSI Buffer                  |
//+----------------------------------------------------+
   int MaPeriod=(int)MathRound(InpChannelPeriod/2);
   first=InpChannelPeriod-1+MaPeriod-1;
   if(first+1<prev_calculated)
      first=prev_calculated-2;
   else
     {
      for(i=0; i<first; i++)
        {
         TangoMaBuffer[i]=EMPTY_VALUE;
        }
     }
//--- ma cycle
   for(i=first; i<rates_total && !IsStopped(); i++)
     {
      double sum=0.0;
      for(k=(i-MaPeriod+1); k<=i; k++)
         sum+=TangoBuffer[k];
      //--- Tango Ma Buffer
      TangoMaBuffer[i]=sum/MaPeriod;
      //--- BSI Index Buffer
      BSIBuffer[i]=calc_bsi(high,low,close,tick_volume,i,InpChannelPeriod);
     }

//+----------------------------------------------------+
//| Main calculation loop of the indicator             |
//+----------------------------------------------------+
   first=min_rates_total-1;
   if(first+1<prev_calculated)
      first=prev_calculated-2;
//---
   for(i=first; i<rates_total && !IsStopped(); i++)
     {
      //---
      bool is_update=false;
      //---  detect trend
      double ma1 = TangoMaBuffer[i-1];
      double ma2 = TangoMaBuffer[i];
      double bsi1 = BSIBuffer[i-1];
      double bsi2 = BSIBuffer[i];

      if((MathMax(ma1,ma2)<bsi2 && bsi1<bsi2) || (MathMin(ma1,ma2)>bsi2 && bsi1>bsi2))
        {
         //+----------------------------------------------------+
         //| Trend Line                                         |
         //+----------------------------------------------------+
         double a,b;
         double price[],upper[],lower[];
         ArraySetAsSeries(price,true);
         ArraySetAsSeries(upper,true);
         ArraySetAsSeries(lower,true);
         //---  Get Rate info
         int chk_h = CopyHigh(Symbol(),PERIOD_CURRENT,time[i],InpTrendPeriod,upper);
         int chk_l = CopyLow(Symbol(),PERIOD_CURRENT,time[i],InpTrendPeriod,lower);
         int chk_c = CopyClose(Symbol(),PERIOD_CURRENT,time[i],InpTrendPeriod,price);

         if(chk_c<InpTrendPeriod)
            continue;
         if(chk_h!=chk_c || chk_l!=chk_c)
            continue;
         //--- Calc regression
         if(!calc_regression(a,b,InpTrendPeriod,price))
            continue;
         //---
         double mid=a;
         double h1,h2,l1,l2;
         h1=0;
         h2=0;
         l1=0;
         l2=0;

         //---
         for(j=0; j<InpTrendPeriod; j++)
           {
            //---  calc trend high & low
            if(h1<upper[j]-mid)
               h1=upper[j]-mid;
            else
               if(h2<upper[j]-mid)
                  h2=upper[j]-mid;
            if(l1<mid-lower[j])
               l1=mid-lower[j];
            else
               if(l2<mid-lower[j])
                  l2=mid-lower[j];
            mid+=b;
            //---
           }
         //--- change trend line
         if(HighesBuffer[i-1]<HighesBuffer[i] || LowesBuffer[i-1]>LowesBuffer[i])
           {
            //---
            UpTrendBuffer[i] = a+(h1+h2)/2;
            LoTrendBuffer[i] = a-(l1+l2)/2;
            MdTrendBuffer[i]=a;
            SlopeBuffer[i]=b;
            //---
            for(j=1; j<InpTrendPeriod; j++)
              {
               //---
               UpTrendBuffer[i-j] = UpTrendBuffer[i-j+1]+b;
               LoTrendBuffer[i-j] = LoTrendBuffer[i-j+1]+b;
               MdTrendBuffer[i-j] = MdTrendBuffer[i-j+1]+b;
               //---
              }
            is_update=true;
           }
        }
      else
        {
         //+----------------------------------------------------+
         //| Channel                                            |
         //+----------------------------------------------------+
         is_update=true;
         UpTrendBuffer[i] = UpRangeBuffer[i];
         LoTrendBuffer[i] = DnRangeBuffer[i];
         MdTrendBuffer[i] = (UpRangeBuffer[i]+DnRangeBuffer[i])/2;
         SlopeBuffer[i]=0.0;
        }

      if(!is_update)
        {
         if(SlopeBuffer[i-1]==0)
           {
            //---
            UpTrendBuffer[i-1] = UpRangeBuffer[i-1];
            LoTrendBuffer[i-1] = DnRangeBuffer[i-1];
            MdTrendBuffer[i]=(UpRangeBuffer[i-1]+DnRangeBuffer[i-1])/2;
            SlopeBuffer[i-1]=0;
            //---
           }
         //---
         SlopeBuffer[i]=SlopeBuffer[i-1];
         UpTrendBuffer[i] = UpTrendBuffer[i-1]-SlopeBuffer[i];
         LoTrendBuffer[i] = LoTrendBuffer[i-1]-SlopeBuffer[i];
         MdTrendBuffer[i]=MdTrendBuffer[i-1]-SlopeBuffer[i];
        }
     }
//--- return value of prev_calculated for next call   return(rates_total);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+----------------------------------------------------+
//| Regression                                         |
//+----------------------------------------------------+
bool calc_regression(double  &a,double  &b,int span,double  &price[])
  {
//---
   double sumy=0.0;
   double sumx=0.0;
   double sumxy=0.0;
   double sumx2=0.0;
//---
   int x;
   int cnt=0;
   for(x=0; x<span; x++)
     {
      //---
      if(price[x]==0)
         continue;
      sumx+=x;
      sumx2+= x*x;
      sumy += price[x];
      sumxy+= price[x]*x;
      cnt++;
     }
//---
   double c=sumx2*cnt-sumx*sumx;
   if(c==0.0)
      return false;
   b=(sumxy*cnt-sumx*sumy)/c;
   a=(sumy-sumx*b)/cnt;
   return true;
  }
//+------------------------------------------------------------------+
//| B.S.I Index                                                      |
//+------------------------------------------------------------------+
double calc_bsi(const double  &hi[],
                const double  &lo[],
                const double  &cl[],
                const long  &vol[],
                int  pos,
                int span)
  {
//---
   int k;
   double sumpos=0.0;
   double sumneg=0.0;
   double sumhigh=0.0;
   double sumpvol = 0.0;
   double sumnvol = 0.0;
//---
   for(k=(pos-span+1); k<=pos; k++)
     {
      //---
      double v=1.0;
      if(InpUsingVolumeWeight && VolBuffer[k]>0)
        {
         double vol_fact=MathSqrt(VolBuffer[k]);
         v=MathSqrt(vol[k])/vol_fact;
        }
      //--- Range position ratio
      double ratio=0;
      //--- Bar Spread
      double sp=(hi[k]-lo[k]);
      //--- Not DownBar
      if(!(cl[k-1]-sp*0.2>cl[k]))
        {
         ratio=-1*(lo[k]/TangoMaBuffer[k])+2;
         sumpos+=(cl[k]-lo[k])*ratio*v;
        }
      //--- Not UpBar
      if(!(cl[k-1]+sp*0.2<cl[k]))
        {
         ratio=-1*(hi[k]/TangoMaBuffer[k])+2;
         sumneg+=(hi[k]-cl[k])*ratio*v;
        }
     }
//---
   double tmppos,tmpneg;
   tmppos=sumpos/span/ Point();
   tmpneg=sumneg/span/ Point();
//---
   double bsi;
   if((tmppos+tmpneg)!=0)
      bsi=TangoMaBuffer[pos]+8*Point()*(tmppos-tmpneg)*MathAbs((tmppos-tmpneg)/(tmppos+tmpneg));
   else
      bsi=TangoMaBuffer[pos]+0.0;
   return (bsi);
  }
//+------------------------------------------------------------------+
