countries=c("ETH")
run_id=1
years=c(2000:2020)

folder="archive/03_burden_stochastic"
subfolder1=dir(folder)[2]
subfolder2=dir(folder)[1]
subfolder3=dir(folder)[3]

file_scn1=paste0(folder,"/",subfolder1,"/burden_results_stochastic_202310gavi-3_yf-no-vaccination_",run_id,".csv")
file_scn2=paste0(folder,"/",subfolder2,"/burden_results_stochastic_202310gavi-3_yf-routine-default_",run_id,".csv")
file_scn3=paste0(folder,"/",subfolder3,"/burden_results_stochastic_202310gavi-3_yf-routine-campaign-default_",run_id,".csv")

scn1_data=readr::read_csv(file_scn1)
scn1_data_subset=subset(scn1_data,country %in% countries)
scn1_data_subset=subset(scn1_data_subset,year %in% years)
scn1_deaths=sum(scn1_data_subset$deaths)

scn2_data=readr::read_csv(file_scn2)
scn2_data_subset=subset(scn2_data,country %in% countries)
scn2_data_subset=subset(scn2_data_subset,year %in% years)
scn2_deaths=sum(scn2_data_subset$deaths)

scn3_data=readr::read_csv(file_scn3)
scn3_data_subset=subset(scn3_data,country %in% countries)
scn3_data_subset=subset(scn3_data_subset,year %in% years)
scn3_deaths=sum(scn3_data_subset$deaths)

scn1_deaths
scn2_deaths
scn3_deaths