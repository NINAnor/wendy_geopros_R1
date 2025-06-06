#' ahp_group UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList

# Copyright (C) 2024 Reto Spielhofer; Norwegian Institute for Nature Research (NINA)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
mod_ahp_group_ui <- function(id){
  ns <- NS(id)
  tagList(
    mainPanel(
      h3("Prioritise benefits from Nature I"),
      bslib::value_box(
        title= "",
        value = paste0("How would you personally prioritise different groups of “Benefits from Nature” within " ,area_name, "?"),
        showcase_layout = "left center",
        theme = value_box_theme(bg = orange, fg = "black"),
        showcase = bs_icon("question-octagon-fill"),
        br(),
        h4("Use the sliders to compare the importance between each group"),
        br(),
        actionButton(ns("how_grp"),"Explain me the groups")
      ),
      br(),
      uiOutput(ns("slider")),
      br(),
      actionButton(ns("conf2"), "Next task", style="color: black; background-color: #31c600; border-color: #31c600")
    )
    
  )
}

#' ahp_group Server Functions
#'
#' @noRd
mod_ahp_group_server <- function(id, userID, siteID, area_name){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    
    es_sec<-c("Provisioning","Cultural","Regulation")
    
    es_sec<-unlist(as.vector(es_sec))
    sec_comb<-as.data.frame(t(combn(es_sec, 2)))
    
    observeEvent(input$how_grp,{
      showModal(modalDialog(
        title = "Three groups of Benefits from Nature",
        br(),
        h3("Provisioning"),
        h4("These benefits are any type of direct products that can be extracted from nature, necessary and useful for human well-being. Along with food, other types of provisioning benefits include drinking water, timber, wood fuel, natural gas, oils, plants that can be made into clothes and other materials, and medicinal benefits."),
        br(),
        h3("Cultural"),
        h4("As human interact and alter nature, the natural world has in turn altered us. It has guided our cultural, intellectual, and social development by being a constant force present in our lives. The importance of nature to the human mind can be traced back to the beginning of mankind with ancient civilizations drawing pictures of animals, plants, and weather patterns on cave walls. A cultural benefit is a non-material benefit that contributes to the development and cultural advancement of people, the societies and cultures; the building of knowledge and the spreading of ideas; creativity born from interactions with nature (music, art, architecture); and recreation."),
        br(),
        h3("Regulation"),
        h4("Nature provides many of the basic processes that make life possible for people. Plants clean air and filter water, bacteria decompose wastes, bees pollinate flowers, and tree roots hold soil in place to prevent erosion. All these processes work together to make the planet earth clean, sustainable, functional, and resilient to change."),
        br(),
        h5(HTML('Adapted from <a href="https://www.nwf.org/Educational-Resources/Wildlife-Guide/Understanding-Conservation/Ecosystem-Services" target="_blank">the National Wildlife Federation</a>'))
        ))
    })
    
    output$slider <- shiny::renderUI({
      ns <- session$ns
      
      lapply(1:nrow(sec_comb),function(n){
        pair_id <- paste0(sec_comb[n,]$V1,"_",sec_comb[n,]$V2)
        pair_lable<-""
        choice1<-paste0(sec_comb[n,]$V1, " is overwhelmingly more important")
        choice2<-paste0(sec_comb[n,]$V1, " is very strongly more important")
        choice3<-paste0(sec_comb[n,]$V1, " is strongly more important")
        choice4<-paste0(sec_comb[n,]$V1, " is moderately more important")
        
        choice5<-paste0(sec_comb[n,]$V2, " is overwhelmingly more important")
        choice6<-paste0(sec_comb[n,]$V2, " is very strongly more important")
        choice7<-paste0(sec_comb[n,]$V2, " is strongly more important")
        choice8<-paste0(sec_comb[n,]$V2, " is moderately more important")
        choices<-c(choice1,
                   choice2,choice3,choice4, "both are equally important",choice8,choice7,choice6, choice5)
        
        id_left<-paste0(sec_comb[n,]$V1," benefits of nature")
        id_right<-paste0(sec_comb[n,]$V2," benefits of nature")
        
        tagList(
          column(6, id_left),
          column(6, id_right),
          sliderTextInput(ns(pair_id),
                          pair_lable,
                          grid = F,
                          force_edges = TRUE,
                          choices = choices,
                          width = "75%",
                          selected = choices[5]
                          
          )#/slider
        )#/tagList
        
      })
      
      
      
    })
    
    
    ### store the values
    observeEvent(input$conf2,{
      show_modal_spinner(
        color = green,
        text = "update data base"
      )
      val_list<-list()
      # id_ist<-list()
      res<-lapply(1:nrow(sec_comb),function(a){
        
        
        var<-paste0(sec_comb[a,]$V1,"_",sec_comb[a,]$V2)
        val_list[[a]]<-input[[var]]
        return(val_list)
      })
      comp_val <- unlist(res)
      
      sec_comb$comp_val<-comp_val
      
      sec_comb$recode <- rep(0,nrow(sec_comb))
      
      n<-lapply(1:nrow(sec_comb),function(a){
        if(sec_comb[a,]$comp_val == "both are equally important"){
          sec_comb[a,]$recode <- 1
        } else if(grepl("is overwhelmingly more important",sec_comb[a,]$comp_val) == TRUE){
          sec_comb[a,]$recode <- 8
        } else if(grepl("is very strongly more important",sec_comb[a,]$comp_val) == TRUE){
          sec_comb[a,]$recode <- 6
        } else if(grepl("is strongly more important",sec_comb[a,]$comp_val) == TRUE){
          sec_comb[a,]$recode <- 4
        } else if(grepl("is moderately more important",sec_comb[a,]$comp_val) == TRUE){
          sec_comb[a,]$recode <- 2
        }
        
        if(grepl(sec_comb[a,]$V1,sec_comb[a,]$comp_val) == TRUE){
          sec_comb[a,]$recode<-sec_comb[a,]$recode*-1
        } else {
          sec_comb[a,]$recode<-sec_comb[a,]$recode
        }
      })
      sec_comb$recode <- as.integer(unlist(n))
      sec_comb$userID<-rep(userID,nrow(sec_comb))
      sec_comb$siteID<-rep(siteID,nrow(sec_comb))
      sec_comb$group <- rep(4,nrow(sec_comb))
      sec_comb$group <- as.integer(sec_comb$group)
      
      colnames(sec_comb)<-c("ES_left","ES_right","selection_text","selection_val","userID","siteID", "ahp_section")
      # insert_upload_job(table_con$project, table_con$dataset, "es_pair", sec_comb)
      es_pair = bq_table(project = project_id, dataset = dataset, table = 'es_pair')
      bq_table_upload(x = es_pair, values = sec_comb, create_disposition='CREATE_IF_NEEDED', write_disposition='WRITE_APPEND')
      remove_modal_spinner()
    })
    
    cond <- reactive({input$conf2})
    
    return(cond)
    
  })
}

## To be copied in the UI
# mod_ahp_group_ui("ahp_group_1")

## To be copied in the server
# mod_ahp_group_server("ahp_group_1")
