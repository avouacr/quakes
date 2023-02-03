
server <- function(input, output) {
  
  df_quakes <- 
    aws.s3::s3read_using(
      FUN = readr::read_csv,
      object = "diffusion/shiny-template/quakes.csv",
      bucket = "avouacr",
      opts = list("region" = "")
    )
  
  data <- reactive({
    
    quakes_sub <- dplyr::filter(df_quakes, mag >= input$magSlider)
    
    return(quakes_sub)
  })
  
  # Base map
  output$map <- leaflet::renderLeaflet({
    mymap <- leaflet::leaflet()
    mymap <- leaflet::addTiles(mymap)
    mymap <- leaflet::setView(mymap, lng=178,lat=-23,zoom=4)
    mymap <- leaflet::addProviderTiles(mymap, leaflet::providers$Esri.WorldStreetMap)
  })
  
  # Update markers
  observe({
    proxy <- leaflet::leafletProxy("map")
    proxy <- leaflet::clearMarkers(proxy)
    if (nrow(data()) > 0) {
      proxy <- leaflet::addMarkers(proxy, data=data(), ~long, ~lat, label = ~mag)  
    }
  })
}
