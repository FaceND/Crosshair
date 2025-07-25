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

enum ENUM_SELECTED
{
 YES = 1, // Yes
 NO  = 0  // No
};

enum ENUM_SPREAD_UNIT
{
 SPREAD_IN_PIPS    = 0, // Show spread in PIPs
 SPREAD_IN_POINTS  = 1  // Show spread in POINTs
};

input group "OPTIONS"
input ENUM_SELECTED        ShowCrosshair          = YES;  // Show crosshair between the cursor
input ENUM_SELECTED        ShowInfo               = YES;  // Show candle information on hover
input ENUM_SELECTED        ShowABS                = NO;   // Show ask,bid,spread price on the chart

input group "SETTINGS"
input ENUM_APPLIED_VOLUME  InfoVolumeType         = VOLUME_TICK;     // Volume type
input ENUM_SPREAD_UNIT     SpreadUnit             = SPREAD_IN_PIPS;  // Unit to use when reporting spread

input group "CROSSHAIR"
input color                CrosshairColor         = clrLightGray;    // Color
input ENUM_LINE_STYLE      CrosshairStyle         = STYLE_SOLID;     // Style
input int                  CrosshairWidth         = 1;               // Width

input group "INFORMATION"
input int                  Information_X          = 8;               // X Distance
input int                  Information_Y          = 5;               // Y Distance
input int                  InformationSpaceVolue  = 40;              // Space between Text & Volue
input color                InformationColor       = clrWhite;        // Text color
input int                  InformationSize        = 8;               // Font size

//-- Lines name
#define VLINE_NAME  "Vertical"
#define HLINE_NAME  "Horizontal"

//-- Labels name
#define INFO_OPEN   "OpenInfo"
#define INFO_HIGH   "HighInfo"
#define INFO_LOW    "LowInfo"
#define INFO_CLOSE  "CloseInfo"
#define INFO_VOLUME "VolumeInfo"

#define INFO_OPEN_VOLUE   "OpenInfo-volue"
#define INFO_HIGH_VOLUE   "HighInfo-volue"
#define INFO_LOW_VOLUE    "LowInfo-volue"
#define INFO_CLOSE_VOLUE  "CloseInfo-volue"
#define INFO_VOLUME_VOLUE "VolumeInfo-volue"

#define INFO_ASK    "AskInfo"
#define INFO_BID    "BidInfo"
#define INFO_SPREAD "SpreadInfo"

#define INFO_ASK_VOLUE    "AskInfo-volue"
#define INFO_BID_VOLUE    "BidInfo-volue"
#define INFO_SPREAD_VOLUE "SpreadInfo-volue"

int previous_x = -1;
int previous_y = -1;

int bar_index;
string current_info[];

