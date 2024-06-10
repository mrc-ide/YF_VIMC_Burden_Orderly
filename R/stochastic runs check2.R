folder="archive/03_burden_stochastic"
subfolder1=dir(folder)[2]
subfolder2=dir(folder)[1]
subfolder3=dir(folder)[3]

n_runs=200
countries_select=c("ETH","SOM")
n_countries=length(countries_select)
year_min=2000
years_select=c(2020,2030)
n_end_years=length(years_select)

output_array=array(NA,dim=c(n_runs,n_countries,n_end_years,2),
                   dimnames=list(run=c(1:n_runs),country=countries_select,year_end=years_select,
                                 scenario=c("routine-default","routine-campaign-default")))

for(run_id in 1:n_runs){
  nv_data=readr::read_csv(paste0(folder,"/",subfolder1,"/burden_results_stochastic_202310gavi-3_yf-no-vaccination_",run_id,".csv"))
  rd_data=readr::read_csv(paste0(folder,"/",subfolder2,"/burden_results_stochastic_202310gavi-3_yf-routine-default_",run_id,".csv"))
  rdc_data=readr::read_csv(paste0(folder,"/",subfolder3,"/burden_results_stochastic_202310gavi-3_yf-routine-campaign-default_",run_id,".csv"))
  
  for(n_c in 1:n_countries){
    country_select=countries_select[n_c]
    for(n_y in 1:n_end_years){
      years=c(year_min:years_select[n_y])
      
      nv_data_subset=subset(nv_data,country==country_select)
      nv_data_subset=subset(nv_data_subset,year %in% years)
      nv_deaths=sum(nv_data_subset$deaths)
      
      rd_data_subset=subset(rd_data,country==country_select)
      rd_data_subset=subset(rd_data_subset,year %in% years)
      
      rdc_data_subset=subset(rdc_data,country==country_select)
      rdc_data_subset=subset(rdc_data_subset,year %in% years)
      
      output_array[run_id,n_c,n_y,1]=nv_deaths-sum(rd_data_subset$deaths)
      output_array[run_id,n_c,n_y,2]=nv_deaths-sum(rdc_data_subset$deaths)
    }
  }
}

#Check no apparent negative impact of vaccination
all(output_array>=0)

#Check zero impact for up to 2020 due to no vaccination start
all(output_array[,,1,]==0)

#Check all positive impact of vaccination for up to 2030
all(output_array[,,2,]>0)
