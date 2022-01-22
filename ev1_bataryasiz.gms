Set

t /1*24/;


scalar N /10000/;


display  t,N;

parameters
P_PV(t) Panelin saatlik üretim verisi [kWh]
/ 1    0
  2    0
  3    0
  4    0
  5    0
  6    0 
  7    0
  8    0.2
  9    0.6
  10   1.2
  11   2.5
  12   3
  13   2.8
  14   2.2
  15   1.5
  16   1.1
  17   0.7 
  18   0.2
  19   0
  20   0
  21   0
  22   0
  23   0
  24   0/ 
P_load_inflex(t) Evin saatlik tüketim değerleri [kW]
/ 1    0.2
  2    0.2
  3    0.2
  4    0.2
  5    0.2
  6    0.2
  7    2.00705
  8    1.00705
  9    0.2
  10   0.2
  11   0.2
  12   0.2
  13   0.2
  14   0.24
  15   0.24
  16   0.315
  17   0.375
  18   2.875
  19   1.685
  20   3.635
  21   3.185
  22   2.604
  23   2.475
  24   0.3/
Grid_buy_price(t) Saatlik Şebekeden alış fiyatı [kW-tl]
/
  1    0.829
  2    0.829
  3    0.829
  4    0.829
  5    0.829
  6    0.829   
  7    1.3046
  8    1.3046
  9    1.3046
  10   1.3046
  11   1.3046
  12   1.3046
  13   1.3046
  14   1.3046
  15   1.3046
  16   1.3046
  17   2.06
  18   2.06
  19   2.06
  20   2.06
  21   2.06
  22   2.06
  23   0.829
  24   0.829/
  
Grid_sell_price(t) Saatlik Şebekeye satış fiyatı [kW-tl]
/
  1    0.5
  2    0.5
  3    0.5
  4    0.5
  5    0.5
  6    0.5
  7    1
  8    1
  9    1
  10   1
  11   1
  12   1
  13   1
  14   1
  15   1
  16   1
  17   1.5
  18   1.5
  19   1.5
  20   1.5
  21   1.5
  22   1.5
  23   0.5
  24   0.5/;

  
display P_PV, P_load_inflex;

variables

minimize_cost
P_buy(t)

P_sell(t)

u_1(t)
u_2(t);

positive Variables

P_buy(t)
P_sell(t)
;

binary variables
u_1(t)
u_2(t);

Equations
Balance
Objective
LG1
LG2
;

Balance(t) .. P_PV(t)+P_buy(t)=e= P_sell(t)+P_load_inflex(t);
LG1(t)     .. P_buy(t)=l=u_1(t)*N;
LG2(t)     .. P_sell(t)=l=(1-u_1(t))*N;
Objective.. minimize_cost =e= sum(t,P_buy(t)*Grid_buy_price(t)-P_sell(t)*Grid_sell_price(t));

model smarthouse /all/;

SOLVE smarthouse USING MIP MINIMIZING minimize_cost;
execute_Unload "ev1_bataryasiz.gdx" P_buy, P_sell,minimize_cost, P_load_inflex ;

execute 'GDXXRW.EXE ev1_bataryasiz.gdx O=ev1_bataryasiz.xlsx SQ=N Var=P_buy Rng=P_buy!'
execute 'GDXXRW.EXE ev1_bataryasiz.gdx O=ev1_bataryasiz.xlsx SQ=N Var=P_sell Rng=P_sell!'
execute 'GDXXRW.EXE ev1_bataryasiz.gdx O=ev1_bataryasiz.xlsx SQ=N Var=P_sell Rng=P_sell!'
execute 'GDXXRW.EXE ev1_bataryasiz.gdx O=ev1_bataryasiz.xlsx SQ=N Var=minimize_cost Rng=minimize_cost!'


Execute "=shellexecute ev1_bataryasiz.xlsx";
