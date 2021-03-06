

defClasses <- function(ncat=10, beta.param=0.3){ 
	# Defines classes for thermodynamic integration.
	# For details of the method see Xia et al 2011 Sys Bio.
	#
	# Args:
	# 	ncategories: number of classes that will be used in thermodynamic integration.
	#	beta.param:  parameter describing the shape of a beta distribution.
	# 
	# Returns:
	#	The vector of temperatures for thermodynamic integration.
	
	
    K <- ncat-1
    k <- 0:K
    b <- k/K
    temp<- rev(b^(1/beta.param))
    temp[length(temp)] <- 0.00001 # last category is not exactly 0 to avoid -inf likelihoods
	return(temp)
}

       
initUpdateFreq <- function(update.freq=NULL){
	# Initializes update frequencies for likelihood and two prior levels.
	#
	# Args:
	# 	update.freq: the vector (length = 3) of update frequencies (likelihood, priorMBM, priorVOU/VBM).
	#
	# Returns:
	#	The vector of update frequencies which sums to 1. 
	
	if (length(update.freq) != 3 && !is.null(update.freq)) {
		stop("Update.freq must contain 3 elements" )
	}
	
	
	# calculate update frequencies
	if (!is.null(update.freq)) {
		update.freq	<- cumsum(update.freq/sum(update.freq))
	} else {
		update.freq	<- cumsum(c(0.35,0.2,0.45))
	}
	
	return(update.freq)

}


initWinSize <- function(jive, window.sizes=NULL){
	# Calculates window sizes for sampling proposals.
	# User-defined window sizes are not supported at this stage.
	#
	# Args:
	# 	jive: jive.object (see makeJive function)
	#
	# Returns:
	#   A list of windows sizes for: msp - species-specific means, 
	#							     ssp - species-specific variances,
	#								 mvn - prior on means (MBM),
	#								 svn - prior on variances (VBM/VOU).
	
	ll.ws <- list()
	xx    <- apply(jive$traits, 1, sd, na.rm = T) # CHECK IF ITS SD OR VAR
	yy    <- sd(xx)
	
	ll.ws[["msp"]] <- xx 
	ll.ws[["ssp"]] <- xx
	ll.ws[["mvn"]] <- c(2 * yy, yy) # anc.state of means windows size, evol rate of means window size
	
	if (jive$model == "BM") {
		ll.ws[["svn"]] <- c(2 * yy, yy) # anc.state of sigmas windows size, evol rate of sgimas window size
	} else { 
		ll.ws[["svn"]] <- c(1.5, yy, 2 * yy, rep(2 * yy, jive$nreg)) # alpha from max likelihood on observed std dev <------------------------ alpha parameter to adjust
	}
	
	return(ll.ws)
	
}


## tranform simmap into map, input - simmap object
relSim <- function(x) {
	
	foo<-function(x) {
		x/sum(x)
	}
	
	x$mapped.edge <- t(apply(x$mapped.edge, 1, FUN=foo))
	x$mapped.edge <- x$mapped.edge[, order(colnames(x$mapped.edge))]
	
	return(x)
				
}

calcLogSD <- function(x){

	x <- log(apply(x, 1, var, na.rm = T))
	return(x)

}


calcSD <- function(x){

	x <- apply(x, 1, var, na.rm = T)
	return(x)

}


calcSDtrue <- function(x){

	x <- apply(x, 1, sd, na.rm = T)
	return(x)

}




##-------------------------- initialize windows sizes functions
initWinSizeMVN <- function (x){

	ws		<- list()
	ws$msp	<- (apply(x, 1, sd, na.rm = T))*2 # <--------------- may need further tuning
	ws$ssp	<- (calcSDtrue(x)*10)
	#ws$msp	<- (apply(x, 1, sd, na.rm = T))/2 # <--------------- may need further tuning
	#ws$ssp	<- (calcSDtrue(x)*5)
	#ws$ssp	<- 0.01
	
	return(ws)

}
 
