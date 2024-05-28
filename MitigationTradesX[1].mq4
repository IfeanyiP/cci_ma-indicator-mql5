//+------------------------------------------------------------------+
//|                                            MT4_DATA_HANDLING.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define sec_wait_context 10
#define max_errors 30
#define wait_error 1000
#define busysleep 100
#define EB_NEXTTRY 0
#define EB_WAITTRY 1
#define EB_TERMINATE 2
#define StoplevelAdd 0
input int Take_profit = 20; // Take Profit
input int Stop_loss = 20; // Stop Loss
input bool RISK = true;// Money Management
input double Percentage = 10; //Percentage Risk
input double lotsize = 1; // Fixed Volume
input int Trade_numbers = 1; // Maximum Open Trades
input int Trade_number = 1; // Trades per Signal
enum trades  {HIGH_LOW, OPEN_CLOSE};
input trades candlesmeasure = HIGH_LOW; //Bar Height
input double Maxsize = 80; //Maximum Previous Bar Height
input double Minsize = 20; //Minimum Previous Bar Height
input int Desiredspread = 200; // Max Spread
input bool Trailing_Switch = false;// Use trailing stop
//+------------------------------------------------------------------+
input double trailing_stop_activation = 23;// Trailing Stop Trigger
double trailing_start = (trailing_stop_activation * 10);
input double trailing_stop_distance = 5;// Trailing Stop
double trailing_step = (trailing_stop_distance * 10); // trailing step
input bool usetime = true;//Use Trade Time
input string openinghour_min = "00:30"; // Trade Time Start
input string closinghour_min = "23:30"; // Trade Time End
input double X = 30; //Mitigation trigger
double loss = 5000000000000000; //   Floating loss
double gain = 5000000000000000; //  Floating Profit
bool mitigation = true; // mitigation switch
datetime end = D'2024.03.27'; // Expiry Date

