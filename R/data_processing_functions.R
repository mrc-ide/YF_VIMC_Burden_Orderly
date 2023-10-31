library(assertthat)

#-------------------------------------------------------------------------------
#number of deaths, cases by scenario and country
get_key_values<- function(ce_data=list()){
  #assert_that
  
  countries=unique(ce_data$country)
  n_countries=length(countries)
  years=unique(ce_data$year)
  n_years=length(years)
  n_lines=n_countries*n_years
  
  output_frame1=data.frame(country=sort(rep(countries,n_years)),year=rep(years,n_countries),
                           cases=rep(NA,n_lines),deaths=rep(NA,n_lines),dalys=rep(NA,n_lines),YLL=rep(NA,n_lines))
  output_frame2=data.frame(country=countries,cases=rep(NA,n_countries),deaths=rep(NA,n_countries),dalys=rep(NA,n_countries),
                           YLL=rep(NA,n_countries))
  line=0
  for(n_c in 1:n_countries){
    subset1=subset(ce_data,country==countries[n_c])
    output_frame2$cases[n_c]=sum(subset1$cases)
    output_frame2$deaths[n_c]=sum(subset1$deaths)
    output_frame2$dalys[n_c]=sum(subset1$dalys)
    output_frame2$YLL[n_c]=sum(subset1$YLL)
    for(n_y in 1:n_years){
      line=line+1
      subset2=subset(subset1,year==years[n_y])
      output_frame1$cases[line]=sum(subset2$cases)
      output_frame1$deaths[line]=sum(subset2$deaths)
      output_frame1$dalys[line]=sum(subset2$dalys)
      output_frame1$YLL[line]=sum(subset2$YLL)
    }
  }
  
  return(list(results_by_country=output_frame2,results_by_country_year=output_frame1))
}