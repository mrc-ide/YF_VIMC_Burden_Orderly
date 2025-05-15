comp="C:/Users/kjfras16"
#comp="C:/Users/Work_KJF82"
FOI_R0_data_regions=readRDS(file=paste(comp,"Documents/0 - Yellow fever model MCMC results/Model runs 2022-10/",
                                       "Run2022_10_C_case_sero_272regions_newCFR/FOI_R0_summary_734regions.Rds",sep="/"))
FOI_R0_data_regions$country=substr(FOI_R0_data_regions$region,1,3)
input_data_regions=readRDS(file=paste(comp,"Documents/00 - Big data files to back up infrequently",
                                      "00 - YellowFeverDynamics key datasets/input_data_734_regions_burden.Rds",sep="/"))
regions=input_data_regions$region_labels
n_years=length(input_data_regions$years_labels)
input_data_countries=readRDS(file="exdata/input_data_36countries_preventive-default_nocovid.Rds")
countries=input_data_countries$region_labels
n_countries=length(countries)
assertthat::assert_that(all(countries %in% FOI_R0_data_regions$country))

FOI_R0_data_country=data.frame(region=countries,FOI_med=rep(0,n_countries),R0_med=rep(0,n_countries))
for(n_c in c(1:n_countries)){
  FOI_R0_data_subset_country=subset(FOI_R0_data_regions,FOI_R0_data_regions$country==countries[n_c])
  regions_country=FOI_R0_data_subset_country$region
  pop_total_by_region=rowSums(input_data_regions$pop_data[regions %in% regions_country,n_years,],2)
  pop_country=sum(pop_total_by_region)
  pop_fraction_by_region=pop_total_by_region/pop_country
  FOI_R0_data_country$FOI_med[n_c]=sum(FOI_R0_data_subset_country$FOI_med*pop_fraction_by_region)
  FOI_R0_data_country$R0_med[n_c]=sum(FOI_R0_data_subset_country$R0_med*pop_fraction_by_region)
}
saveRDS(FOI_R0_data_country,file="exdata/FOI_R0_med_country.Rds")