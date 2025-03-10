#' delphi_round1 UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_delphi_round1_ui <- function(id){
  ns <- NS(id)

  tagList(
    mainPanel(
      value_box(
        title = "",
        value = uiOutput(ns("title_es"))
        
      ),
      br(),
      actionButton(ns("alert"),
                   label = "Explain me this nature benefit"),

      br(),
      # questions of importance
      uiOutput(ns("imp_text")),
      sliderInput(ns("imp_own"), "... for you personally in the study area?",
                  min = 0, max = 5, value = 3),

      sliderInput(ns("imp_other"), "...for the whole society in general in the study area?",
                  min = 0, max = 5, value = 3),

      br(),
      # are you able to map the ES?
      uiOutput(ns("map_poss")),
      br(),
      # if ES not mappable
      conditionalPanel(
        condition = "input.map_poss == 'No'", ns = ns ,
        tagList(
          value_box(
            title = "",
            value = "Would you trust an expert evaluation regarding suitable areas for this nature benefit?",
            theme = value_box_theme(bg = orange, fg = "black"),
            showcase = bs_icon("question-octagon-fill")
          ),
          selectizeInput(ns("expert_map"),label="" ,choices = c("Yes","No"),options = list(
            placeholder = 'Please select an option below',
            onInitialize = I('function() { this.setValue(""); }')))%>%
            
            shinyInput_label_embed(
              icon("info") %>%
                bs_embed_tooltip(title = "An expert evaluation could be either a physical model, including various indicators or expert judgements based on their knowledge",placement = "right")
            ),
          use_bs_tooltip()
        )
        

        # actionButton(ns("submit2"),"save")
      ),
      
      conditionalPanel(
        condition = "input.expert_map != ''", ns=ns,
        actionButton(ns("confirm"), "Next task", style="color: black; background-color: #31c600; border-color: #31c600")
      )
    )
  )
}

callback <- c(
  '$("#remove").on("click", function(){',
  '  table.rows(".selected").remove().draw();',
  '});'
)

