##################################
#Trabajar con el paquete spotifyr
#################################

#Paquetes
library(spotifyr)
library(tidyverse)

#Credenciales
id <- "d42df380447347c2a5946a38b1e24132"
secret <- "4acc065f735642a99ff653efd065d984"
Sys.setenv(SPOTIFY_CLIENT_ID = id)
Sys.setenv(SPOTIFY_CLIENT_SECRET = secret)
access_token <- get_spotify_access_token()

#Buscar los artistas de rock escuchados en el mercado chileno. Se recorren las primeras 1000 hojas 
bandas_chile <- map(c(0:1000), get_genre_artists, genre = "rock", market = "cl", limit = 50) %>% 
  reduce(bind_rows) 

#La mayoría de las filas están repetidas, por lo que es necesario limpiar. No entiendo bien el motivo de la repetición. Puede ser un error en el paquete

bandas_filter <- bandas_chile %>% 
  distinct()


#Buscamos las información de la discografía para cada una de las bandas que aparecieron, pero seleccionado solo las menos populares, ya que ahí es más probable encontrar a las chilenas

bandas_chilenas <- bandas_filter %>% 
  as.data.frame() %>% 
  filter(popularity <=  60 | name == "Los Prisioneros" |  name == "Los Bunkers") %>% 
  pull(id)  

i <- 0
album_info <-  map(bandas_chilenas, function(x) {
  i <<- i + 1
  print(i)
  if (x != "6dH5I8Q7HhXu74cBXkP0LD") {
    get_artist_audio_features(x, include_groups = "album")
  } 
}) 


album_info <- album_info %>% 
  reduce(bind_rows)

#Guardar información
save(bandas_chile, file = "data/bandas_chile.RData")
save(bandas_filter, file = "data/bandas_filter.RData")
save(album_info, file = "data/album_info.RData")