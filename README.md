# Crosshair

An interactive crosshair-based indicator for MetaTrader 5 that displays detailed candle information directly on the chart.
It provides OHLC (Open, High, Low, Close) and volume data for the selected bar, with optional multi-chart synchronization 
for a seamless analysis experience.

---

## 📑 Table of Contents
- [Features](#-features)
- [Installation](#-installation)
- [Inputs](#-inputs)
- [Customization](#-customization)
- [Usage](#-usage)
- [Contributing](#-contributing)
- [Notes](#-notes)
- [License](#-license)

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

## 📖 Usage

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
