path = getwd() #Path = repository folder
setwd(path)
results_folder=paste0(path,"/shared/2026 tests with fixed reported vaccination effectiveness")
library(vimpact)

id0 = "20260727-142808-b6704d66"
id1 = "20260727-142809-f3ea2d7f"
id2 = "20260727-142811-202104ac"

burden_outcome = "deaths"
archive_folder = paste0(path,"/archive/02b_burden_central_estimate")
prefix = "central_estimates_2026_alt_vacc_eff_test_"
results0 = read.csv(paste0(archive_folder,"/",id0,"/",prefix,"01_novacc.csv"),header = TRUE)
results1 = read.csv(paste0(archive_folder,"/",id1,"/",prefix,"02_default_routine.csv"),header = TRUE)
results2 = read.csv(paste0(archive_folder,"/",id2,"/",prefix,"03_default_routine_campaign.csv"),
                    header = TRUE)
nrows = nrow(results0)
countries = unique(results0$country)
n_countries = length(countries)
years = c(2024:2100)
n_years = length(years)
nrows2 = n_years*n_countries

res_novax = data.frame(country = results0$country, year = results0$year, age = results0$age,
                       value = results0[[burden_outcome]], activity_type = rep("novax", nrows),
                       burden_outcome = rep(burden_outcome,nrows))
#res_novax = subset(res_novax, year %in% years)
res_r = data.frame(country = results1$country, year = results1$year, age = results1$age,
                   value = results1[[burden_outcome]], activity_type = rep("routine", nrows),
                   burden_outcome = rep(burden_outcome,nrows))
#res_r = subset(res_r, year %in% years)
res_r_c = data.frame(country = results2$country, year = results2$year, age = results2$age,
                     value = results2[[burden_outcome]], activity_type = rep("campaign", nrows),
                     burden_outcome = rep(burden_outcome,nrows))
#res_r_c = subset(res_r_c, year %in% years)

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

#impact_r = impact_by_year_of_vaccination_activity_type(baseline_burden = res_novax,
impact_r = impact_by_year_of_vaccination_birth_cohort(baseline_burden = res_novax,
                                                      focal_burden = res_r,
                                                      fvps = fvps_routine,
                                                      vaccination_years = years)
impact_r$impact_ratio=impact_r$impact/impact_r$fvps
write.csv(impact_r, row.names = FALSE, file = paste0(results_folder,"/impact_r.csv"))

#impact_r_c = impact_by_year_of_vaccination_activity_type(baseline_burden = res_novax,
impact_r_c = impact_by_year_of_vaccination_birth_cohort(baseline_burden = res_novax,
                                                        focal_burden = res_r_c,
                                                        fvps = fvps_r_campaign,
                                                        vaccination_years = years)
impact_r_c$impact_ratio=impact_r_c$impact/impact_r_c$fvps
write.csv(impact_r_c, row.names = FALSE, file = paste0(results_folder,"/impact_r_c.csv"))
