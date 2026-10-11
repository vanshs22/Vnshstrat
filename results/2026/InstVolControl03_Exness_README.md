# inst-vol_control-03 Exness research implementation

## Files

- `InstVolControl03_Exness.pine`: TradingView chart-level strategy/signal implementation.
- `InstVolControl03_Exness.mq5`: Multi-symbol MT5 Expert Advisor for Strategy Tester.

## Intended symbols

`EURUSDm,XAUUSDm,US500m,USTECm`

The `m` suffix is an Exness Standard-account convention reported by Exness documentation, but the exact server symbols must be verified in the user’s MT5 terminal.

## Logic

- Monthly rebalance.
- 252-day momentum score.
- 63-day annualized volatility estimate.
- 200-day SMA trend filter.
- Long-only.
- Select the strongest eligible instrument.
- Volatility-targeted exposure with a 1.5x cap.
- Daily loss lock: 2.5%.
- Maximum drawdown lock: 6.5%.
- No live orders are placed by this repository.

## Important implementation limitation

TradingView’s normal strategy tester executes orders on the chart symbol. It cannot reproduce the true multi-symbol portfolio in one ordinary strategy account. The Pine file sizes a chart-symbol test position directly as notional units (`equity × exposure / price`) so you can compare returns without entering a broker point value. This is not exact Exness lot/margin sizing; use the MT5 EA and verified contract specifications for broker-accurate sizing.

The MT5 file does not invent broker contract sizes or costs. It reads contract/tick/volume specifications from the connected MT5 server. Verify the intended Exness Standard server symbols, contract size, volume step, margin, spread, commission, swaps, and trading sessions before testing.

The original Yahoo/ETF strategy results are not Exness-specific and must not be treated as validation for these symbols.

## GoCharting

`InstVolControl03_GoCharting.lipi` is a current-chart Lipi indicator. Paste it into GoCharting’s Lipi Editor and add it to the chart. It calculates the strategy’s current-chart momentum, volatility, trend eligibility, and exposure estimate.

GoCharting’s official Lipi documentation states that Lipi scripts are indicators and do not provide a strategy/order-placement surface or multi-symbol data requests. Therefore this file cannot be a GoCharting Strategy Tester order-execution strategy; use the Pine file for TradingView backtesting or the MT5 EA for multi-symbol Strategy Tester execution.

### Limited-history chart mode

The Lipi indicator now includes `Short-history test mode`. Enable it only when the chart has insufficient history: it uses 10-bar momentum, 5-bar volatility, and 20-bar trend settings so a roughly 20-day chart can display signals. This is a diagnostic short-history variant and is **not equivalent** to the original 252/63/200-bar strategy. For faithful testing, use at least 252/200 bars on the intended timeframe.
