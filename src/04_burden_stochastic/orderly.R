orderly2::orderly_parameters(life_exp_file="",country_list_file="",input_id="",
                             p_severe_inf=0.12,p_death_severe_inf=0.39,YLD_per_case=0.006486,n_reps=1,flag_cluster=TRUE)
orderly2::orderly_shared_resource("life_expectancy.csv"=life_exp_file,"country_list.csv"=country_list_file)
orderly2::orderly_dependency(name="01_input_data_setup", query=input_id,files="input_data_countries.Rds")
orderly2::orderly_dependency(name="02_get_epi_parameters", query="latest",
                             files=c("FOI_R0_countries.Rds","vaccine_efficacy.Rds"))
orderly2::orderly_artefact("burden output", "burden_results_stochastic.csv" )

input_data=readRDS(file = "input_data_countries.Rds")
countries_all=input_data$region_labels
FOI_R0_data_countries=readRDS("FOI_R0_countries.Rds")
assert_that(length(FOI_R0_data_countries$country)==length(countries_all))
FOI_values=FOI_R0_data_countries$FOI
R0_values=FOI_R0_data_countries$R0
life_exp_data=read.csv(file="life_expectancy.csv",header=TRUE)
years_data=c(2000:2099)
n_years=length(years_data)
N_age=101

countries=read.csv(file="country_list.csv",header=TRUE)$country
assert_that(all(countries %in% countries_all))
n_countries=length(countries)
nrows=N_age*n_years*n_countries

FOI_values=FOI_values[FOI_R0_data_countries$country %in% countries,]
R0_values=R0_values[FOI_R0_data_countries$country %in% countries,]
input_data=YEP::input_data_truncate(input_data,regions_new=countries)
life_exp_data=subset(life_exp_data,country_code %in% countries)
years_life_exp=unique(life_exp_data$year)

template=data.frame(region=sort(rep(countries,N_age*n_years)),year=rep(sort(rep(years_data,N_age)),n_countries),
                    age_min=rep(c(1:N_age)-1,n_years*n_countries),
                    age_max=rep(c(1:N_age),n_years*n_countries),life_exp=rep(NA,nrows))
line=0
for(n_c in 1:n_countries){
  life_exp_data_subset1=subset(life_exp_data,country_code==countries[n_c])
  for(n_year in 1:n_years){
    year1=years_data[n_year]
    year2=years_life_exp[findInterval(year1,years_life_exp)]
    life_exp_data_subset2=subset(life_exp_data_subset1,year==year2)
    for(i in 1:N_age){
      line=line+1
      template$life_exp[line]=life_exp_data_subset2$value[findInterval(template$age_min[line],life_exp_data_subset2$age_from)]
    }
  }
}

vaccine_efficacy=readRDS("vaccine_efficacy.Rds")
mode_start=1
start_SEIRV=NULL
dt=5.0
deterministic=FALSE

if(flag_cluster){
  mode_parallel="clusterMap"
  cluster=parallel::clusterMap(parallel::makeCluster(4))
} else{
  mode_parallel="none"
  cluster=NULL
}

set.seed(1)
for(set in 1:n_param_sets){
  cat("\t",set,sep="")
  dataset_single <- Generate_VIMC_Burden_Dataset(input_data,FOI_values[,set],R0_values[,set],template,vaccine_efficacy[set],
                                                 p_severe_inf,p_death_severe_inf,YLD_per_case,mode_start,
                                                 start_SEIRV,dt,n_reps,deterministic,mode_parallel,cluster)
  if(set==1){
    data_out=dataset_single
    nrows=nrow(dataset_single)
  } else {
    data_out=rbind(data_out,dataset_single)
  }
}
data_out$set=sort(rep(c(1:n_param_sets),nrows))
write.csv(data_out,file="burden_results_stochastic.csv",row.names=FALSE)

if(flag_cluster){parallel::stopCluster(cluster)}
