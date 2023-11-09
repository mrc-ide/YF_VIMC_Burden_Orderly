path=getwd()
source("R/conversion_functions.R")
pop_data_file = paste0(path, "/shared/2023_burden_pop_data_1940_2101_36countries.Rds")
pop_data = readRDS(file = pop_data_file)
pop_data_array = convert_pop_data(pop_data,year_begin = 2000,year_end = 2100,N_age = 101)
pop_data_vector=rep(NA,367236)
i=0
for(n_c in 1:36){
  for(n_y in 1:101){
    for(n_a in 1:101){
      i=i+1
      pop_data_vector[i]=pop_data_array[n_c,n_y,n_a]
    }
  }
}

scenario_prefix="202310gavi-3_yf-"
scenarios = c("routine-default","no-vaccination","routine-bluesky","routine-campaign-bluesky",
              "routine-campaign-default","routine-ia2030","routine-campaign-ia2030")
results_data_files=rep("",length(scenarios))
for(n_run in 1:length(scenarios)){
  results_data_files[n_run] = paste0(path, "/shared/2023 Results/central_estimates_",scenario_prefix, scenarios[n_run], ".csv")
  assertthat::assert_that(file.exists(results_data_files[n_run]))
  results_data=read.csv(results_data_files[n_run],header=TRUE)
  results_data$cohort_size=pop_data_vector
  write.csv(results_data,file=results_data_files[n_run],row.names=FALSE)
}