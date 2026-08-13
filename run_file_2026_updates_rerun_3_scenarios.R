#Run code for 2023 burden calculations again with edited/alternative inputs
#Uses old version of orderly (orderly2) and YEP (branch Frozen_Model_2023_Paper&VIMC)

#Initialize
path = getwd() #Path = repository folder
setwd(path)

#Install old versions of YEP and orderly2
#install.packages("orderly2",repos = c("https://mrc-ide.r-universe.dev", "https://cloud.r-project.org"))
library(orderly2)
#orderly2::orderly_init(force=TRUE)
#pak::pak("mrc-ide/YEP@Version-0.2-milestone") 
library(YEP)
source(paste0(path, "/R/additional_functions.R"))
source(paste0(path, "/R/conversion_functions.R")) #Functions for converting population and vaccination data from GAVI format to format used by YEP

#Set up inputs
scenarios = paste0("2026_updates_",c("01_novacc","02_default_routine","03_default_routine_campaign"))
vacc_data_files = paste0(path,"/shared/",c("scenario-1-No vaccination.csv",
                                           "scenario-2-default-Routine.csv",
                                           "scenario-3-default-Routine and Campaign.csv"))
assertthat::assert_that(all(file.exists(vacc_data_files)))
pop_data_file = paste0(path,"/shared/2023_burden_pop_data_1940_2101_36countries.Rds")
country_list_reruns=sort(unique(readRDS(pop_data_file)$country_code))
country_list_file = paste0(path,"/shared/country_list_reruns.csv")
write.csv(data.frame(country=country_list_reruns),file=country_list_file,row.names=FALSE)
input_data_ids=rep("",length(scenarios))
for(n_scn in 1:length(scenarios)){
  input_data_ids[n_scn] = orderly2::orderly_run("01_input_data_setup", 
                                            list(scenario_name = scenarios[n_scn],
                                                 vacc_data_file = vacc_data_files[n_scn], 
                                                 pop_data_file = pop_data_file, 
                                                 country_list_file = country_list_file, 
                                                 FOI_R0_median_data_regions_file = paste0(path, "/shared/FOI_R0_median_734regions.Rds"), 
                                                 FOI_R0_data_regions_file = paste0(path, "/shared/FOI_R0_200_datasets_734regions.Rds"), 
                                                 vaccine_efficacy_median = 0.6078878, 
                                                 vaccine_efficacy_data_file = paste0(path, "/shared/vacc_eff_200_values.Rds"), 
                                                 cfr_data_file = paste0(path, "/shared/P_severe_severeDeath_new.RDS"), 
                                                 p_severe_inf_median = 0.12, 
                                                 p_death_severe_inf_median = 0.39, 
                                                 input_data_regions_file = paste0(path, "/shared/input_data_734_regions_burden.Rds")))
}

#Run burden central estimate (median FOI, R0 and vaccine efficacy values), 
for(n_scn in 1:length(scenarios)){
  central_estimate_id = orderly2::orderly_run("02b_burden_central_estimate", 
                                              list(life_exp_file = "gavi_life_expectancy.csv", 
                                                   countries_to_run_file = country_list_file, 
                                                   input_id = input_data_ids[n_scn], 
                                                   YLD_per_case = 0.006486, 
                                                   n_reps = 1,
                                                   mode_parallel = "none", 
                                                   n_cores=4))
}

#Run stochastic burden calculations 
for(n_scn in 1:length(scenarios)){
  stochastic_id = orderly2::orderly_run("03_burden_stochastic", 
                                        list(life_exp_file = "gavi_life_expectancy.csv", 
                                             countries_to_run_file = country_list_file, 
                                             input_id = input_data_ids[n_scn], 
                                             YLD_per_case = 0.006486, 
                                             n_reps = 1, 
                                             flag_cluster = FALSE))
}