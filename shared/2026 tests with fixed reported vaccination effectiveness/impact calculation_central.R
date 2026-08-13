path = getwd() #Path = repository folder
setwd(path)
library(vimpact)

# example_novax <- read.csv(system.file("extdata/example_novax_burden.csv", package = "vimpact"))
# example_routine <- read.csv(system.file("extdata/example_routine_burden.csv", package = "vimpact"))
# example_routine_campaign <- read.csv(system.file("extdata/example_routine_campaign_burden.csv", package = "vimpact"))

burden_outcome = "deaths"
results_folder = paste0(path,"/shared/2026 tests with fixed reported vaccination effectiveness")
results0 = read.csv(paste0(results_folder,"/central_estimates_2026_alt_vacc_eff_test_01_novacc.csv"),
                    header = TRUE)
results1 = read.csv(paste0(results_folder,"/central_estimates_2026_alt_vacc_eff_test_02_default_routine.csv"),
                    header = TRUE)
results2 = read.csv(paste0(results_folder,"/central_estimates_2026_alt_vacc_eff_test_03_default_routine_campaign.csv"),
                    header = TRUE)
nrows = nrow(results0)
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
write.csv(impact_routine, row.names = FALSE, file = paste0(results_folder,"/impact_routine.csv"))
write.csv(impact_routine_campaign, row.names = FALSE, file = paste0(results_folder,"/impact_routine_campaign.csv"))

