# Pacotes -----------------------------------------------------------------

library(dplyr)
library(fixest)
library(broom)
library(ggplot2)
library(stringr)

# Carregar dados ----------------------------------------------------------
df = readr::read_csv(file = "enoe_married_female.csv",
                        show_col_types = FALSE)

# --- 0) suposições de nomes ------------------------------------------------
# adapte se os nomes forem diferentes no seu df
df_name <- "df"           # seu data.frame já carregado
df <- get(df_name)

time_var <- "time"        # coluna com quarter index
weight_var <- NULL        # coloque nome do peso se houver, ex: "weight"
df = df |> dplyr::mutate(edusq = edu^2)
controles <- c("eda", "edu", "edusq", "dchild2_12")   # edusq = education squared? adapte

# --- 1) criar variável state_id a partir de dummies dent2..dent32 -----------
# lista dos nomes das colunas que representam estado (ex.: dent2 .. dent32)
state_dummies <- paste0("dent", 2:32)   # ajuste se os nomes forem ligeiramente diferentes

# verificar quais dessas colunas existem no df
state_dummies <- state_dummies[state_dummies %in% names(df)]
if(length(state_dummies) == 0) stop("Nenhuma coluna dent2..dent32 encontrada no dataset. Verifique os nomes.")

# Criar state_id: pega a coluna com valor 1, ou concatena se houver múltiplas 1s
# Aqui assumimos que cada observação tem exatamente uma dummy de estado = 1.
df <- df %>%
  mutate(
    # cria string com o nome da dummy que vale 1; se nenhuma, fica NA
    state_dummy_name = apply(select(., all_of(state_dummies)), 1, function(x) {
      idx <- which(x == 1)
      if(length(idx) == 0) return(NA_character_)
      # se houver múltiplos 1, pega o primeiro (ou ajuste conforme necessário)
      state_dummies[idx[1]]
    }),
    # criar uma variável factor/ID a partir do nome da dummy
    state_id = ifelse(is.na(state_dummy_name), NA_character_, state_dummy_name),
    state_id = as.factor(state_id)
  )

# conferir se houve NA no state_id (linhas sem dummy = 1)
na_states <- sum(is.na(df$state_id))
cat("Observações sem state_id (NA):", na_states, "\n")
if(na_states > 0) {
  cat("Atenção: há observações sem dummy de estado igual a 1. Verifique. Você pode imputar ou excluir essas observações.\n")
}

# --- 2) criar event e eventf com binning (mesmo que antes) --------------------
df <- df %>%
  mutate(event = !!rlang::sym(time_var) - 4,
         event_binned = pmin(pmax(event, -3), 7),
         eventf = factor(event_binned),
         eventf = relevel(eventf, ref = "-1"))

# --- 3) função corrigida para rodar event-study ------------------------------
run_event_study <- function(outcome,
                            data,
                            state_fe = "state_id",     # nome da coluna state_id criado acima
                            controls = controles,
                            weight = weight_var,
                            cluster = "state_id") {    # passe o nome da coluna como string
  # montar formula
  controls_formula <- paste(controles, collapse = " + ")
  form <- as.formula(paste0(outcome, " ~ i(eventf, ref = '-1') + ", controls_formula, " | ", state_fe))
  
  # chamar feols: passar cluster como string é aceito por fixest
  if(is.null(weight)) {
    mod <- feols(form, data = data, cluster = cluster)
  } else {
    # feols aceita weights = data[[weight]] ou weights = data$nome se nome literal
    mod <- feols(form, data = data, cluster = cluster, weights = data[[weight]])
  }
  
  td <- broom::tidy(mod, conf.int = TRUE) %>%
    filter(str_detect(term, "eventf")) %>%
    mutate(event = as.integer(str_extract(term, "-?\\d+"))) %>%
    arrange(event)
  
  return(list(model = mod, tidy = td))
}

# --- 4) rodar para outcomes (adapte nomes) -----------------------------------
outcomes <- c("unemp", "inact", "formal_new", "informal_new")  # ajuste se necessário

results <- list()
for(y in outcomes) {
  cat("Running event-study for:", y, "\n")
  results[[y]] <- run_event_study(y, data = df, state_fe = "state_id", cluster = "state_id")
  print(summary(results[[y]]$model))
}

# --- 5) plot exemplos -------------------------------------------------------
plot_event_coefs <- function(tidy_df, title = NULL) {
  ggplot(tidy_df, aes(x = event, y = estimate)) +
    geom_point(size = 2) +
    geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2) +
    geom_vline(xintercept = 0, linetype = "dashed") +
    geom_hline(yintercept = 0, color = "gray50") +
    labs(x = "Event time", y = "Coef (ref = -1)", title = title) +
    scale_x_continuous(breaks = seq(-3,7,1)) +
    theme_minimal()
}

for(y in outcomes) {
  p <- plot_event_coefs(results[[y]]$tidy, paste("Event-study:", y))
  print(p)
}
