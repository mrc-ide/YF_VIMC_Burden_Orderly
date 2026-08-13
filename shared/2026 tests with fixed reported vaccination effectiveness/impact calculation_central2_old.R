path = getwd() #Path = repository folder
setwd(path)
results_folder=paste0(path,"/shared/2026 tests with fixed reported vaccination effectiveness")
library(vimpact)

burden_outcome = "deaths"
archive_folder = paste0(path,"/shared/2026 updates (3 scenarios)")
prefix = "central_estimates_2026_updates_"
results0 = read.csv(paste0(archive_folder,"/",prefix,"01_novacc.csv"),header = TRUE)
results1 = read.csv(paste0(archive_folder,"/",prefix,"02_default_routine.csv"),header = TRUE)
results2 = read.csv(paste0(archive_folder,"/",prefix,"03_default_routine_campaign.csv"),
                    header = TRUE)
#countries = unique(results0$country)
countries=c("ETH","NGA")
results0=subset(results0,country %in% countries)
results1=subset(results1,country %in% countries)
results2=subset(results2,country %in% countries)
nrows = nrow(results0)
n_countries = length(countries)
years = c(2024:2100)
n_years = length(years)
nrows2 = n_years*n_countries

res_novax_old = data.frame(country = results0$country, year = results0$year, age = results0$age,
                           value = results0[[burden_outcome]], activity_type = rep("novax", nrows),
                           burden_outcome = rep(burden_outcome,nrows))
#res_novax_old = subset(res_novax_old, year %in% years)
res_r_old = data.frame(country = results1$country, year = results1$year, age = results1$age,
                       value = results1[[burden_outcome]], activity_type = rep("routine", nrows),
                       burden_outcome = rep(burden_outcome,nrows))
#res_r_old = subset(res_r_old, year %in% years)
res_r_c_old = data.frame(country = results2$country, year = results2$year, age = results2$age,
                         value = results2[[burden_outcome]], activity_type = rep("campaign", nrows),
                         burden_outcome = rep(burden_outcome,nrows))
#res_r_c_old = subset(res_r_c_old, year %in% years)

fvps_data= readRDS(file = paste0(path,"/shared/2026 tests with fixed reported ",
                                 "vaccination effectiveness/fvps.rds"))
fvps_data = subset(fvps_data,country %in% countries)
fvps_novaxx = subset(fvps_data,scenario=="yf-no-vaccination") #8417
fvps_routine = subset(fvps_data,scenario=="yf-routine-default") #11762
fvps_r_campaign = subset(fvps_data,scenario=="yf-routine-campaign-default") #15210

fvps_routine = subset(fvps_routine,coverage_set!="YF:YF,campaign,none:default") #3345
fvps_routine$age=fvps_routine$age_from

fvps_r_campaign = subset(fvps_r_campaign,coverage_set!="YF:YF,campaign,none:default") #6793
fvps_r_campaign$activity_type = "campaign" #change all activity types to campaign to combine
fvps_r_campaign$age=fvps_r_campaign$age_from

#impact_r_old = impact_by_year_of_vaccination_activity_type(baseline_burden = res_novax_old,
impact_r_old = impact_by_year_of_vaccination_birth_cohort(baseline_burden = res_novax_old,
                                                          focal_burden = res_r_old,
                                                          fvps = fvps_routine,
                                                          vaccination_years = years)
impact_r_old$impact_ratio=impact_r_old$impact/impact_r_old$fvps
write.csv(impact_r_old, row.names = FALSE, file = paste0(results_folder,"/impact_r_old.csv"))

#impact_r_c_old = impact_by_year_of_vaccination_activity_type(baseline_burden = res_novax_old,
impact_r_c_old = impact_by_year_of_vaccination_birth_cohort(baseline_burden = res_novax_old,
                                                            focal_burden = res_r_c_old,
                                                            fvps = fvps_r_campaign,
                                                            vaccination_years = years)
impact_r_c_old$impact_ratio=impact_r_c_old$impact/impact_r_c_old$fvps
write.csv(impact_r_c_old, row.names = FALSE, file = paste0(results_folder,"/impact_r_c_old.csv"))

