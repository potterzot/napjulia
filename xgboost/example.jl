#=
Example use of XGBoost module

=#

#Modules
using XGBoost
using Distributions

#Includes
include "readlibsvm.jl"

# Get the data
#xTrain, yTrain = readlibsvm("../data/agaricus.txt.train", (6513, 126))
#xTest, yTest = readlibsvm("../data/agaricus.txt.test", (1611, 126))

# Number of rounds
#num_rounds = 2

#=WAYS OF TRAINING=#
# Dense matrix training of xgboost
#dense = xgboost(xTrain, num_round, label=yTrain, eta=1, max_depth=2, objective="binary:logistic")

# Sparse matrix training
#param = ["eta"=>1, "max_depth"=>2, "objective"=>"binary:logistic")
#sparse = xgboost(sptrain(xTrain), num_round, label=yTrain, param=param)

# Dmatrix
#dmat = DMatrix(xTrain, label=yTrain)
#model = xgboost(dmat, num_rounds, param=param) 

# Alternatively, you can specify a libSVM formatted txt file as the data input

#=PREDICTION=#
#predict = predict(dense, xTest)



# Open the data file
filename = "/home/potterzot/data/uci_ml/agaricus-lepiota.data"
f = open(filename, "r")

k = 1
nfold = 5

if rand(0:nfold)==k
  # write test
else
  # write train


