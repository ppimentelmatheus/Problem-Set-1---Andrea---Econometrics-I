# Pacotes -----------------------------------------------------------------

library(tidyverse)

# Carregar dados ----------------------------------------------------------
dados = readr::read_csv(file = "enoe_married_female.csv",
                        show_col_types = FALSE)

# Questão 01 - Letra A ----------------------------------------------------
# Tratar dados ------------------------------------------------------------

# Verificar se todas as colunas foram carregadas corretamente
spec(dados)

# Criar coluna de início do evento

dados = dados |> 
  dplyr::mutate(event = time - 4)

dados = dados |> 
  dplyr::mutate(event = !!rlang::sym(time_var) - 4)
  
# Verificar se as colunas foram corretamente construídas

medias = dados |> 
  dplyr::group_by(time) |> 
  summarise(media_valor = mean(event))

medias

dados = dados |> 
  dplyr::mutate(
    D0 = ifelse(dados$event == 0 , 1, 0 ),
    Dm1 = ifelse(dados$event == -1, 1, 0 ),
    Dm2 = ifelse(dados$event == -2, 1, 0 ),
    Dm3 = ifelse(dados$event == -3, 1, 0),
    D1 = ifelse(dados$event == 1, 1, 0),
    D2 = ifelse(dados$event == 2, 1, 0),
    D3 = ifelse(dados$event == 3, 1, 0),
    D4 = ifelse(dados$event == 4, 1, 0),
    D5 = ifelse(dados$event == 5, 1, 0),
    D6 = ifelse(dados$event == 6, 1, 0),
    D7 = ifelse(dados$event == 7, 1, 0)
    )


# Modelo ------------------------------------------------------------------
res_unemp = lm(unemp ~ 1 + D0 + Dm2 + Dm3 + D1 + D2 + D3 + D4 + D5 + D6 + D7 +
                 eda + edu + dchild2_12, 
               data = dados)

summary(res_unemp)

res_inac = lm(inact ~ 1 + D0 + Dm2 + Dm3 + D1 + D2 + D3 + D4 + D5 + D6 + D7 +
                 eda + edu + dchild2_12, 
               data = dados)
summary(res_inac)


res_formal = lm(dados$formal_new ~ 1 + D0 + Dm2 + Dm3 + D1 + D2 + D3 + D4 + D5 + D6 + D7 +
                eda + edu + dchild2_12, 
              data = dados)
summary(res_formal)

res_informal = lm(dados$informal_new ~ 1 + D0 + Dm2 + Dm3 + D1 + D2 + D3 + D4 + D5 + D6 + D7 +
                  eda + edu + dchild2_12, 
                data = dados)
summary(res_informal)


