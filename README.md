# Crosshair

An interactive crosshair-based indicator for MetaTrader 5 that displays detailed candle information directly on the chart.
It provides OHLC (Open, High, Low, Close) and volume data for the selected bar, with optional multi-chart synchronization 
for a seamless analysis experience.

---

## 📑 Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Inputs](#inputs)
- [Customization](#customization)
- [Usage](#usage)
- [Script Code](#script-code)
- [Contributing](#contributing)
- [Note](#Notes)
- [License](#license)

---

## ✨ Features
  - Crosshair-driven interaction for precise candle inspection
  - Displays OHLC values (Open, High, Low, Close)
  - Supports both tick volume and real volume
  - Real-time updates as the cursor moves across the chart
  - Multi-chart crosshair synchronization (time-based)

---

## 🚀 Installation

1. Download or clone this repository:
   ```
   git clone https://github.com/FaceND/Crosshair.git
   ```

2. Copy the indicator file (`.mq5` or compiled `.ex5`) into:
   ```
   MQL5/Indicators/
   ```

3. Restart MetaTrader 5

4. Open MT5 → Navigator → Indicators → Drag & Drop the indicator onto a chart

---

## 📝 Inputs

### 🔹 Multi-Chart

| Input            | Description                                                                                                 |
| ---------------- | ----------------------------------------------------------------------------------------------------------- |
| `Chart Sync`     | Enables synchronization of the crosshair across multiple charts using time-based events.                    |
| `Throttle (ms)`  | Controls update frequency (in milliseconds) to optimize performance and prevent excessive event triggering. |



### 🔹 Options

| Input                                 | Description                                                               |
| ------------------------------------- | ------------------------------------------------------------------------- |
| `Show Crosshair between the cursor`   | Displays the crosshair lines following the cursor position.               |
| `Show candle information on hover`    | Shows candle information (OHLC and volume) when hovering over a bar.      |
| `Show "ask,bid,spread" on the chart`  | Displays Ask, Bid, and Spread information when candle info is not active. |

### 🔹 Settings

| Input         | Description                                                            |
| ------------- | ---------------------------------------------------------------------- |
| `Volume type` | Selects the volume type used for display (tick volume or real volume). |

### 🔹 Crosshair

| Input     | Description                                    |
| --------- | ---------------------------------------------- |
| `Color`   | Defines the color of the crosshair lines.      |
| `Style`   | Sets the line style (solid, dashed, dotted).   |
| `Width`   | Controls the thickness of the crosshair lines. |

### 🔹 Information

| Input                        | Description                                       |
| ---------------------------- | ------------------------------------------------- |
| `X Distance`                 | Horizontal offset (pixels) from the chart corner. |
| `Y Distance`                 | Vertical offset (pixels) from the chart corner.   |
| `Space between Text & Volue` | Space between text labels and volume display.     |
| `Text color`                 | Text color used in the information panel.         |
| `Font size`                  | Font size of the displayed information.           |

---

## 🎨 Customization

You can customize the name of the object event by modifying the following number in the script.
```mql5
#define EVT_MOUSE_MOVE  2001
#define EVT_MOUSE_LEAVE 2002
```

---

## 📖  Usage

1. Attach the indicator to multiple charts
2. Move your mouse on any chart
3. The crosshair position will be shared across charts
4. Each chart will display candle data aligned to the same time

### Behavior

* Hover over a candle → displays OHLC + volume
* Crosshair moves → updates instantly across all synced charts
* Works with different symbols and timeframes
* Uses **time-based synchronization** for consistency

---

## 💻 Script Code

Below is the MQL5 code used to create the "Crosshair" indicator

```mql5
//+------------------------------------------------------------------+
//|                                                    Crosshair.mq5 |
//|                                           Copyright 2025, FaceND |
//|                              https://github.com/FaceND/Crosshair |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2025, FaceND."
#property link        "https://github.com/FaceND/Crosshair"
#property version     "1.4"
#property description "Interactive crosshair-based indicator that displays detailed candle information "
#property description "including OHLC (Open, High, Low, Close) and volume data directly on the chart, "
#property description "updating dynamically as the cursor moves to provide precise and efficient market analysis."
#property strict
#property indicator_chart_window
#property indicator_plots 0

input group "MUTI-CHART"
input bool                 ChartSync              = false;         // Chart Sync
input int                  ThrottleMs             = 100;           // Throttle (ms)

input group "OPTIONS"
input bool                 ShowCrosshair          = true;  // Show Crosshair between the cursor
input bool                 ShowInfo               = true;  // Show candle information on hover
input bool                 ShowABS                = true;  // Show "ask,bid,spread" on the chart

input group "SETTINGS"
input ENUM_APPLIED_VOLUME  InfoVolumeType         = VOLUME_TICK;   // Volume type

input group "Crosshair"
input color                CrosshairColor         = clrLightGray;  // Color
input ENUM_LINE_STYLE      CrosshairStyle         = STYLE_SOLID;   // Style
input int                  CrosshairWidth         = 1;             // Width

input group "INFORMATION"
input int                  Information_X          = 8;             // X Distance
input int                  Information_Y          = 5;             // Y Distance
input int                  InformationSpaceVolue  = 40;            // Space between Text & Volue
input color                InformationColor       = clrWhite;      // Text color
input int                  InformationSize        = 8;             // Font size

struct CrosshairState
  {
   datetime time;
   double   price;
   int      bar;
   int      window;
   bool     visible;
  };

struct InformationList
  {
   string open;
   string high;
   string low;
   string close;
   string volume;
   string spread;
   datetime time;
  };

CrosshairState Crosshair;
InformationList Current_bar;

#define EVT_MOUSE_MOVE  2001
#define EVT_MOUSE_LEAVE 2002

#define VLINE_NAME         "Crosshair_Vertical"
#define HLINE_NAME         "Crosshair_Horizontal"

#define INFO_OPEN          "Crosshair_OpenInfo"
#define INFO_HIGH          "Crosshair_HighInfo"
#define INFO_LOW           "Crosshair_LowInfo"
#define INFO_CLOSE         "Crosshair_CloseInfo"
#define INFO_VOLUME        "Crosshair_VolumeInfo"

#define INFO_OPEN_VOLUE    "Crosshair_OpenInfo-volue"
#define INFO_HIGH_VOLUE    "Crosshair_HighInfo-volue"
#define INFO_LOW_VOLUE     "Crosshair_LowInfo-volue"
#define INFO_CLOSE_VOLUE   "Crosshair_CloseInfo-volue"
#define INFO_VOLUME_VOLUE  "Crosshair_VolumeInfo-volue"

#define INFO_ASK           "Crosshair_AskInfo"
#define INFO_BID           "Crosshair_BidInfo"
#define INFO_SPREAD        "Crosshair_SpreadInfo"

#define INFO_ASK_VOLUE     "Crosshair_AskInfo-volue"
#define INFO_BID_VOLUE     "Crosshair_BidInfo-volue"
#define INFO_SPREAD_VOLUE  "Crosshair_SpreadInfo-volue"

int previous_x = -1;
int previous_y = -1;

datetime mouse_time;
int previous_bar = -1;

int chart_height;
int chart_width;

uint event_last_send = 0;
const int period_seconds = PeriodSeconds();
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- Create Vertical and Horizontal line
   if(ShowCrosshair)
     {
      if(!CreateLineObject(VLINE_NAME, OBJ_VLINE)|| 
         !CreateLineObject(HLINE_NAME, OBJ_HLINE))
        {
         return INIT_FAILED;
        }
     }
   //--- Create candle infomation
   if(ShowInfo)
     {
      if(!CreateTextObject(INFO_OPEN,   5)||
         !CreateTextObject(INFO_HIGH,   4)||
         !CreateTextObject(INFO_LOW,    3)||
         !CreateTextObject(INFO_CLOSE,  2)||
         !CreateTextObject(INFO_VOLUME, 1))
        {
         return INIT_FAILED;
        }
      if(!CreateTextObject(INFO_OPEN_VOLUE,   5, InformationSpaceVolue)||
         !CreateTextObject(INFO_HIGH_VOLUE,   4, InformationSpaceVolue)||
         !CreateTextObject(INFO_LOW_VOLUE,    3, InformationSpaceVolue)||
         !CreateTextObject(INFO_CLOSE_VOLUE,  2, InformationSpaceVolue)||
         !CreateTextObject(INFO_VOLUME_VOLUE, 1, InformationSpaceVolue))
        {
         return INIT_FAILED;
        }
     }
   //--- Create Bid, Ask and Spread
   if(ShowABS)
     {
      if(!CreateTextObject(INFO_ASK,    3)||
         !CreateTextObject(INFO_BID,    2)||
         !CreateTextObject(INFO_SPREAD, 1))
        {
         return INIT_FAILED;
        }
      if(!CreateTextObject(INFO_ASK_VOLUE,    3, InformationSpaceVolue-10)||
         !CreateTextObject(INFO_BID_VOLUE,    2, InformationSpaceVolue-10)||
         !CreateTextObject(INFO_SPREAD_VOLUE, 1, InformationSpaceVolue-10))
        {
         return INIT_FAILED;
        }
     }
   //--- Enable mouse move events
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   Crosshair.visible = false;
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "Crosshair_", -1, -1);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Custom indicator Timer function                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   UpdateText();
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Chart Event Handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int                 id,
                  const long           &lparam,
                  const double         &dparam,
                  const string         &sparam)
  {
   //+----------------------- Mouse Position ------------------------+
   const int x = (int)lparam;
   const int y = (int)dparam;
   //+---------------------------------------------------------------+
   if(id == CHARTEVENT_CUSTOM + EVT_MOUSE_MOVE)
     {
      if(!ChartSync)
        {
         if(previous_bar != -1)
           {
            UpdateText(false);
           }
         HideCrosshair();
         Crosshair.bar = -1;
         previous_bar = Crosshair.bar;
        }
      else
        {
         HandleReceiveMove(x, y, (datetime)sparam);
        }
     return;
     }
   else if(id == CHARTEVENT_CUSTOM + EVT_MOUSE_LEAVE)
     {
      HideCrosshair();

      Crosshair.bar = -1;
      Crosshair.visible = false;

      UpdateText(false);
      return;
     }
   else if(id == CHARTEVENT_MOUSE_MOVE)
     {
      previous_x = x;
      previous_y = y;

      HandleMouseMove(x, y);
      return;
     }
   else if(id == CHARTEVENT_CHART_CHANGE)
     {
      chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
      chart_width  = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS,  0);
      if(!ChartGetInteger(0, CHART_AUTOSCROLL))
        {
         HandleMouseMove(previous_x, previous_y);
        }
      return;
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int             rates_total,
                const int         prev_calculated,
                const datetime            &time[],
                const double              &open[],
                const double              &high[],
                const double               &low[],
                const double             &close[],
                const long         &tick_volume[],
                const long              &volume[],
                const int               &spread[])
  {
   GetCurrentBarInfomation(rates_total-1, time, open, high, low, 
                           close, volume, tick_volume, spread);
   if((Crosshair.bar == 0 && Crosshair.visible) || Crosshair.bar == -1)
     {
      UpdateText(false);
     }
   return rates_total;
  }
//+------------------------------------------------------------------+
//| Function to create the Crosshair lines                           |
//+------------------------------------------------------------------+
bool CreateLineObject(const string obj_name, const ENUM_OBJECT line_type)
  {
   if(ObjectFind(0, obj_name) == -1)
     {
      if(!ObjectCreate(0, obj_name, line_type, 0, 0, 0))
        {
         Print("Error creating line: ", obj_name,
               " Error code: ", GetLastError());
         return false;
        }
      ObjectSetInteger(0, obj_name, OBJPROP_WIDTH,      CrosshairWidth);
      ObjectSetInteger(0, obj_name, OBJPROP_STYLE,      CrosshairStyle);
      ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE,          false);
      ObjectSetInteger(0, obj_name, OBJPROP_SELECTED,            false);
      ObjectSetInteger(0, obj_name, OBJPROP_HIDDEN,               true);
      ObjectSetString (0, obj_name, OBJPROP_TOOLTIP,              "\n");
      ObjectSetInteger(0, obj_name, OBJPROP_ZORDER,                100);
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Function to create the candle information                        |
//+------------------------------------------------------------------+
bool CreateTextObject(const string obj_name, const int line_number = 1, const int sub_distance = 0)
  {
   if(ObjectFind(0, obj_name) == -1)
     {
      if(!ObjectCreate(0, obj_name, OBJ_LABEL, 0, 0, 0))
        {
         Print("Error creating label: ", obj_name,
               " Error code: ", GetLastError());
         return false;
        }
      //+------------------------------------------------------------+
      int y_offset = Information_Y + (line_number *
                    (InformationSize + InformationSize));
      int x_offset = Information_X + sub_distance;
      //+------------------------------------------------------------+
      ObjectSetInteger(0, obj_name, OBJPROP_CORNER,  CORNER_LEFT_LOWER);
      ObjectSetInteger(0, obj_name, OBJPROP_COLOR,    InformationColor);
      ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE,  InformationSize);
      ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE,          false);
      ObjectSetInteger(0, obj_name, OBJPROP_SELECTED,            false);
      ObjectSetInteger(0, obj_name, OBJPROP_HIDDEN,               true);
      ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE,        y_offset);
      ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE,        x_offset);
      ObjectSetString (0, obj_name, OBJPROP_TEXT,                  " ");
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Function to handle when mouse move event                         |
//+------------------------------------------------------------------+
void HandleMouseMove(const int x_coordinate, const int y_coordinate)
  {
   ResetLastError();

   GetBarTimePrice(Crosshair, x_coordinate, y_coordinate);
   if(Crosshair.window == 0 && IsInsideChart(x_coordinate, y_coordinate))
     {
      //+--------------------------- Bar ----------------------------+
      bool history_mode = Crosshair.time <= Current_bar.time;
      Crosshair.bar = iBarShift(_Symbol, _Period, Crosshair.time, !history_mode);
      //+--------------------------- Time ---------------------------+
      mouse_time = Crosshair.time;
      if(Crosshair.bar != -1)
        {
         Crosshair.time = AlignToTimeframe(Crosshair.time);
        }
      //+--------------------------- Line ---------------------------+
      UpdateCrosshair(Crosshair.time, Crosshair.price);
      BroadcastEvent((ushort)EVT_MOUSE_MOVE, x_coordinate,
                        y_coordinate, (string)mouse_time);
      Crosshair.visible = true;
     }
   else
     {
      Crosshair.bar = -1;
      HideCrosshair();
      BroadcastEvent((ushort)EVT_MOUSE_LEAVE, x_coordinate,
                        y_coordinate, (string)mouse_time);
      Crosshair.visible = false;
     }
   //+------------------------------ Text ---------------------------+
   EventKillTimer();
   if(Crosshair.bar != previous_bar)
     {
      if(HoverStateChanged(previous_bar, Crosshair.bar))
        {
         UpdateText(true);
        }
      else
        {
         EventSetMillisecondTimer(30); 
        }
     }
   //+---------------------------------------------------------------+
  }
//+------------------------------------------------------------------+
//| Function to handle when receive mouse move event                 |
//+------------------------------------------------------------------+
void HandleReceiveMove(const int x_coordinate, const int y_coordinate, const datetime time)
  {
   ResetLastError();

   if(GetBarTimePrice(Crosshair, x_coordinate, y_coordinate))
     {
      //+--------------------------- Bar ----------------------------+
      bool history_mode = Crosshair.time <= Current_bar.time;
      Crosshair.bar = iBarShift(_Symbol, _Period, time, !history_mode);
      //+--------------------------- Time ---------------------------+
      Crosshair.time = time;
      if(Crosshair.bar != -1)
        {
         Crosshair.time = AlignToTimeframe(Crosshair.time);
        }
      //+--------------------------- Line ---------------------------+
      UpdateCrosshair(Crosshair.time, Crosshair.price);
      Crosshair.visible = true;
     }
   //+------------------------------ Text ---------------------------+
   EventKillTimer();
   if(Crosshair.bar != previous_bar)
     {
      if(HoverStateChanged(previous_bar, Crosshair.bar))
        {
         UpdateText(true);
        }
      else
        {
         EventSetMillisecondTimer(50); 
        }
     }
   //+---------------------------------------------------------------+
  }
//+------------------------------------------------------------------+
//| Function to get bar's information with OnCalculate function      |
//+------------------------------------------------------------------+
void GetCurrentBarInfomation(
                          const int                rates,
                          const datetime&          time[],
                          const double&            open[],
                          const double&            high[],
                          const double&             low[],
                          const double&           close[],
                          const long&       real_volume[],
                          const long&       tick_volume[],
                          const int&             spread[])
  {
   Current_bar.open   = DoubleToString(open[rates],  _Digits);
   Current_bar.high   = DoubleToString(high[rates],  _Digits);
   Current_bar.low    = DoubleToString(low[rates],   _Digits);
   Current_bar.close  = DoubleToString(close[rates], _Digits);
   Current_bar.volume = FormatVolume(SelectVolume(
                              real_volume[rates],
                              tick_volume[rates]));
   Current_bar.spread = IntegerToString(spread[rates]);
   Current_bar.time   = time[rates];
  }
//+------------------------------------------------------------------+
//| Function to get bar's information with index                     |
//+------------------------------------------------------------------+
void GetBarInfomation(const int bar, InformationList &list)
  {
   MqlRates rates[];
   
   if(CopyRates(_Symbol, 0, bar, 1, rates) != -1)
     {
      list.open   = DoubleToString(rates[0].open,  _Digits);
      list.high   = DoubleToString(rates[0].high,  _Digits);
      list.low    = DoubleToString(rates[0].low,   _Digits);
      list.close  = DoubleToString(rates[0].close, _Digits);
      list.volume = FormatVolume(SelectVolume(
                                    rates[0].real_volume, 
                                    rates[0].tick_volume));
     }
  }
//+------------------------------------------------------------------+
//| Function to update text information object                       |
//+------------------------------------------------------------------+
void UpdateText(const bool redraw = true)
  {
   InformationList info;

   bool showInfoCondition = ShowInfo && Crosshair.visible && Crosshair.bar != -1;
   bool showABSCondition = ShowABS && !showInfoCondition;

   if(showInfoCondition)
     {
      if(Crosshair.bar > 0)
        {
         GetBarInfomation(Crosshair.bar, info);
        }
      else
        {
         info = Current_bar;
        }
     }

   UpdateBarObject(info, showInfoCondition);
   UpdateABSObject(showABSCondition);

   if(redraw)
     {
      ChartRedraw();
     }
   previous_bar = Crosshair.bar;
  }
//+------------------------------------------------------------------+
//| Function to show Crosshair lines                                 |
//+------------------------------------------------------------------+
void UpdateCrosshair(const datetime time, const double price)
  {
   //--- Vertical Line
   ObjectMove(0, VLINE_NAME, 0, time, 0);
   ObjectSetInteger(0, VLINE_NAME, OBJPROP_COLOR, CrosshairColor);
   ObjectSetInteger(0, VLINE_NAME, OBJPROP_BACK,           false);
   ObjectSetString (0, VLINE_NAME, OBJPROP_TOOLTIP,         "\n");
   ObjectSetInteger(0, VLINE_NAME, OBJPROP_ZORDER,            -1);

   //--- Horizon Line
   ObjectMove(0, HLINE_NAME, 0, 0, price);
   ObjectSetInteger(0, HLINE_NAME, OBJPROP_COLOR,  CrosshairColor);
   ObjectSetInteger(0, HLINE_NAME, OBJPROP_BACK,            false);
   ObjectSetString (0, HLINE_NAME, OBJPROP_TOOLTIP,          "\n");
   ObjectSetInteger(0, HLINE_NAME, OBJPROP_ZORDER,             -1);
   
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Function to hidden Crosshair lines                               |
//+------------------------------------------------------------------+
void HideCrosshair()
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
//| Function to update condle information                            |
//+------------------------------------------------------------------+
void UpdateBarObject(const InformationList &list, const bool not_blank = true)
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

         ObjectSetString(0, INFO_OPEN_VOLUE,   OBJPROP_TEXT,  list.open);
         ObjectSetString(0, INFO_HIGH_VOLUE,   OBJPROP_TEXT,  list.high);
         ObjectSetString(0, INFO_LOW_VOLUE,    OBJPROP_TEXT,  list.low);
         ObjectSetString(0, INFO_CLOSE_VOLUE,  OBJPROP_TEXT,  list.close);
         ObjectSetString(0, INFO_VOLUME_VOLUE, OBJPROP_TEXT,  list.volume);
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
     }
  }
//+------------------------------------------------------------------+
//| Function to update ask and bid data                              |
//+------------------------------------------------------------------+
void UpdateABSObject(const bool not_blank = true)
  {
   if(ShowABS)
     {
      if(not_blank)
        {
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

         ObjectSetString(0, INFO_ASK,    OBJPROP_TEXT, "ask");
         ObjectSetString(0, INFO_BID,    OBJPROP_TEXT, "bid");
         ObjectSetString(0, INFO_SPREAD, OBJPROP_TEXT, "spr.");

         ObjectSetString(0, INFO_ASK_VOLUE, OBJPROP_TEXT,
                        DoubleToString(ask, _Digits));
         ObjectSetString(0, INFO_BID_VOLUE, OBJPROP_TEXT,
                        Current_bar.close);
         ObjectSetString(0, INFO_SPREAD_VOLUE, OBJPROP_TEXT,
                        Current_bar.spread);
        }
      else
        {
         ObjectSetString(0, INFO_ASK,   OBJPROP_TEXT, " ");
         ObjectSetString(0, INFO_BID,   OBJPROP_TEXT, " ");
         ObjectSetString(0, INFO_SPREAD, OBJPROP_TEXT, " ");

         ObjectSetString(0, INFO_ASK_VOLUE,    OBJPROP_TEXT, " ");
         ObjectSetString(0, INFO_BID_VOLUE,    OBJPROP_TEXT, " ");
         ObjectSetString(0, INFO_SPREAD_VOLUE, OBJPROP_TEXT, " ");
        }
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void BroadcastEvent(ushort event, const long lparam, const double dparam, const string sparam)
  {
   if(GetTickCount() - event_last_send < (uint)ThrottleMs) return;
   event_last_send = GetTickCount();

   long self = ChartID();
   long id = ChartFirst();

   while(id != -1)
     {
      if(id != self)
        {
         EventChartCustom(id, event, lparam, dparam, sparam);
        }
      id = ChartNext(id);
     }
  }
//+------------------------------------------------------------------+
//| Function to create the candle information                        |
//+------------------------------------------------------------------+ 
bool GetBarTimePrice(CrosshairState &state, const int x, const int y)
  {
   return ChartXYToTimePrice(0, x, y, state.window,
                              state.time, state.price);
  }
//+------------------------------------------------------------------+
//| Function to create the candle information                        |
//+------------------------------------------------------------------+
bool IsInsideChart(const int x, const int y)
  {
   return (x > 8 && y > 8 &&
           x <= chart_width-8 &&
           y <= chart_height-8);
  }
//+------------------------------------------------------------------+
//| Function to create the candle information                        |
//+------------------------------------------------------------------+
bool HoverStateChanged(const int previous, const int current)
  {
   return (previous == -1) != (current == -1);
  }
//+------------------------------------------------------------------+
//| Function to align datetime to the start of the timeframe period  |
//+------------------------------------------------------------------+
datetime AlignToTimeframe(const datetime time)
  {
   return time - time % period_seconds;
  }
//+------------------------------------------------------------------+
//| Custom indicator Construction object function                    |
//+------------------------------------------------------------------+
long SelectVolume(const long real_volume, const long tick_volume)
  {
   return (InfoVolumeType == VOLUME_REAL)
          ? real_volume
          : tick_volume;
  }
//+------------------------------------------------------------------+
//| Function to format volume value                                  |
//+------------------------------------------------------------------+
string FormatVolume(const long volume)
  {
   const string string_volume = IntegerToString(volume);
   const int length = StringLen(string_volume);
   if(length <= 6)
     {
      return string_volume;
     }
   int index = length - 6;

   string integer = StringSubstr(string_volume, 0, index);
   string dicimal = StringSubstr(string_volume, index, 4);
   
   return integer + "." + dicimal + "M";
  }
//+------------------------------------------------------------------+
```

---

## 🤝 Contributing

Contributions are welcome! If you have any improvements, bug fixes, or new features to suggest, please follow these steps

1. Fork the repository
2. Create a new branch

   ```
   git checkout -b feature/your-feature-name
   ```
3. Make your changes
4. Commit your work

   ```
   git commit -m "Add your feature"
   ```
5. Push to your branch

   ```
   git push origin feature/your-feature-name
   ```
6. Open a Pull Request

---

## 📌 Notes

* This indicator works per chart (no multi-chart synchronization)
* Designed for performance and smooth interaction
* Best used for manual trading and analysis

---

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
