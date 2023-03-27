ESCALA_AGING = IF('BACKLOG PB'[IDADE_DIAS]<=1;"Menos de 1 dia";
IF(
               AND('BACKLOG PB'[IDADE_DIAS] >1;'BACKLOG PB'[IDADE_DIAS]<=15);"De 1 a 15 dias";
IF(
               AND('BACKLOG PB'[IDADE_DIAS] >15;'BACKLOG PB'[IDADE_DIAS]<=30);"De 15 a 30 dias";
IF(
               AND('BACKLOG PB'[IDADE_DIAS] >30;'BACKLOG PB'[IDADE_DIAS]<=60);"De 30 a 60 dias";
IF(
               AND('BACKLOG PB'[IDADE_DIAS] >60;'BACKLOG PB'[IDADE_DIAS]<=90);"De 60 a 90 dias";
IF(
               AND('BACKLOG PB'[IDADE_DIAS] >90;'BACKLOG PB'[IDADE_DIAS]<=100);"De 90 a 100 dias";
IF(
              'BACKLOG PB'[IDADE_DIAS] >100;"Mais de 100 Dias")))))))