# input is trait matrix, rows are species, cols - observations
initWinSizeMBM <- function(x, nreg, model, root.station){
	
	xx <- sd(apply(x, 1, mean, na.rm = T)) # Standard deviation of the species means
	if (model == "BM1") {
		ws <- c(2, xx) # evol rate of mean window size, theta window size
	} else { # model BMM
		if (root.station==FALSE) ws <- c(rep(2, nreg), xx) # evol rate of mean window size, theta window size
		if (root.station==TRUE)	ws <- c(rep(2, nreg), rep(xx, nreg)) # evol rate of mean window size, mean windows sizes, 
	}

	return(ws)
	
}

initWinSizeVOU <- function(x, nreg, root.station){
	
	#xx <- sd(calcSD(x) ) # CHECK IF ITS SD OR VAR
	xx1 <- 2
	if (root.station==TRUE)	ws <- c(2, 0.5, rep(xx1, nreg)) # alpha from max likelihood on observed std dev <------------------------ alpha parameter to adjust	
	if (root.station==FALSE) ws <- c(2, 0.5, xx1, rep(xx1, nreg)) # alpha from max likelihood on observed std dev <------------------------ alpha parameter to adjust
	
	return(ws)
	
}

initWinSizeMWN <- function(x, nreg){
	
#	xx <- sd(calcSD(x)) # CHECK IF ITS SD OR VAR
#	xx1 <- 2
	#xx1 <- mean(apply(x, 1, sd, na.rm = T)) * 2 # Test; TODO: check if mixing appropriate
	xx1 <- mean(apply(x, 1, sd, na.rm = T)) * 5 # Test; TODO: check if mixing appropriate
	ws <- c(0.5, rep(xx1,nreg)) # evol rate of sigmas window size, anc.state of sigmas windows size,

	return(ws)
	
}

# input is trait matrix, rows are species, cols - observations
initWinSizeMOU <- function(x, nreg, root.station){
	
	#xx <- sd(calcSD(x) ) # CHECK IF ITS SD OR VAR
	xx1 <- 2
	if (root.station==TRUE)	ws <- c(2, 0.5, rep(xx1, nreg)) # alpha from max likelihood on observed std dev <------------------------ alpha parameter to adjust	
	if (root.station==FALSE) ws <- c(2, 0.5, xx1, rep(xx1, nreg)) # alpha from max likelihood on observed std dev <------------------------ alpha parameter to adjust
	
	return(ws)
	
}

initWinSizeVWN <- function(x, nreg){
	
#	xx <- sd(calcSD(x)) # CHECK IF ITS SD OR VAR
	xx1 <- 2
#	xx1 <- mean(apply(x, 1, sd, na.rm = T)) * 2 # Test; TODO: check if mixing appropriate
	ws <- c(0.5, rep(xx1,nreg)) # evol rate of sigmas window size, anc.state of sigmas windows size,

	return(ws)
	
}

initWinSizeVBM <- function(x){
	
	xx <- sd(calcSD(x)) # CHECK IF ITS SD OR VAR
	xx1 <- 2
	ws <- c(0.5, xx1) # evol rate of sigmas window size, anc.state of sigmas windows size,

	return(ws)
	
}

# input is trait matrix, rows are species, cols - observations
# order: alpha, sig, anc.state, theta1, theta2...
initWinSizeVOU <- function(x, nreg, root.station){
	
	#xx <- sd(calcSD(x) ) # CHECK IF ITS SD OR VAR
	xx1 <- 2
	if (root.station==TRUE)	ws <- c(2, 0.5, rep(xx1, nreg)) # alpha from max likelihood on observed std dev <------------------------ alpha parameter to adjust	
	if (root.station==FALSE) ws <- c(2, 0.5, xx1, rep(xx1, nreg)) # alpha from max likelihood on observed std dev <------------------------ alpha parameter to adjust
	
	return(ws)
	
}



##-------------------------- initialize start parameters values functions
# initialize MCMC parameters
initParamMVN <- function (x){

	init  <- list()
	init$mspA  <- apply(x, 1, mean, na.rm = T) # initialize means for species
	init$sspA  <- calcSD(x) # initialize sigma.sq for species because of the variance
	
	return(init)
}


