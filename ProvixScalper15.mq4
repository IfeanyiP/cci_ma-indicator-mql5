//+------------------------------------------------------------------+
//|                                                  BOLL_CANDLE.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023,ddscoles"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


int Trade_number = 1; // Number of Trades

input static string Trading_time = "================Trading Time====================="; //Trading Time
input bool verbose = true; // Verbose true/false
input bool BuyTrade = true; // Allow Buy Trade
input bool SellTrade = true;// Allow Sell Trade
input int maxopenorders = 1;//Max Open Orders
input string openinghour_min = "00:30"; // Start Trading Time (HH:MM)
input string closinghour_min = "18:30"; // Stop Trading Time (HH:MM)
input string Order_comment = "";// Order comment
input bool useMM = true;
input double MinLot = 0.02;// Min Lot size
input double MaxLot = 10;// Max Lot size
input double lotSize = 0.1;  // Fixed Lot
input bool closeatoppositecandle = false;//Close At Price Reversal
input bool Oppsignal = false;// Close At Opposite Signal
input double marginPer10k = 2.5;
input int initial_magic = 123; // Magic Number
input int Desiredspread = 200; // Spread
int NumTrades;
int Tickets[100];
datetime end = D'2054.09.10'; // Expiry Date

string T1 = "T3 Fatl.ex4";
string T2 = "TES Filter.ex4";
string T3 = "TES Filter Trading Zone Indicator.ex4";
string T4 = "wpr_t3.ex4";

input static string MAA = "================MA for Trade Open Filter====================="; //MA for Trade Open Filter
input bool MA = true;//Use MA Filter for Trade Open
input int Price = 0;// Price
input int MA_Period = 65; // MA Period
input ENUM_MA_METHOD MA_METHOD = MODE_SMA;// MA Method
//====================================================================
input static string WPR = "================WPR T3 Trade Open Filter====================="; //WPR T3 Trade Open Filter
input bool wpr = true;//Use WPR T3 Trade Open
//======================================================
input static string TESFILTERTRADE = "================TES FILTER TRADE SETTINGS====================="; //TES FILTER TRADE SETTINGS
input double TAKEPROFIT = 400;// TES Trade TP
input double STOPLOSS = 200;// TES Trade SL
input static string FATI = "================T3 Fati Trade Open Filter====================="; //T3 Fati Trade Open
input bool t3fati = true; // Use T3 Fati Trade Open
input bool Testrail = true;// Use Trailing Stop
input bool Breakeven = false;// Use Breakeven
input double TrailingStart = 50;// Trailing Trigger
input double TrailingPercentage = 60; // Trail Percent (Default to 60%)
input double TrailingBuffer = 20;// Trailing Buffer
//===========================================
input double breakstart = 50;// Break even Trigger
input double Breakbuffer = 5;// Breakeven Buffer
input bool TESTP_SL = true;// Use TES TP & SL
double t21;
double t1,t11,t3,t31,t4,t41,t42;
double t2;
//datetime lastBarTime = 0; // Variable to store the opening time of the last bar





