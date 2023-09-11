
orderly2::orderly_parameters(FOI_R0_median_data_regions_file="",FOI_R0_data_regions_file="",
                             vaccine_efficacy_median=1.0,vaccine_efficacy_data_file="",input_data_regions_file="")
orderly2::orderly_dependency(name="01_input_data_setup", query="latest",files="input_data_countries.Rds")
orderly2::orderly_shared_resource("FOI_R0_median_regions.Rds"=FOI_R0_median_data_regions_file,
                                  "FOI_R0_regions.Rds"=FOI_R0_data_regions_file,
                                  "vaccine_efficacy.Rds"=vaccine_efficacy_data_file)
orderly2::orderly_artefact("FOI and R0 median values", "FOI_R0_med_countries.Rds" )
orderly2::orderly_artefact("FOI and R0 values", "FOI_R0_countries.Rds" )
orderly2::orderly_artefact("vaccine efficacy median value", "vaccine_efficacy_med.Rds" )
orderly2::orderly_artefact("vaccine efficacy values", "vaccine_efficacy.Rds" )

FOI_R0_median_data_regions=readRDS(file="FOI_R0_median_regions.Rds")
region_countries=substr(FOI_R0_median_data_regions$region,1,3)
input_data_regions=readRDS(file=input_data_regions_file)
regions=input_data_regions$region_labels
n_regions=length(regions)
assertthat::assert_that(all(FOI_R0_median_data_regions$region==regions))

n_years=length(input_data_regions$years_labels)
input_data_countries=readRDS(file="input_data_countries.Rds")
countries=input_data_countries$region_labels
n_countries=length(countries)

FOI_R0_data_regions=readRDS(file="FOI_R0_regions.Rds")
assertthat::assert_that(all(unique(FOI_R0_data_regions$region)==regions))
n_param_sets=nrow(FOI_R0_data_regions)/n_regions
vacc_eff_values=readRDS(file="vaccine_efficacy.Rds")
assertthat::assert_that(length(vacc_eff_values)==n_param_sets)

FOI_R0_med_data_countries=data.frame(country=countries,FOI_med=rep(0,n_countries),R0_med=rep(0,n_countries))
FOI_R0_data_countries=list(country=countries,FOI=array(NA,dim=c(n_countries,n_param_sets)),
                           R0=array(NA,dim=c(n_countries,n_param_sets)))
for(n_c in c(1:n_countries)){
  regions_country=regions[region_countries==countries[n_c]]
  n_regions_country=length(regions_country)
  FOI_R0_med_data_subset_country=subset(FOI_R0_median_data_regions,region %in% regions_country)
  FOI_R0_data_subset_country=subset(FOI_R0_data_regions,region %in% regions_country)
  pop_total_by_region=rowSums(input_data_regions$pop_data[regions %in% regions_country,n_years,],2)
  pop_country=sum(pop_total_by_region)
  pop_fraction_by_region=pop_total_by_region/pop_country
  FOI_R0_med_data_countries$FOI_med[n_c]=sum(FOI_R0_med_data_subset_country$FOI_med*pop_fraction_by_region)
  FOI_R0_med_data_countries$R0_med[n_c]=sum(FOI_R0_med_data_subset_country$R0_med*pop_fraction_by_region)
  for(n_set in 1:n_param_sets){
    lines=c(1:n_regions_country)+((n_set-1)*n_regions_country)
    FOI_R0_data_countries$FOI[n_c,n_set]=sum(FOI_R0_data_subset_country$FOI[lines]*pop_fraction_by_region)
    FOI_R0_data_countries$R0[n_c,n_set]=sum(FOI_R0_data_subset_country$R0[lines]*pop_fraction_by_region)
  }
}
saveRDS(FOI_R0_med_data_countries,file="FOI_R0_med_countries.Rds")
saveRDS(FOI_R0_data_countries,file="FOI_R0_countries.Rds")

saveRDS(list(vaccine_efficacy_median=vaccine_efficacy_median),file="vaccine_efficacy_med.Rds")