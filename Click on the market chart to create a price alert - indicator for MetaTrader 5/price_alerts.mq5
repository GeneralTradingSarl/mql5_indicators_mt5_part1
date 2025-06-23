//+------------------------------------------------------------------+
//|                                                 Price Alerts.mq5 |
//|                            Copyright phade 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright phade 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1

#property indicator_label1 "PRICE ALERT"
#property indicator_type1 DRAW_ARROW
#property indicator_style1 STYLE_SOLID
#property indicator_color1 clrLightBlue

#define KEY_UP 38


enum GMTOffset{

    GMT_plus_3 = 3, // GMT+3
    GMT_plus_2 = 2, // GMT+2
    GMT_plus_1 = 1, // GMT+1
    GMT = 0 // GMT
};


enum Direction{

    up = 1, // Bullish Alert
    down = 0 // Bearish Alert
};


enum AlertType{

    email = 2, // Email 
    mobile = 1, // Mobile Notification
    normal = 0 // Basic Alert
};


input GMTOffset timezone = 1; // Timezone
input Direction direction = 1; // Alert Configuration
input AlertType type = 0; // Type of alert

bool isMouseClicked = false;

int bars;
double price_buf[];



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, price_buf, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_ARROW, 214);
   
   bars = Bars(Symbol(), Period());
   
   ChartRedraw(0);

   return INIT_SUCCEEDED;
}



int completedProcess = 0;

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
                const int &spread[]){
                
      if(rates_total < bars-1)
         return 0;    
      
      if(price_buf[bars-1] == 0.0){
      
         price_buf[bars-1] = EMPTY_VALUE;
      }
        
      if (price_buf[bars-1] != 0.0 && price_buf[bars-1] != EMPTY_VALUE){
      
           double currentPrice = close[rates_total-1];
      
           // Compare the current market price with the threshold
           if (currentPrice > price_buf[bars-1] && direction == 1 && completedProcess != 1){ 
                  
               string alertMessage = (string)_Symbol + ": " + "Market moved up past the price alert threshold at the price level: " + DoubleToString(currentPrice, _Digits);         
                    
               if(type == 0) Alert(alertMessage);
               else if(type == 1) SendNotification(alertMessage); 
               else if(type == 2) SendMail("Price Alert for " + (string)_Symbol, alertMessage);             
               completedProcess = 1;
           }
           
           else if (currentPrice < price_buf[bars-1] && direction == 0 && completedProcess != 1){    
               
               string alertMessage = (string)_Symbol + ": " + "Market moved down past the price alert threshold at the level: " + DoubleToString(currentPrice, _Digits);  
                           
               if(type == 0) Alert(alertMessage);
               else if(type == 1) SendNotification(alertMessage); 
               else if(type == 2) SendMail("Price Alert for " + (string)_Symbol, alertMessage); 
               completedProcess = 1;   
           }
      }            

      return rates_total;
  }
//+------------------------------------------------------------------+


void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam){                 
                     
      if(id == CHARTEVENT_KEYDOWN){
       
         if((int)lparam == KEY_UP){
      
            isMouseClicked = false; // alert can be altered when the keyboard up arrow key is pressed    
            completedProcess = 0; 
         }
      }              
            
      if (id == CHARTEVENT_CLICK && !isMouseClicked){
       
            datetime currentTime = AdjustTimeForGMT(TimeCurrent(), GMT_plus_1);         
            string formattedTime = TimeToString(currentTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS);     
                       
            Print("Created an alert on " + (string)_Symbol + " at price: " + DoubleToString(GetMouseY(dparam)) + " " + formattedTime);                     
            price_buf[bars-1] = GetMouseY(dparam);                      
            Comment("ALERT AT PRICE: ", NormalizeDouble(GetMouseY(dparam), 5));  
                                       
            isMouseClicked = true; // lock the alert in place
       }
}


double GetMouseY(const double &dparam){

        long chartHeightInPixels = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
        double priceRange = ChartGetDouble(0, CHART_PRICE_MAX) - ChartGetDouble(0, CHART_PRICE_MIN);
        double pixelsPerPrice = chartHeightInPixels / priceRange;
        double mouseYValue = ChartGetDouble(0, CHART_PRICE_MAX) - dparam / pixelsPerPrice;
        
        return mouseYValue;
}


datetime AdjustTimeForGMT(const datetime time, const GMTOffset gmt_offset){

    datetime adjusted_time;

    switch (gmt_offset){
    
        case 3:
            adjusted_time = time; // GMT+3 by default
            break;
        case 2:
            adjusted_time = time - 3600; // minus 1 hour for GMT+2
            break;
        case 1:
            adjusted_time = time - 7200; // minus 2 hours for GMT+1
            break;
        case 0:
            adjusted_time = time - 10800; // minus 3 hours for GMT
            break;
        default:
            adjusted_time = time;
            Print("Invalid GMT offset provided.");
            break;
    }

    return adjusted_time;
}




void OnDeinit(const int reason){

  ChartSetString(0, CHART_COMMENT, "");
  
  IndicatorRelease(0);
}  