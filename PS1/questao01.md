### Questão 01

Neste problema, vamos quantificar o impacto dinâmico da COVID-19 em mulheres casadas nas taxas de trabalho trimestrais. Usando os dados contidos no csv. 

As variáveis que encontramos são:

* *newid* que captura um identificador da mulher na pesquisa;

* *time* que captura o trimestre da pesquisa;

* *eda* que captura a idade

* *dent2-dent32* detonota um estado-especifíco dummy 

* *dchild2_12* indica a presença de uma criança na família com idade menor de 12 anos

* *edu* captura a educação da mulher 

* *inac* um indicador de inatividade 

* *unemp* é um indicador de desemprego

* *formal_new* um indicador de emprego formal

* *informal_new* um indicador de emprego informal

##### Model

$$
Y_{ist} = \sum_{j \in [-3,-2] \cup [0,7]} \alpha_j D_{it}^{j} + \beta X_{it} + \eta_{s} + \varepsilon_{ist}  
$$

#### Letra c

As dummies de event-time já desempenham exatamente o mesmo papel dos efeitos fixos de trimestre.

Os efeitos fixos de trimestre contolam qualquer variação comum a todos os indivíduos em um determinado trimestre.

Isso significa incluir um cojunto de dummies:

$$
\delta_t \para cada \t
$$

Eles capturam mudanças agregadas ao longo do tempo, exógenas aos indivíduos. Na especificação de *event study*, incluímos um conjunto de dummies:

$$
D_{it}^{j} = 1\{event = j \}
$$

Em que no nosso caso: event - time - 4. E incluímos dummies para cada lag em relação ao tempo de início do evento.  