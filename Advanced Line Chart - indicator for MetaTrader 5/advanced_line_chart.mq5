//+------------------------------------------------------------------+
//|                                          ADVANCED LINE CHART.mq5 |
//|                                  Copyright 2023, Igor Gerasimov. |
//|                                                 tgwls2@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Igor Gerasimov."
#property link      "tgwls2@gmail.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrDarkGray
#property indicator_width1 1
#define   THIRD (1/(double)3)
#define   ELOG2 MathLog(2)
double Z[],Z0[3]= {0,0,0};
datetime T=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    SetIndexBuffer(0,Z,INDICATOR_DATA);
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
    const int x=rates_total-1,
              y=prev_calculated-1;
    if(T!=time[x] || y<=0)
        {
            if(y<=0) ArrayFill(Z0,0,3,0);
            const int y0=y<x?y:y-1;
            for(int z=(y0>=0?y0:0); z<x && !IsStopped(); z++)
                {
                    const double s=high[z]-low[z],
                                 t=(high[z]+low[z])/2,
                                 u=((high[z]-Temp(open[z],high[z],low[z],close[z],t,s))/s-0.5)*2,
                                 w=u-Z0[0],
                                 v=MathAbs(w)>0?w/MathMax(MathMax(MathAbs(w),MathAbs(Z0[0]-Z0[1])),MathAbs(Z0[1]-Z0[2])):0;
                    Z[z]=t-(high[z]-t)*(u+v)/2;
                    Z0[2]=Z0[1];
                    Z0[1]=Z0[0];
                    Z0[0]=u;
                }
        }
    {
        const double s0=high[x-1]-low[x-1],
                     s=high[x]-low[x],
                     t=(high[x]+low[x])/2,
                     u=((high[x]-Temp(open[x],high[x],low[x],close[x],t,s))/s-0.5)*2,
                     w=u-Z0[0],
                     v=MathAbs(w)>0?w/MathMax(MathMax(MathAbs(w),MathAbs(Z0[0]-Z0[1])),MathAbs(Z0[1]-Z0[2])):0,
                     r=MathMax((double)((int)TimeCurrent()-(int)time[x]+1)/PeriodSeconds(PERIOD_CURRENT),(MathMax(s,s0)>0?s/MathMax(s,s0):0)),
                     d=1-r,
                     a=MathSin(d*M_PI_2),
                     b=r>0?r*(1-r*MathLog(1/r)/ELOG2):0,
                     c=MathTanh(d*12);
        Z[x]=(Z[x-1]*c+(t-(high[x]-t)*(u+v)/2)*b+(Z[x-1]+(Z[x-1]-Z[x-2])/2+close[x])*a/2)/(a+b+c);
    }
    T=time[x];
    return(rates_total);
}
//+------------------------------------------------------------------+
//| Temp                                                             |
//+------------------------------------------------------------------+
double Temp(const double o,
            const double h,
            const double l,
            const double c,
            const double m,
            const double r)
{
    const double a=3*MathPow(r,2),b=a>0?4*(MathPow(c,2)+MathPow(o,2))/a-8*c*o/a-THIRD:0;
    return(m+(h-m)*((MathMin(o,c)>m || c>o)?b:((MathMax(o,c)<m || c<o)?-b:0)));
}
//+------------------------------------------------------------------+
