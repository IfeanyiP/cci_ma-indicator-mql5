//+------------------------------------------------------------------+
//|                                   TrendFollowingMultiCurrency.mq4|
//|                        Copyright 2024, Your Name                |
//|                                       https://www.yourwebsite.com |
//+------------------------------------------------------------------+
#property strict

// Input parameters
input int    RiskPercent = 2;            // Risk percentage per trade
input double StopLossPips = 50;          // Stop loss in pips
input double TakeProfitPips = 100;       // Take profit in pips

// Trend following parameters
input int    MA_Period = 20;             // Moving average period
input int    MA_Method = MODE_SMA;       // Moving average method
input int    MA_Price = PRICE_CLOSE;     // Applied price for moving average

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Add your initialization code here
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Add your deinitialization code here
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Loop through currency pairs
   string symbols[] = {"EURUSD", "GBPUSD", "USDJPY"}; // Add more pairs as needed
   for (int i = 0; i < ArraySize(symbols); i++)
     {
      double maValue = iMA(symbols[i], 0, MA_Period, 0, MA_Method, MA_Price, 0);
      double closePrice = Close[i];
      double stopLoss = StopLossPips * Point;
      double takeProfit = TakeProfitPips * Point;

      // Check for trend
      if (closePrice > maValue)
        {
         // Buy signal
         double lotSize = CalculateLotSize();
         int ticket = OrderSend(symbols[i], OP_BUY, lotSize, closePrice, 3, 0, 0, "Trend Buy", 0, 0, Green);
         if (ticket > 0)
           {
            OrderModify(ticket, 0, closePrice - stopLoss, closePrice + takeProfit, 0, clrNONE);
           }
        }
      else if (closePrice < maValue)
        {
         // Sell signal
         double lotSize = CalculateLotSize();
         int ticket = OrderSend(symbols[i], OP_SELL, lotSize, closePrice, 3, 0, 0, "Trend Sell", 0, 0, Red);
         if (ticket > 0)
           {
            OrderModify(ticket, 0, closePrice + stopLoss, closePrice - takeProfit, 0, clrNONE);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Custom function to calculate lot size based on risk percentage   |
//+------------------------------------------------------------------+
double CalculateLotSize()
  {
   double accountBalance = AccountBalance();
   double riskAmount = accountBalance * RiskPercent / 100;
   double lotSize = riskAmount / (StopLossPips * MarketInfo(Symbol(), MODE_POINT));
   return NormalizeDouble(lotSize, 2);
  }
