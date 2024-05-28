//+------------------------------------------------------------------+
//|                                                     ufxtrial.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023"
#property link      ""
#property version   "1.00"
//#property strict
#include  <Controls\Button.mqh>
CButton KillButton, KillerButton, KillestButton, Autotrading, hedging, swing, pattern, divergance, priceaction, grid, martigale, Killmartigale, Killermartigale, Killestmartigale, Killhedging, Killerhedging, Killesthedging, Killswing, Killerswing, Killestswing, Killpattern, Killerpattern, Killestpattern, Killdivergance, Killerdivergance, Killestdivergance, Killpriceaction, Killerpriceaction, Killestpriceaction, close;

#define sec_wait_context 10
#define max_errors 30
#define wait_error 1000
#define busysleep 100
#define EB_NEXTTRY 0
#define EB_WAITTRY 1
#define EB_TERMINATE 2
#define StoplevelAdd 0

//+------------------------------------------------------------------+
//-------------------------------------Expert initialization function-------------------------------------------------
int enable_daily_profit = 1 ; // Enable option to stop trading if a daily profit exceeds following values (it considers profit for ALL currencies)
double daily_profit = 0.4 ; // Daily profit in the account currency
double daily_profit_percent = 0 ; // Daily profit as a percent to Balance of start of the day
int  WHENTOMOVE = 14;
bool USEMOVETOBREAK = true;
int piplock = 13;
int Total = 12;
int initial_magic = 123000;                         //magic number fot the first deal
int initial_magic1 = 123001;
int initial_magic11 = 123003;
int initial_magic22 = 123004;
int initial_magic111 = 123005;
int initial_magic222 = 123006;
int entryhour = 4;
int command_attempts = 40;
int StopLevel;
input double lot1 = 0.01;//1st trade lot size
input double lot2 = 0.04;//2nd trade lot size
input double lot3 = 0.12;//3rd trade lot size
input double lot4 = 0.24;//4th trade lot size
input double lot5 = 0.72;//5th trade lot size
input int Pending_Orders_Gap = 20;// Order Distance 2
input double Lot5_SL = 100;//Stop loss
input double TP = 100;// Take profit
input double Lot1_Gap = 20;// Order Distance 1
input int Desiredspread = 20; // Max, Spread,Pips (0=Disable)
datetime end = D'2024.04.02'; // Expiry Date
input static string Trading_days = "=====================Trading Days================"; // Trading Times

input bool Monday = true;
input bool Tuesday = true;
input bool Wednesday = true;
input bool Thursday = true;
input bool Friday = true;
input bool Saturday = true;
input bool Sunday = true;
input string Trade_Start_Time1 = "14:00"; // Start Trading Time (HH:MM)
input string Trade_Start_Time2 = "18:00"; // Start Trading Time (HH:MM)
input double Maximum_daily_Loss_percentage = 40;// Max DD
string openinghour_min4 = "23:56";

//----------------------------------END-------------------------------------------------------



//-----------------------------------------------------------------------------------
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }

//------------------------------ Expert tick function ------------------------------------------------------------                                           |


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime localtime = TimeLocal();
   string hourmin = TimeToString(localtime, TIME_MINUTES);

   if(Trade_Start_Time1 != "00:00")
     {
      //------------------------------------------------
      if(StringSubstr(hourmin, 0, 5) == Trade_Start_Time1 && TimeCurrent() < end && (weekdayM() == 1 || weekdayT() == 2 || weekdayW() == 3 || weekdayTHUR() == 4 || weekdayFri() == 5 || weekdaysat() == 6 || weekdaysun() == 0)
         && Spread() <= Desiredspread)
        {
         double close1= iClose(_Symbol,_Period,1);
         if(OrdersTotal()<1)
           {
            int s = OrderSend(Symbol(), OP_BUYSTOP, lot1, NormalizeDouble((Ask + (Lot1_Gap * _Point)), Digits), 0, 0, NormalizeDouble((Ask + ((TP+ Lot1_Gap) * _Point)), Digits), NULL, initial_magic, 0, 0); // magic4 b4
            int s4 = OrderSend(Symbol(), OP_SELLSTOP, lot1, NormalizeDouble((Bid - (Lot1_Gap * _Point)), Digits), 0, 0, NormalizeDouble((Bid - ((TP+ Lot1_Gap) * _Point)), Digits), NULL, initial_magic, 0, 0); // magic4 b4
           }

        }
     }
