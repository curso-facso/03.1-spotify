

library(httr)
library(jsonlite)



library(httr)
library(jsonlite)

# Detalles de la aplicación en Reddit
client_id <- "DX3G_cp3oFZz2dnMv9Fm2Q"
client_secret <- "Ixr5PuZxvRxWc8tp1xbijolQBwYeOg"
username <- "klaus_lehmann"
password <- "klehmann89"
user_agent <- "facso"
auth_url <- "https://www.reddit.com/api/v1/access_token"
library(base64enc)  # Para codificar en base64

auth_header <- base64encode(charToRaw(paste(client_id, ":", client_secret, sep = "")))

# Configurar los datos de la solicitud
body_data <- list(
  grant_type = "password",
  username = username,
  password = password
)

# Configurar los encabezados de la solicitud
headers <- c(
  `User-Agent` = user_agent,
  Authorization = paste("Basic", auth_header)
)

# Realizar la solicitud POST para obtener el token de acceso
response <- POST(url = auth_url,
                 body = body_data,
                 encode = "form",
                 add_headers(headers))

response$status_code

token <- content(response) 
access_token <- token$access_token


# Extraer tópicos
reddit_api_url <- "https://www.reddit.com/subreddits/popular.json"


# Configurar los encabezados de la solicitud con el token de acceso
headers <- c(
  `Authorization` = paste("Bearer", access_token, sep = " "),
  `User-Agent` = "facso"
)

# Realizar la solicitud GET
response <- GET(url = reddit_api_url, add_headers(headers))

response$status_code

# Verificar el estado de la respuesta
if (http_status(response)$status_code == 200) {
  # La solicitud fue exitosa, convertir la respuesta JSON a un data frame
  subreddit_data <- content(response, as = "parsed")
  # Mostrar los nombres de los subreddits más populares
  popular_subreddits <- subreddit_data$data$children$name
  print(popular_subreddits)
} else {
  # Manejar errores
  cat("Error al obtener subreddits populares:", http_status(response)$status_code, "\n")
  cat("Mensaje de error:", content(response)$error, "\n")
}


