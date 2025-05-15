library(YEP)
path = getwd() #Path = repository folder
source(paste0(path, "/R/conversion_functions.R")) #Functions for converting population and vaccination data from GAVI format to format used by YEP

#Initialize---------------------------------------------------------------------
orderly2::orderly_init(path) 

#Create designations for each scenario------------------------------------------
scenarios=c("preventive-default_update_catchup")
#scenarios = c("no-vaccination", "preventive-default_nocovid", "preventive-default_update", "preventive-default_update_catchup")
input_data_ids = vacc_data_files = rep("", length(scenarios))
for(n_run in 1:length(scenarios)){
  vacc_data_files[n_run] = paste0(path, "/shared/coverage_202210covidimpact-2_yf-", scenarios[n_run], ".csv")
}

#Set up input data - population/vaccination data converted from GAVI population and coverage data
#FOI/R0 values calculated for each selected country from regional values, vaccine efficacy values loaded
#Median values for central estimates and sets of values for stochastic calculations supplied
pop_data_file = paste0(path, "/shared/202210covidimpact-2_dds-202208_int_pop_both.Rds") #NB Only goes to 2100 - ideally want to 2101
country_list_file = paste0(path, "/shared/countries_all.csv")
FOI_R0_median_data_regions_file = paste0(path, "/shared/FOI_R0_median_734regions.Rds")
FOI_R0_data_regions_file = paste0(path, "/shared/FOI_R0_200_datasets_734regions.Rds")
vaccine_efficacy_median = 0.9829146
vaccine_efficacy_data_file = paste0(path, "/shared/vacc_eff_200_values.Rds")
p_severe_inf_median = 0.12
p_death_severe_inf_median = 0.39
cfr_data_file = paste0(path, "/shared/P_severe_severeDeath.RDS")
input_data_regions_file = paste0(path, "/shared/input_data_734_regions_burden.Rds")
for(n_run in 1:length(scenarios)){
  input_data_ids[n_run] = orderly2::orderly_run("input_data_setup", 
  list(vacc_data_file = vacc_data_files[n_run], pop_data_file = pop_data_file, country_list_file = country_list_file, 
  FOI_R0_median_data_regions_file = FOI_R0_median_data_regions_file, FOI_R0_data_regions_file = FOI_R0_data_regions_file, 
  vaccine_efficacy_median = vaccine_efficacy_median, vaccine_efficacy_data_file = vaccine_efficacy_data_file, 
  cfr_data_file = cfr_data_file, p_severe_inf_median = p_severe_inf_median, p_death_severe_inf_median = p_death_severe_inf_median, 
  input_data_regions_file = input_data_regions_file))
}
write.csv(data.frame(scenario = scenarios, id = input_data_ids), "shared/input_data_list.csv", row.names = FALSE)
input_data_ids = read.csv("shared/input_data_list.csv", header = TRUE)$id

#Run burden central estimate (median FOI, R0 and vaccine efficacy values), optionally for a subset of countries
countries_to_run_file = paste0(path, "/shared/countries_select.csv")
central_estimate_ids = rep("", 4)
time1 = Sys.time()
for(n_run in 1:length(scenarios)){
  central_estimate_ids[n_run] = orderly2::orderly_run("burden_central_estimate", 
  list(life_exp_file = "gavi_life_expectancy.csv", countries_to_run_file = countries_to_run_file, input_id = input_data_ids[n_run], 
  YLD_per_case = 0.006486, n_reps = 1))
}
time2 = Sys.time()
time_ce = as.numeric(time2-time1)
write.csv(data.frame(scenario = scenarios, id = central_estimate_ids), "shared/output_list1_central_estimates.csv", 
          row.names = FALSE)

#Run stochastic burden calculations using all parameter sets (containing individual FOI, R0 and vaccine efficacy values), optionally for a subset of countries
countries_to_run_file = paste0(path, "/shared/countries_select.csv")
stochastic_ids = rep("", 4)
time1 = Sys.time()
for(n_run in 1:length(scenarios)){
  stochastic_ids[n_run] = orderly2::orderly_run("burden_stochastic", 
  list(life_exp_file = "gavi_life_expectancy.csv", countries_to_run_file = countries_to_run_file, input_id = input_data_ids[n_run], 
  YLD_per_case = 0.006486, n_reps = 1, flag_cluster = FALSE))
}
time2 = Sys.time()
time_sto = as.numeric(time2-time1)
write.csv(data.frame(scenario = scenarios, id = stochastic_ids), "shared/output_list2_stochastic.csv", row.names = FALSE)

#Checking which results folder is for which scenario using metadata
#orderly2::orderly_metadata(dir("archive/01_input_data_setup")[1])$parameters$vacc_data_file