//==================================================
//==================================================
   if(Trade_Start_Time2 != "00:00")
     {
      //------------------------------------------------
      if(StringSubstr(hourmin, 0, 5) == Trade_Start_Time2 && TimeCurrent() < end && (weekdayM() == 1 || weekdayT() == 2 || weekdayW() == 3 || weekdayTHUR() == 4 || weekdayFri() == 5 || weekdaysat() == 6 || weekdaysun() == 0)
         && Spread() <= Desiredspread)
        {
         double close13= iClose(_Symbol,_Period,1);
         if(OrdersTotal()<1 && StringSubstr(hourmin, 0, 5) == Trade_Start_Time2)
           {
            int s2 = OrderSend(Symbol(), OP_BUYSTOP, lot1, NormalizeDouble((Ask + (Lot1_Gap * _Point)), Digits), 0, 0, NormalizeDouble((Ask + ((TP+ Lot1_Gap) * _Point)), Digits), NULL, initial_magic22, 0, 0); // magic4 b4
            int s43 = OrderSend(Symbol(), OP_SELLSTOP, lot1, NormalizeDouble((Bid - (Lot1_Gap * _Point)), Digits), 0, 0, NormalizeDouble((Bid - ((TP+ Lot1_Gap) * _Point)), Digits), NULL, initial_magic22, 0, 0); // magic4 b4
           }
        }
     }
   if(StringSubstr(hourmin, 0, 5) == Trade_Start_Time2 && countpending() == 2)
     {
      ndeletebb();
      ndeletess();
     }

