
library(YEP)
path = getwd() #Path = repository folder

#Load coverage data, divide into campaign/default and select years to look at---
scenarios = c("routine-default","no-vaccination","routine-bluesky","routine-campaign-bluesky",
              "routine-campaign-default","routine-ia2030","routine-campaign-ia2030")
n_scn=length(scenarios)
coverage_datasets_campaign=coverage_datasets_routine=list()
years_check=c(1940:2000)
diag_frame1=data.frame(scenario=scenarios,n_campaign=rep(NA,n_scn),n_routine=rep(NA,n_scn))
for(n_run in 1:n_scn){
  vacc_data_file = paste0(path, "/shared/coverage_202310gavi-1_yf-", scenarios[n_run], ".csv")
  assertthat::assert_that(file.exists(vacc_data_file))
  coverage_data=read.csv(vacc_data_file,header=TRUE)
  coverage_data=subset(coverage_data,year %in% years_check)
  coverage_datasets_campaign[[n_run]]=subset(coverage_data,activity_type=="campaign")
  coverage_datasets_routine[[n_run]]=subset(coverage_data,activity_type=="routine")
  diag_frame1$n_campaign[n_run]=nrow(coverage_datasets_campaign[[n_run]])
  diag_frame1$n_routine[n_run]=nrow(coverage_datasets_routine[[n_run]])
}
diag_frame1

check_matrix1=check_matrix2=array(TRUE,dim=c(n_scn,n_scn))
for(i in 1:n_scn){
  for(j in 1:n_scn){
    if(i!=j){
      check_matrix1[i,j]=check_matrix1[i,j]=all(diag_frame1$n_campaign[i]==diag_frame1$n_campaign[j])
      check_matrix2[i,j]=check_matrix2[j,i]=all(diag_frame1$n_routine[i]==diag_frame1$n_routine[j])
    }
  }
}