#' delphi_round1 Server Functions
#'
#' @noRd
mod_delphi_round1_server <- function(id, sf_stud_geom, rand_es_sel, order, userID, site_id, site_type, var_lang, pred){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    mapTIME_start <-Sys.time()
    
    order<-as.numeric(order)
    rand_es_sel<-rand_es_sel[order,]
    ## the band names of the predictor variables (might be adjusted in the future if predictors can be selected according to project)
    
    ### visualization parameter for img, mean
    # cols   <- c("#e80909", "#fc8803", "#d8e03f", "#c4f25a","#81ab1f")
    # maxentviz = list(bands= 'probability',min= 0, max= 1, palette= cols)
    rv1<-reactiveValues(
      u = reactive({})
    )
    a<-paste0("esNAME_",var_lang)
    ## descriptives of ecosystem services
    output$title_es<-renderUI(h3(dplyr::select(rand_es_sel,contains(paste0("esNAME_",var_lang)))))
    #output$descr_es<-renderUI(h4(dplyr::select(rand_es_sel,contains(paste0("esDESCR_",var_lang)))))
    
    observeEvent(input$alert,{
      showModal(modalDialog(
        title = "",
        h4(dplyr::select(rand_es_sel,contains(paste0("esDESC_lay_",var_lang)))),

      ))
    })


    # output$res_text<-renderText(paste0("The map indicates areas well suited for ",dplyr::select(rand_es_sel,contains(paste0("esNAME_",var_lang)))," based on your answers."))
    # output$es_quest_where<-renderUI(h5(paste0("Please draw one or several rectangles that show areas you think that are well suited for ", dplyr::select(rand_es_sel,contains(paste0("esNAME_",var_lang))),"?")))
    # output$res_text<-renderUI(
    #   tagList(
    #     bslib::value_box(
    #       title= "",
    #       value = paste0("The map indicates areas well suited for ",dplyr::select(rand_es_sel,contains(paste0("esNAME_",var_lang)))," based on your answers."),
    #       showcase_layout = "left center",
    #       theme = "success",
    #       showcase = bs_icon("check-square"),
    #       h5("Red colors indicate areas of higher suitability, blue colors lower suitability"),
    #     )
    #   )
    # )
    
    output$es_quest_where<-renderUI(
      tagList(
        value_box(
          title = "",
          value = dplyr::select(rand_es_sel,contains(paste0("esQUEST_",var_lang))),
          h5("Draw and modify rectangles inside the orange bounds of the study area."),
          h5("Draw a maximum of five rectangles"),
          br(),
          h5("The minimum area of a rectangle is 62.5ha or approximately 70 soccer fields."),
          h5("You will see the [ha] during you draw the rectangle. In addition, the app indicates if your last drawn polygon is too small or too big."),
          theme = value_box_theme(bg = orange, fg = "black"),
          showcase = bs_icon("question-octagon-fill"),
          
        )
      )
    )
    output$es_quest_how<-renderUI(tagList(
      value_box(
        title = "",
        value = paste0("For each rectangle indicate, how well you think they are suited for ",dplyr::select(rand_es_sel,contains(paste0("esNAME_",var_lang)))),
        theme = value_box_theme(bg = orange, fg = "black"),
        showcase = bs_icon("question-octagon-fill")
      )
    ))
    output$imp_accText<-renderUI(
      tagList(
        value_box(
          title = "",
          value = paste0("How important is an easy access (by foot, bike, car) to your rectangles to benefit from ", dplyr::select(rand_es_sel,contains(paste0("esNAME_",var_lang))),"?"),
          theme = value_box_theme(bg = orange, fg = "black"),
          showcase = bs_icon("question-octagon-fill")
        )
      ))
    
    output$blog_descr<-renderUI(
      tagList(
        value_box(
          title = "",
          value = paste0("Briefly explain in some bullet points why you choosed these particular areas. What makes them suitable to benefit from ",dplyr::select(rand_es_sel,contains(paste0("esNAME_",var_lang))) ,"?"),
          theme = value_box_theme(bg = orange, fg = "black"),
          showcase = bs_icon("question-octagon-fill")
        )
      ))
    
    output$imp_text<-renderUI(
      tagList(
        value_box(
          title = "",
          value = paste0("How important are the benefits of ", dplyr::select(rand_es_sel,contains(paste0("esNAME_",var_lang))),"..."),
          theme = value_box_theme(bg = orange, fg = "black"),
          showcase = bs_icon("question-octagon-fill")
        )
      ))
    
    # # image 
    # output$image_es<-renderUI({
    #   tags$figure(
    #     class = "centerFigure",
    #     tags$img(
    #       src = "placeholder_es.jpg",
    #       width = 600,
    #       alt = "A placehoder image for the ES"
    #     ),
    #     tags$figcaption("A placehoder image for the ES")
    #   )
    # })
    
    
    # UI rendered to ask if able to map ES
    output$map_poss<-renderUI({
      tagList(
        value_box(
          title = "",
          value = paste0("Are you able to map areas that are well suited for ", dplyr::select(rand_es_sel,contains(paste0("esNAME_",var_lang)))," according to you in the study area?"),
          theme = value_box_theme(bg = orange, fg = "black"),
          showcase = bs_icon("question-octagon-fill")
        ),
        selectizeInput(ns("map_poss"),label="",choices = c("Yes","No"),options = list(
          placeholder = 'Please select an option below',
          onInitialize = I('function() { this.setValue(""); }')
        ))
        
      )

      # lable <- paste0("Are you able to show on a map area where you personally user and benefit from ", dplyr::select(rand_es_sel,contains(paste0("esNAME_",var_lang))),"?")
      # selectizeInput(ns("map_poss"),label=lable,choices = c("Yes","No"),options = list(
      #   placeholder = 'Please select an option below',
      #   onInitialize = I('function() { this.setValue(""); }')
      # ))
    })
    
    map<-leaflet(sf_stud_geom)%>%
      addPolygons(color = "orange", weight = 3, smoothFactor = 0.5,
                  opacity = 1.0, fillOpacity = 0)%>%
      addProviderTiles(providers$OpenStreetMap.Mapnik,options = tileOptions(minZoom = 8, maxZoom = 15),group = "Openstreet map")%>%
      addProviderTiles(providers$Esri.WorldImagery,options = tileOptions(minZoom = 8, maxZoom = 15),group = "World image")%>%
      addDrawToolbar(targetGroup='drawPoly',
                     polylineOptions = F,
                     polygonOptions = F,
                     circleOptions = F,
                     markerOptions = F,
                     circleMarkerOptions = F,
                     rectangleOptions = drawRectangleOptions(
                       showArea = TRUE,
                       shapeOptions = drawShapeOptions(
                         clickable = TRUE
                       )
                     ),
                     singleFeature = FALSE,
                     editOptions = editToolbarOptions(selectedPathOptions = selectedPathOptions()))%>%
      addLayersControl(baseGroups = c("Openstreet map","World image"),
                       options = layersControlOptions(collapsed = T))
    
    # second for results
    map_res<-leaflet(sf_stud_geom)%>%
      addProviderTiles(providers$OpenStreetMap.Mapnik,options = tileOptions(minZoom = 8, maxZoom = 15),group = "Openstreet map")%>%
      addProviderTiles(providers$Esri.WorldImagery,options = tileOptions(minZoom = 8, maxZoom = 15),group = "World image")%>%
      addDrawToolbar(targetGroup='drawPoly',
                     polylineOptions = F,
                     polygonOptions = F,
                     circleOptions = F,
                     markerOptions = F,
                     circleMarkerOptions = F,
                     rectangleOptions = F,
                     singleFeature = FALSE,
                     editOptions = editToolbarOptions(selectedPathOptions = selectedPathOptions()))%>%
      addLayersControl(baseGroups = c("Openstreet map","World image"),
                       options = layersControlOptions(collapsed = FALSE))
    
    observeEvent(input$confirm,{
      # removeNotification(id="note1")
      rv1$u <-reactive({1})
    })
    
    rv<-reactiveValues(
      edits = reactive({})
    )
    
    ## call the edit map module from the mapedit package
    #edits<-mapedit::editMap(map, targetLayerId = "poly_r1", record = T,sf = T,editor = c("leaflet.extras", "leafpm"))
    
    observeEvent(input$map_poss,{
      if(input$map_poss == "Yes"){
        
        rv$edits<-callModule(
          module = editMod,
          leafmap = map,
          id = "map_sel")

        
        insertUI(selector =paste0("#",ns("map_poss")),
                 where = "afterEnd",
                 ui=tagList(
                   uiOutput(ns("es_quest_where")),
                   br(),
                   editModUI(ns("map_sel")),
                   
                   htmlOutput(ns("overlay_result")),
                   uiOutput(ns("btn1")),
                   
                 )
        )
        
      }#/if yes
    })#/map_poss
    
    ## if mapping not possible: (save results has to be added!)
    observeEvent(input$confirm,{
      
      if(input$expert_map !=""){
        show_modal_spinner(color = green,text = "update data base")
        train_param<-list(
          esID = rand_es_sel$esID,
          userID = userID,
          siteID = site_id,
          imp_acc= as.integer(0),
          imp_nat= as.integer(0),
          imp_lulc = as.integer(0),
          imp_own = as.integer(input$imp_own),
          imp_other = as.integer(input$imp_other),
          rel_training_A = as.numeric(0),
          n_poly = as.integer(0),
          blog = "NA",
          poss_mapping = "No",
          expert_trust = input$expert_map,
          mapping_order = as.numeric(order),
          extrap_AUC = as.numeric(0),
          extrap_KAPPA = as.numeric(0),
          extrap_propC = as.numeric(0),
          # extrap_demIMP = as.numeric(0),
          # extrap_accIMP = as.numeric(0),
          # extrap_lulcIMP = as.numeric(0),
          # extrap_natIMP = as.numeric(0),
          mapTIME_h = as.numeric((Sys.time()-mapTIME_start)/3600)
        )
        train_param<-as.data.frame(train_param)
        # insert_upload_job(table_con$project, table_con$dataset, "es_mappingR1", train_param)
        es_mapping_tab = bq_table(project = project_id, dataset = dataset, table = 'es_mappingR1')
        bq_table_upload(x = es_mapping_tab, values = train_param, create_disposition='CREATE_IF_NEEDED', write_disposition='WRITE_APPEND')
        
        removeUI(
          selector = paste0("#",ns("expert_map"))
        )
        remove_modal_spinner()
      }
      
      
    })
    
    ##  check for intersecting training / study area and poly areas in general
    observe({
      req(rv$edits)
      rectangles <- rv$edits()$finished

      
      n_poly<-nrow(as.data.frame(rectangles))
      if(site_type == "onshore"){
        resolution = 250^2
      }else{
        resolution = 500^2
      }
      
      #with res of 250m grid we can sample at least 10 pts with variaton within 0.6km2
      A_min<-resolution*10
      #A_max<-0.05*round(as.numeric(st_area(sf_stud_geom)),0)
      A_max<-A_min*20
      if(n_poly == 0){
        output$overlay_result <- renderText({
          paste("<font color=\"#FF0000\"><b><li>Draw at least one rectangle<li/></b></font>")
        })
      } else if(n_poly==1){
        n_within<-nrow(as.data.frame(st_within(rectangles,sf_stud_geom)))
        if(n_within < n_poly){
          output$overlay_result <- renderText({
          paste("<font color=\"#FF0000\"><b>","You can`t save the rectangles:","</b> <li>Place your rectangle completely into the the study area<li/></font>")
          })
          # shinyalert(  title = "",
          #              text = "Place your rectangle inside the orange borders",
          #              type = "warning",
          #              closeOnEsc = TRUE,
          #              closeOnClickOutside = TRUE,
          #              showCancelButton = F,
          #              showConfirmButton = TRUE,
          #              animation = "slide-from-bottom",
          #              size = "s")
          removeUI(
            selector = paste0("#",ns("savepoly")))
        }else{
          area<-round(as.numeric(st_area(rectangles)),0)
          min_train<-min(area)
          max_train<-max(area)
          if(min_train<A_min & max_train<=A_max){
            output$overlay_result <- renderText({
              paste("<font color=\"#FF0000\"><b>","You can`t save the rectangles:","</b> <li>The area of the rectangle is too small<li/></font>")
            })
            removeUI(
              selector = paste0("#",ns("savepoly")))
            
          }else if(min_train>A_min & max_train>A_max){
            output$overlay_result <- renderText({
              paste("<font color=\"#FF0000\"><b>","You can`t save the rectangles:","</b> <li>The area of the rectangle is too big<li/></font>")
            })
            removeUI(
              selector = paste0("#",ns("savepoly")))
            
            
          }else{
            output$btn1<-renderUI(
              actionButton(ns("savepoly"),"save")
            )
            output$overlay_result <- renderText({
              "Save or draw further rectangles"
            })
            
          }
          
        }
        
      }else if(n_poly<=5 & n_poly>1){
        n_within<-nrow(as.data.frame(st_within(rectangles,sf_stud_geom)))
        n_inter<-nrow(as.data.frame(st_intersects(rectangles)))
        q=n_inter-n_poly
        if(q!=0 & n_within<n_poly){
          removeUI(
            selector = paste0("#",ns("savepoly")))
          output$overlay_result <- renderText({
            paste("<font color=\"#FF0000\"><b>","You can`t save the rectangles:","</b><li>Place your last rectangle completely into the the study area<li/><li>Remove overlays<li/></font>")
            
          })
        }else if(q==0 & n_within<n_poly){
          removeUI(
            selector = paste0("#",ns("savepoly")))
          output$overlay_result <- renderText({
            paste("<font color=\"#FF0000\"><b>","You can`t save the rectangles:","</b> <li>Place your last rectangle completely into the the study area<li/></font>")
            
          })
        }else if(q!=0 & n_within==n_poly){
          removeUI(
            selector = paste0("#",ns("savepoly")))
          output$overlay_result <- renderText({
            paste("<font color=\"#FF0000\"><b>","You can`t save the rectangles:","</b> <li>Remove overlays from last rectangle<li/></font>")
            
          })
        }else if(q==0 & n_within==n_poly){
          area<-round(as.numeric(st_area(rectangles)),0)
          min_train<-min(area)
          max_train<-max(area)
          if(min_train<A_min & max_train<=A_max){
            output$overlay_result <- renderText({
              paste("<font color=\"#FF0000\"><b>","You can`t save the rectangles:","</b> <li>The area of the last rectangle is too small<li/></font>")
            })
            removeUI(
              selector = paste0("#",ns("savepoly")))
            
          }else if(min_train>A_min & max_train>A_max){
            output$overlay_result <- renderText({
              paste("<font color=\"#FF0000\"><b>","You can`t save the rectangles:","</b> <li>The area of the last rectangle is too big<li/></font>")
            })
            removeUI(
              selector = paste0("#",ns("savepoly")))
            
            
          }else{
            output$btn1<-renderUI(
              actionButton(ns("savepoly"),"save")
            )
            output$overlay_result <- renderText({
              "Save or draw further rectangles"
            })
            
          }
        }
      }else{
        output$overlay_result <- renderText({
          paste("<font color=\"#FF0000\"><b>","You can`t save the rectangles:","</b> <li>Draw a maximum of five rectangles<li/></font>")
        })
        removeUI(
          selector = paste0("#",ns("savepoly")))
      }
      
    })
    
    #remove mapping question as soon as decided
    observeEvent(input$map_poss,{
      if(input$map_poss !=""){
        removeUI(
          selector = paste0("#",ns("map_poss"))
        )
        # removeUI(
        #   selector = paste0("#",ns("imp_own"),"-label"))
        # removeUI(
        #   selector = paste0("#",ns("imp_own")))
        removeUI(
          selector =  paste0("div:has(> #",ns("imp_own"),")")
        )
        # removeUI(
        #   selector = paste0("#",ns("imp_other"),"-label"))
        # removeUI(
        #   selector = paste0("#",ns("imp_other")))

        removeUI(
          selector =  paste0("div:has(> #",ns("imp_other"),")")
        )
        removeUI(
          selector = paste0("#",ns("imp_text")))

      }
    })
    
    ### confirm the drawings and render the results table
    tbl_out<-eventReactive(input$savepoly,{
      tbl<-rv$edits()$finished
      
      # do not give possibility to submit map without polygons
      req(tbl, cancelOutput = FALSE)
      tbl<-tbl%>%st_drop_geometry()
      tbl$value_es<-rep(NA,(nrow(tbl)))
      tbl
    })
    
    ### confirm the drawings and render the leaflet map
    observeEvent(input$savepoly, {
      tbl<-tbl_out()
      polygon<-rv$edits()$finished
      
      # do not give possibility to submit map without polygons
      req(polygon, cancelOutput = FALSE)
      
      ## render new UI of polygon map and slider remove rest
      insertUI(
        selector = paste0("#",ns("savepoly")),
        where = "afterEnd",
        ui = tagList(
          uiOutput(ns("es_quest_how")),
          br(),
          leafletOutput(ns("map_res")),
          br(),
          uiOutput(ns("slider")),
          br(),
          uiOutput(ns("imp_accText")),
          sliderInput(ns("imp_acc"), "0 = not important - 1 = very important",
                      min = 0, max = 1, step = 0.1, value = 0.5)%>%
            shinyInput_label_embed(
              icon("info") %>%
                bs_embed_tooltip(title = "Ask yourself how important an easy access to the area is necessary to use or profit from this nature benefit. Is it important for you to be able to reach your areas without effort? 1 = not important at all, 5 = very important",placement = "right")),
          use_bs_tooltip(),
          br(),
          uiOutput(ns("blog_descr")),
          textInput(ns("blog"), label = "")%>%
            shinyInput_label_embed(
              icon("info") %>%
                bs_embed_tooltip(title = "Explain briefly the features or factors why you have chosen these areas. You can do that in single expressions or a blog-like statement. Use short sentences up to max 250 characters in total.",placement = "right")),
          use_bs_tooltip() ,
          br(),
          conditionalPanel(
            condition = "input.blog != ''", ns=ns,
            actionButton(ns("submit"),"save values", style="color: black; background-color: #31c600; border-color: #31c600")
          )
        )
      )
      
      removeUI(
        selector = paste0("#",ns("savepoly")))
      
      removeUI(
        selector = paste0("#",ns("map_sel"),"-map"))
      
      removeUI(
        selector = paste0("#",ns("es_quest_where")))
      
      removeUI(
        selector = paste0("#",ns("overlay_result")))
      
      
      
      cent_poly <- st_centroid(polygon)
      output$map_res<-renderLeaflet(map_res %>%
                                      addPolygons(data=polygon) %>%
                                      addLabelOnlyMarkers(data = cent_poly,
                                                          lng = ~st_coordinates(cent_poly)[,1], lat = ~st_coordinates(cent_poly)[,2], label = cent_poly$`_leaflet_id`,
                                                          labelOptions = labelOptions(noHide = TRUE, direction = 'top', textOnly = TRUE,
                                                                                      style = list(
                                                                                        "color" = "red",
                                                                                        "font-family" = "serif",
                                                                                        "font-style" = "bold",
                                                                                        "font-size" = "20px"
                                                                                      ))))
      
      ## create a slider for each of the polygons
      
      output$slider <- shiny::renderUI({
        ns <- session$ns
        tagList(
          paste0("The number for each rectangle in the map corresponds to the number of the slider. For each individual rectangle, how suitable do you think the area is for ",dplyr::select(rand_es_sel,contains(paste0("esNAME_",var_lang))),"? 1 = not suitable, 2 = little suitable, 3 = suitable, 4 = very suitable, 5 = very suitable "),
          br(),
          br(),
          lapply(1:nrow(tbl),function(n){
            polynr <- tbl[n,]$`_leaflet_id`
            id<-paste0("id_",polynr)
            lable<-paste0("Polygon Nr in map: ",polynr)
            sliderInput(ns(id),lable, min = 1, max = 5, step = 1, value = 3)
          })
        )
        
      })
    })
    

    ## keep mapping time
    mapTIME_end <-eventReactive(input$submit,{
      mapTIME_end <-Sys.time()
    })
    ## remove map UI and sliders show result
    observeEvent(input$submit, {
      
      insertUI(
        selector = paste0("#",ns("submit")),
        where = "afterEnd",
        ui = tagList(
          # textOutput(ns("res_text")),
          bslib::value_box(
            title= "",
            value = paste0("Based on your inputs, we calculated a map of the study area that shows the probability to benefit from ",dplyr::select(rand_es_sel,contains(paste0("esNAME_",var_lang)))),
            showcase_layout = "left center",
            theme = value_box_theme(bg = blue, fg = "black"),
            showcase = bs_icon("check-square"),
            h5("Red colors indicate areas of higher probability, blue colors lower probability to benefit"),
          ),
          br(),
          leafletOutput(ns("res_map")),
          br(),
          uiOutput(ns("btn_cond"))
          
        )
      ) ## insert ui
      
      removeUI(
        selector = paste0("#",ns("map_res"))
      )
      removeUI(
        selector =  paste0("div:has(> #",ns("imp_acc"),")")
      )
      removeUI(
        selector = paste0("#",ns("imp_accText")))
      removeUI(
        selector = paste0("#",ns("es_quest_how"))
      )
      removeUI(
        selector = paste0("#",ns("slider"))
      )
      removeUI(
        selector = paste0("#",ns("blog_descr"))
      )
      removeUI(
        selector = paste0("#",ns("blog"))
      )
      removeUI(
        selector =  paste0("div:has(> #",ns("blog"),")")
      )
      removeUI(
        selector =  paste0("div:has(> #",ns("select"),")")
      )
      removeUI(
        selector = paste0("#",ns("submit"))
      )
      removeUI(
        selector =  paste0("div:has(> #",ns("pull-right"),")")
      )
      removeUI(
        selector = paste0("div:has(>> #",ns("blog"),")")
      )
      
      
    })
    
    ### predict probability of ES with RF but save polys, ratings, esid and userID on bq
    
    ### gather poly
    # prediction<-eventReactive(input$submit, {
    observeEvent(input$submit, {
      show_modal_progress_line(text = "fetch data", color = green)
      req(mapTIME_end)
      mapTIME_end<-mapTIME_end()
      
        
        polygon<-rv$edits()$finished
        req(polygon, cancelOutput = FALSE)
        polygon<-as.data.frame(polygon)
        polygon$es_value<-rep(NA,nrow(polygon))
        sliderval<-list()
        
        # extract the values from the slider
        res<-lapply(1:nrow(polygon),function(a){
          var<-paste0("id_",polygon[a,]$`_leaflet_id`)
          # print(as.numeric(input[[var]]))
          # polygon$es_value[a]<-as.numeric(input[[var]])
          sliderval[[a]]<-input[[var]]
          return(sliderval)
        })
        vecA <- unlist(res)
        
        # write attributes to geometry
        polygon$es_value <- vecA
        polygon$esID <- rep(rand_es_sel$esID,nrow(polygon))
        polygon$userID <- rep(userID,nrow(polygon))
        polygon$siteID <- rep(site_id,nrow(polygon))
        polygon$delphi_round<-rep(1, nrow(polygon))
        update_modal_progress(0.1, text = "update data base")
        n_polys <-nrow(polygon)
        polygon<-st_as_sf(polygon)
        train_area<-as.numeric(sum(st_area(polygon)))
        
        #create new polygon object with wkt as geometry
        polygons<-polygon%>%st_drop_geometry()
        polygons$geometry<-st_as_text(polygon$geometry)
        update_modal_progress(0.15, text = "update data base")
        #save it on bq
        poly_table = bq_table(project = project_id, dataset = dataset, table = 'ind_polys_R1')
        bq_table_upload(x = poly_table, values = polygons, create_disposition='CREATE_IF_NEEDED', write_disposition='WRITE_APPEND')

        
        ################### not for the moment, just upload polygons to bq
        ############ training pts
        update_modal_progress(0.2, text = "update data base")
        
        
        if(site_type == "onshore"){
          resolution<-250*250
        }else{
          resolution<-500*500
        }
        # 
        # 
        # ## N background (outside poly points) according to area of extrapolation
        A_roi<-as.numeric(sf_stud_geom$siteAREAkm2*10^6)
        # 
        # # max pts for efficient extrapolation each cell
        all_back_pts<- round(A_roi/resolution,0)
        # 
        # ## although zooming on the map while drawing is limited, we assure that at least 10pts are within a poly
        min_in_pts<-10
        
        # # inside pts are area + es value weighted
        for (i in 1:nrow(polygon)) {
          A_tmp <- as.numeric(st_area(polygon[i,]))
          tmp_ratio<-A_tmp/A_roi
          tmp_pts<-round(all_back_pts*tmp_ratio,0)
          
          if(tmp_pts<=min_in_pts){
            tmp_pts<-min_in_pts
          }else{
            tmp_pts<-tmp_pts
          }
          # npts in this poly must be max_pts*tmp_ratio*es_value
          tmp_pts = st_sample(polygon[i,], round(tmp_pts*(polygon[i,]$es_value/5),0),type="random")
          tmp_pts<-st_as_sf(tmp_pts)
          tmp_pts$inside<-rep(1,nrow(tmp_pts))
          if(i==1){
            pts_in<-tmp_pts
          }else{
            pts_in<-rbind(pts_in,tmp_pts)
          }
          
        }
        # weight predictors
        pred<-load_var(path=pred)
        # pred_w<-stack(pred$dem*1, pred$eii*1, pred$acc*as.numeric(input$imp_acc))
        pred_w<-raster::stack(pred$dem*1, pred$lulc*1, pred$int*1, pred$acc*as.numeric(input$imp_acc))
        # pred_w<-c(rast(pred$acc),rast(pred$dem))
        
        
        pts_in<-st_transform(pts_in,st_crs(pred))
        pts <- do.call(rbind, st_geometry(pts_in)) %>% 
          as_tibble() %>% setNames(c("lon","lat"))
        pts$SPECIES<-rep("pres",nrow(pts))
        
        
        if(nrow(pts)>1500){
          pts<-pts[sample(nrow(pts), 1500), ]
        }
        
        
        
        ############ save map on gcs within studID folder
        update_modal_progress(0.4, text = "train model")
        SDM <- SSDM::modelling('MARS', pts, 
                               pred_w, Xcol = 'lon', Ycol = 'lat')
        
        train_param <-
          list(
            esID = rand_es_sel$esID,
            userID = userID,
            siteID = site_id,
            imp_acc= as.integer(input$imp_acc),
            imp_nat= as.integer(0),
            imp_lulc = as.integer(0),
            imp_own = as.integer(input$imp_own),
            imp_other = as.integer(input$imp_other),
            rel_training_A = as.integer(sum(st_area(polygon)))/A_roi,
            n_poly = as.integer(n_polys),
            blog = input$blog,
            poss_mapping = "Yes",
            expert_trust = "no_own_mapping",
            mapping_order = as.numeric(order),
            extrap_AUC = SDM@evaluation$AUC,
            extrap_KAPPA = SDM@evaluation$Kappa,
            extrap_propC = SDM@evaluation$prop.correct,
            # extrap_demIMP = SDM@variable.importance$dem,
            # extrap_accIMP = SDM@variable.importance$acc,
            # extrap_lulcIMP = SDM@variable.importance$lulc,
            # extrap_natIMP = SDM@variable.importance$int,
            mapTIME_h = as.numeric((Sys.time()-mapTIME_start)/3600)
            
          )
        train_param<-as.data.frame(train_param)
        
        update_modal_progress(0.6, text = "evaluate model & update data base")
        # write to bq
        es_mapping_tab = bq_table(project = project_id, dataset = dataset, table = 'es_mappingR1')
        bq_table_upload(x = es_mapping_tab, values = train_param, create_disposition='CREATE_IF_NEEDED', write_disposition='WRITE_APPEND')
        
        prediction<-SDM@projection
        
        update_modal_progress(0.8, text = "save your map")
        temp_file <- tempfile(fileext = paste0(rand_es_sel$esID,"_",userID,".tif"))
        writeRaster(prediction, filename = temp_file, format = "GTiff")
        
        file_name <-paste0(site_id,"/3_ind_R1/",rand_es_sel$esID,"/",userID)
        gcs_upload(temp_file, bucket_name, name = file_name, predefinedAcl = "bucketLevel")
        file.remove(temp_file)
        
        update_modal_progress(0.9, text = "draw map")
      
      prediction[prediction < 0.15] <- NA
      
      
      bins <- c(0.15, 0.25, 0.5, 0.75, 1)
      colors <- c("#0000FF", "#00FFFF", "#FFFFFF", "#FF7F7F", "#FF0000")
      labels <- c("Low", "Moderate", "High", "Very High")
      
      # Create color palette function
      color_palette <- colorBin(palette = colors, domain = values(prediction), bins = bins, na.color = "transparent")
      
      
      # color_palette <- colorNumeric(
      #   palette = colorRampPalette(c("blue", "green", "yellow", "red"))(100),
      #   domain = values(prediction),
      #   na.color = "transparent"
      # )
      # prediction<-prediction
      output$res_map <- renderLeaflet({
        leaflet(sf_stud_geom)%>%
          addPolygons(color = "orange", weight = 3, smoothFactor = 0.5,
                      opacity = 1.0, fillOpacity = 0)%>%
          addProviderTiles(providers$OpenStreetMap.Mapnik,options = tileOptions(minZoom = 8, maxZoom = 15),group = "Openstreet map")%>%
          addProviderTiles(providers$Esri.WorldImagery,options = tileOptions(minZoom = 8, maxZoom = 15),group = "World image")%>%
          addRasterImage(prediction,colors = color_palette, opacity = 0.6)%>%
          addLegend(
            pal = color_palette,
            values = values(prediction),
            labels= labels,
            title = paste0("Probability to benefit from ",dplyr::select(rand_es_sel,contains(paste0("esNAME_",var_lang)))),
            position = "bottomright"
          )
          # addLayersControl(baseGroups = c("Openstreet map","World image"),
          #                  options = layersControlOptions(collapsed = T))
      })
      remove_modal_progress()
      output$btn_cond<-renderUI({
        req(train_param)
        actionButton(ns("confirm2"), "Next task", style="color: black; background-color: #31c600; border-color: #31c600")
      })
      
    })
    
    
    #modify reactive value to trigger cond
    observeEvent(input$confirm2,{
      # removeNotification(id="note1")
      rv1$u <-reactive({1})
    })
    # play back the value of the confirm button to be used in the main app
    cond <- reactive({rv1$u()})
    
    return(cond)
  })
}

## To be copied in the UI
# mod_delphi_round1_ui("delphi_round1_1")

## To be copied in the server
# mod_delphi_round1_server("delphi_round1_1")
