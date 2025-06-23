//------------------------------------------------------------------

   #property copyright "mladen"
   #property link      "www.forex-tsd.com"

//------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3

#property indicator_label1  "eco trend"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'221,247,221',clrMistyRose
#property indicator_label2  "eco"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrLimeGreen,clrPaleVioletRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
#property indicator_label3  "eco signal"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrPaleVioletRed
#property indicator_style3  STYLE_DOT
#property indicator_width3  1

//
//
//
//
//

enum enStyle
{
   dis_tape,  // Display as tape
   dis_zero,  // Display as zero based zone
   dis_line   // Display as lines
};
enum enColors
{
   cl_onSlope,  // Color based on the slope of the oscillator
   cl_onZero    // Color based on zero cross
};
input double   Period1      = 32;     // T3 period no.1
input double   Period2      =  5;     // T3 period no.2
input double   Period3      =  5;     // T3 signal line period
input double   Hot          =  0.4;   // T3 hot
input bool     Original     =  false; // T3 original Tim Tillson calculation
input enColors ColorOnSlope =  cl_onZero; // Color based on : 
input enStyle  DisplayStyle = dis_zero;   // Display style

//
//
//
//
//

double eco[];
double sig[];
double fill1[];
double fill2[];
double colorBuffer[];

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
   SetIndexBuffer(0,fill1,INDICATOR_DATA);
   SetIndexBuffer(1,fill2,INDICATOR_DATA);
   SetIndexBuffer(2,eco  ,INDICATOR_DATA);
   SetIndexBuffer(3,colorBuffer,INDICATOR_COLOR_INDEX); 
   SetIndexBuffer(4,sig,INDICATOR_DATA);

   //
   //
   //
   //
   //
         
   IndicatorSetString(INDICATOR_SHORTNAME,"Blau T3 ergodic candlestick oscillator("+DoubleToString(Period1,1)+","+DoubleToString(Period1,2)+","+DoubleToString(Period3,1)+","+")");
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

   //
   //
   //
   //
   //
   
      for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
      {
         double co = iT3(iT3(close[i]-open[i],Period1,Hot,Original,i,rates_total,0),Period2,Hot,Original,i,rates_total,1);
         double hl = iT3(iT3(high[i]-low[i]  ,Period1,Hot,Original,i,rates_total,2),Period2,Hot,Original,i,rates_total,3);
            if (hl!=0)
                  eco[i]  = 100.0*co/hl;
            else  eco[i]  = 0;
                  sig[i]  = iT3(eco[i],Period3,Hot,Original,i,rates_total,4);
                  
            //
            //
            //
            //
            //
                              
            if (i>0)
            {
               colorBuffer[i]=colorBuffer[i-1];
               if (ColorOnSlope==cl_onSlope)
               {
                  if (eco[i]>eco[i-1]) colorBuffer[i]=0;
                  if (eco[i]<eco[i-1]) colorBuffer[i]=1;
               }
               else
               {
                  if (eco[i]>0) colorBuffer[i]=0;
                  if (eco[i]<0) colorBuffer[i]=1;
               }                  
            }
            
            //
            //
            //
            //
            //
            
            fill1[i] = EMPTY_VALUE;
            fill2[i] = EMPTY_VALUE;
            switch (DisplayStyle)
            {
               case dis_tape:
                     if (colorBuffer[i] == 0) { fill1[i] = MathMax(eco[i],sig[i]); fill2[i] = MathMin(eco[i],sig[i]); }
                     if (colorBuffer[i] == 1) { fill1[i] = MathMin(eco[i],sig[i]); fill2[i] = MathMax(eco[i],sig[i]); }
                     break;
               case dis_zero:
                     if (ColorOnSlope==cl_onSlope)
                     {
                        if (colorBuffer[i] == 0 && eco[i]>0) { fill1[i] = eco[i]; fill2[i] = 0; }
                        if (colorBuffer[i] == 0 && eco[i]<0) { fill2[i] = eco[i]; fill1[i] = 0; }
                        if (colorBuffer[i] == 1 && eco[i]>0) { fill2[i] = eco[i]; fill1[i] = 0; }
                        if (colorBuffer[i] == 1 && eco[i]<0) { fill1[i] = eco[i]; fill2[i] = 0; }
                     }
                     else
                     {
                        fill1[i] = MathMax(eco[i],0);
                        fill2[i] = MathMin(eco[i],0);
                     }                        
                     break;
               case dis_line: break;
            }
      }      
      return(rates_total);
}



//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define t3Instances 5
double workT3[][t3Instances*6];
double workT3Coeffs[][6];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define _c4     4
#define _alpha  5

//
//
//
//
//

double iT3(double price, double period, double hot, bool original, int r, int total, int instanceNo=0)
{
   if (ArrayRange(workT3,0) != total)               ArrayResize(workT3,total);
   if (ArrayRange(workT3Coeffs,0) < (instanceNo+1)) ArrayResize(workT3Coeffs,instanceNo+1);

   if (workT3Coeffs[instanceNo][_period] != period)
   {
     workT3Coeffs[instanceNo][_period] = period;
        double a = hot;
            workT3Coeffs[instanceNo][_c1] = -a*a*a;
            workT3Coeffs[instanceNo][_c2] = 3*a*a+3*a*a*a;
            workT3Coeffs[instanceNo][_c3] = -6*a*a-3*a-3*a*a*a;
            workT3Coeffs[instanceNo][_c4] = 1+3*a+a*a*a+3*a*a;
            if (original)
                 workT3Coeffs[instanceNo][_alpha] = 2.0/(1.0 + period);
            else workT3Coeffs[instanceNo][_alpha] = 2.0/(2.0 + (period-1.0)/2.0);
   }
   
   //
   //
   //
   //
   //
   
   int buffer = instanceNo*6;
   if (r == 0)
      {
         workT3[r][0+buffer] = price;
         workT3[r][1+buffer] = price;
         workT3[r][2+buffer] = price;
         workT3[r][3+buffer] = price;
         workT3[r][4+buffer] = price;
         workT3[r][5+buffer] = price;
      }
   else
      {
         workT3[r][0+buffer] = workT3[r-1][0+buffer]+workT3Coeffs[instanceNo][_alpha]*(price              -workT3[r-1][0+buffer]);
         workT3[r][1+buffer] = workT3[r-1][1+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][0+buffer]-workT3[r-1][1+buffer]);
         workT3[r][2+buffer] = workT3[r-1][2+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][1+buffer]-workT3[r-1][2+buffer]);
         workT3[r][3+buffer] = workT3[r-1][3+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][2+buffer]-workT3[r-1][3+buffer]);
         workT3[r][4+buffer] = workT3[r-1][4+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][3+buffer]-workT3[r-1][4+buffer]);
         workT3[r][5+buffer] = workT3[r-1][5+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][4+buffer]-workT3[r-1][5+buffer]);
      }

   //
   //
   //
   //
   //
   
   return(workT3Coeffs[instanceNo][_c1]*workT3[r][5+buffer] + 
          workT3Coeffs[instanceNo][_c2]*workT3[r][4+buffer] + 
          workT3Coeffs[instanceNo][_c3]*workT3[r][3+buffer] + 
          workT3Coeffs[instanceNo][_c4]*workT3[r][2+buffer]);
}