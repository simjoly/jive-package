#conditional prior on sd of species-specific normal likelihoods under WN model with multiple means
# require(ape)
# require(MASS)

likWNM<-function(pars, x, tree, regimes, scaleHeight){

	# pars: [1] = sigma^2, [2:nreg] = ancestral means
	# x = vector of observed values
	# regimes: a vector of character regimes
	# tree: a simmap tree
	# scaleHeight: Whether the total length of the tree should be set to 1

	Y      <- as.matrix(x)	
	sig.sq <- pars[1] # sigma
	tvcv   <- vcv(tree)
	n      <- dim(tvcv)[1]
	vcv.m  <- matrix(nrow=n,ncol=n,0)
	if (scaleHeight) { # Rescale tree to unit length
		diag(vcv.m) <- 1
	} else { # Keep original tree length
		diag(vcv.m) <- tvcv[1]		
	}	
	m      <- matrix(1, n, 1)
	means  <- pars[-1] # means
	m[, ]  <- means[as.factor(regimes)] # vector of expected mean for each species
	DET    <- determinant(sig.sq * vcv.m, logarithm=T)

	log.lik.WNM <- try((-n/2 * log(2 * pi) - (as.numeric(DET$modulus))/2 - 1/2 * (t(Y - m)%*%ginv(sig.sq * vcv.m)%*%(Y - m))), silent=T)
	
	if (is.na(log.lik.WNM) | (class(log.lik.WNM) == "try-error" )) {
			return(-Inf)
	} else {
		return(log.lik.WNM)
	}

}
