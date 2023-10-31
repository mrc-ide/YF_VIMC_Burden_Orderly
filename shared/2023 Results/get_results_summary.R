source("R/data_processing_functions.R")
path=getwd()

scenario_prefix="202310gavi-3_yf-"
scenarios = c("routine-default","no-vaccination","routine-bluesky","routine-campaign-bluesky",
              "routine-campaign-default","routine-ia2030","routine-campaign-ia2030")
ce_data_files=rep("", length(scenarios))
for(n_run in 1:length(scenarios)){
  ce_data_files[n_run] = paste0(path, "/shared/2023 Results/central_estimates_",scenario_prefix, scenarios[n_run], ".csv")
  assertthat::assert_that(file.exists(ce_data_files[n_run]))
}

run_data=list()
for(n_run in 1:length(scenarios)){
  run_data[[n_run]]=get_key_values(read.csv(ce_data_files[n_run],header=TRUE))
  if(n_run==1){
    results_by_scenario_country=cbind(rep(scenarios[n_run],nrow(run_data[[n_run]]$results_by_country)),
                                      run_data[[n_run]]$results_by_country)
    results_by_scenario_country_year=cbind(rep(scenarios[n_run],nrow(run_data[[n_run]]$results_by_country_year)),
                                           run_data[[n_run]]$results_by_country_year)
  } else {
    results_by_scenario_country=rbind(results_by_scenario_country,
                                      cbind(rep(scenarios[n_run],nrow(run_data[[n_run]]$results_by_country)),
                                            run_data[[n_run]]$results_by_country))
    results_by_scenario_country_year=rbind(results_by_scenario_country_year,
                                           cbind(rep(scenarios[n_run],nrow(run_data[[n_run]]$results_by_country_year)),
                                                 run_data[[n_run]]$results_by_country_year))
  }
}
colnames(results_by_scenario_country)[1]=colnames(results_by_scenario_country_year)[1]="scenario"
write.csv(results_by_scenario_country,file=paste0(path, "/shared/2023 Results/central_estimates_summary_by_country.csv"),
          row.names=FALSE)
write.csv(results_by_scenario_country_year,file=paste0(path, "/shared/2023 Results/central_estimates_summary_by_country_year.csv"),
          row.names=FALSE)

countries=unique(results_by_scenario_country$country)
n_countries=length(countries)
matplot(x=c(1,n_countries),y=c(0,max(results_by_scenario_country$deaths)),xlab="Country",ylab="Deaths",xaxt="n")
axis(side=1,at=c(1:n_countries),labels=countries,cex.axis=0.3)
for(n_run in 1:length(scenarios)){
  
}
