//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1

#property indicator_label1  "aroon oscillator line"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrLimeGreen,clrPaleVioletRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_minimum -101
#property indicator_maximum  101

//
//
//
//
//

input int    AroonPeriod  = 25; // Aroon period
input double Filter       = 50; // Level filter value

double osc[];
double oscc[];

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,osc ,INDICATOR_DATA);
   SetIndexBuffer(1,oscc,INDICATOR_COLOR_INDEX);
      IndicatorSetInteger(INDICATOR_LEVELS,2);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0, Filter);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,-Filter);
      IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrDimGray);
      IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrDimGray);
      IndicatorSetString(INDICATOR_SHORTNAME,"Arron oscillator("+DoubleToString(AroonPeriod,0)+")");
   return(0);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

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
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
   {
      double max = high[i]; double maxi = 0;
      double min = low[i];  double mini = 0;
             for (int k=1; k<AroonPeriod && (i-k)>=0; k++)
             {
                if (max<high[i-k]) { maxi=k; max = high[i-k]; }
                if (min>low[i-k] ) { mini=k; min = low[i-k];  }
             }                  
      osc[i] = 100.0*(mini-maxi)/(double)AroonPeriod;;
      if (i>0)
      {
         oscc[i] = 0;
            if(osc[i]> Filter) oscc[i]=1;
            if(osc[i]<-Filter) oscc[i]=2;
      }      
   }
   return(rates_total);
}