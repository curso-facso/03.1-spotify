# Usando httr para peticiones directas a la API
library(httr)
library(jsonlite)

# Función para obtener el contenido COMPLETO de un artículo
obtener_contenido_completo <- function(titulo, idioma = "es") {
  url <- paste0("https://", idioma, ".wikipedia.org/w/api.php")
  
  respuesta <- GET(url, query = list(
    action = "query",
    format = "json",
    prop = "extracts",
    titles = titulo,
    exlimit = 1,
    explaintext = TRUE,  # Texto plano sin HTML
    exsectionformat = "plain"
  ))
  
  if (status_code(respuesta) == 200) {
    contenido <- fromJSON(content(respuesta, "text", encoding = "UTF-8"))
    paginas <- contenido$query$pages
    
    # Obtener la primera (y única) página
    pagina <- paginas[[1]]
    
    if (!is.null(pagina$extract)) {
      return(list(
        titulo = pagina$title,
        contenido = pagina$extract,
        longitud = nchar(pagina$extract)
      ))
    } else {
      return("Página no encontrada")
    }
  } else {
    return("Error al obtener el contenido")
  }
}

# Función para obtener contenido con formato HTML (si lo prefieres)
obtener_contenido_html <- function(titulo, idioma = "es") {
  url <- paste0("https://", idioma, ".wikipedia.org/w/api.php")
  
  respuesta <- GET(url, query = list(
    action = "query",
    format = "json",
    prop = "extracts",
    titles = titulo,
    exlimit = 1
    # Sin explaintext para mantener HTML
  ))
  
  if (status_code(respuesta) == 200) {
    contenido <- fromJSON(content(respuesta, "text", encoding = "UTF-8"))
    paginas <- contenido$query$pages
    pagina <- paginas[[1]]
    
    if (!is.null(pagina$extract)) {
      return(list(
        titulo = pagina$title,
        contenido_html = pagina$extract,
        longitud = nchar(pagina$extract)
      ))
    } else {
      return("Página no encontrada")
    }
  } else {
    return("Error al obtener el contenido")
  }
}

# Función para obtener estructura completa con secciones
obtener_estructura_completa <- function(titulo, idioma = "es") {
  url <- paste0("https://", idioma, ".wikipedia.org/w/api.php")
  
  respuesta <- GET(url, query = list(
    action = "parse",
    format = "json",
    page = titulo,
    prop = "text|sections",
    disableeditsection = TRUE
  ))
  
  if (status_code(respuesta) == 200) {
    contenido <- fromJSON(content(respuesta, "text", encoding = "UTF-8"))
    
    if (!is.null(contenido$parse)) {
      return(list(
        titulo = contenido$parse$title,
        contenido_html = contenido$parse$text,
        secciones = contenido$parse$sections
      ))
    } else {
      return("Página no encontrada")
    }
  } else {
    return("Error al obtener el contenido")
  }
}

# Ejemplo de uso
titulo <- "Ciencia de datos"
resumen <- obtener_resumen(titulo)
print(paste("Resumen de", titulo, ":"))
print(resumen)

# Función para buscar páginas con título y contenido
buscar_paginas <- function(consulta, idioma = "es", limite = 5) {
  url <- paste0("https://", idioma, ".wikipedia.org/w/api.php")
  
  respuesta <- GET(url, query = list(
    action = "query",
    format = "json",
    list = "search",
    srsearch = consulta,
    srlimit = limite
  ))
  
  if (status_code(respuesta) == 200) {
    contenido <- fromJSON(content(respuesta, "text", encoding = "UTF-8"))
    resultados <- contenido$query$search
    
    # Crear un data frame con título y snippet (extracto)
    if (nrow(resultados) > 0) {
      df_resultados <- data.frame(
        titulo = resultados$title,
        extracto = resultados$snippet,
        stringsAsFactors = FALSE
      )
      return(df_resultados)
    } else {
      return(data.frame(titulo = character(0), extracto = character(0)))
    }
  } else {
    return("Error en la búsqueda")
  }
}

