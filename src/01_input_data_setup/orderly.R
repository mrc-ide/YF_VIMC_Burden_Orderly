orderly2::orderly_parameters(vacc_data_file = "",pop_data_file = "",country_list_file = "",
                             FOI_R0_median_data_regions_file = "",FOI_R0_data_regions_file = NULL,
                             vaccine_efficacy_median = 1.0,vaccine_efficacy_data_file = NULL,
                             p_severe_inf_median = 0.12,p_death_severe_inf_median = 0.39,cfr_data_file = NULL,
                             input_data_regions_file = "")
orderly2::orderly_artefact("country input data", "input_data_countries.Rds" )
orderly2::orderly_artefact("FOI and R0 median values", "FOI_R0_med_countries.Rds" )
orderly2::orderly_artefact("FOI and R0 values", "FOI_R0_countries.Rds" )
orderly2::orderly_artefact("vaccine efficacy median value", "vaccine_efficacy_med.Rds" )
orderly2::orderly_artefact("vaccine efficacy values", "vaccine_efficacy.Rds" )
orderly2::orderly_artefact("severe infection rate median value","p_severe_inf_median.Rds")
orderly2::orderly_artefact("severe infection death rate median value","p_death_severe_inf_median.Rds")
orderly2::orderly_artefact("Severe infection rate and severe infection death rate values values", "cfr.Rds" )

#Read in files------------------------------------------------------------------
vacc_data = read.csv(file = vacc_data_file)
pop_data = readRDS(file = pop_data_file)
countries_select = read.csv(file = country_list_file,header = TRUE)$country
FOI_R0_median_data_regions = readRDS(file = FOI_R0_median_data_regions_file)
input_data_regions = readRDS(file = input_data_regions_file)
FOI_R0_data_regions = readRDS(file = FOI_R0_data_regions_file)
vacc_eff_values = readRDS(file = vaccine_efficacy_data_file)
cfr_values = readRDS(file = cfr_data_file)

#TODO - Add more assert_that checks?
region_countries = substr(FOI_R0_median_data_regions$region,1,3)
assertthat::assert_that(all(countries_select %in% unique(region_countries)))
regions = input_data_regions$region_labels
n_regions = length(regions)
assertthat::assert_that(all(FOI_R0_median_data_regions$region == regions))
n_countries = length(countries_select)
if(is.null(FOI_R0_data_regions) == FALSE){
  assertthat::assert_that(all(unique(FOI_R0_data_regions$region) == regions))
  n_param_sets = nrow(FOI_R0_data_regions)/n_regions
  assertthat::assert_that(length(vacc_eff_values) == n_param_sets)
} else {n_param_sets = 0}

#TODO - Add options for these to be non-fixed?
N_age = 101
years_data = c(1940:2100) #Ideally want 2101 to get output for 2100, but need pop data for 2101
assertthat::assert_that(all(years_data %in% pop_data$year))

assertthat::assert_that(all(countries_select %in% unique(pop_data$country_code))) #All selected countries must be in pop data
n_countries = length(countries_select)
pop_data_select = subset(pop_data,country_code %in% countries_select)
vacc_data_select = subset(vacc_data,country_code %in% countries_select)

#Account for any selected countries not included in vaccination data (because no vaccination included in them)
if(any(countries_select %in% unique(vacc_data_select$country_code) == FALSE)){
  countries_missing = countries_select[countries_select %in% unique(vacc_data_select$country_code) == FALSE]
  n_countries_to_add = length(countries_missing)
  for(i in 1:n_countries_to_add){
    add_vacc_data = vacc_data_select[1,]
    add_vacc_data$country_code = add_vacc_data$country = countries_missing[i]
    add_vacc_data$activity_type = "dummy"
    add_vacc_data$year = years_data[1]
    add_vacc_data$target = 0
    add_vacc_data$coverage = 0
    vacc_data_select = rbind(vacc_data_select,add_vacc_data)
  }
  vacc_data_select = vacc_data_select[order(vacc_data_select$country_code),]
}

#Convert population and vaccination data into arrays and create YEP input data in standard format 
pop_data_array = convert_pop_data(pop_data_select,year_begin = years_data[1],year_end = max(years_data),N_age = N_age)
vacc_data_array = convert_vacc_data(vacc_data_select,year_begin = years_data[1],year_end = max(years_data),N_age = N_age)
saveRDS(list(region_labels = countries_select,years_labels = years_data,age_labels = c(0:(N_age-1)),
             vacc_data = vacc_data_array,pop_data = pop_data_array),
        file = "input_data_countries.Rds")

#Get country epi data-----------------------------------------------------------
n_years = length(input_data_regions$years_labels)
FOI_R0_med_data_countries = data.frame(country = countries_select,FOI_med = rep(0,n_countries),R0_med = rep(0,n_countries))
if(n_param_sets>0){
  FOI_R0_data_countries = list(country = countries_select,FOI = array(NA,dim = c(n_countries,n_param_sets)),
                             R0 = array(NA,dim = c(n_countries,n_param_sets)))
}
for(n_c in c(1:n_countries)){
  regions_country = regions[region_countries == countries_select[n_c]]
  n_regions_country = length(regions_country)
  
  #Population fraction by region to calculate weighted average of FOI/R0
  pop_total_by_region = rowSums(input_data_regions$pop_data[regions %in% regions_country,n_years,],2)
  pop_country = sum(pop_total_by_region)
  pop_fraction_by_region = pop_total_by_region/pop_country
  
  #Central estimate data
  FOI_R0_med_data_subset_country = subset(FOI_R0_median_data_regions,region %in% regions_country)
  FOI_R0_med_data_countries$FOI_med[n_c] = sum(FOI_R0_med_data_subset_country$FOI_med*pop_fraction_by_region)
  FOI_R0_med_data_countries$R0_med[n_c] = sum(FOI_R0_med_data_subset_country$R0_med*pop_fraction_by_region)
  
  #Stochastic data (if required)
  if(n_param_sets>0){
    FOI_R0_data_subset_country = subset(FOI_R0_data_regions,region %in% regions_country)
    for(n_set in 1:n_param_sets){
      lines = c(1:n_regions_country)+((n_set-1)*n_regions_country)
      FOI_R0_data_countries$FOI[n_c,n_set] = sum(FOI_R0_data_subset_country$FOI[lines]*pop_fraction_by_region)
      FOI_R0_data_countries$R0[n_c,n_set] = sum(FOI_R0_data_subset_country$R0[lines]*pop_fraction_by_region)
    }
  }
}

#Save epi and additional data---------------------------------------------------
saveRDS(FOI_R0_med_data_countries,file = "FOI_R0_med_countries.Rds")
saveRDS(list(vaccine_efficacy_median = vaccine_efficacy_median),file = "vaccine_efficacy_med.Rds")
saveRDS(list(p_severe_inf_median = p_severe_inf_median), file = "p_severe_inf_median.Rds")
saveRDS(list(p_death_severe_inf_median = p_death_severe_inf_median), file = "p_death_severe_inf_median.Rds")
if(n_param_sets>0){
  saveRDS(FOI_R0_data_countries,file = "FOI_R0_countries.Rds")
  saveRDS(list(vaccine_efficacy = vacc_eff_values),file = "vaccine_efficacy.Rds")
  saveRDS(data.frame(p_severe_inf = cfr_values$P_severe, p_death_severe_inf = cfr_values$P_severeDeath),file = "cfr.Rds")
}