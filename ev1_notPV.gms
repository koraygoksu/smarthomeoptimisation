Set

t /1*24/;


scalar BatCap_ESS /3.6/, CE /0.96/, DE /0.96/, N /10000/,
       R_ESS /1.08/, SoE_ESS_init /2.5/, SoE_ESS_min /1/;


display  t, BatCap_ESS, CE, DE, N, R_ESS, SoE_ESS_init, SoE_ESS_min ;

parameters

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

  
display P_load_inflex;

variables

minimize_cost
P_buy(t)
P_ESSch(t)
P_ESSdsch(t)
P_sell(t)
SoE_ESS(t)
u_1(t)
u_2(t);

positive Variables

P_buy(t)
P_ESSch(t)
P_ESSdsch(t)
P_sell(t)
SoE_ESS(t);

binary variables
u_1(t)
u_2(t);

Equations
Balance
Objective
LG1
LG2
ESS1
ESS2
ESS3
ESS4
ESS5
ESS6;

Balance(t) .. P_buy(t)+P_ESSdsch(t)=e= P_sell(t)+P_load_inflex(t)+P_ESSch(t);
LG1(t)     .. P_buy(t)=l=u_1(t)*N;
LG2(t)     .. P_sell(t)=l=(1-u_1(t))*N;
ESS1(t)    .. P_ESSdsch(t)=l=R_ESS*u_2(t);
ESS2(t)    .. P_ESSch(t)=l=R_ESS*(1-u_2(t));
ESS3(t)$(ord(t)>1).. SoE_ESS(t)=e=SoE_ESS(t-1)+P_ESSch(t)*CE-(P_ESSdsch(t)/DE);
ESS4(t)$(ord(t)=1).. SoE_ESS(t)=e=SoE_ESS_init;
ESS5(t).. SoE_ESS_min =l= SoE_ESS(t);
ESS6(t).. SoE_ESS(t) =l= BatCap_ESS;
Objective.. minimize_cost =e= sum(t,P_buy(t)*Grid_buy_price(t)-P_sell(t)*Grid_sell_price(t));

model smarthouse /all/;

SOLVE smarthouse USING MIP MINIMIZING minimize_cost;
execute_Unload "ev1_notPV.gdx" P_buy, P_sell, SoE_ESS, P_ESSch, P_ESSdsch, minimize_cost ;

execute 'GDXXRW.EXE ev1_notPV.gdx O=ev1_notPV.xlsx SQ=N Var=P_buy Rng=P_buy!'
execute 'GDXXRW.EXE ev1_notPV.gdx O=ev1_notPV.xlsx SQ=N Var=P_sell Rng=P_sell!'
execute 'GDXXRW.EXE ev1_notPV.gdx O=ev1_notPV.xlsx SQ=N Var=SoE_ESS Rng=SoE_ESS!'
execute 'GDXXRW.EXE ev1_notPV.gdx O=ev1_notPV.xlsx SQ=N Var=P_ESSch Rng=P_ESSch!'
execute 'GDXXRW.EXE ev1_notPV.gdx O=ev1_notPV.xlsx SQ=N Var=P_ESSdsch Rng=P_ESSdsch!'
execute 'GDXXRW.EXE ev1_notPV.gdx O=ev1_notPV.xlsx SQ=N Var=minimize_cost Rng=minimize_cost!'

Execute "=shellexecute ev1_notPV.xlsx";

