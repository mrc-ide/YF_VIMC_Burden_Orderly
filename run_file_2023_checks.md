#Check scenarios for 2023 burden calculations

library(YEP)
path = getwd() #Path = repository folder
source(paste0(path, "/R/conversion_functions.R")) #Functions for converting population and vaccination data from GAVI format to format used by YEP

#Initialize---------------------------------------------------------------------
orderly2::orderly_init(path) 

#Create designations for each scenario------------------------------------------
scenarios = c("routine-default","no-vaccination","routine-bluesky","routine-campaign-bluesky",
              "routine-campaign-default","routine-ia2030","routine-campaign-ia2030")
input_data_ids = read.csv("shared/input_data_list.csv", header = TRUE)$id

#Image population and vaccination data for selected countries and check for discrepancies
colour_scheme=readRDS(file=paste(path.package("YEP"), "exdata/colour_scheme_example.Rds", sep="/"))
colour_scale=colour_scheme$colour_scale
input_datasets=list()
for(n_run in 1:length(scenarios)){
  input_datasets[[n_run]]=readRDS(file=paste0("archive/01_input_data_setup/",input_data_ids[n_run],"/input_data_countries.Rds"))
}
countries_view="NGA" #input_datasets[[1]]$region_labels
par(mfrow=c(2,4),mar=c(4,4,2,2))
for(n_region in 1:length(countries_view)){
  for(n_run in 1:length(scenarios)){
    if(n_run==1){YEPaux::plot_region_input_data(input_datasets[[n_run]],countries_view[n_region],"pop",colour_scale,NULL)}
    YEPaux::plot_region_input_data(input_datasets[[n_run]],countries_view[n_region],"vacc",colour_scale,NULL)
  }
}

#Check selected groups of scenarios match up for chosen years
scenario_check_against=5
scenarios_to_check=c(4,7)
years_i=c(1:length(input_datasets[[1]]$years_labels))[input_datasets[[1]]$years_labels %in% c(1940:1980)]
check_frame=data.frame(country=countries_view)
for(n_run in scenarios_to_check){check_frame=cbind(check_frame,rep("OK",length(countries_view)))}
colnames(check_frame)=c("country",scenarios[scenarios_to_check])
for(n_region in 1:length(countries_view)){
  vacc_data=list()
  for(n_run in 1:length(scenarios)){
    vacc_data[[n_run]]=input_datasets[[n_run]]$vacc_data[n_region,years_i,]
  }
  flags=c()
  for(n_run in scenarios_to_check){
    if(all(vacc_data[[n_run]]==vacc_data[[scenario_check_against]])){} else {
      flags=append(flags,n_run)
      check_frame[n_region,c(1:ncol(check_frame))[colnames(check_frame)==scenarios[n_run]]]="ERROR"
    }
  }
  if(length(flags)==0){
    cat("\n",countries_view[n_region],"- OK",sep=" ")
  } else {
    cat("\n",countries_view[n_region],"-",scenarios[flags],sep=" ")
  }
}
write.csv(check_frame,file="shared/discrepancy_check.csv",row.names=FALSE)
