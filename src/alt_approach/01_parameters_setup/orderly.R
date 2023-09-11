orderly2::orderly_parameters(parameter_sets_file="",n_param_sets=1)
orderly2::orderly_shared_resource("parameter_sets.Rds"=parameter_sets_file)
orderly2::orderly_artefact("Selected parameter sets","parameter_sets_selected.Rds")

parameter_sets=readRDS("parameter_sets.Rds")
#TODO - Add assert_that functions to make sure this is MCMC chain data

n_param_sets_all=nrow(parameter_sets)
interval=floor((n_param_sets_all-1)/(n_param_sets-1))
rows=1+(interval*c(0:(n_param_sets-1)))

parameter_sets_selected=parameter_sets[rows,]
saveRDS(parameter_sets_selected,"parameter_sets_selected.Rds")