const int period_seconds = PeriodSeconds();
double unit;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //-- Create Vertical and Horizontal line
   if(ShowCrosshair)
     {
      if(!CreateLine(VLINE_NAME, OBJ_VLINE)|| 
          !CreateLine(HLINE_NAME, OBJ_HLINE))
        {
         return INIT_FAILED;
        }
     }
   //-- Create candle infomation
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
      if(!CreateCandleInfo(INFO_OPEN_VOLUE,   5, InformationSpaceVolue)||
         !CreateCandleInfo(INFO_HIGH_VOLUE,   4, InformationSpaceVolue)||
         !CreateCandleInfo(INFO_LOW_VOLUE,    3, InformationSpaceVolue)||
         !CreateCandleInfo(INFO_CLOSE_VOLUE,  2, InformationSpaceVolue)||
         !CreateCandleInfo(INFO_VOLUME_VOLUE, 1, InformationSpaceVolue))
        {
         return INIT_FAILED;
        }
      GetCandleInfo(0, current_info);
     }
   //-- Create Bid, Ask and Spread
   if(ShowABS)
     {
      if(!CreateCandleInfo(INFO_ASK,    3)||
         !CreateCandleInfo(INFO_BID,    2)||
         !CreateCandleInfo(INFO_SPREAD, 1))
        {
         return INIT_FAILED;
        }
      if(!CreateCandleInfo(INFO_ASK_VOLUE,    3, InformationSpaceVolue-10)||
         !CreateCandleInfo(INFO_BID_VOLUE,    2, InformationSpaceVolue-10)||
         !CreateCandleInfo(INFO_SPREAD_VOLUE, 1, InformationSpaceVolue-10))
        {
         return INIT_FAILED;
        }
     }
   
   //-- Enable mouse move events
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);

   const double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   unit = SpreadUnit ? point : point * 10;

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
      
      ObjectDelete(0, INFO_OPEN_VOLUE);
      ObjectDelete(0, INFO_HIGH_VOLUE);
      ObjectDelete(0, INFO_LOW_VOLUE);
      ObjectDelete(0, INFO_CLOSE_VOLUE);
      ObjectDelete(0, INFO_VOLUME_VOLUE);
     }
   if(ShowABS)
     {
      ObjectDelete(0, INFO_ASK);
      ObjectDelete(0, INFO_BID);
      ObjectDelete(0, INFO_SPREAD);

      ObjectDelete(0, INFO_ASK_VOLUE);
      ObjectDelete(0, INFO_BID_VOLUE);
      ObjectDelete(0, INFO_SPREAD_VOLUE);
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
   ResetLastError();
   //+----------------------- Mouse Position ------------------------+
   const int x = (int)lparam;
   const int y = (int)dparam;
   //+---------------------------------------------------------------+
   switch(id)
     {
      case CHARTEVENT_MOUSE_MOVE:
        {
         ProcessChartChange(x, y);
         previous_x = x;
         previous_y = y;
         break;
        }
      case CHARTEVENT_CHART_CHANGE:
        {
         ProcessChartChange(previous_x, previous_y);
         break;
        }
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
   if(bar_index == 0)
     {
      GetCandleInfo(0, current_info);
      UpdateCandleInfo(current_info);
      UpdateAskBidSpread(false);
     }
   else if(bar_index == -1 || !ShowInfo)
     {
      UpdateAskBidSpread(true);
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
      ObjectSetInteger(0, line_name, OBJPROP_WIDTH,      CrosshairWidth);
      ObjectSetInteger(0, line_name, OBJPROP_STYLE,      CrosshairStyle);
      ObjectSetInteger(0, line_name, OBJPROP_SELECTABLE,          false);
      ObjectSetInteger(0, line_name, OBJPROP_SELECTED,            false);
      ObjectSetInteger(0, line_name, OBJPROP_HIDDEN,               true);
      ObjectSetInteger(0, line_name, OBJPROP_ZORDER,                 -1);
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Function to create the candle information                        |
//+------------------------------------------------------------------+
bool CreateCandleInfo(string info_name, int line_number=1, int sub_distance=0)
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
                    (InformationSize + InformationSize));
      int x_offset = Information_X + sub_distance;
      //+------------------------------------------------------------+
      ObjectSetInteger(0, info_name, OBJPROP_CORNER,  CORNER_LEFT_LOWER);
      ObjectSetInteger(0, info_name, OBJPROP_FONTSIZE,  InformationSize);
      ObjectSetInteger(0, info_name, OBJPROP_COLOR,    InformationColor);
      ObjectSetInteger(0, info_name, OBJPROP_SELECTABLE,          false);
      ObjectSetInteger(0, info_name, OBJPROP_SELECTED,            false);
      ObjectSetInteger(0, info_name, OBJPROP_HIDDEN,               true);
      ObjectSetInteger(0, info_name, OBJPROP_YDISTANCE,        y_offset);
      ObjectSetInteger(0, info_name, OBJPROP_XDISTANCE,        x_offset);
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
      if(bar_index < Bars(_Symbol, _Period) && sub_window == 0)
        {
         UpdateLines(time, price);
        }
      else
        {
         HiddenLines();
        }
     }
   string info[];

   bool showInfoCondition = ShowInfo && bar_index != -1 && sub_window == 0;
   bool showABSCondition = ShowABS && (!ShowInfo || !showInfoCondition);

   if(showInfoCondition)
     {
      GetCandleInfo(bar_index, info);
     }
   UpdateCandleInfo(info, showInfoCondition);
   UpdateAskBidSpread(showABSCondition); 
  }
