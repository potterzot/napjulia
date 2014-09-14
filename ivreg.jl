#=
Implementation of LIML regressions with Bekker adjustments to standard errors

=#
using DataFrames

function iv(y, W, X, Z, model="liml")
  #=
  Two Stage Least Squares (2SLS)
  Limited Information Maximum Likelihood (LIML)
  Generalized Method of Moments (GMM)

  Required Variables:
  Y is dependent variable
  X is instrumented variables (endogenous variables)
  Z is instruments (excluded exogenous)
  W is non-instrumented exogenous variables
  
  Options:
  wt is an NxN matrix of weights
  bekker is a bekker adjustment to standard errors
  
  In stata form:

  ivregress liml Y W (X=Z)

  In equation form:
  Y = X*b + W*d + u
  X = Z*a + v
  =#

  # Number of each type of variable
  N = size(y, 1) #number of obs
  K = size(X, 2) 
  L = size(W, 2)
  M = size(Z, 2)

  df_ess = K + L
  df_rss = N - df_ess

  #Calculate the matrixMatrices
  A = hcat(y,X,W,Z)
  Y = hcat(y,X)
  AA = A' * A
  
  #Sub matrices
  yy = AA[1,1] # 1x1
  XX = AA[2:1+K, 2:1+K] # KxK
  Xy = AA[2:1+K, 1] # Kx1
  WW = AA[2+K:2+K+L, 2+K:2+K+L] # LxL
  ZZ = AA[2+K+L:end, 2+K+L:end] # MxM
  XZ = AA[2:1+K, 2+K:end] # KxM
  PZ = Z * pinv((Z' * Z) * Z' # NxN
  MZ = eye(N) - PZ # NxN
  XPZX = X' * PZ * X # KxK
  XPZy = X' * PZ * y # Kx1 
  YMY = Y' * MZ * Y # 1+K x 1+K
  YPZY = YY - YMY

  #Get lambda/alpha
  if model=="2sls"
    alpha = 0
  elseif(model=="liml" || model=="fuller")
    HH = YY * pinv(YPZY)
    lambda = eigmin(HH) # lambda is 1.84247. alpha = 1 - 1/lambda = .4572
    if model=="liml"
      alpha = 1 - 1/lambda
    elseif model=="fuller"
      alpha = ((1 - 2/lambda) * C / N) / ((1 + 1/lambda) * C / N) #C is fuller param 
  end
  ###BETAS
  # first regression (Z)
  betaZ = pinv(ZZ) * XZ'
 
  # second regression (X)
  H = XPZX - alpha * XX
  betaX = pinv(H) * (XPZy - alpha * Xy)
  
  # Variances
  err = Y - X * betaX #Residuals
  rss = err' * err #Sum of Squared Residuals / Residual SS
  tss = (y - mean(y))' * (y - mean(y)) #Total sum of squares
  mss = rss - tss # model sum of squares
  mse = rss / df_rss # Variance of Residuals, also sigma squared of the regression
  rmse = sqrt(mse) # standard error of the regression
  tss_uncentered = yy[1]
  r_squared_centered = 1-rss/tss # centered R-Squared
  r_squared_uncentered = 1-rss/tss_uncentered # uncentered R-squared
 
  #Z beta Variance
  err1 = X .- Z * betaZ
  mse1 = (err1' * err1) / (N-M)
  rmse1 = sqrt(mse1)
  seZ = rmse1 .* sqrt(diag(pinv(zz)))
 
  #X beta Variance
  Xbar = X - err .* (err' * X)/rss
  Sigma = mse * ( (1-alpha)^2 * (Xbar' * PZ * Xbar) + alpha^2 * (Xbar' * MZ * Xbar) )
  seX = rmse .* sqrt(diag(pinv(xx)))
  seX_bekker = sqrt(pinv(H) * Sigma * pinv(H))
  #T-statistic
  betaX / seX

  
  
  return betaX
end

function test()
  #=
  Test the LIML implementation using mroz dataset. Results should be:

          Coef      Std Err   Bekker
  hours    .001789  .001148   .00203
  exper   -.092979  .145624   .25486
  =#
    
  mroz = readtable("/home/potterzot/data/stata/mroz.csv") 
 
  # Drop incomplete cases
  data = complete_cases!(mroz)

  # Small sample for testing
  data = data[data[:age].<=31, :]

  
  # Dependent variable 
  Y = data[:lwage]

  # Instrumented Variable
  X = data[:hours]

  # Instruments
  Z = hcat(data[:educ], data[:kidslt6], data[:kidsge6], data[:age], data[:nwifeinc])

  result = iv(Y, X, Z)
end








