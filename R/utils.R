#' Read all csv files in a folder
#' \code{read_all_csv} returns a list of all csv files located inside folder in its arguments
#'
#' @param folder A character string. Path to folder containing csv files
#' @return The output is a list of all CSV files inside the argument folder
read_all_csv<-function(folder){
  filenames<-list.files(path = folder,recursive = T)
  filenames<-paste0(folder,filenames)
  filenames<-grep("\\.csv$",filenames,value = TRUE)

  dfs<-purrr::map(filenames,read.csv)
  names(dfs)<-sub(".*/(.*)/.*","\\1",filenames)
  dfs
}

#' Delete all characters before the last slash including the slash
#'
#' @param expression column of a dataframe
sanitize_node <- function(expression) {
  sub("/.*/","",expression)
}

#' Calculate survey duration
#'
#' @param endtime Column end
#' @param startime column start
#'
#' @return Duration in minutes
calculate_survey_duration <- function(endtime, startime){
  as.numeric(round(sum(((endtime - startime)/60000),na.rm = T),digits = 2))
}

#' Calculates form lifetime
#'
#' @param  endtime column end
#' @param  startime column start
#'
#' @return Duration in minutes
form_lifetime <- function(endtime, startime){
  as.numeric(round((tail(endtime[!is.na(endtime)],1) - startime[1])/60000,digits = 2))
}

#' Count occurrence of a specified type
#'
#' @param allaudit List of all audit files
#' @param  event a specific event
#'
#' @return Number of specified event if happened
count_event_type<-function(allaudit, event){
  lapply(allaudit, function(x){
    sum(stringr::str_count(x$event, event))
  }) %>% unlist()
}

#' perform checks using audit files
#'
#' @param pathtofolder path to all audit csv files folder
#' @param excluded variables you want to exclude when calculating survey duration
#'
#' @return Data frame with survey duration and other useful information
#'
#' @export
auditcheck<-function(pathtofolder, excluded=NULL){
  allaudit<-read_all_csv(pathtofolder)
  allaudit<-lapply(allaudit, function(x) {
    x$node<-sanitize_node(x$node)
    return(x)
  })
  start_to_exit<-lapply(allaudit, function(x){
    form_lifetime(x$end, x$start)
  }) %>% unlist()
  time_on_questions<-lapply(allaudit, function(x){
    calculate_survey_duration(x$end[x$event %in% c("question","group questions")],
                              x$start[x$event %in% c("question","group questions")])
  }) %>% unlist()
  if(!is.null(excluded)){
    time_on_excluded_questions<-lapply(allaudit, function(x){
      calculate_survey_duration(x$end[x$node %in% excluded],
                                x$start[x$node %in% excluded])
    }) %>% unlist()
  }
  jump<-count_event_type(allaudit,"jump")
  endscreen<-count_event_type(allaudit,"end screen")
  formsave<-count_event_type(allaudit,"form save")
  formexit<-count_event_type(allaudit,"form exit")
  formresume<-count_event_type(allaudit,"form resume")
  formfinalize<-count_event_type(allaudit,"form finalize")
  saveerror<-count_event_type(allaudit,"save error")

  checks<- data.frame(
    start_to_exit=start_to_exit,
    time_on_questions=time_on_questions,
    time_on_filterd_questions=if(is.null(excluded)) {"NULL"} else(time_on_questions-time_on_excluded_questions),
    jump=jump,
    endscreen=endscreen,
    formsave=formsave,
    formexit=formexit,
    formresume=formresume,
    formfinalize=formfinalize,
    saveerror=saveerror
  ) %>% tibble::rownames_to_column("uuid")

  return(checks)

}