# Función para guardar contenido en archivo
guardar_articulo <- function(titulo, idioma = "es", formato = "texto") {
  if (formato == "texto") {
    contenido <- obtener_contenido_completo(titulo, idioma)
    if (is.list(contenido)) {
      nombre_archivo <- paste0(gsub("[^A-Za-z0-9]", "_", titulo), ".txt")
      writeLines(contenido$contenido, nombre_archivo, useBytes = TRUE)
      cat("Artículo guardado en:", nombre_archivo, "\n")
      cat("Longitud:", contenido$longitud, "caracteres\n")
    }
  } else if (formato == "html") {
    contenido <- obtener_contenido_html(titulo, idioma)
    if (is.list(contenido)) {
      nombre_archivo <- paste0(gsub("[^A-Za-z0-9]", "_", titulo), ".html")
      writeLines(contenido$contenido_html, nombre_archivo, useBytes = TRUE)
      cat("Artículo guardado en:", nombre_archivo, "\n")
    }
  }
}

# Función para buscar y descargar múltiples artículos
descargar_articulos_busqueda <- function(consulta, idioma = "es", limite = 3) {
  # Buscar artículos
  resultados <- buscar_paginas(consulta, idioma, limite)
  
  if (is.data.frame(resultados) && nrow(resultados) > 0) {
    articulos_descargados <- list()
    
    for (i in 1:nrow(resultados)) {
      titulo <- resultados$titulo[i]
      cat("Descargando:", titulo, "\n")
      
      contenido <- obtener_contenido_completo(titulo, idioma)
      if (is.list(contenido)) {
        articulos_descargados[[i]] <- contenido
      }
      
      # Pausa para no sobrecargar el servidor
      Sys.sleep(0.5)
    }
    
    return(articulos_descargados)
  } else {
    return("No se encontraron artículos")
  }
}

# Ejemplos de uso para contenido completo

# Ejemplo 1: Descargar un artículo completo
print("=== Descargando artículo completo ===")
articulo <- obtener_contenido_completo("Inteligencia artificial")
if (is.list(articulo)) {
  cat("Título:", articulo$titulo, "\n")
  cat("Longitud:", articulo$longitud, "caracteres\n")
  cat("Primeros 500 caracteres:\n")
  cat(substr(articulo$contenido, 1, 500), "...\n")
}

# Ejemplo 2: Guardar artículo en archivo
print("\n=== Guardando artículo en archivo ===")
guardar_articulo("Machine learning", formato = "texto")

# Ejemplo 3: Descargar múltiples artículos de una búsqueda
print("\n=== Descargando múltiples artículos ===")
articulos <- descargar_articulos_busqueda("ciencia de datos", limite = 2)
if (is.list(articulos)) {
  for (i in 1:length(articulos)) {
    if (is.list(articulos[[i]])) {
      cat("Artículo", i, ":", articulos[[i]]$titulo, 
          "(", articulos[[i]]$longitud, "caracteres)\n")
    }
  }
}

# Ejemplo 4: Obtener estructura con secciones
print("\n=== Obteniendo estructura completa ===")
estructura <- obtener_estructura_completa("Python")
if (is.list(estructura)) {
  cat("Título:", estructura$titulo, "\n")
  cat("Número de secciones:", nrow(estructura$secciones), "\n")
  cat("Secciones principales:\n")
  print(estructura$secciones$line[1:5])  # Primeras 5 secciones
}

# Función auxiliar para limpiar HTML si es necesario
limpiar_html <- function(texto) {
  # Remover tags HTML
  texto <- gsub("<[^>]*>", "", texto)
  # Limpiar entidades HTML comunes
  texto <- gsub("&nbsp;", " ", texto)
  texto <- gsub("&amp;", "&", texto)
  texto <- gsub("&lt;", "<", texto)
  texto <- gsub("&gt;", ">", texto)
  return(texto)
}


respuesta <- buscar_paginas("ciencia de datos", "es", 2)