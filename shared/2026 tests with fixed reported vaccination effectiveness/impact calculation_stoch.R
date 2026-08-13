path = getwd() #Path = repository folder
setwd(path)
library(vimpact)

folder0 = paste0(path,"/archive/03_burden_stochastic/20260727-142927-9213e1b7")
folder1 = paste0(path,"/archive/03_burden_stochastic/20260727-143430-9fe42c82")
folder2 = paste0(path,"/archive/03_burden_stochastic/20260727-143853-0aab0d50")

burden_outcome = "deaths"
n_sets = 200
for(n in 1:n_sets){
  results0 = read.csv(paste0(folder0,"/burden_results_stochastic_2026_alt_vacc_eff_test_01_novacc_",n,".csv"),
                      header = TRUE)
  results1 = read.csv(paste0(folder1,"/burden_results_stochastic_2026_alt_vacc_eff_test_02_default_routine_",n,".csv"),
                      header = TRUE)
  results2 = read.csv(paste0(folder2,"/burden_results_stochastic_2026_alt_vacc_eff_test_03_default_routine_campaign_",
                             n,".csv"),
                      header = TRUE)
  if(n==1){
    nrows = nrow(results0) 
    n_pts = nrows/101
  }
  
  example_novax = data.frame(country = results0$country, year = results0$year, age = results0$age,
                             value = results0[[burden_outcome]], activity_type = rep("novax", nrows),
                             burden_outcome = rep(burden_outcome,nrows))
  example_routine = data.frame(country = results1$country, year = results1$year, age = results1$age,
                               value = results1[[burden_outcome]], activity_type = rep("routine", nrows),
                               burden_outcome = rep(burden_outcome,nrows))
  example_routine_campaign = data.frame(country = results2$country, year = results2$year, age = results2$age,
                                        value = results2[[burden_outcome]], activity_type = rep("campaign", nrows),
                                        burden_outcome = rep(burden_outcome,nrows))
  
  impact_routine <- impact_by_calendar_year(baseline_burden = example_novax, 
                                            focal_burden = example_routine)
  impact_routine_campaign <- impact_by_calendar_year(baseline_burden = example_novax, 
                                                     focal_burden = example_routine_campaign)
  impact_routine$set = impact_routine_campaign$set = rep(n, n_pts)
  if(n==1){
    impact_routine_all = impact_routine
    impact_routine_campaign_all = impact_routine_campaign
  } else {
    impact_routine_all = rbind(impact_routine_all,impact_routine)
    impact_routine_campaign_all = rbind(impact_routine_campaign_all,impact_routine_campaign)
  }
}

write.csv(impact_routine_all, row.names = FALSE, 
          file = paste0(results_folder,"/impact_routine_stoch.csv"))
write.csv(impact_routine_campaign_all, row.names=FALSE, 
          file = paste0(results_folder,"/impact_routine_campaign_stoch.csv"))