//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {


   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   static datetime OT;
   datetime NT[3];

   CopyTime(_Symbol, _Period, 0, 1, NT);
   if(OT != NT[0])
     {
      t1 = iCustom(_Symbol,PERIOD_CURRENT,T1,0,2);
      t11 = iCustom(_Symbol,PERIOD_CURRENT,T1,1,2);
      t2 = iCustom(_Symbol,PERIOD_CURRENT,T2,0,1);
      t21 = iCustom(_Symbol,PERIOD_CURRENT,T2,1,1);
      t3 = iCustom(_Symbol,PERIOD_CURRENT,T3,0,1);
      t31 = iCustom(_Symbol,PERIOD_CURRENT,T3,1,1);
      t4 = iCustom(_Symbol,PERIOD_CURRENT,T4,0,1);
      t41 = iCustom(_Symbol,PERIOD_CURRENT,T4,1,0);
      t42 = iCustom(_Symbol,PERIOD_CURRENT,T4,2,0);
      OT = NT[0];
     }
   double Ma1 = iMA(_Symbol,PERIOD_CURRENT,MA_Period,0,MA_METHOD,PRICE_CLOSE,0);
   if(TimeCurrent() < end)
     {
      if(Breakeven == true)
         breakeven();
      if(Testrail == true)
         trail2();
      datetime localtime = TimeLocal();
      string hourmin = TimeToString(localtime, TIME_MINUTES);
      if(StringSubstr(hourmin, 0, 5) >= openinghour_min && StringSubstr(hourmin, 0, 5) < closinghour_min)
        {
         CalculateLotSizeB();
         static datetime OT;
         datetime NT[3];

         CopyTime(_Symbol, _Period, 0, 1, NT);
         if(OT != NT[0])
           {
            // ============================================================================
            if(OrdersTotal() < maxopenorders)
              {
               //==========================ONLY TES ZONE FILTER AND WPR T3==============================
               if(wpr == true && MA == false && hisbuy() == false && t3fati == false)
                 {
                  if(t2 != EMPTY_VALUE && t21 == EMPTY_VALUE && (t2 >= 50 || t21 >= 50))
                    {
                     if(t3 == 1 && t31 == 0)
                       {
                        if(t4 != EMPTY_VALUE && (t41 == EMPTY_VALUE || t41 == 0) && t42 <= -75)
                          {
                           //Comment("Buy signal detected WPR");
                           BUYS();
                          }
                       }
                    }
                 }


               //==========================ONLY TES ZONE FILTER AND MA==============================
               if(wpr == false && MA == true && hisbuy() == false && t3fati == false)
                 {
                  if(t2 != EMPTY_VALUE && t21 == EMPTY_VALUE && (t2 >= 50 || t21 >= 50))
                    {
                     if(t3 == 1 && t31 == 0)
                       {
                        if(Close[1] > Ma1 && Close[1] > Open[1] && MA == true)
                          {
                           //Comment("Buy signal detected");
                           BUYS();
                          }
                       }
                    }
                 }

               //==========================ONLY TES ZONE FILTER AND T3FATI==============================
               if(wpr == false && MA == false && hisbuy() == false && t3fati == true)
                 {
                  if(t2 != EMPTY_VALUE && t21 == EMPTY_VALUE && (t2 >= 50 || t21 >= 50))
                    {
                     if(t3 == 1 && t31 == 0)
                       {
                        if(t1 != EMPTY_VALUE && t11 == EMPTY_VALUE)
                          {
                           //Comment("Buy signal detected");
                           BUYS();
                          }
                       }
                    }
                 }

               //========================== ONLY TES ZONE FILTER AND WPR T3 && MA==============================
               if(wpr == true && MA == true && hisbuy() == false && t3fati == false)
                 {
                  if(t2 != EMPTY_VALUE && t21 == EMPTY_VALUE && (t2 >= 50 || t21 >= 50))
                    {
                     if(t3 == 1 && t31 == 0)
                       {
                        if(t4 != EMPTY_VALUE && (t41 == EMPTY_VALUE || t41 == 0))
                          {

                           if(Close[1] > Ma1 && Close[1] > Open[1] && MA == true)
                             {
                             // Comment("Buy signal detected");
                              BUYS();
                             }
                          }
                       }
                    }
                 }

               //==========================ONLY TES ZONE FILTER AND WPR T3 AND T3FATI==============================
               if(wpr == true && MA == false && hisbuy() == false && t3fati == true)
                 {
                  if(t2 != EMPTY_VALUE && t21 == EMPTY_VALUE && (t2 >= 50 || t21 >= 50))
                    {
                     if(t3 == 1 && t31 == 0)
                       {
                        if(t4 != EMPTY_VALUE && (t41 == EMPTY_VALUE || t41 == 0))
                          {
                           if(t1 != EMPTY_VALUE && t11 == EMPTY_VALUE)
                             {
                              //Comment("Buy signal detected");
                              BUYS();
                             }
                          }
                       }
                    }
                 }
               //==========================ONLY TES ZONE FILTER AND MA AND T3FATI==============================
               if(wpr == false && MA == true && hisbuy() == false && t3fati == true)
                 {
                  if(t2 != EMPTY_VALUE && t21 == EMPTY_VALUE && (t2 >= 50 || t21 >= 50))
                    {
                     if(t3 == 1 && t31 == 0)
                       {
                        if(Close[1] > Ma1 && Close[1] > Open[1])
                          {
                           if(t1 != EMPTY_VALUE && t11 == EMPTY_VALUE)
                             {
                              //Comment("Buy signal detected");
                              BUYS();
                             }
                          }
                       }
                    }
                 }
               //==========================ONLY TES ZONE FILTER AND MA AND T3FATI && WPR T3==============================
               if(wpr == true && MA == true && hisbuy() == false && t3fati == true)
                 {
                  if(t2 != EMPTY_VALUE && t21 == EMPTY_VALUE && (t2 >= 50 || t21 >= 50))
                    {
                     if(t3 == 1 && t31 == 0)
                       {
                        //---
                        if(t1 != EMPTY_VALUE && t11 == EMPTY_VALUE && hisbuy() == false)
                          {
                           if(t4 != EMPTY_VALUE && (t41 == EMPTY_VALUE || t41 == 0))
                             {
                              if(Close[1] > Ma1 && Close[1] > Open[1])
                                {
                                // Comment("Buy signal detected");
                                 BUYS();
                                }
                             }
                          }
                       }
                    }
                 }

               //==========================ONLY TES ZONE FILTER==============================
               if(wpr == false && MA == false && hisbuy() == false && hisbuyT() == false && t3fati == false)
                 {
                  //if(t2 != EMPTY_VALUE && t21 == EMPTY_VALUE)
                    {
                     if(t3 == 1 && t31 == 0)
                       {
                        //Comment("Buy signal detected (ONLY TES ZONE FILTER)");
                        BUYS();
                       }
                    }
                 }



               //=========================
               //================================================================================================
               //==============================    SELL TRADES    ==================================================================

               //==========================ONLY TES ZONE FILTER AND WPR T3==============================
               if(wpr == true && MA == false && hissell() == false && t3fati == false)
                 {
                  if(t2 == EMPTY_VALUE && t21 != EMPTY_VALUE && (t2 <= -50 || t21 <= -50))
                    {
                     if(t3 == 0 && t31 == -1)
                       {
                        if((t4 == EMPTY_VALUE || t4 == 0) && t41 != EMPTY_VALUE)
                          {
                           //Comment("Sell signal detected");
                           SELLS();
                          }
                       }
                    }
                 }


               //==========================ONLY TES ZONE FILTER AND MA ==============================
               if(wpr == false && MA == true && hissell() == false && t3fati == false)
                 {
                  if(t2 == EMPTY_VALUE && t21 != EMPTY_VALUE && (t2 <= -50 || t21 <= -50))
                    {
                     if(t3 == 0 && t31 == -1)
                       {
                        if(Close[1] < Ma1 && Close[1] < Open[1] && MA == true)
                          {
                           SELLS();
                           //Comment("Sell signal detected");
                          }
                       }
                    }
                 }


               //==========================ONLY TES ZONE FILTER AND T3FATI==============================
               if(wpr == false && MA == false && hissell() == false && t3fati == true)
                 {
                  if(t2 == EMPTY_VALUE && t21 != EMPTY_VALUE && (t2 <= -50 || t21 <= -50))
                    {
                     if(t3 == 0 && t31 == -1)
                       {
                        if(t1 != EMPTY_VALUE && t11 != EMPTY_VALUE && hissell() == false)
                          {
                           SELLS();
                           //Comment("Sell signal detected");
                          }
                       }
                    }
                 }


               //==========================ONLY TES ZONE FILTER AND MA AND WPR T3==============================
               if(wpr == true && MA == true && hissell() == false && t3fati == false)
                 {
                  if(t2 == EMPTY_VALUE && t21 != EMPTY_VALUE && (t2 <= -50 || t21 <= -50))
                    {
                     if(t3 == 0 && t31 == -1)
                       {
                        if((t4 == EMPTY_VALUE || t4 == 0) && t41 != EMPTY_VALUE)
                          {
                           if(Close[1] < Ma1 && Close[1] < Open[1] && MA == true)
                             {
                              SELLS();
                              //Comment("Sell signal detected");
                             }
                          }
                       }
                    }
                 }


               //==========================ONLY TES ZONE FILTER AND T3FATI && WPR T3==============================
               if(wpr == true && MA == false && hissell() == false && t3fati == true)
                 {
                  if(t2 == EMPTY_VALUE && t21 != EMPTY_VALUE && (t2 <= -50 || t21 <= -50))
                    {
                     if(t3 == 0 && t31 == -1)
                       {
                        if((t4 == EMPTY_VALUE || t4 == 0) && t41 != EMPTY_VALUE)
                          {
                           if(t1 != EMPTY_VALUE && t11 != EMPTY_VALUE && hissell() == false)
                             {
                              SELLS();
                              //Comment("Sell signal detected");
                             }
                          }
                       }
                    }
                 }


               //==========================ONLY TES ZONE FILTER AND MA && T3 FATI ==============================
               if(wpr == false && MA == true && hissell() == false && t3fati == true)
                 {
                  if(t2 == EMPTY_VALUE && t21 != EMPTY_VALUE && (t2 <= -50 || t21 <= -50))
                    {
                     if(t3 == 0 && t31 == -1)
                       {
                        if(Close[1] < Ma1 && Close[1] < Open[1] && MA == true)
                          {
                           SELLS();
                           //Comment("Sell signal detected");
                          }
                       }
                    }
                 }
               //==========================ONLY TES ZONE FILTER AND MA && T3 FATI && WPR T3 ==============================
               if(wpr == true && MA == true && hissell() == false && t3fati == true)
                 {
                  if(t2 == EMPTY_VALUE && t21 != EMPTY_VALUE && (t2 <= -50 || t21 <= -50))
                    {
                     if(t3 == 0 && t31 == -1)
                       {
                        if(t1 != EMPTY_VALUE && t11 != EMPTY_VALUE && hissell() == false)
                          {
                           if((t4 == EMPTY_VALUE || t4 == 0) && t41 != EMPTY_VALUE)
                             {
                              if(Close[1] < Ma1 && Close[1] < Open[1])
                                {
                                 SELLS();
                                 //Comment("Sell signal detected(ONLY TES ZONE FILTER AND MA && T3 FATI && WPR T3)");
                                }
                             }
                          }
                       }
                    }
                 }
               //==========================ONLY TES ZONE FILTER==============================
               if(wpr == false && MA == false && hissell() == false && hissellT() == false  && t3fati == false)
                 {
                  //if(t2 == EMPTY_VALUE && t21 != EMPTY_VALUE)
                    {
                     if(t3 == 0 && t31 == -1)
                       {
                        SELLS();
                        //Comment("Sell signal detected (ONLY TES ZONE FILTER)");
                       }
                    }
                 }
              }
            OT = NT[0];
           }
         //==========================

         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(Oppsignal == true)
           {
            if(t3 == 1 && t31 == 0)
              {
               //Comment("Opposite signal detected, sell closed");
               closesell();
              }

            else
               if(t3 == 0 && t31 == -1)
                 {
                  //Comment("Opposite signal detected, buy closed");
                  closebuy();
                 }

           }

         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
         if(closeatoppositecandle == true)
           {
            //Comment("Opposite candlestick detected, order closed");
            enguf();
           }

         //========
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool hisbuyT()// int b4
  {
   for(int Count = OrdersTotal() - 1; Count >= 0; Count--)
     {
      if(OrderSelect(Count, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderType() == OP_BUY)
           {
            return true;                                                                                                                                                                         //RefreshRates();
           }
         break;
        }
      GetLastError();
     }
   return false;
  }
//----------------------------------------------------------------------------------
bool hissellT()
  {
   for(int Count = OrdersTotal() - 1; Count >= 0; Count--)
     {
      if(OrderSelect(Count, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderType() == OP_SELL)
           {
            return true;                                                                                                                                                                         //RefreshRates();
           }
         break;
        }
      GetLastError();
     }
   return false;
  }
//+------------------------------------------------------------------+
//+----------------------------------
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BUYS()
  {
   static datetime OT;
   datetime NT[3];

   CopyTime(_Symbol, _Period, 0, 1, NT);

   if(OT != NT[0])
     {
      //============================================================================
      NumTrades = Trade_number;
      for(int l = 0; l < NumTrades; l++)
        {
         if(useMM == true && TESTP_SL == true && BuyTrade == true)
           {
            double SLS = NormalizeDouble((Ask - (STOPLOSS * _Point)), Digits);
            double TPS = NormalizeDouble((Ask + (TAKEPROFIT * _Point)), Digits);
            double buyLotSize = CalculateLotSizeB();
            Tickets[l] = OrderSend(Symbol(), OP_BUY,buyLotSize,Ask, 0, SLS, TPS, NULL, initial_magic, 0, Green);
           }
         //  else
           {
            if(verbose == true)
              {

               GetLastError();
              }
           }
         if(useMM == false && TESTP_SL == true && BuyTrade == true)
           {
            double SLS = NormalizeDouble((Ask - (STOPLOSS * _Point)), Digits);
            double TPS = NormalizeDouble((Ask + (TAKEPROFIT * _Point)), Digits);
            Tickets[l] = OrderSend(Symbol(), OP_BUY, lotSize, Ask, 0, SLS, TPS, NULL, initial_magic, 0, Green);
           }
         else
           {
            if(verbose == true)
              {

               GetLastError();
              }
           }
         //------------------------------WITHOUT TP/SL-------------------------------------
         if(TESTP_SL == false && BuyTrade == true)
           {
            Tickets[l] = OrderSend(Symbol(), OP_BUY, lotSize, Ask, 0, 0, 0, NULL, initial_magic, 0, Green);
           }
        }
      OT = NT[0];
     }
  }
//+------------------------------------------------------------------+
void SELLS()
  {
   static datetime OT;
   datetime NT[3];

   CopyTime(_Symbol, _Period, 0, 1, NT);

   if(OT != NT[0])
     {

      //============================================================================
      NumTrades = Trade_number;
      for(int l = 0; l < NumTrades; l++)
        {
         if(useMM == true && TESTP_SL == true && SellTrade == true)
           {
            //=================================SELL===========================================
            double SLSs = NormalizeDouble((Bid + (STOPLOSS * _Point)), Digits);
            double TPSs = NormalizeDouble((Bid - (TAKEPROFIT * _Point)), Digits);
            double sellLotSize = CalculateLotSizeB();
            Tickets[l] = OrderSend(Symbol(), OP_SELL,sellLotSize, Bid, 0, SLSs, TPSs, NULL, initial_magic, 0, Green);

            //==================================SELL==========================================
           }
         else
           {
            if(verbose == true)
              {

               GetLastError();
              }
           }
         if(useMM == false && TESTP_SL == true && SellTrade == true)
           {
            double SLSs = NormalizeDouble((Bid + (STOPLOSS * _Point)), Digits);
            double TPSs = NormalizeDouble((Bid - (TAKEPROFIT * _Point)), Digits);
            Tickets[l] = OrderSend(Symbol(), OP_SELL, lotSize, Bid, 0, SLSs, TPSs, NULL, initial_magic, 0, Green);
           }
         else
           {
            if(verbose == true)
              {
               GetLastError();
              }
           }
         //-------------------------------TESTPSL================================
         if(useMM == false && TESTP_SL == false && SellTrade == true)
           {
            Tickets[l] = OrderSend(Symbol(), OP_SELL, lotSize, Bid, 0, 0, 0, NULL, initial_magic, 0, Green);
           }
         else
           {
            if(verbose == true)
              {
               GetLastError();
              }
           }

         //===============================
         //-------------------------------TESTPSL================================
         if(useMM == true && TESTP_SL == false && SellTrade == true)
           {
            Tickets[l] = OrderSend(Symbol(), OP_SELL, lotSize, Bid, 0, 0, 0, NULL, initial_magic, 0, Green);
           }
         else
           {
            if(verbose == true)
              {
               GetLastError();
              }
           }
        }
     }
   OT = NT[0];
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//====================================================================

//+------------------------------------------------------------------+
void closesell()
  {
   for(int i = OrdersTotal() - 1 ; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
        {
         if(OrderType() == OP_SELL)
           {
            bool p =    OrderClose(OrderTicket(), OrderLots(), Ask, 10, 0);
           }
        }
     }
   GetLastError();
   return; // check
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void closebuy()
  {
   for(int i = OrdersTotal() - 1 ; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())

        {
         if(OrderType() == OP_BUY)
           {
            bool o = OrderClose(OrderTicket(), OrderLots(), Bid, 10, 0);
           }
        }
     }
   GetLastError();
   return; // check
  }


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void trail2()
  {
   static double B = TrailingStart * _Point;
   static double S = TrailingStart * _Point;

   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol())
           {
            if(OrderType() == OP_BUY)
              {
               if(Bid - OrderOpenPrice() >= B)
                 {
                  if(OrderStopLoss() < Bid - TrailingStart * MarketInfo(OrderSymbol(), MODE_POINT))
                    {
                     double trailingSL = Bid- (TrailingPercentage / 100.0)*B;

                     int s =  OrderModify(OrderTicket(), OrderOpenPrice(), trailingSL, OrderTakeProfit(), Red);
                     B = (TrailingStart + TrailingBuffer) * _Point;
                     Comment("Buy trailing activated");
                    }
                 }
              }
            else
               if(OrderType() == OP_SELL)
                 {
                  if(OrderOpenPrice() - Ask > S)
                    {
                     if((OrderStopLoss() > Ask + TrailingStart * MarketInfo(OrderSymbol(), MODE_POINT)) || (OrderStopLoss() == 0))
                       {
                        double trailingSLs = Ask+ (TrailingPercentage / 100.0) * S;

                        int q = OrderModify(OrderTicket(), OrderOpenPrice(), trailingSLs, OrderTakeProfit(), Red);
                        S = (TrailingStart + TrailingBuffer) * _Point;
                        Comment("Sell trailing activated");

                       }
                    }
                 }
           }
        }
     }
  }
