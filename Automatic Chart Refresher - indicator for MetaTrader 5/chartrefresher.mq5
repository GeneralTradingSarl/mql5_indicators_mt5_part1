//+------------------------------------------------------------------+
//|                                               ChartRefresher.mq5 |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_plots  0
#property indicator_buffers   0

// Define the input parameters
input int RefreshIntervalMinutes = 1; // Interval in minutes

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   EventSetTimer(RefreshIntervalMinutes * 60); // Set a timer to trigger the OnTimer event every 1 minute (60 seconds)
   return(INIT_SUCCEEDED);
 }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){

   EventKillTimer(); // Remove the timer when the indicator is removed from the chart
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime& time[],
    const double& open[], const double& high[], const double& low[], const double& close[],
    const long& tick_volume[], const long& volume[], const int& spread[])
{ 
return rates_total; }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer(){

   ChartRedraw(); // Refresh the chart
   PrintFormat("Chart refreshed using a refresh period of %d (in minutes)", RefreshIntervalMinutes); //uncomment to test it, comment out when using
}
//+------------------------------------------------------------------+
