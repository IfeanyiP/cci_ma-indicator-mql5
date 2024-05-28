extern double lots = 0.5;
extern int SlowPeriod = 40;
extern int FastPeriod = 12;
extern int MovingShift = 0;
extern int StopLoss = 30;
extern int TakeProfit = 70;

void OnTick()
  {
    //first lets try and keep it simple by converting the stoploss and take profit provided into points
    //for buy orders
    double stop_loss = NormalizeDouble((Ask - StopLoss * _Point),_Digits);
    double take_profit = NormalizeDouble((Ask + TakeProfit * _Point),_Digits);
    
    //present the moving average function for creating moving average indicators which is iMA
    //for current candle
    double Moving_Average_Slow = iMA(Symbol(),PERIOD_CURRENT,SlowPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,0);
    double Moving_Average_Fast = iMA(Symbol(),PERIOD_CURRENT,FastPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,0);
    
    //for previous candle
    double Moving_Average_Slow_One = iMA(Symbol(),PERIOD_CURRENT,SlowPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,1);
    double Moving_Average_Fast_One = iMA(Symbol(),PERIOD_CURRENT,FastPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,1);
    
    //creating a boolean value for placing orders
    bool Cross_moving_Average = Moving_Average_Fast > Moving_Average_Slow && Moving_Average_Fast_One < Moving_Average_Slow_One;
    
    //using an if statement to acertain when the stated moving averages intersects each other
    if(OrdersTotal() == 0 && Cross_moving_Average == true)
    {
      int Buy = OrderSend(Symbol(),OP_BUY,lots,Ask,0,stop_loss,take_profit,"BUY NOW",0,0,clrBlue);
    }
  }
//+------------------------------------------------------------------+
