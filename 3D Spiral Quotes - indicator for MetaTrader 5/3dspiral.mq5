//+------------------------------------------------------------------+
//|                                                     3DSpiral.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                         https://www.mql5.com/en/users/nikolay7ko |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Nikolay Semko"
#property link      "https://www.mql5.com/ru/users/nikolay7ko"
#property link      "SemkoNV@bk.ru"
#property version   "3.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   0
#include <Canvas\iCanvas_CB.mqh> //https://www.mql5.com/ru/code/22164

input int N = 200; // Maximum circles

double cl[];
int Size;
double max=-DBL_MAX, min=DBL_MAX;
double _r;
int _per=0,per=0;
double K;
bool rotate = true;
int startPos = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() {
   ChartSetInteger(0,CHART_SHOW,false);
   SetIndexBuffer(0,cl);
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
   _r=_Height/2-7;
   _per=int(2*M_PI*_r);
   per = _per;
   K=100*_Height;
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   ChartSetInteger(0,CHART_SHOW,true);
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
   int d=rates_total-prev_calculated;
   Size = rates_total;
   if (prev_calculated == 0 && rates_total>per*N) startPos = rates_total-per*N;
   if (d>0) {
        int from = prev_calculated>0?prev_calculated-1:0;
        for(int i=from;i<Size;i++){

         //cl[i]=(close[i]-close[i-1])/close[i];
         cl[i]=close[i];
         if (i >= startPos+1) {
            if(cl[i]>max) max=cl[i];
            if(cl[i]<min) min=cl[i];
         }
        }
   } else {
      //cl[Size-1]=(close[Size-1]-close[Size-2])/close[Size-2];
      cl[Size-1]=close[Size-1];
   }
   Draw();
   return(rates_total);
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
   if (id==CHARTEVENT_CLICK) rotate = !rotate;
   if (id==CHARTEVENT_MOUSE_MOVE)  {
      if (!rotate) per = int((1+5.0*_MouseX/_Width)*_per);
      Draw();
   }
  
}
//+------------------------------------------------------------------+
void Draw() {
   static uint last = 0;
   static int mx = 0,my =0;
   uint cur = GetTickCount();
   if (cur-last<30) return;
   last = cur;
   ulong t=GetMicrosecondCount();
   int X=_Width/2;
   int Y=_Height/2-5;
   Canvas.Erase(0x00FFFFFF);
   if (max-min<=0) return;
   int nn=0;
   double c=0;
   if (rotate) {
      mx = _MouseX;
      my = _MouseY;
   }
   int _a=(X   - mx + 5*per);
   int _b=(Y+5 - my + 5*per);
  
   for (int i=startPos,j=0; i<Size; i++,j++) {
      double r = _r*(0.3+0.7*(cl[i]-min)/(max-min));
      double cc=cos(j*2*M_PI/per);
      if (c<0 && cc>=0) nn++;
      c=cc;
      double z =r -r*2*double(j)/(Size-startPos);
      double x = c*r;
      double y = sin(j*2*M_PI/per)*r;
      //double R=sqrt(x*x+y*y+z*z);
      double x1=x*cos(_a*2*M_PI/per)+z*sin(_a*2*M_PI/per);
      double z1=-x*sin(_a*2*M_PI/per)+z*cos(_a*2*M_PI/per);
      double y1=y*cos(_b*2*M_PI/per)+z1*sin(_b*2*M_PI/per);
      double z2=-y*sin(_b*2*M_PI/per)+z1*cos(_b*2*M_PI/per);
      z2=z2+_r;
      x=X+K*x1/(z2+K);
      y=Y+K*y1/(z2+K);
      _PixelSet((int)x,(int)y,Canvas.Grad(double(i-startPos)/(Size-startPos)));
   }
   t=GetMicrosecondCount()-t;
   _CommXY(20,30,_Symbol);
   _Comment("Total "+string(nn)+" Circles");
   _Comment("Circle period = " + string(per)+" bars");
   _Comment("Runtime = "+string (t) +" mks");
   _Comment("Max : "+string(max));
   _Comment("Min : "+string(min));   
   Canvas.Update();
}