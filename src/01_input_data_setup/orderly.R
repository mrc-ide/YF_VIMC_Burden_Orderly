orderly2::orderly_parameters(vacc_data_file="",pop_data_file="",country_list_file="")#,suffix="")
orderly2::orderly_shared_resource("countries_all.csv"=country_list_file)
orderly2::orderly_artefact("country input data", "input_data_countries.Rds" )

vacc_data=read.csv(file=vacc_data_file)
pop_data=readRDS(file=pop_data_file)

#TODO - Add options for these to be non-fixed?
N_age=101
years_data=c(1940:2100)

countries_select=read.csv(file="countries_all.csv",header=TRUE)$country
assert_that(all(countries_select %in% unique(pop_data$country_code))) #All selected countries must be in population data
n_countries=length(countries_select)
pop_data_select=subset(pop_data,country_code %in% countries_select)
vacc_data_select=subset(vacc_data,country_code %in% countries_select)

#Account for any selected countries not included in vaccination data (because no vaccination included in them)
if(any(countries_select %in% unique(vacc_data_select$country_code)==FALSE)){
  countries_missing=countries_select[countries_select %in% unique(vacc_data_select$country_code) == FALSE]
  n_countries_to_add=length(countries_missing)
  for(i in 1:n_countries_to_add){
    add_vacc_data=vacc_data_select[1,]
    add_vacc_data$country_code=add_vacc_data$country=countries_missing[i]
    add_vacc_data$activity_type="dummy"
    add_vacc_data$year=years_data[1]
    add_vacc_data$target=0
    add_vacc_data$coverage=0
    vacc_data_select=rbind(vacc_data_select,add_vacc_data)
  }
  vacc_data_select=vacc_data_select[order(vacc_data_select$country_code),]
}

#Convert population and vaccination data into arrays and create YEP input data in standard format 
pop_data_array=convert_pop_data(pop_data_select,year_begin=years_data[1],year_end=max(years_data),N_age=N_age)
vacc_data_array=convert_vacc_data(vacc_data_select,year_begin=years_data[1],year_end=max(years_data),N_age=N_age)
input_data=list(region_labels=countries_select,years_labels=years_data,age_labels=c(0:(N_age-1)),
                vacc_data=vacc_data_array,pop_data=pop_data_array)
saveRDS(input_data,file=paste0("input_data_countries.Rds"))
#saveRDS(input_data,file=paste0("input_data_countries_",suffix,".Rds"))