//===================================================

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void breakeven()
  {
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == Symbol())
           {
            if(OrderType() == OP_BUY)
              {
               if((OrderStopLoss() < OrderOpenPrice()) || (OrderStopLoss() == 0))
                 {
                  if(Bid - OrderOpenPrice() >= breakstart * _Point)
                    {
                     double trailingSL = OrderOpenPrice() + Breakbuffer * _Point;
                     int s =  OrderModify(OrderTicket(), OrderOpenPrice(), trailingSL, OrderTakeProfit(), Red);
                     Comment("Buy breakeven activated");

                    }
                 }
              }
            else
               if(OrderType() == OP_SELL)
                 {
                  if((OrderStopLoss() > OrderOpenPrice())|| (OrderStopLoss() == 0))
                    {
                     if(OrderOpenPrice() - Ask >= breakstart* _Point)
                       {
                        double trailingSL = OrderOpenPrice() - Breakbuffer * _Point;
                        int q = OrderModify(OrderTicket(), OrderOpenPrice(), trailingSL, OrderTakeProfit(), Red);
                        Comment("Sell breakeven activated");
                       }
                    }
                 }
           }
        }
     }
  }
//===================================================

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateLotSizeB()
  {
   double calculatedLotSize = 0;
   double currentMargin = AccountFreeMargin();
// Comment(currentMargin);

   if(useMM == true)
     {
      double calculatedLotSize1 = (10000/currentMargin);
      calculatedLotSize = (marginPer10k /calculatedLotSize1);
      if(calculatedLotSize > MaxLot)
        {
         calculatedLotSize = MaxLot;
        }
      else
         if(calculatedLotSize < MinLot)
           {
            calculatedLotSize = MinLot;
           }
      //Comment("Calculated Lot Size: ", calculatedLotSize);   // Display calculated lot size in the chart

     }
   return NormalizeDouble(calculatedLotSize,2);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void enguf()
  {
   double close = iClose(_Symbol, PERIOD_CURRENT, 1);
   double open = iOpen(_Symbol, PERIOD_CURRENT, 1);
   bool bullish = close > open;
   bool bearish = close < open;
//============================================
   double close3 = iClose(_Symbol, PERIOD_CURRENT, 3);
   double close4 = iClose(_Symbol, PERIOD_CURRENT, 4);

   double open4 = iOpen(_Symbol, PERIOD_CURRENT, 4);

   double open3 = iOpen(_Symbol, PERIOD_CURRENT, 3);


   double low = iLow(_Symbol, PERIOD_CURRENT, 1);
   double low2 = iLow(_Symbol, PERIOD_CURRENT, 2);
   double low3 = iLow(_Symbol, PERIOD_CURRENT, 3);

   double high2 = iHigh(_Symbol, PERIOD_CURRENT, 2);

   double high = iHigh(_Symbol, PERIOD_CURRENT, 1);
   double high3 = iHigh(_Symbol, PERIOD_CURRENT, 3);


   double close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
   double open2 = iOpen(_Symbol, PERIOD_CURRENT, 2);
   double upperwickBull = high2 - close2;
   double upperwickBear = high2 - open2;
   double upperwickBear1 = high - open;
   double lowerwickBull = open2 - low2;
   double lowerwickBull1 = open - low;
   double lowerwickBear = close2 - low2;
   double upperwickBull1 = high - close;
   double lowerwickBear1 = close - low;
   double candleSize1 = MathAbs(open - close);
   double candleSize2 = MathAbs(open2 - close2);
   double candleSize3 = MathAbs(open3 - close3);
   double candleSize4 = MathAbs(open4 - close4);
   bool validCandleSizes = (candleSize1 >= 15 * _Point) && (candleSize2 >= 1 * _Point) && (candleSize3 >= 1 * _Point);

   double body = MathAbs(close2 - open2);
   double body1 = MathAbs(close - open);
   bool bullish2 = close2 > open2;
   bool bearish2 = close2 < open2;
   bool bullish3 = close3 > open3;
   bool bearish3 = close3 < open3;
   bool bullish4 = close4 > open4;
   bool bearish4 = close4 < open4;

//=====================
   if(validCandleSizes && !bullish && (close < close2 || close < open2))
     {
      //Comment("candle reversal detected, buy closed");
      closebuy();
     }

   if(validCandleSizes && bullish && (close > close2 || close > open2))
     {
      //Comment("Buy candle reversal detected, sell closed");
      closesell();
     }



  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool hisbuy()
  {
   for(int i = OrdersHistoryTotal() - 1 ; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))

        {
         if(OrderType() == OP_BUY)
           {
            // Comment("Trueeeeeee");
            return true;
           }
         break;
        }
     }
   GetLastError();
   return false; // check
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool hissell()
  {
   for(int i = OrdersHistoryTotal() - 1 ; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == Symbol())

        {
         if(OrderType() == OP_SELL)
           {
            return true;
           }
         break;
        }
     }
   GetLastError();
   return false; // check
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+



//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
