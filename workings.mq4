extern int period = 14;
double william_percentage_range[];

int OnInit()
{
  //IndicatorBuffers(1);
  //SetIndexStyle(0, DRAW_LINE);
  //SetIndexBuffer(0, william_percentage_range);
  IndicatorShortName("WPR(" + IntegerToString(period) + ")");
  SetIndexLabel(0, "WPR");
  
  //indicator parameters
  SetIndexStyle(0, DRAW_LINE);
  SetIndexBuffer(0, william_percentage_range);
  SetIndexEmptyValue(0, 0);
  //initialization done
  return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const long &spread[])
{
  //declaring variables for the indicator
  int i, limit;
  double highest, highest_close, lowest, lowest_close;
  
  //checking the number o bars to be calculated when the indicator is called
  limit = rates_total - prev_calculated;
  if(prev_calculated>0)
  {
    limit++;
    
    //counting using the for loop
    for(i = 0; i < limit && i < prev_calculated; i++)
    {
      highest = High[iHighest(NULL,0,MODE_HIGH,period,i)];
      lowest = Low[iLowest(NULL,0,MODE_LOW,period,i)];
      highest_close = Close[iHighest(NULL,0,MODE_CLOSE,period,i)];
      lowest_close = Close[iLowest(NULL,0,MODE_LOW,period,i)];
      
      william_percentage_range[i] = ((highest_close - close[i])/(highest_close - lowest_close)) * -100;
    }
    
    //the return value
    return(rates_total);
  }
}
