//+------------------------------------------------------------------+
//| InstVolControl03_Exness.mq5                                      |
//| Multi-symbol MT5 research EA for Exness Standard symbols.         |
//| Verify every symbol specification in the intended MT5 server.     |
//+------------------------------------------------------------------+
#property strict
#include <Trade/Trade.mqh>
CTrade trade;

input string SymbolsCSV="EURUSDm,XAUUSDm,US500m,USTECm";
input int MomentumLookback=252;
input int VolatilityLookback=63;
input int TrendPeriod=200;
input double TargetVolPercent=5.0;
input double MaxExposure=1.5;
input double RiskBudgetPercent=0.50;
input double MaxDailyLossPercent=2.5;
input double MaxDrawdownPercent=6.5;
input int TimerSeconds=10;
input ulong MagicNumber=26100604;

string symbols[];
datetime last_day=0,last_month=0;
double day_start=0,peak_equity=0;
bool daily_lock=false,total_lock=false;

int OnInit(){
 StringSplit(SymbolsCSV,',',symbols);trade.SetExpertMagicNumber(MagicNumber);peak_equity=AccountInfoDouble(ACCOUNT_EQUITY);day_start=peak_equity;EventSetTimer(TimerSeconds);return INIT_SUCCEEDED;
}
void OnDeinit(const int reason){EventKillTimer();}
double CloseAt(string s,int shift){return iClose(s,PERIOD_D1,shift);}
double AnnualVol(string s){
 double sum=0,sq=0;int n=0;
 for(int i=1;i<=VolatilityLookback;i++){double a=CloseAt(s,i),b=CloseAt(s,i+1);if(a<=0||b<=0)continue;double r=MathLog(a/b);sum+=r;sq+=r*r;n++;}
 if(n<20)return 0;return MathSqrt(MathMax(0,sq/n-MathPow(sum/n,2)))*MathSqrt(252.0);
}
bool Eligible(string s,double &score,double &vol){
 double now=CloseAt(s,1),old=CloseAt(s,1+MomentumLookback),trend=0;
 if(now<=0||old<=0)return false;
 for(int i=1;i<=TrendPeriod;i++){double c=CloseAt(s,i);if(c<=0)return false;trend+=c;}
 trend/=TrendPeriod;vol=AnnualVol(s);score=now/old-1;return vol>0&&score>0&&now>trend;
}
void RiskCheck(){
 double e=AccountInfoDouble(ACCOUNT_EQUITY);peak_equity=MathMax(peak_equity,e);
 if(day_start>0&&e<=day_start*(1-MaxDailyLossPercent/100.0))daily_lock=true;
 if(peak_equity>0&&e<=peak_equity*(1-MaxDrawdownPercent/100.0))total_lock=true;
 if(daily_lock||total_lock)for(int i=0;i<ArraySize(symbols);i++)if(PositionSelect(symbols[i]))trade.PositionClose(symbols[i]);
}
void Rebalance(){
 if(daily_lock||total_lock)return;
 string best="";double best_score=-DBL_MAX,best_vol=0;
 for(int i=0;i<ArraySize(symbols);i++){double score,vol;if(Eligible(symbols[i],score,vol)&&score>best_score){best=symbols[i];best_score=score;best_vol=vol;}}
 for(int i=0;i<ArraySize(symbols);i++)if(symbols[i]!=best&&PositionSelect(symbols[i]))trade.PositionClose(symbols[i]);
 if(best=="")return;
 double ask=SymbolInfoDouble(best,SYMBOL_ASK),contract=SymbolInfoDouble(best,SYMBOL_TRADE_CONTRACT_SIZE),step=SymbolInfoDouble(best,SYMBOL_VOLUME_STEP),minv=SymbolInfoDouble(best,SYMBOL_VOLUME_MIN);
 if(ask<=0||contract<=0||step<=0)return;
 double exposure=MathMin(MaxExposure,(TargetVolPercent/100.0)/best_vol);
 // This is a portfolio-notional budget. Actual broker margin and contract details must be verified.
 exposure=MathMin(exposure,RiskBudgetPercent/100.0*2.0);
 double volume=MathFloor((AccountInfoDouble(ACCOUNT_EQUITY)*exposure/(ask*contract))/step)*step;
 if(volume<minv)return;
 trade.SetExpertMagicNumber(MagicNumber);trade.SetDeviationInPoints(30);
 if(!PositionSelect(best))trade.Buy(volume,best,0,0,0,"inst-vol-control-03");
}
void OnTimer(){
 RiskCheck();MqlDateTime now;TimeToStruct(TimeCurrent(),now);
 if(last_day==0||now.day_of_year!=TimeDay(last_day)){last_day=TimeCurrent();day_start=AccountInfoDouble(ACCOUNT_EQUITY);daily_lock=false;}
 if(last_month==0||now.mon!=TimeMonth(last_month)){last_month=TimeCurrent();Rebalance();}
}
void OnTick(){RiskCheck();}