//======================================
   if(StringSubstr(hourmin, 0, 5) == "23:53" && countpending() == 2)
     {
      ndeleteD1();
      ndeleteD2();
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(buy() == 1 || sell()== 1)
     {
      pendeleteB();
      pendeleteS();
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   F1();
   F1Sell();
   ClosedOrderProfit12();
   ClosedOrderProfit2();
   chckerP();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void F1()
  {
//===========================================================================================
   if(OrdersTotal() >= 1)
     {
      int count = countpending();
      if(OrdersTotal() == 1 && count == 0)
        {
         int b = OrderSelect((OrdersTotal() - 1), SELECT_BY_POS, MODE_TRADES);
         if(OrderType() == OP_BUY  && (OrderMagicNumber() == initial_magic || OrderMagicNumber() == initial_magic22))
           {
            // Comment("kkkkkkkkkkkkkk");
            int B4 = OrderSend(Symbol(), OP_SELLSTOP, lot2, NormalizeDouble((OrderOpenPrice() - (Pending_Orders_Gap * _Point)), Digits), 0, 0, NormalizeDouble((OrderOpenPrice() - ((TP+ Pending_Orders_Gap) * _Point)), Digits), NULL, initial_magic1, 0, 0); // magic4 b4
            GetLastError();
           }
        }

      //=================================================================================================================================================
      if(OrdersTotal() == 2 && count == 0)
        {
         int c = OrderSelect((OrdersTotal() - 1), SELECT_BY_POS, MODE_TRADES);
         if(OrderType() == OP_SELL  && OrderMagicNumber() == initial_magic1)
           {
            int s77 = OrderSend(Symbol(), OP_BUYSTOP, lot3, NormalizeDouble((OrderOpenPrice() + (Pending_Orders_Gap * _Point)), Digits), 0, 0, NormalizeDouble((OrderOpenPrice() + ((TP+ Pending_Orders_Gap) * _Point)), Digits), NULL, initial_magic1, 0, 0); // magic4 b4
           }

        }


      //=============================================================================================================================================
      if(OrdersTotal() == 3 && count == 0)
        {

         int d = OrderSelect((OrdersTotal() - 1), SELECT_BY_POS, MODE_TRADES);

         if(OrderType() == OP_BUY && OrderMagicNumber() == initial_magic1)
           {
            int B47 = OrderSend(Symbol(), OP_SELLSTOP, lot4, NormalizeDouble((OrderOpenPrice() - (Pending_Orders_Gap * _Point)), Digits), 0, 0, NormalizeDouble((OrderOpenPrice() - ((TP+ Pending_Orders_Gap) * _Point)), Digits), NULL, initial_magic1, 0, 0); // magic4 b4
           }
        }

      //===============================================================================================================================================

      if(OrdersTotal() == 4 && count == 0)
        {

         int z = OrderSelect((OrdersTotal() - 1), SELECT_BY_POS, MODE_TRADES);
         if(OrderType() == OP_SELL  && OrderMagicNumber() == initial_magic1 && lastorder() == false)
           {
            double SL85 = NormalizeDouble((OrderOpenPrice() + (Pending_Orders_Gap * _Point)) - ((Lot5_SL+Pending_Orders_Gap) * _Point), Digits);
            int s773 = OrderSend(Symbol(), OP_BUYSTOP, lot5, NormalizeDouble((OrderOpenPrice() + (Pending_Orders_Gap * _Point)), Digits), 0, SL85, NormalizeDouble((OrderOpenPrice() + ((TP+ Pending_Orders_Gap) * _Point)), Digits), NULL, initial_magic1, 0, 0); // magic4 b4
           }

        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void F1Sell()
  {
   if(OrdersTotal() >= 1)
     {
      int count = countpending();
      if(OrdersTotal() == 1 && count == 0)
        {
         int m = OrderSelect((OrdersTotal() - 1), SELECT_BY_POS, MODE_TRADES);
         if(OrderType() == OP_SELL && (OrderMagicNumber() == initial_magic || OrderMagicNumber() == initial_magic22))
           {
            //Comment("kkkkkkkkkkkkkk");
            int sXX = OrderSend(Symbol(), OP_BUYSTOP, lot2, NormalizeDouble((OrderOpenPrice() + (Pending_Orders_Gap * _Point)), Digits), 0, 0, NormalizeDouble((OrderOpenPrice() + ((TP+ Pending_Orders_Gap) * _Point)), Digits), NULL, initial_magic11, 0, 0); // magic4 b4

            GetLastError();
           }
        }


      //=================================================================================================================================================
      if(OrdersTotal() == 2 && count == 0)
        {

         int k = OrderSelect((OrdersTotal() - 1), SELECT_BY_POS, MODE_TRADES);
         if(OrderType() == OP_BUY && OrderMagicNumber() == initial_magic11)
           {
            int s477 = OrderSend(Symbol(), OP_SELLSTOP, lot3, NormalizeDouble((OrderOpenPrice() - (Pending_Orders_Gap * _Point)), Digits), 0, 0, NormalizeDouble((OrderOpenPrice() - ((TP+ Pending_Orders_Gap) * _Point)), Digits), NULL, initial_magic11, 0, 0); // magic4 b4
           }

        }
      //=============================================================================================================================================
      if(OrdersTotal() == 3 && count == 0)
        {

         int j = OrderSelect((OrdersTotal() - 1), SELECT_BY_POS, MODE_TRADES);

         if(OrderType() == OP_SELL && OrderMagicNumber() == initial_magic11)
           {
            int sX7X = OrderSend(Symbol(), OP_BUYSTOP, lot4, NormalizeDouble((OrderOpenPrice() + (Pending_Orders_Gap * _Point)), Digits), 0, 0, NormalizeDouble((OrderOpenPrice() + ((TP+ Pending_Orders_Gap) * _Point)), Digits), NULL, initial_magic11, 0, 0); // magic4 b4
           }
        }

      //===============================================================================================================================================
      if(OrdersTotal() == 4 && count == 0)
        {

         int d = OrderSelect((OrdersTotal() - 1), SELECT_BY_POS, MODE_TRADES);
         if(OrderType() == OP_BUY && OrderMagicNumber() == initial_magic11 && lastorder() == false)
           {
            double SL8r = NormalizeDouble((OrderOpenPrice() - (Pending_Orders_Gap * _Point)) + ((Lot5_SL+Pending_Orders_Gap) * _Point), Digits);

            int s47CC7 = OrderSend(Symbol(), OP_SELLSTOP, lot5, NormalizeDouble((OrderOpenPrice() - (Pending_Orders_Gap * _Point)), Digits), 0, SL8r, NormalizeDouble((OrderOpenPrice() - ((TP+ Pending_Orders_Gap) * _Point)), Digits), NULL, initial_magic11, 0, 0); // magic4 b4
           }

        }

     }

  }

//------------------------------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
//------------------------------------------OTHER NEEDED-----------------------------------------------
int countpending()
  {
   int s = 0;
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         if(OrderType() > OP_SELL)
           {
            s++;
           }
        }
      GetLastError();
     }
   return(s);
  }


//============================================================================================================================================

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void closeALL()
  {
   for(int i = OrdersTotal() - 1 ; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol() && OrdersTotal() <= Total)

        {
         if(OrderType() == OP_BUY)
           {
            int y = OrderClose(OrderTicket(), OrderLots(), Bid, 10, 0);
           }


         else
            if(OrderType() == OP_SELL)
              {
               int r = OrderClose(OrderTicket(), OrderLots(), Ask, 10, 0);
              }
        }
     }

   GetLastError();
   return; // check
  }
//----------------------------------------OTHERS NEEDED ENDS HERE----------------------------------------
//-----==========================================================================================================================================


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void ndelete()//int b4
  {
   for(int i = OrdersTotal() - 1 ; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
        {

         if(OrderType() == OP_BUYSTOP) //|| OrderType()==OP_SELLSTOP)
           {
            int yy = OrderDelete(OrderTicket(), clrNONE);
           }
         //   break;

        }
     }
   GetLastError();

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ndeletes()//int b4
  {
   for(int i = OrdersTotal() - 1 ; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
        {

         if(OrderType() == OP_SELLSTOP) //|| OrderType()==OP_SELLSTOP)
           {
            int yy = OrderDelete(OrderTicket(), clrNONE);
           }
         //   break;

        }
     }
   GetLastError();

  }


//=========================================================================================================================================================
void ClosedOrderProfit2()// int b4
  {
   for(int Count = OrdersHistoryTotal() - 1; Count >= 0; Count--)
     {
      if(OrderSelect(Count, SELECT_BY_POS, MODE_HISTORY))
        {
         if(OrderSymbol() == Symbol())

           {
            if(OrderCloseTime() > 0 && (OrderProfit()>0||OrderProfit()<0))
              {
               int diff = ((int)(TimeCurrent() - OrderCloseTime()));
               if(diff < 1&& countpending()==1)
                 {
                  ndelete();
                  ndeletes();                                                                                                                                                                          //RefreshRates();
                 }
              }
            break;


           }
        }

      GetLastError();
     }
   return;//return 0 b4
  }
//=============================================================================================================================================================

//+------------------------------------------------------------------+
//|

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
void ClosedOrderProfit12()// int b4
  {

   for(int Count = OrdersHistoryTotal() - 1; Count >= 0; Count--)
     {
      if(OrderSelect(Count, SELECT_BY_POS, MODE_HISTORY))
        {
         if(OrderSymbol() == Symbol())

           {
            if((OrderProfit() > 0 || OrderProfit() < 0) && OrderCloseTime() > 0 && OrdersTotal() >= 1)
              {
               int diff = ((int)(TimeCurrent() - OrderCloseTime()));
               if(diff < 1)
                 {
                  closeALL();
                  closebuy();
                  closesell();
                  // ndelete();
                  //  ndeletes();
                  //RefreshRates();
                 }

               break;


              }
           }

         GetLastError();
        }
      return;//return 0 b4
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void pendeleteB()
  {
   for(int i = OrdersTotal() - 1 ; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
        {
         if(OrderType() == OP_BUYSTOP && (OrderMagicNumber() == initial_magic || OrderMagicNumber() == initial_magic22))
           {
            if(countpending() == 1)
              {
               ndeletebb();
               ndeletess();
               ndeleteD1();
               ndeleteD2();
              }
           }
        }
     }
   GetLastError();
   return; // check
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void pendeleteS()
  {
   for(int i = OrdersTotal() - 1 ; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
        {
         if(OrderType() == OP_SELLSTOP && (OrderMagicNumber() == initial_magic|| OrderMagicNumber() == initial_magic22))
           {
            if(countpending() == 1)
              {
               ndeletebb();
               ndeletess();
               ndeleteD1();
               ndeleteD2();
              }


           }
        }
     }
   GetLastError();
   return; // check
  }



//+------------------------------------------------------------------+
//|                                                                  |

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int pencount()
  {
   int b1 = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      bool j = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderType() == OP_BUYSTOP||OrderType() == OP_SELLSTOP)
        {
         b1 = b1 + 1;
        }
     }
   return(b1);
  }
//+------------------------------------------------------------------+
int sell()
  {
   int b1 = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      bool k = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderType() == OP_SELL)
        {
         b1 = b1 + 1;
        }
     }
   return(b1);
  }

//----------------------------
int buy()
  {
   int b1 = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      bool k = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(OrderType() == OP_BUY)
        {
         b1 = b1 + 1;
        }
     }
   return(b1);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
int weekdayM()
  {
   int date = 0;
   string weekdays = " ";
   if(Monday == true)
     {

      datetime timeds = TimeLocal();
      MqlDateTime structime;
      TimeToStruct(timeds, structime);
      date = structime.day_of_week;


      if(date == 1)
         weekdays = "monday";
     }
   return date;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int weekdayT()
  {
   int date = 0;
   string weekdays = " ";
   if(Tuesday == true)
     {

      datetime timeds = TimeLocal();
      MqlDateTime structime;
      TimeToStruct(timeds, structime);
      date = structime.day_of_week;


      if(date == 2)
         weekdays = "TUES";
     }
   return date;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int weekdayW()
  {
   int date = 0;
   string weekdays = " ";
   if(Wednesday == true)
     {

      datetime timeds = TimeLocal();
      MqlDateTime structime;
      TimeToStruct(timeds, structime);
      date = structime.day_of_week;


      if(date == 3)
         weekdays = "wed";
     }
   return date;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int weekdayTHUR()
  {
   int date = 0;
   string weekdays = " ";
   if(Thursday == true)
     {

      datetime timeds = TimeLocal();
      MqlDateTime structime;
      TimeToStruct(timeds, structime);
      date = structime.day_of_week;

      if(date == 4)
         weekdays = "thurs";
     }
   return date;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int weekdayFri()
  {
   int date = 0;
   string weekdays = " ";
   if(Friday == true)
     {

      datetime timeds = TimeLocal();
      MqlDateTime structime;
      TimeToStruct(timeds, structime);
      date = structime.day_of_week;


      if(date == 5)
         weekdays = "fri";
     }
   return date;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int weekdaysat()
  {
   int date = 0;
   string weekdays = " ";
   if(Saturday == true)
     {

      datetime timeds = TimeLocal();
      MqlDateTime structime;
      TimeToStruct(timeds, structime);
      date = structime.day_of_week;

      if(date == 6)
         weekdays = "sat";
     }
   return date;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int weekdaysun()
  {
   int date = 0;
   string weekdays = " ";
   if(Sunday == true)
     {

      datetime timeds = TimeLocal();
      MqlDateTime structime;
      TimeToStruct(timeds, structime);
      date = structime.day_of_week;


      if(date == 0)
         weekdays = "sun";
     }
   return date;
  }
//+-------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long Spread()
  {
   long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   if(spread >= Desiredspread)
     {
      //Comment("DESIRED SPREAD EXCEEDED");

     }

   return spread;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//==================
double profitclose2()
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
void chckerP() //DAILY
  {
   double amt = (Ap() + Al() + (comm()*2) + profitclose2());

   datetime localtime = TimeLocal();
   string hourmin = TimeToString(localtime, TIME_MINUTES);

   double acct_balance = AccountInfoDouble(ACCOUNT_BALANCE);

   double result_balance = (Maximum_daily_Loss_percentage/100) * acct_balance;

   for(int i = OrdersHistoryTotal() - 1 ; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {

         if(OrderOpenTime() < TimeCurrent() - TimeCurrent() % 86400)
           {
            break;
           }
         //   Comment(result_balance);

         if(amt < 0 && amt <= -result_balance)
           {

            closebuy();
            closesell();
            ndelete();
            ndeletes();

           }

        }
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Al() // BUY HISTORY TRADES
  {

   double orderprofits = 0;
   for(int i = OrdersHistoryTotal() - 1 ; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
         if(OrderOpenTime() < TimeCurrent() - TimeCurrent() % 86400)
           {
            break ;
           }
         if(OrderProfit()<0)
           {
            orderprofits+=OrderProfit();
           }

        }
     }
   return orderprofits;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Ap() // BUY HISTORY TRADES
  {

   double orderprofits = 0;
   for(int i = OrdersHistoryTotal() - 1 ; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
         if(OrderOpenTime() < TimeCurrent() - TimeCurrent() % 86400)
           {
            break ;
           }
         if(OrderProfit()>0)
           {
            orderprofits+=OrderProfit();
           }

        }
     }
   return orderprofits;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double comm() // BUY HISTORY TRADES
  {

   double orderprofits = 0;
   for(int i = OrdersHistoryTotal() - 1 ; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
         if(OrderOpenTime() < TimeCurrent() - TimeCurrent() % 86400)
           {
            break ;
           }
         if(OrderCommission()>0)
           {
            orderprofits+=OrderCommission();
           }

        }
     }
   return orderprofits;
  }
//+------------------------------------------------------------------+
datetime Ropntime()//int b4
  {
   datetime sellstopx = 0;
   for(int i = OrdersTotal() - 1 ; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
        {
         if(OrderType() == OP_SELLSTOP && OrderMagicNumber() == initial_magic) //|| OrderType()==OP_SELLSTOP)
           {
            sellstopx = OrderOpenTime();
           }
        }
     }
   return sellstopx;
  }
//+------------------------------------------------------------------+
void ndeletess()//int b4
  {
   for(int i = OrdersTotal() - 1 ; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
        {

         if(OrderType() == OP_SELLSTOP && OrderMagicNumber() == initial_magic) //|| OrderType()==OP_SELLSTOP)
           {
            int yy = OrderDelete(OrderTicket(), clrNONE);
           }
         //   break;

        }
     }
   GetLastError();

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ndeletebb()//int b4
  {
   for(int i = OrdersTotal() - 1 ; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
        {

         if(OrderType() == OP_BUYSTOP && OrderMagicNumber() == initial_magic) //|| OrderType()==OP_SELLSTOP)
           {
            int yy = OrderDelete(OrderTicket(), clrNONE);
           }
         //   break;

        }
     }
   GetLastError();

  }
//+------------------------------------------------------------------+
//========


//+------------------------------------------------------------------+
void ndeleteD2()//int b4
  {
   for(int i = OrdersTotal() - 1 ; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
        {

         if(OrderType() == OP_SELLSTOP && OrderMagicNumber() == initial_magic22) //|| OrderType()==OP_SELLSTOP)
           {
            int yy = OrderDelete(OrderTicket(), clrNONE);
           }
         //   break;

        }
     }
   GetLastError();

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ndeleteD1()//int b4
  {
   for(int i = OrdersTotal() - 1 ; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
        {

         if(OrderType() == OP_BUYSTOP && OrderMagicNumber() == initial_magic22) //|| OrderType()==OP_SELLSTOP)
           {
            int yy = OrderDelete(OrderTicket(), clrNONE);
           }
         //   break;

        }
     }
   GetLastError();

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool lastorder()// int b4
  {

   for(int Count = OrdersHistoryTotal() - 1; Count >= 0; Count--)
     {
      if(OrderSelect(Count, SELECT_BY_POS, MODE_HISTORY))
        {
         if(OrderSymbol() == Symbol())

           {
            if(OrderLots() == lot5 && OrderCloseTime() > 0)
              {
               int diff = ((int)(TimeCurrent() - OrderCloseTime()));
               if(diff < 1)
                 {
                  return true;
                  //RefreshRates();
                 }
               break;
              }
           }

         GetLastError();
        }
     }
   return false;
  }

//+------------------------------------------------------------------+
