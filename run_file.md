library(YEP)
path=getwd() #Path = repository folder
source(paste0(path,"/R/conversion_functions.R")) #Functions for converting population and vaccination data from GAVI format to format used by YEP

#Initialize---------------------------------------------------------------------
orderly2::orderly_init(path) 

#Create designations for each scenario------------------------------------------
input_data_ids=vacc_data_files=rep("",4)
scenarios=c("no-vaccination","preventive-default_nocovid","preventive-default_update","preventive-default_update_catchup")
for(n_run in 1:length(scenarios)){
  vacc_data_files[n_run]=paste0(path,"/shared/coverage_202210covidimpact-2_yf-",scenarios[n_run],".csv")
  # dirname=paste0(path,"/outputs/",scenarios[n_run])
  # if(file.exists(dirname)==FALSE){dir.create(dirname)}
}

#Set up input datasets containing population/vaccination data using GAVI population and coverage data
pop_data_file=paste(path,"shared/202210covidimpact-2_dds-202208_int_pop_both.Rds",sep="/")
country_list_file="countries_all.csv"
for(n_run in 1:length(scenarios)){
  input_data_ids[n_run]=orderly2::orderly_run("01_input_data_setup",
  list(vacc_data_file=vacc_data_files[n_run],pop_data_file=pop_data_file,country_list_file=country_list_file))
}
#write.csv(data.frame(scenario=scenarios,id=input_data_ids),"shared/input_data_list.csv")

#Calculate FOI/R0 values for each selected country from regional values, and load vaccine efficacy values
#Median values for central estimates and sets of values for stochastic calculations supplied
epi_data_id = orderly2::orderly_run("02_get_epi_parameters",
  list(FOI_R0_median_data_regions_file="FOI_R0_summary_734regions.Rds",
  FOI_R0_data_regions_file="FOI_R0_2_datasets_734regions.Rds",
  vaccine_efficacy_median=0.9824007,vaccine_efficacy_data_file="vacc_eff_2_values.Rds",
  input_data_regions_file=paste0(path,"/shared/input_data_734_regions_burden.Rds")))
  
#Run burden central estimate (median FOI, R0 and vaccine efficacy values), optionally for a subset of countries
central_estimate_ids=rep("",4)
for(n_run in 1:length(scenarios)){
  central_estimate_ids[n_run]=orderly2::orderly_run("03_burden_central_estimate",
  list(life_exp_file="gavi_life_expectancy.csv",country_list_file="countries_select.csv",input_id=input_data_ids[n_run],
  p_severe_inf=0.12,p_death_severe_inf=0.39,YLD_per_case=0.006486,n_reps=1))
}
#write.csv(data.frame(scenario=scenarios,id=central_estimate_ids),"shared/output_list1_central_estimates.csv")

#Run stochastic burden calculations using all parameter sets (containing individual FOI, R0 and vaccine efficacy values), optionally for a subset of countries
stochastic_ids=rep("",4)
for(n_run in 1:length(scenarios)){
  stochastic_ids[n_run]=orderly2::orderly_run("04_burden_stochastic",
  list(life_exp_file="gavi_life_expectancy.csv",country_list_file="countries_select.csv",input_id=input_data_ids[n_run],
  p_severe_inf=0.12,p_death_severe_inf=0.39,YLD_per_case=0.006486,n_reps=1,flag_cluster=FALSE))
}
#write.csv(data.frame(scenario=scenarios,id=stochastic_ids),"shared/output_list2_stochastic.csv")

#Checking which results folder is for which scenario using metadata
#orderly2::orderly_metadata(dir("archive/01_input_data_setup")[1])$parameters$vacc_data_file