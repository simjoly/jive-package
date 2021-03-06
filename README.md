# jive-package

**Joint Inter- and intraspecific Variance Evolution**

This is the working repository for the jive R package. The original source code was obtained as supplementary data from Kostikova et al. (2016), but this version includes many improvements and updates.

## About

The **jive** R package implements the Joint Inter- and intraspecific Variance Evolution (KOstikova et al. 2016). It uses a MCMC approach to estimates species means and variances of a trait, as well as the parameters of evolutionary models that describe the evolution of these shapes and variances.

## Installation

### Manual installation

TODO: Download either the source files or the binaries for the [latest release](https://github.com/simjoly/pofadinr/releases) and install them in R.

### Direct installation in R

You first need to install the devtools package.

$> install.packages("devtools")

And then, intall the pofadinr package from the github repository.

$> library(devtools)

$> install_github("simjoly/jive-package")

### Source and binaries 

TODO: Check the [latest release](https://github.com/simjoly/pofadinr/releases).

## Notes

This package depends on the function OUwie of the OUwie R package for some model fitting.

This package is provided as is with no garantee regarding the results or that it will performed as expected.

## References

Kostikova, A., D. Silvestro, P. B. Pearman, and N. Salamin. 2016. Bridging inter- and intraspecific trait evolution with a hierarchical Bayesian approach. Syst Biol 65:417–431.

* Edit the help file skeletons in 'man', possibly combining help files for multiple functions.
* Edit the exports in 'NAMESPACE', and add necessary imports.
* Put any C/C++/Fortran code in 'src'.
* If you have compiled code, add a useDynLib() directive to 'NAMESPACE'.
* Run R CMD build to build the package tarball.
* Run R CMD check to check the package tarball.

Read "Writing R Extensions" for more information.
