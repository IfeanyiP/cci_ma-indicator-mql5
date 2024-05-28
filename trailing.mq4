//this code is a trailing stop bot,which increases the trade ones there it reaches a certain treshold
extern double ma_period = 10;
extern double stop_loss = 50;
extern double takeprofit = 200;
extern double ma_method = MODE_SMA;
extern double ma_price = PRICE_CLOSE;
extern double lot_size = 1.0;
void OnTick()
{
  string symbols[] = {"EURUSD", "USDJPY", "GBPUSD"};
  for(int i = 0; i < OrdersTotal() -1; i--)
  {
    double moving_average = iMA(symbols[i],PERIOD_CURRENT,ma_period,0,ma_method,ma_price,0);
    double stopLoss1 = stop_loss * _Point;
    double takeProfit1 = takeprofit * _Point;
    double closeprice = Close[i];
    
    if(closeprice > moving_average)
    {
      int ticket = OrderSend(symbols[i],OP_BUY,lot_size,closeprice,0,stopLoss1,takeProfit1,"buy",0,0,clrBlue);
     if(ticket > 0)
     {
       int modify = OrderModify(ticket,0,closeprice-stopLoss1,closeprice+takeProfit1,0,clrBlack);
     }
     
    }
    else if(closeprice < moving_average)
    {
      int ticket2 = OrderSend(symbols[i],OP_SELL,lot_size,closeprice,0,stopLoss1,takeProfit1,"sell",0,0,clrAqua);
      if(ticket2 > 0)
      {
       int modify2 = OrderModify(ticket2,0,closeprice+stopLoss1,closeprice-takeProfit1,0,clrBeige);
      }
    } 
  }
}

