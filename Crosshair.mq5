//+------------------------------------------------------------------+
//|                                                    Crosshair.mq5 |
//|                                           Copyright 2025, FaceND |
//|                              https://github.com/FaceND/Crosshair |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, FaceND."
#property link      "https://github.com/FaceND/Crosshair"
#property indicator_chart_window
#property indicator_plots 0
#property strict

enum INPUT_SELECTED
{
 YES = 1, // Yes
 NO  = 0  // No
};

input group "OPTION"
input INPUT_SELECTED       ShowCrosshair    = YES;   // Show crosshair between the cursor
input INPUT_SELECTED       ShowInfo         = YES;   // Show candle information on hover

input group "SETTINGS"
input ENUM_APPLIED_VOLUME  InfoVolumeType   = VOLUME_TICK;      // Volume type
input INPUT_SELECTED       ShowBidAsk       = NO;    // Show bid & ask price on the chart

input group "CROSSHAIR"
input color                CrosshairColor   = clrLightGray;     // Color
input ENUM_LINE_STYLE      CrosshairStyle   = STYLE_SOLID;      // Style
input int                  CrosshairWidth   = 1;                // Width

input group "INFORMATION"
input int                  Information_X          = 8;          // X Distance
input int                  Information_Y          = 8;          // Y Distance
input int                  InformationSpaceLine   = 7;          // Space Between Lines
input color                InformationColor       = clrWhite;   // Text color
input int                  InformationSize        = 8;          // Font size


// Label name
#define VLINE_NAME "Vertical"
#define HLINE_NAME "Horizontal"

#define INFO_OPEN   "OpenInfo"
#define INFO_HIGH   "HighInfo"
#define INFO_LOW    "LowInfo"
#define INFO_CLOSE  "CloseInfo"
#define INFO_VOLUME "VolumeInfo"

#define ASK_NAME "ASKInfo"
#define BID_NAME "BidInfo"

int previous_x = -1;
int previous_y = -1;

