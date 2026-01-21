# YF_VIMC_Burden_Orderly

This repository contains code for running yellow fever burden calculations for the Vaccine Impact Modelling Consortium (VIMC) for multiple scenarios, running both stochastic sets of calculations (using multiple sets of epidemiological parameter values) and central estimates (using a single set of median epidemiological parameter values).

The code in this repository requires the YEP (Yellow Fever Epidemic Prevention) (https://github.com/mrc-ide/YEP/) and orderly (https://github.com/mrc-ide/orderly/) packages. It is organized into a user-friendly framework using orderly. See the vignette files for examples of running a set of scenarios using example files in the /shared/ folder.

Note that due to ongoing development of the YEP package, it is necessary to use version 0.2 of YEP to run code in this repository. The first vignette file (00_Get_Started.Rmd) shows how to install the correct version.
