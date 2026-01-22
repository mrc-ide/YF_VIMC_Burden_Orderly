library(assertthat)

#-------------------------------------------------------------------------------
# Convert vaccination data into 3-D array of immunity data
# suitable for use with YEP
convert_vacc_data <- function(vacc_activity_data=list(),year_begin=1940,year_end=2100,N_age=101){
  
  assert_that(is.list(vacc_activity_data))
  
  vacc_activity_data_selected=vacc_activity_data[,c(5,6,8,9,10,13)]
  years=c(year_begin:year_end)
  n_years=length(years)
  
  country_list=names(table(vacc_activity_data_selected$country_code))
  n_countries=length(country_list)
  vacc_immunity_data=array(NA,dim=c(n_countries,n_years,N_age))
  
  for(n_country in 1:n_countries){
    country_select=country_list[n_country]
    vacc_activity_data_country=subset(vacc_activity_data_selected,country_code==country_select)
    
    coverage_values=vacc_immunity_data_country=array(0,dim=c(n_years,N_age))
    for(i in 1:nrow(vacc_activity_data_country)){
      coverage=vacc_activity_data_country$coverage[i]
      n_age_range=(c((vacc_activity_data_country$age_first[i]+1):(vacc_activity_data_country$age_last[i]+1)))
      n_year=match(vacc_activity_data_country$year[i],years)
      if(all(coverage_values[n_year,n_age_range]==0)){ #If no overlap, coverage set from line value
        coverage_values[n_year,n_age_range]=coverage
      } else { #If overlap with another line, coverages combined
        for(n_age in n_age_range){
          coverage_values[n_year,n_age]=calc_new_immunity(coverage_values[n_year,n_age],coverage,skew=0)
        }
      }
    }
    
    for(n_year in 2:n_years){
      vacc_immunity_data_country[n_year,1]=coverage_values[n_year-1,1]
      for(n_age in 2:N_age){
        vacc_immunity_data_country[n_year,n_age]=calc_new_immunity(vacc_immunity_data_country[n_year-1,n_age-1],
                                                                   coverage_values[n_year-1,n_age],skew=0)
      }
    }
    
    vacc_immunity_data[n_country,,]=vacc_immunity_data_country
    
  }
  
  return(vacc_immunity_data)
    
}
#-------------------------------------------------------------------------------
# Convert population data in long format with some ages missing in some years into 3-D array of population data
# suitable for use with YEP
convert_pop_data <- function(pop_data_long=list(),year_begin=1940,year_end=2100,N_age=101){
  
  assert_that(is.list(pop_data_long))
  #TODO - Add something to check age format
  
  years=c(year_begin:year_end)
  n_years=length(years)
  pop_data_selected=pop_data_long[,c(2,6,4,5,8)]
  pop_data_selected=subset(pop_data_selected,year %in% years)
  
  country_list=names(table(pop_data_selected$country_code))
  n_countries=length(country_list)
  pop_data_array=array(0,dim=c(n_countries,n_years,N_age))
  
  for(n_country in 1:n_countries){
    country_select=country_list[n_country]
    pop_data_country=subset(pop_data_selected,country_code==country_select)
    
    for(i in 1:nrow(pop_data_country)){
      n_age=pop_data_country$age_from[i]+1
      n_year=match(pop_data_country$year[i],years)
      pop_data_array[n_country,n_year,n_age]=pop_data_country$value[i]
    }
  }
  
  return(pop_data_array)
  
}
#-------------------------------------------------------------------------------
# Calculate immunity outcomes from campaign/routine vaccination coverage data
calc_new_immunity <- function(immunity,coverage,skew=0) {
  
  # Parameter skew determines how vaccination in subsequent campaigns is
  # allocated:
  # for skew=0, allocation is random, whereas for
  # skew=1, the same part of the population is first targeted in each campaign,
  # such that the coverage in 2 subsequent campaigns is only equal to the
  # larger individual coverage.
  # skew=-1: different parts of the population are targeted in each subsequent
  # campaign.
  
  if(skew == 0){
    return(immunity + coverage - immunity*coverage) #allocation is random
  } 
  
  if(skew %in% 1){
    return(max(c(immunity, coverage), na.rm = TRUE)) #100% correlation
  } 
  
  if(skew %in% -1){
    return(min(c(1, immunity + coverage), na.rm = TRUE)) #doses are targeted at unvaccinated
  } else {
    covmax <- max(immunity, coverage, na.rm = TRUE)
    covmin <- min(immunity, coverage, na.rm = TRUE)
    
    pop_prop <- c(covmin, covmax - covmin, 1-covmax)
    c1_strat <- c(1,0,0)*skew + (1-skew)*covmin
    c2_strat <- c(1,1,0)*skew + (1-skew)*covmax
    
    return( sum((1-(1-c1_strat)*(1-c2_strat)) * pop_prop) )
  }
  
}