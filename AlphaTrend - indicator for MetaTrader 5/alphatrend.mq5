#property copyright "Mahmut Deniz"
#property version   "1.00"

// Indicator properties
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   3
// AlphaTrend line properties
#property indicator_label1  "AlphaTrend"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDimGray,clrGreen,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
// Buy signal properties
#property indicator_label2  "Buy Signal"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrGreen
#property indicator_width2  1
// Sell signal properties
#property indicator_label3  "Sell Signal"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_width3  1

// Arrow codes
#define ARROW_BUY    233
#define ARROW_SELL   234

// Input parameters
input double   Multiplier = 1.0;           // Multiplier
input int      CommonPeriod = 14;          // Common Period
input bool     ShowSignals = false;         // Show Signals?
input bool     NoVolumeData = false;       // Change calculation (no volume data)?
input ENUM_APPLIED_PRICE PriceType = PRICE_CLOSE; // Applied Price

// Indicator buffers
double AlphaTrendBuffer[];   // Main AlphaTrend buffer
double ColorBuffer[];        // Color buffer
double BuyBuffer[];          // Buy signals buffer
double SellBuffer[];         // Sell signals buffer
double ATRBuffer[];          // ATR buffer
double RSIBuffer[];          // RSI buffer
double MFIBuffer[];          // MFI buffer
double PrevAlphaTrend[];     // Previous AlphaTrend values

// Indicator handles
int atr_handle;              // ATR indicator handle
int rsi_handle;              // RSI indicator handle
int mfi_handle;              // MFI indicator handle

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
    // Initialize buffers
    SetIndexBuffer(0, AlphaTrendBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, ColorBuffer, INDICATOR_COLOR_INDEX);
    SetIndexBuffer(2, BuyBuffer, INDICATOR_DATA);
    SetIndexBuffer(3, SellBuffer, INDICATOR_DATA);
    SetIndexBuffer(4, ATRBuffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(5, RSIBuffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(6, MFIBuffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(7, PrevAlphaTrend, INDICATOR_CALCULATIONS);

    // Set arrow codes for signals
    PlotIndexSetInteger(1, PLOT_ARROW, ARROW_BUY);
    PlotIndexSetInteger(2, PLOT_ARROW, ARROW_SELL);

    // Initialize indicators
    atr_handle = iATR(NULL, 0, CommonPeriod);
    rsi_handle = iRSI(NULL, 0, CommonPeriod, PriceType);
    mfi_handle = iMFI(NULL, 0, CommonPeriod, VOLUME_TICK);

    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                                |
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
    
    if(rates_total < CommonPeriod) return 0;
    
    int start = prev_calculated > 0 ? prev_calculated - 1 : CommonPeriod;
    
    // Copy indicator data
    if(CopyBuffer(atr_handle, 0, 0, rates_total, ATRBuffer) <= 0) return 0;
    if(CopyBuffer(rsi_handle, 0, 0, rates_total, RSIBuffer) <= 0) return 0;
    if(CopyBuffer(mfi_handle, 0, 0, rates_total, MFIBuffer) <= 0) return 0;
    
    // Main calculation loop
    for(int i = start; i < rates_total; i++) {
        double upT   = low[i] - ATRBuffer[i] * Multiplier;
        double downT = high[i] + ATRBuffer[i] * Multiplier;
        
        bool trend_condition = NoVolumeData ? RSIBuffer[i] >= 50 : MFIBuffer[i] >= 50;
        
        if(trend_condition) {
            AlphaTrendBuffer[i] = upT < AlphaTrendBuffer[i-1] ? AlphaTrendBuffer[i-1] : upT;
        } else {
            AlphaTrendBuffer[i] = downT > AlphaTrendBuffer[i-1] ? AlphaTrendBuffer[i-1] : downT;
        }
        

        
        // Store previous value for comparison
        PrevAlphaTrend[i] = AlphaTrendBuffer[i-2];
        
        // Set color
        ColorBuffer[i] = AlphaTrendBuffer[i] > PrevAlphaTrend[i] ? 1 : (AlphaTrendBuffer[i] < PrevAlphaTrend[i] ? 2 : 0);
        
        // Calculate signals
        if(ShowSignals) {
            // Buy signal
            if(AlphaTrendBuffer[i] > PrevAlphaTrend[i] && 
               AlphaTrendBuffer[i-1] <= PrevAlphaTrend[i-1]) {
                BuyBuffer[i] = low[i] * 0.9999;
            } else {
                BuyBuffer[i] = EMPTY_VALUE;
            }
            
            // Sell signal
            if(AlphaTrendBuffer[i] < PrevAlphaTrend[i] && 
               AlphaTrendBuffer[i-1] >= PrevAlphaTrend[i-1]) {
                SellBuffer[i] = high[i] * 1.0001;
            } else {
                SellBuffer[i] = EMPTY_VALUE;
            }
        }
    }
    
    return(rates_total);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    IndicatorRelease(atr_handle);
    IndicatorRelease(rsi_handle);
    IndicatorRelease(mfi_handle);
}