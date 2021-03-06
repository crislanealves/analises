# Definir diret�rio:

setwd("~/basedosdados")

# Pacotes necess�rios: 

library(bigrquery)
library(tidyverse)

# Definindo objetos e a Query 

project_id <- "projectrais"

query_rais <- "SELECT ano, natureza_juridica, SUM(1) AS numero_vinculos
FROM `basedosdados.br_me_rais.microdados_vinculos`
WHERE natureza_juridica IN (1023, 1058, 1082, 1015, 1031, 1040, 1066, 1074)
GROUP BY ano, natureza_juridica
ORDER BY ano, natureza_juridica ASC"

# Baixar dados direto no R 

graf_rais <- bq_table_download(bq_project_query(project_id, query_rais )) 

# Modificando a tabela para adequ�-la a visualiza��o
graf_rais_impuro <- graf_rais%>%
  pivot_wider(names_from = natureza_juridica ,
              values_from = numero_vinculos)%>%
  group_by(ano)%>%
  summarise(executivo_federal = sum(`1015`, na.rm = TRUE),
            executivo_estadual = sum(`1023`, na.rm = TRUE),
            executivo_municipal = sum(`1031`, na.rm = TRUE),
            legislativo_federal = sum(`1040`, na.rm = TRUE),
            legislativo_estadual = sum(`1058`, na.rm = TRUE),
            legislativo_municipal = sum(`1066`, na.rm = TRUE),
            judiciario_federal = sum(`1074`, na.rm = TRUE),
            judiciario_estadual = sum(`1082`, na.rm = TRUE))%>%
  #deixando em milhares
  mutate(across(executivo_federal : judiciario_estadual, ~ ./1000))

# Exportando a base para ser usada no flourish

write.csv(graf_rais_impuro, "grafico_rais.csv")

# A partir da base gerada foram constru�dos tr�s gr�ficos no Flourish, seguem os links:
# N�vel federal: https://app.flourish.studio/visualisation/5204319/edit
# N�vel estadual: https://app.flourish.studio/visualisation/5234347/edit
# N�vel municipal: https://app.flourish.studio/visualisation/5234476/edit 