int bar_index;
string current_info[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Create Vertical and Horizontal line
   if(ShowCrosshair)
     {
      if(!CreateLine(VLINE_NAME, OBJ_VLINE)|| 
          !CreateLine(HLINE_NAME, OBJ_HLINE))
        {
         return INIT_FAILED;
        }
     }
   // Create candle infomation
   if(ShowInfo)
     {
      if(!CreateCandleInfo(INFO_OPEN,   5)||
         !CreateCandleInfo(INFO_HIGH,   4)||
         !CreateCandleInfo(INFO_LOW,    3)||
         !CreateCandleInfo(INFO_CLOSE,  2)||
         !CreateCandleInfo(INFO_VOLUME, 1))
        {
         return INIT_FAILED;
        }
      // Create Ask and Bid
      if(ShowBidAsk)
        {
         if(!CreateCandleInfo(ASK_NAME, 2)||
            !CreateCandleInfo(BID_NAME, 1))
        {
         return INIT_FAILED;
        }
      }
   GetCandleInfo(0, current_info);
   }
   // Enable mouse move events
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);

   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0, VLINE_NAME);
   ObjectDelete(0, HLINE_NAME);

   if(ShowInfo)
     {
      ObjectDelete(0, INFO_OPEN);
      ObjectDelete(0, INFO_HIGH);
      ObjectDelete(0, INFO_LOW);
      ObjectDelete(0, INFO_CLOSE);
      ObjectDelete(0, INFO_VOLUME);

      if(ShowBidAsk)
        {
         ObjectDelete(0, ASK_NAME);
         ObjectDelete(0, BID_NAME);
        }
     }
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Chart Event Handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int                 id,
                  const long           &lparam,
                  const double         &dparam,
                  const string         &sparam)
  {
   switch(id)
     {
      case CHARTEVENT_CHART_CHANGE:
      case CHARTEVENT_MOUSE_WHEEL:
         ProcessChartChange(previous_x, previous_y);
         break;

      case CHARTEVENT_MOUSE_MOVE:
        {
         int x = (int)lparam;
         int y = (int)dparam;

         ProcessChartChange(x, y);

         previous_x = x;
         previous_y = y;
        }
      break;
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int           rates_total,
                const int       prev_calculated,
                const datetime          &time[],
                const double            &open[],
                const double            &high[],
                const double             &low[],
                const double           &close[],
                const long       &tick_volume[],
                const long            &volume[],
                const int             &spread[])
  {
   if(ShowInfo)
     {
      if(bar_index == 0)
        {
         GetCandleInfo(0, current_info);
         UpdateCandleInfo(current_info);
        }
      else if(bar_index == -1 && ShowBidAsk)
        {
         UpdateAskBid();
        }
     }
   return rates_total;
  }
//+------------------------------------------------------------------+
//| Function to create the crosshair lines                           |
//+------------------------------------------------------------------+
bool CreateLine(string line_name, ENUM_OBJECT line_type)
  {
   if(ObjectFind(0, line_name) == -1)
     {
      if(!ObjectCreate(0, line_name, line_type, 0, 0, 0))
        {
         Print("Error creating line: ", line_name,
               " Error code: ", GetLastError());
         return false;
        }
      ObjectSetInteger(0, line_name, OBJPROP_COLOR, CrosshairColor);
      ObjectSetInteger(0, line_name, OBJPROP_WIDTH, CrosshairWidth);
      ObjectSetInteger(0, line_name, OBJPROP_STYLE, CrosshairStyle);
      ObjectSetInteger(0, line_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, line_name, OBJPROP_SELECTED, false);
      ObjectSetInteger(0, line_name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, line_name, OBJPROP_ZORDER, -1);
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Function to create the candle information                        |
//+------------------------------------------------------------------+
bool CreateCandleInfo(string info_name, int line_number=1)
  {
   if(ObjectFind(0, info_name) == -1)
     {
      if(!ObjectCreate(0, info_name, OBJ_LABEL, 0, 0, 0))
        {
         Print("Error creating label: ", info_name,
               " Error code: ", GetLastError());
         return false;
        }

      //+------------------------------------------------------------+
      int y_offset = Information_Y + (line_number *
                    (InformationSize + InformationSpaceLine));
      //+------------------------------------------------------------+

      ObjectSetInteger(0, info_name, OBJPROP_CORNER,  CORNER_LEFT_LOWER);
      ObjectSetInteger(0, info_name, OBJPROP_FONTSIZE,  InformationSize);
      ObjectSetInteger(0, info_name, OBJPROP_COLOR,    InformationColor);
      ObjectSetInteger(0, info_name, OBJPROP_SELECTABLE,          false);
      ObjectSetInteger(0, info_name, OBJPROP_SELECTED,            false);
      ObjectSetInteger(0, info_name, OBJPROP_HIDDEN,               true);
      ObjectSetInteger(0, info_name, OBJPROP_XDISTANCE,   Information_X);
      ObjectSetInteger(0, info_name, OBJPROP_YDISTANCE,        y_offset);
      ObjectSetInteger(0, info_name, OBJPROP_ZORDER,                 -1);
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Function to process when chart change                            |
//+------------------------------------------------------------------+
void ProcessChartChange(const int x_coordinate, const int y_coordinate)
  {
   datetime time;
   double price;
   int sub_window;

   ChartXYToTimePrice(0, x_coordinate, y_coordinate, sub_window, time, price);
     {
      bar_index = iBarShift(_Symbol, _Period, time, true);

      if(bar_index != -1)
        {
         time = AlignToTimeframe(time);
        }
      if(bar_index < Bars(_Symbol, _Period))
        {
         UpdateLines(time, price);
        }
     }
   if(ShowInfo)
     {
      string info[];
      if(bar_index != -1)
        {
         GetCandleInfo(bar_index, info);
         UpdateCandleInfo(info);
         UpdateAskBid(false);
        }
      else
        {
         UpdateCandleInfo(info, false);
         UpdateAskBid();
        }
     }
  }
//+------------------------------------------------------------------+
//| Function to update ask and bid data                              |
//+------------------------------------------------------------------+
void UpdateAskBid(const bool not_blank = true)
  {
   if(not_blank)
     {
      string ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      string bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      ObjectSetString(0, ASK_NAME, OBJPROP_TEXT, "ask   " + 
         DoubleToString(ask, _Digits));
      ObjectSetString(0, BID_NAME, OBJPROP_TEXT, "bid    " + 
         DoubleToString(bid, _Digits));
     }
   else
     {
      ObjectSetString(0, ASK_NAME, OBJPROP_TEXT, " ");
      ObjectSetString(0, BID_NAME, OBJPROP_TEXT, " ");
     }
  }
//+------------------------------------------------------------------+
//| Function to update condle information                            |
//+------------------------------------------------------------------+
void UpdateCandleInfo(const string &infoList[], const bool not_blank = true)
  {
   if(not_blank)
     {
      ObjectSetString(0, INFO_OPEN,   OBJPROP_TEXT,  infoList[0]);
      ObjectSetString(0, INFO_HIGH,   OBJPROP_TEXT,  infoList[1]); 
      ObjectSetString(0, INFO_LOW,    OBJPROP_TEXT,  infoList[2]); 
      ObjectSetString(0, INFO_CLOSE,  OBJPROP_TEXT,  infoList[3]); 
      ObjectSetString(0, INFO_VOLUME, OBJPROP_TEXT,  infoList[4]); 
     }
   else
     {
      ObjectSetString(0, INFO_OPEN,   OBJPROP_TEXT,  " ");
      ObjectSetString(0, INFO_HIGH,   OBJPROP_TEXT,  " "); 
      ObjectSetString(0, INFO_LOW,    OBJPROP_TEXT,  " "); 
      ObjectSetString(0, INFO_CLOSE,  OBJPROP_TEXT,  " ");
      ObjectSetString(0, INFO_VOLUME, OBJPROP_TEXT,  " "); 
     }
  }
//+------------------------------------------------------------------+
//| Function to format volume value                                  |
//+------------------------------------------------------------------+
void GetCandleInfo(const int index, string& array[])
  {  
   MqlRates rates[];
   
   if(ArraySize(array) != 5)
     {
      ArrayResize(array, 5);
     }

   if(CopyRates(_Symbol, 0, index, 1, rates) != -1)
     {
      array[0] = "Open   "    + DoubleToString(rates[0].open,  _Digits);
      array[1] = "High     "  + DoubleToString(rates[0].high,  _Digits);
      array[2] = "Low     "   + DoubleToString(rates[0].low,   _Digits);
      array[3] = "Close   "   + DoubleToString(rates[0].close, _Digits);
      switch(InfoVolumeType)
        {
         case VOLUME_TICK:
            array[4] = "Vol.      " + 
                        FormatVolume(rates[0].tick_volume, 4, 1000000);
            break;
   
         case VOLUME_REAL:
            array[4] = "Vol.      " + 
                        FormatVolume(rates[0].real_volume, 4, 1000000);
            break;
        }
     }
  }
//+------------------------------------------------------------------+
//| Function to update crosshair lines                               |
//+------------------------------------------------------------------+
void UpdateLines(const datetime time, const double price)
  {
   ObjectMove(0, VLINE_NAME, 0, time, 0);
   ObjectMove(0, HLINE_NAME, 0, 0, price);
   
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Function to align datetime to the start of the timeframe period  |
//+------------------------------------------------------------------+
datetime AlignToTimeframe(datetime time)
  {
   int period_seconds = PeriodSeconds(PERIOD_CURRENT);
   return time - time % period_seconds;
  }
//+------------------------------------------------------------------+
//| Function to format volume value                                  |
//+------------------------------------------------------------------+
string FormatVolume(const long volume, const int digits=8, const long threshold=0)
  {
   if(digits < 0)
     {
      return "Error: Digits must be >= 0";
     }
   if(threshold < 0)
     {
      return "Error: Threshold must be >= 0";
     }
   if(volume < threshold)
     {
      return IntegerToString(volume);
     }
   double scaledVolume = volume >= 1000000 ? volume / 1000000.0 : 
                         volume >= 1000    ? volume / 1000.0    : volume;

   string suffix = volume >= 1000000 ? "M" :
                   volume >= 1000    ? "K" : "";

   return digits == 0 && scaledVolume == MathFloor(scaledVolume) 
          ? IntegerToString((int)scaledVolume) + suffix 
          : DoubleToString(scaledVolume, digits) + suffix;
  }
//+------------------------------------------------------------------+