# initialize MCMC parameters for means
initParamMBM <- function(x, nreg, model, root.station){
		
	# initialize MCMC parameters
	mean.init <- mean(apply(x, 1, mean, na.rm = T))
	#init <- c(var(apply(x, 1, mean, na.rm = T)), mean(apply(x, 1, mean, na.rm = T))) 
	if (model == "BM1") {
		init <- c(runif(1, 0.5, 3), mean.init) # [1] sigma.sq, [2] theta
	} else { # model BMM
		if (root.station==FALSE) init <- c(rep(runif(1, 0.5, 3),nreg), mean.init) # [1:nreg] sigma.sq (one per regime), [nreg:nreg+1] theta
		if (root.station==TRUE) init <- c(rep(runif(1, 0.5, 3),nreg),rep(mean.init,nreg)) # [11:nreg] sigma.sq (one per regime), [nreg:nreg+nreg] thetas for each regime
	}

	return(init)
}


# initialize MCMC parameters for means
initParamMWN <- function(x, nreg){
		
	# Initialize MCMC parameters
	# sigma and regimes means 
	init <- c(runif(1, 0.5, 3), rep(mean(apply(x, 1, mean, na.rm = T)), nreg))
	return(init)

}

# initialize MCMC parameters (order: alpha, sig, anc.state, theta1, theta2...
initParamMOU <- function(x, nreg, root.station){
		
	if (root.station==TRUE) init <- c(runif((nreg+2), 0.1, 1)) # could be aither more realistic values such as means and sds of true data
	if (root.station==FALSE) init <- c(runif((nreg+3), 0.1, 1)) # could be aither more realistic values such as means and sds of true data
	return(init)

}

# initialize WN
initParamVWN <- function(x, nreg){
		
	init <- c(runif((nreg+1), 0.5, 3)) # could be aither more realistic values such as means and sds of true data (
	#init <- c(2.941516,2.139533,1.299683,1.364224) just a check
	
	return(init)

}
				   
# initParamVBM <- function(x){
		
# 	init <- c(runif(2, 0.5, 3)) # could be aither more realistic values such as means and sds of true data (
# 	#init <- c(2.941516,2.139533,1.299683,1.364224) just a check
	
# 	return(init)

# }	

initParamVBM <- function(x, nreg, model, root.station){
		
	# initialize MCMC parameters
	var.init <- mean(apply(x, 1, var, na.rm = T))
	#init <- c(var(apply(x, 1, mean, na.rm = T)), mean(apply(x, 1, mean, na.rm = T))) 
	if (model == "BM1") {
		init <- c(runif(1, 0.5, 3), var.init) # [1] sigma.sq, [2] theta
	} else { # model BMM
		if (root.station==FALSE) init <- c(rep(runif(1, 0.5, 3),nreg), var.init) # [1:nreg] sigma.sq (one per regime), [nreg:nreg+1] theta
		if (root.station==TRUE) init <- c(rep(runif(1, 0.5, 3),nreg),rep(var.init,nreg)) # [11:nreg] sigma.sq (one per regime), [nreg:nreg+nreg] thetas for each regime
	}

	return(init)
}


# initialize MCMC parameters (order: alpha, sig, anc.state, theta1, theta2...
initParamVOU <- function(x, nreg, root.station){
	
	xx1 <- mean(apply(x, 1, sd, na.rm = T)) * 10 # Test; TODO: check if mixing appropriate
	# if (root.station==TRUE) init <- c(runif(2, 0.1, 1), -6, -6) # could be aither more realistic values such as means and sds of true data
	# if (root.station==FALSE) init <- c(runif((nreg+3), 0.5, 3)) # could be aither more realistic values such as means and sds of true data
	if (root.station==TRUE) init <- c(runif((nreg+2), 0.1, 1)) # could be more realistic values such as means and sds of true data
	if (root.station==FALSE) init <- c(runif((nreg+3), 0.5, 3)) # could be more realistic values such as means and sds of true data
	#init <- c(2.941516,2.139533,1.299683,1.364224) just a check
	return(init)

}	