//+------------------------------------------------------------------+
//| Function to update ask and bid data                              |
//+------------------------------------------------------------------+
void UpdateAskBidSpread(const bool not_blank = true)
  {
   if(ShowABS)
     {
      if(not_blank)
        {
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double spread = (ask - bid) / unit;

         ObjectSetString(0, INFO_ASK, OBJPROP_TEXT, "ask");
         ObjectSetString(0, INFO_BID, OBJPROP_TEXT, "bid");
         ObjectSetString(0, INFO_SPREAD, OBJPROP_TEXT, "spr.");

         ObjectSetString(0, INFO_ASK_VOLUE, OBJPROP_TEXT,
                        DoubleToString(ask, _Digits));
         ObjectSetString(0, INFO_BID_VOLUE, OBJPROP_TEXT,
                        DoubleToString(bid, _Digits));
         ObjectSetString(0, INFO_SPREAD_VOLUE, OBJPROP_TEXT,
                        TrimDouble(spread));
        }
      else
        {
         ObjectSetString(0, INFO_ASK, OBJPROP_TEXT, " ");
         ObjectSetString(0, INFO_BID, OBJPROP_TEXT, " ");
         ObjectSetString(0, INFO_SPREAD, OBJPROP_TEXT, " ");

         ObjectSetString(0, INFO_ASK_VOLUE, OBJPROP_TEXT, " ");
         ObjectSetString(0, INFO_BID_VOLUE, OBJPROP_TEXT, " ");
         ObjectSetString(0, INFO_SPREAD_VOLUE, OBJPROP_TEXT, " ");
        }
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
//| Function to update condle information                            |
//+------------------------------------------------------------------+
void UpdateCandleInfo(const string &infoList[], const bool not_blank = true)
  {
   if(ShowInfo)
     {
      if(not_blank)
        {
         ObjectSetString(0, INFO_OPEN,   OBJPROP_TEXT,  "Open");
         ObjectSetString(0, INFO_HIGH,   OBJPROP_TEXT,  "High");
         ObjectSetString(0, INFO_LOW,    OBJPROP_TEXT,  "Low");
         ObjectSetString(0, INFO_CLOSE,  OBJPROP_TEXT,  "Close");
         ObjectSetString(0, INFO_VOLUME, OBJPROP_TEXT,  "Vol.");

         ObjectSetString(0, INFO_OPEN_VOLUE,   OBJPROP_TEXT,  infoList[0]);
         ObjectSetString(0, INFO_HIGH_VOLUE,   OBJPROP_TEXT,  infoList[1]);
         ObjectSetString(0, INFO_LOW_VOLUE,    OBJPROP_TEXT,  infoList[2]);
         ObjectSetString(0, INFO_CLOSE_VOLUE,  OBJPROP_TEXT,  infoList[3]);
         ObjectSetString(0, INFO_VOLUME_VOLUE, OBJPROP_TEXT,  infoList[4]);
        }
      else
        {
         ObjectSetString(0, INFO_OPEN,   OBJPROP_TEXT,  " ");
         ObjectSetString(0, INFO_HIGH,   OBJPROP_TEXT,  " ");
         ObjectSetString(0, INFO_LOW,    OBJPROP_TEXT,  " ");
         ObjectSetString(0, INFO_CLOSE,  OBJPROP_TEXT,  " ");
         ObjectSetString(0, INFO_VOLUME, OBJPROP_TEXT,  " ");

         ObjectSetString(0, INFO_OPEN_VOLUE,   OBJPROP_TEXT,  " ");
         ObjectSetString(0, INFO_HIGH_VOLUE,   OBJPROP_TEXT,  " ");
         ObjectSetString(0, INFO_LOW_VOLUE,    OBJPROP_TEXT,  " ");
         ObjectSetString(0, INFO_CLOSE_VOLUE,  OBJPROP_TEXT,  " ");
         ObjectSetString(0, INFO_VOLUME_VOLUE, OBJPROP_TEXT,  " ");
        }
      ChartRedraw();
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
      array[0] = DoubleToString(rates[0].open,  _Digits);
      array[1] = DoubleToString(rates[0].high,  _Digits);
      array[2] = DoubleToString(rates[0].low,   _Digits);
      array[3] = DoubleToString(rates[0].close, _Digits);
      switch(InfoVolumeType)
        {
         case VOLUME_TICK:
            array[4] = FormatVolume(rates[0].tick_volume, 4, 1000000);
            break;
   
         case VOLUME_REAL:
            array[4] = FormatVolume(rates[0].real_volume, 4, 1000000);
            break;
        }
     }
  }
//+------------------------------------------------------------------+
//| Function to update crosshair lines                               |
//+------------------------------------------------------------------+
void UpdateLines(const datetime time, const double price)
  {
   //-- Vertical Line
   ObjectSetInteger(0, VLINE_NAME, OBJPROP_TIME,            time);
   ObjectSetInteger(0, VLINE_NAME, OBJPROP_COLOR, CrosshairColor);
   ObjectSetInteger(0, VLINE_NAME, OBJPROP_BACK,           false);
   ObjectSetInteger(0, VLINE_NAME, OBJPROP_ZORDER,            -1);

   //-- Horizon Line
   ObjectSetDouble (0, HLINE_NAME, OBJPROP_PRICE,           price);
   ObjectSetInteger(0, HLINE_NAME, OBJPROP_COLOR,  CrosshairColor);
   ObjectSetInteger(0, HLINE_NAME, OBJPROP_BACK,            false);
   ObjectSetInteger(0, HLINE_NAME, OBJPROP_ZORDER,             -1);

   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Function to update crosshair lines                               |
//+------------------------------------------------------------------+
void HiddenLines()
  {
   //-- Vertical Line
   ObjectSetInteger(0, VLINE_NAME, OBJPROP_COLOR, clrNONE);
   ObjectSetInteger(0, VLINE_NAME, OBJPROP_BACK,     true);
   ObjectSetInteger(0, VLINE_NAME, OBJPROP_ZORDER,      0);

   //-- Horizon Line
   ObjectSetInteger(0, HLINE_NAME, OBJPROP_COLOR, clrNONE);
   ObjectSetInteger(0, HLINE_NAME, OBJPROP_BACK,     true);
   ObjectSetInteger(0, HLINE_NAME, OBJPROP_ZORDER,      0);

   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Function to align datetime to the start of the timeframe period  |
//+------------------------------------------------------------------+
datetime AlignToTimeframe(datetime time)
  {
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
//| Function to remove trailing zeros from a double                  |
//+------------------------------------------------------------------+
string TrimDouble(double value)
  {
   string str = DoubleToString(value, _Digits);
   int len = StringLen(str);

   // Remove trailing zeros
   while(len > 0 && StringGetCharacter(str, len - 1) == '0')
     {
      len--;
     }

   // If last character is '.', remove it too
   if(len > 0 && StringGetCharacter(str, len - 1) == '.')
      len--;

   return StringSubstr(str, 0, len);
  }
//+------------------------------------------------------------------+