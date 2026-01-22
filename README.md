VF_VIMC_Burden_Orderly instructions - branch 2023-runs

This repository contains code for running yellow fever burden calculations for the Vaccine Impact Modelling Consortium (VIMC) for multiple scenarios, running both stochastic sets of calculations (using multiple sets of epidemiological parameter values) and central estimates (using a single set of median epidemiological parameter values).

The code in this repository requires the YEP (Yellow Fever Epidemic Prevention) (<https://github.com/mrc-ide/YEP/>) and orderly2 (<https://github.com/mrc-ide/orderly2/>) packages. It is organized into a user-friendly framework using orderly2. See the vignette files for examples of running a set of scenarios using example files in the /shared/ folder.

Note that due to ongoing development of the YEP package, it is necessary to use a specific version of YEP to run code in this repository. The first vignette file (00_Get_Started.Rmd) shows how to install the correct version.

Similarly, note that orderly2, the package used here, is an older version of orderly, another package in ongoing development. For this reason, you may see error messages when running orderly2::orderly_run(); these can be ignored if the function finishes running.