int NumTrades;
int Tickets[100];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   int fileH = FileOpen("trade.csv", FILE_WRITE | FILE_CSV);
   if(fileH == INVALID_HANDLE)
     {
      Print("error opening file");
      GetLastError();
      return INIT_FAILED;
     }
   FileWrite(fileH, "Ticket,Type,OpenTime,OpenPrice,CloseTime,ClosePrice,Profit");
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
         ulong ticket = OrderTicket();
         string type = (OrderType() == OP_BUY) ? "Buy" : "Sell";
         datetime openTime = OrderOpenTime();
         double openprice = OrderOpenPrice();
         datetime closeTime = OrderCloseTime();
         double closeprice = OrderClosePrice();
         double profit = OrderProfit();
         FileWrite(fileH, ticket, type, openTime, openprice, closeTime, closeprice, profit);
        }
     }
   FileClose(fileH);

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
   if(TimeCurrent() < end)
     {
      //Comment(LOTR());
      double open1 = iOpen(_Symbol, _Period, 1);
      double close1 = iClose(_Symbol, _Period, 1);
      bool bullish = close1 > open1;
      bool bearish = open1 > close1;
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+

      if(_IsNotTradeContextBusy() < 0)
        {
         return ;
        }
      if(! IsTradeAllowed())
        {
         //Comment("  ") ;
         return ;
        }
      if(! IsConnected() && ! IsTesting())
        {
         //Comment("No connection with the trade server") ;
         return ;
        }
      double high = iHigh(_Symbol, _Period, 1);
      double low = iLow(_Symbol, _Period, 1);
      double diffs = high - low;
      //-----------------------------------
      double close = iClose(_Symbol, _Period, 1);
      double open = iOpen(_Symbol, _Period, 1);
      double diffBull = MathAbs(close - open)+0.0007;
      double diffBear = MathAbs(open - close)+0.0007;

      datetime localtime = TimeLocal();
      string hourmin = TimeToString(localtime, TIME_MINUTES);
      //------------------------------------------------
      if(usetime == true)
        {
         if(StringSubstr(hourmin, 0, 5) >= openinghour_min && StringSubstr(hourmin, 0, 5) < closinghour_min)
           {
            if(OrdersTotal() < Trade_numbers && Spread() <= Desiredspread)
              {
               if(candlesmeasure == HIGH_LOW)
                 {
                  if(diffs >= ((10 * Minsize) * _Point) && diffs <= ((10 * Maxsize) * _Point))
                    {
                     if(RISK == false && bearish && OrdersTotal() < Trade_numbers && hisbuyT() == false && hisbuyG() == false)
                       {

                        BUY();
                       }
                     if(RISK == true && bearish && OrdersTotal() < Trade_numbers  && hisbuyT() == false && hisbuyG() == false)
                       {
                        BUYR();
                       }
                    }
                  if(diffs >= ((10 * Minsize) * _Point) && diffs <= ((10 * Maxsize) * _Point))
                    {
                     if(RISK == false && bullish && OrdersTotal() < Trade_numbers && hissellT() == false && hissellG() == false)
                       {
                        //Comment("SEELLLLLL");
                        SELL();
                       }
                     if(RISK == true && bullish && OrdersTotal() < Trade_numbers && hissellT() == false && hissellG() == false)
                       {
                        SELLR();
                       }
                    }
                 }
               //===========
               //============
               if(candlesmeasure == OPEN_CLOSE)
                 {
                  if(diffBear >= ((10 * Minsize) * _Point) && diffBear <= ((10 * Maxsize) * _Point))
                    {
                     Comment(diffBear, "      ",diffs);
                     if(RISK == false && bearish && OrdersTotal() < Trade_numbers && hisbuyT() == false && hisbuyG() == false)
                       {
                        //Comment("BUYYY");
                        BUY();
                       }
                     if(RISK == true && bearish && OrdersTotal() < Trade_numbers && hisbuyT() == false && hisbuyG() == false)
                       {
                        BUYR();
                       }
                    }
                  if(diffBull >= ((10 * Minsize) * _Point) && diffBull <= ((10 * Maxsize) * _Point))
                    {
                     if(RISK == false && bullish && OrdersTotal() < Trade_numbers  && hissellT() == false && hissellG() == false)
                       {
                        //Comment("SELLLLLLLLL");
                        SELL();
                       }
                     if(RISK == true && bullish && OrdersTotal() < Trade_numbers  && hissellT() == false && hissellG() == false)
                       {
                        SELLR();
                       }
                    }
                 }
              }

            //================

            Comment("\n", "\n", "SYMBOL  ", _Symbol, "\n", "\n", "BALANCE  ", AccountBalance(), "\n", "\n", "EQUITY  ", AccountEquity(), "\n", "\n", "FLOATING PROFIT /LOSS  ", Profit(), "\n", "\n", "WinRate  ", Overall_pl());

           }

         if(Trailing_Switch == true)
           {
            trailingB();
            trailingS();
           }
         diff_1();
         loss_();
         if(mitigation == true && RISK == false)
           {
            mitigationbuy();
            mitigationsell();
            BuyT();
            SellT();
           }

         if(mitigation == true && RISK == true)
           {
            BuyT2();
            SellT2();
            mitigationbuy();
            mitigationsell();
           }
        }
      notradetime();


     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//====================================================================
void trailingB() // trailing stop function
  {

   for(int b = OrdersTotal() - 1 ; b >= 0 ; b--)
     {
      if(OrderSelect(b, SELECT_BY_POS, MODE_TRADES))
        {
         double open = OrderOpenPrice();
         double currentstop = OrderStopLoss();

         if(OrderType() == OP_BUY)
           {
            if(Bid > open && Bid - open > trailing_start * _Point)
              {
               if(currentstop < Bid - trailing_step * _Point)
                 {
                  double newstop = Bid - trailing_step * _Point;

                  bool c =   OrderModify(OrderTicket(), OrderOpenPrice(), newstop, OrderTakeProfit(), 0, 0);

                  break;
                 }

              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//====================================================================
void trailingS() // trailing stop function
  {
   for(int b = OrdersTotal() - 1 ; b >= 0 ; b--)
     {
      if(OrderSelect(b, SELECT_BY_POS, MODE_TRADES))
        {
         double open = OrderOpenPrice();
         double currentstop = OrderStopLoss();
         if(OrderType() == OP_SELL)
           {
            if(Bid < open &&  open - Bid > trailing_start * _Point)
              {
               if(currentstop == 0 || currentstop > Bid + trailing_step * _Point)
                 {
                  double newstop = Bid + trailing_step * _Point;

                  bool c =   OrderModify(OrderTicket(), OrderOpenPrice(), newstop, OrderTakeProfit(), 0, 0);

                  break;
                 }

              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void BUY()
  {
   double open1 = iOpen(_Symbol, _Period, 1);
   double close1 = iClose(_Symbol, _Period, 1);
   bool bullish = close1 > open1;
   bool bearish = open1 > close1;
//---------------------------------------------------------------------------------------------
   static datetime OT;
   datetime NT[1];
   CopyTime(_Symbol, _Period, 0, 1, NT);

   if(OT != NT[0])
     {
      //=================================BUY=======================================
      NumTrades = Trade_number;
      for(int k = 0; k < NumTrades; k++)
        {
         //=================================BUY===========================================
         double TPS = NormalizeDouble((Ask + ((10 * Take_profit) * _Point)), Digits);

         Tickets[k] = OrderSend(Symbol(), OP_BUY, lotsize, Ask, 0, 0, TPS, NULL, 111, 0, Green);
        }
     }
//============================================================================

   OT = NT[0];
  }
//-------------------------------------------------------------------------------------------------------------
//+------------------------------------------------------------------+
void SELL()
  {
   double open2 = iOpen(_Symbol, _Period, 1);
   double close2 = iClose(_Symbol, _Period, 1);
   bool bullish = close2 > open2;
   bool bearish = open2 > close2;
//---------------------------------------------------------------------------------------------
//-----------------------------
   static datetime OT;
   datetime NT[1];

   CopyTime(_Symbol, _Period, 0, 1, NT);

   if(OT != NT[0])
     {
      //============================================================================
      NumTrades = Trade_number;
      for(int l = 0; l < NumTrades; l++)
        {
         //=================================SELL===========================================
         double TPSs = NormalizeDouble((Bid - ((10 * Take_profit) * _Point)), Digits);
         Tickets[l] = OrderSend(Symbol(), OP_SELL, lotsize, Bid, 0, 0, TPSs, NULL, 111, 0, Green);
        }
      //============================================================================
     }

   OT = NT[0];
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void BUYR()
  {
   double open1 = iOpen(_Symbol, _Period, 1);
   double close1 = iClose(_Symbol, _Period, 1);
   bool bullish = close1 > open1;
   bool bearish = open1 > close1;
//---------------------------------------------------------------------------------------------
   static datetime OT;
   datetime NT[1];
   CopyTime(_Symbol, _Period, 0, 1, NT);

   if(OT != NT[0])
     {
      //=================================BUY=======================================
      NumTrades = Trade_number;
      for(int k = 0; k < NumTrades; k++)
        {
         //=================================BUY===========================================
         double TPS = NormalizeDouble((Ask + ((10 * Take_profit) * _Point)), Digits);

         Tickets[k] = OrderSend(Symbol(), OP_BUY, LotRisk(), Ask, 0, 0, TPS, NULL, 111, 0, Green);
        }
     }
//============================================================================

   OT = NT[0];
  }
//-------------------------------------------------------------------------------------------------------------
//+------------------------------------------------------------------+
void SELLR()
  {
   double open2 = iOpen(_Symbol, _Period, 1);
   double close2 = iClose(_Symbol, _Period, 1);
   bool bullish = close2 > open2;
   bool bearish = open2 > close2;
//---------------------------------------------------------------------------------------------
//-----------------------------
   static datetime OT;
   datetime NT[1];

   CopyTime(_Symbol, _Period, 0, 1, NT);

   if(OT != NT[0])
     {
      //============================================================================
      NumTrades = Trade_number;
      for(int l = 0; l < NumTrades; l++)
        {
         //=================================SELL===========================================
         double TPSs = NormalizeDouble((Bid - ((10 * Take_profit) * _Point)), Digits);
         Tickets[l] = OrderSend(Symbol(), OP_SELL, LotRisk(), Bid, 0, 0, TPSs, NULL, 111, 0, Green);
        }
      //============================================================================
     }

   OT = NT[0];
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void diff_1()
  {
   if(OrdersTotal() >= 1 && Profit() >= gain)
     {
      closeall();
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void loss_()
  {
   if(OrdersTotal() >= 1 && Profit() <= -loss)
     {
      closeall();
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double Profit()
  {
   double profit = 0;
   int total  = OrdersTotal();
   for(int cnt = total - 1 ; cnt >= 0 ; cnt--)
     {
      bool d = OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      profit += OrderProfit() + OrderCommission() + OrderSwap();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void closeall()
  {
   for(int i = OrdersTotal() - 1 ; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
        {
         if(OrderType() == OP_BUY)
           {
            bool a = OrderClose(OrderTicket(), OrderLots(), Bid, 10, 0);
           }
         else
            if(OrderType() == OP_SELL)
              {
               bool b =      OrderClose(OrderTicket(), OrderLots(), Ask, 10, 0);
              }
        }
     }

   GetLastError();
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void mitigationbuy()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == _Symbol)
           {
            if(OrderType() == OP_BUY)
              {
               if((OrderLots() == lotsize || OrderLots() == LotRisk()))
                 {
                  if(OrderOpenPrice() > Ask && OrderOpenPrice() - Ask >= (10 * X) * _Point)
                    {
                     closebuy();
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void mitigationsell()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderSymbol() == _Symbol)
           {
            if(OrderType() == OP_SELL)
              {
               if((OrderLots() == lotsize || OrderLots() == LotRisk()))
                 {
                  if(OrderOpenPrice() < Ask && Ask - OrderOpenPrice() >= (10 * X) * _Point)
                    {
                     closesell();
                    }
                 }
              }
           }
        }
     }
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
//+------------------------------------------------------------------+
bool BuyT() // Lot size muliplier function
  {
//------------------------------------------------------------------
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
         if(OrderType() == OP_BUY)
           {
            int diff = ((int)(TimeCurrent() - OrderCloseTime()));
            if(diff <= 60 && OrderProfit() < 0 && OrdersTotal() < Trade_numbers && OrderLots() == lotsize && cheks() == false)
              {
               SELLH();
               break;
              }
           }
         //==========================================================
        }
     }
   return false;
  }

//====================================================================
//+------------------------------------------------------------------+
bool SellT() // Lot size muliplier function
  {
//------------------------------------------------------------------
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
         if(OrderType() == OP_SELL)
           {
            int diff = ((int)(TimeCurrent() - OrderCloseTime()));
            if(diff <= 60 && OrderProfit() < 0 && OrdersTotal() < Trade_numbers && OrderLots() == lotsize && cheks() == false)
              {
               BUYH();
               break;
              }
           }
         //==========================================================
        }
     }
   return false;
  }

//====================================================================
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool BuyT2() // Lot size muliplier function
  {
   static double l=LotRisk();
//------------------------------------------------------------------
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
         if(OrderType() == OP_BUY)
           {
            int diff = ((int)(TimeCurrent() - OrderCloseTime()));
            if(diff <= 60 && OrderProfit() < 0 && OrdersTotal() < Trade_numbers)//&& OrderLots() == l)
              {
               SELLHR();
               l=LotRisk();
               break;
              }
           }
         //==========================================================
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
bool SellT2() // Lot size muliplier function
  {
   static double l=LotRisk();
//------------------------------------------------------------------
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
         if(OrderType() == OP_SELL)
           {
            int diff = ((int)(TimeCurrent() - OrderCloseTime()));
            if(diff <= 60 && OrderProfit() < 0 && OrdersTotal() < Trade_numbers)// && OrderLots() == l)
              {
               BUYHR();
               l=LotRisk();
               break;
              }
           }
         //==========================================================
        }
     }
   return false;
  }

//====================================================================
//+------------------------------------------------------------------+
double LOT()
  {
   double lot = lotsize;

//-----------------------------------------------------------------------
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
     {
      bool b = OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
      if(OrderProfit() < 0)
        {
         if(OrderType() == OP_BUY)
           {
            lot = lot * 2;
           }

         if(OrderType() == OP_SELL)
           {
            lot = lot * 2;

           }
        }
      else
         if(OrderProfit() > 0)
           {
            break;
           }
      //==========================================================
     }
//---------------------------------------------------------------------
   return(NormalizeDouble(lot, 2));
  }

//======================================================
double LOTR()
  {
///
   double lot = LotRisk();

//-----------------------------------------------------------------------
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
     {
      bool b = OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);
      if(OrderProfit() < 0)
        {
         if(OrderType() == OP_BUY)
           {
            lot = lot * 2;
           }

         if(OrderType() == OP_SELL)
           {
            lot = lot * 2;

           }
        }
      else
         if(OrderProfit() > 0)
           {
            break;
           }
      //==========================================================
     }
//---------------------------------------------------------------------
   return(NormalizeDouble(lot, 2));
  }
//========================================================================
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void BUYH()
  {
//---------------------------------------------------------------------------------------------
   static datetime OT;
   datetime NT[1];
   CopyTime(_Symbol, _Period, 0, 1, NT);

   if(OT != NT[0])
     {
      //=================================BUY=======================================
      NumTrades = Trade_number;
      for(int k = 0; k < NumTrades; k++)
        {
         //=================================BUY===========================================
         // double TPi = ((10 * X)/(lotsize*2));
         //double TPS = NormalizeDouble(Ask + (TPi*_Point), Digits);
         double TPS = NormalizeDouble((Ask + ((10 * Take_profit) * _Point)), Digits);
         Tickets[k] = OrderSend(Symbol(), OP_BUY, lotsize*2, Ask, 0, 0, TPS, NULL, 111, 0, Green);
        }
     }
//============================================================================
   OT = NT[0];
  }
//----------------------------------------------------------------------------
//+------------------------------------------------------------------+
void SELLH()
  {
   static datetime OT;
   datetime NT[1];
   CopyTime(_Symbol, _Period, 0, 1, NT);

   if(OT != NT[0])
     {
      //============================================================================
      NumTrades = Trade_number;
      for(int l = 0; l < NumTrades; l++)
        {
         //=================================SELL===========================================
         double TPi = ((10 * X)/(lotsize*2));
         double TPSs = NormalizeDouble(Bid - (TPi*_Point), Digits);
         Tickets[l] = OrderSend(Symbol(), OP_SELL, lotsize*2, Bid, 0, 0, TPSs, NULL, 111, 0, Green);
        }
      //============================================================================
     }
   OT = NT[0];
  }


//=================================================

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BUYHR()
  {
//---------------------------------------------------------------------------------------------
   static datetime OT;
   datetime NT[1];
   CopyTime(_Symbol, _Period, 0, 1, NT);

   if(OT != NT[0])
     {
      //=================================BUY=======================================
      NumTrades = Trade_number;
      for(int k = 0; k < NumTrades; k++)
        {
         //=================================BUY===========================================
         double TPi = ((10 * X)/(LotRisk()*2));
         double TPS = NormalizeDouble((Ask + (TPi) * _Point), Digits);

         Tickets[k] = OrderSend(Symbol(), OP_BUY, LotRisk()*2, Ask, 0, 0, TPS, NULL, 111, 0, Green);
        }
     }
//============================================================================
   OT = NT[0];
  }
//----------------------------------------------------------------------------
//+------------------------------------------------------------------+
void SELLHR()
  {
   static datetime OT;
   datetime NT[1];
   CopyTime(_Symbol, _Period, 0, 1, NT);

   if(OT != NT[0])
     {
      //============================================================================
      NumTrades = Trade_number;
      for(int l = 0; l < NumTrades; l++)
        {
         //=================================SELL===========================================
         double TPi = ((10 * X)/(LotRisk()*2));
         double TPSs = NormalizeDouble((Bid - (TPi) * _Point), Digits);
         Tickets[l] = OrderSend(Symbol(), OP_SELL, LotRisk()*2, Bid, 0, 0, TPSs, NULL, 111, 0, Green);
        }
      //============================================================================
     }
   OT = NT[0];
  }
//=================================================
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double LotRisk()
  {
   double Acct = AccountBalance();
   double Risk = (Percentage / 100) * Acct;
   double lotsizeR = (Risk / (Stop_loss * 10));

   return(NormalizeDouble(lotsizeR, 2));
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
long Spread()
  {
   long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   return spread;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int _IsNotTradeContextBusy()
  {

   if(IsTradeContextBusy())
     {
      long StartWaitingTime = GetTickCount();
      Print("Trade context is busy. Waiting...");

      while(true)
        {

         if(GetTickCount() - StartWaitingTime > sec_wait_context * 1000)
           {
            //Print("Waiting limit exceeded (" + sec_wait_context + " sec.)!");
            return(-2);
           }

         if(!IsTradeContextBusy())
           {

            return(0);
           }

         Sleep(busysleep);
        }
     }
   else
     {

      return(1);
     }
  }
//============================================================================================================
//+------------------------------------------------------------------+
double Overall_pl()
  {
   double orderprofits = 0;
   int numWinningTrades = 0;
   int totalOrders = OrdersHistoryTotal();

   for(int i = totalOrders - 1; i >= 0; i--)
     {
      bool b = OrderSelect(i, SELECT_BY_POS, MODE_HISTORY);

      if(OrderOpenTime() < TimeCurrent() - TimeCurrent() % 86400)
        {
         break;
        }

      if(OrderProfit() > 0 && (OrderType() == OP_BUY || OrderType() == OP_SELL))
        {
         orderprofits += OrderProfit();
         numWinningTrades++;
        }
     }

   double winrate = 0.0;

   if(totalOrders > 0)
     {
      winrate = ((double)numWinningTrades / totalOrders) * 100.0;
     }

   return NormalizeDouble(winrate, 2);
  }


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool hisbuyT()// int b4
  {
   for(int Count = OrdersHistoryTotal() - 1; Count >= 0; Count--)
     {
      if(OrderSelect(Count, SELECT_BY_POS, MODE_HISTORY))
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
   for(int Count = OrdersHistoryTotal() - 1; Count >= 0; Count--)
     {
      if(OrderSelect(Count, SELECT_BY_POS, MODE_HISTORY))
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

//========
//+------------------------------------------------------------------+
bool hisbuyG()// int b4
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
bool hissellG()
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





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void notradetime()
  {
   double open1 = iOpen(_Symbol, _Period, 1);
   double close1 = iClose(_Symbol, _Period, 1);
   bool bullish = close1 > open1;
   bool bearish = open1 > close1;


   double high = iHigh(_Symbol, _Period, 1);
   double low = iLow(_Symbol, _Period, 1);
   double diffs = high - low;
//-----------------------------------
   double close = iClose(_Symbol, _Period, 1);
   double open = iOpen(_Symbol, _Period, 1);
   double diffBull = MathAbs(close - open)+0.0007;
   double diffBear = MathAbs(open - close)+0.0007;
   if(usetime == false)
     {
      if(OrdersTotal() < Trade_numbers && Spread() <= Desiredspread)
        {
         if(candlesmeasure == HIGH_LOW)
           {
            if(diffs >= ((10 * Minsize) * _Point) && diffs <= ((10 * Maxsize) * _Point))
              {
               if(RISK == false && bearish && OrdersTotal() < Trade_numbers && hisbuyT() == false && hisbuyG() == false)
                 {
                  BUY();
                 }
               if(RISK == true && bearish && OrdersTotal() < Trade_numbers  && hisbuyT() == false && hisbuyG() == false)
                 {
                  BUYR();
                 }
              }
            if(diffs >= ((10 * Minsize) * _Point) && diffs <= ((10 * Maxsize) * _Point))
              {
               if(RISK == false && bullish && OrdersTotal() < Trade_numbers && hissellT() == false && hissellG() == false)
                 {
                  //Comment("SEELLLLLL");
                  SELL();
                 }
               if(RISK == true && bullish && OrdersTotal() < Trade_numbers && hissellT() == false && hissellG() == false)
                 {
                  SELLR();
                 }
              }
           }

         //===========
         //============
         if(candlesmeasure == OPEN_CLOSE)
           {
            if(diffBear >= ((10 * Minsize) * _Point) && diffBear <= ((10 * Maxsize) * _Point))
              {
               Comment(diffBear, "      ",diffs);
               if(RISK == false && bearish && OrdersTotal() < Trade_numbers && hisbuyT() == false && hisbuyG() == false)
                 {
                  //Comment("BUYYY");
                  BUY();
                 }
               if(RISK == true && bearish && OrdersTotal() < Trade_numbers && hisbuyT() == false && hisbuyG() == false)
                 {
                  BUYR();
                 }
              }
            if(diffBull >= ((10 * Minsize) * _Point) && diffBull <= ((10 * Maxsize) * _Point))
              {
               if(RISK == false && bullish && OrdersTotal() < Trade_numbers  && hissellT() == false && hissellG() == false)
                 {
                  //Comment("SELLLLLLLLL");
                  SELL();
                 }
               if(RISK == true && bullish && OrdersTotal() < Trade_numbers  && hissellT() == false && hissellG() == false)
                 {
                  SELLR();
                 }
              }
           }
        }


      //================

      // Comment("\n", "\n", "SYMBOL  ", _Symbol, "\n", "\n", "BALANCE  ", AccountBalance(), "\n", "\n", "EQUITY  ", AccountEquity(), "\n", "\n", "FLOATING PROFIT /LOSS  ", Profit(), "\n", "\n", "WinRate  ", Overall_pl());

     }

   if(Trailing_Switch == true)
     {
      trailingB();
      trailingS();
     }
   diff_1();
   loss_();
   if(mitigation == true && RISK == false)
     {
      mitigationbuy();
      mitigationsell();
      BuyT();
      SellT();
     }
   if(mitigation == true && RISK == true)
     {
      BuyT2();
      SellT2();
      mitigationbuy();
      mitigationsell();
     }
  }



//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool cheks()
  {
   for(int Count = OrdersTotal() - 1; Count >= 0; Count--)
     {
      if(OrderSelect(Count, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderType() == OP_BUY||OrderType() == OP_SELL)
           {
            if(OrderLots() == lotsize*2 || OrderLots() == LotRisk()*2)
              {
               return true;                                                                                                                                                                         //RefreshRates();
              }
            break;
           }
         GetLastError();
        }
     }
   return false;
  }


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
