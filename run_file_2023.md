#Run code for 2023 burden calculations

library(YEP)
path = getwd() #Path = repository folder
source(paste0(path, "/R/additional_functions.R"))
source(paste0(path, "/R/conversion_functions.R")) #Functions for converting population and vaccination data from GAVI format to format used by YEP

#Initialize---------------------------------------------------------------------
orderly2::orderly_init(path) 

#Create designations for each scenario------------------------------------------
scenario_prefix="202310gavi-3_yf-"
# scenarios = c("routine-default","no-vaccination","routine-bluesky","routine-campaign-bluesky",
#               "routine-campaign-default","routine-ia2030","routine-campaign-ia2030")
scenarios = c("routine-default")
input_data_ids = vacc_data_files = rep("", length(scenarios))
for(n_run in 1:length(scenarios)){
  vacc_data_files[n_run] = paste0(path, "/shared/coverage_",scenario_prefix, scenarios[n_run], ".csv")
  assertthat::assert_that(file.exists(vacc_data_files[n_run]))
}

#Set up input data - population/vaccination data converted from GAVI population and coverage data
#FOI/R0 values calculated for each selected country from regional values, vaccine efficacy values loaded
#Median values for central estimates and sets of values for stochastic calculations supplied
for(n_run in 1:length(scenarios)){
  input_data_ids[n_run] = orderly2::orderly_run("01_input_data_setup", 
  list(scenario_name = paste0(scenario_prefix,scenarios[n_run]),
  vacc_data_file = vacc_data_files[n_run], 
  pop_data_file = paste0(path, "/shared/2023_burden_pop_data_1940_2101_36countries.Rds"), 
  country_list_file = paste0(path, "/shared/countries_all.csv"), 
  FOI_R0_median_data_regions_file = paste0(path, "/shared/FOI_R0_median_734regions.Rds"), 
  FOI_R0_data_regions_file = paste0(path, "/shared/FOI_R0_200_datasets_734regions.Rds"), 
  vaccine_efficacy_median = 0.6078878, 
  vaccine_efficacy_data_file = paste0(path, "/shared/vacc_eff_200_values.Rds"), 
  cfr_data_file = paste0(path, "/shared/P_severe_severeDeath_new.RDS"), 
  p_severe_inf_median = 0.12, 
  p_death_severe_inf_median = 0.39, 
  input_data_regions_file = paste0(path, "/shared/input_data_734_regions_burden.Rds")))
}
write.csv(data.frame(scenario = scenarios, id = input_data_ids), "shared/input_data_list.csv", row.names = FALSE)
input_data_ids = read.csv("shared/input_data_list.csv", header = TRUE)$id

#Run burden central estimate (median FOI, R0 and vaccine efficacy values), optionally for a subset of countries
central_estimate_ids = rep("", length(scenarios))
time1 = Sys.time()
for(n_run in 1:length(scenarios)){
  central_estimate_ids[n_run] = orderly2::orderly_run("02_burden_central_estimate", 
  list(life_exp_file = "gavi_life_expectancy.csv", 
  countries_to_run_file = paste0(path, "/shared/countries_all.csv"), 
  input_id = input_data_ids[n_run], 
  YLD_per_case = 0.006486, 
  n_reps = 1,
  mode_parallel = "clusterMap", 
  n_cores=4))
}
time2 = Sys.time()
time_ce = as.numeric(time2-time1)
write.csv(data.frame(scenario = scenarios, id = central_estimate_ids), "shared/output_list1_central_estimates.csv", 
          row.names = FALSE)

#Run stochastic burden calculations using all parameter sets (containing individual FOI, R0 and vaccine efficacy values), optionally for a subset of countries
stochastic_ids = rep("", length(scenarios))
time1 = Sys.time()
for(n_run in 1:length(scenarios)){
  stochastic_ids[n_run] = orderly2::orderly_run("03_burden_stochastic", 
  list(life_exp_file = "gavi_life_expectancy.csv", 
  countries_to_run_file = paste0(path, "/shared/countries_all.csv"), 
  input_id = input_data_ids[n_run], 
  YLD_per_case = 0.006486, 
  n_reps = 1, 
  flag_cluster = FALSE))
}
time2 = Sys.time()
time_sto = as.numeric(time2-time1)
write.csv(data.frame(scenario = scenarios, id = stochastic_ids), "shared/output_list2_stochastic.csv", row.names = FALSE)

#Checking which results folder is for which scenario using metadata
#orderly2::orderly_metadata(dir("archive/01_input_data_setup")[1])$parameters$vacc_data_file