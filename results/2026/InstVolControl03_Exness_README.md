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

TradingView’s normal strategy tester executes orders on the chart symbol. It cannot reproduce the true multi-symbol portfolio in one ordinary strategy account. Use the Pine file for chart-level signal validation and alerts; use the MT5 EA for multi-symbol portfolio testing.

The MT5 file does not invent broker contract sizes or costs. It reads contract/tick/volume specifications from the connected MT5 server. Verify the intended Exness Standard server symbols, contract size, volume step, margin, spread, commission, swaps, and trading sessions before testing.

The original Yahoo/ETF strategy results are not Exness-specific and must not be treated as validation for these symbols.
