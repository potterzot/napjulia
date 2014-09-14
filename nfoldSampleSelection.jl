using Distributions

function nfold_sample_selection(filename, k=1, nfolds=5)
  #=
  Split a sample into training and testing data
  =#
  f = open(filename, "r")
  ftest = open("$(filename).test", "w")
  ftrain = open("$(filename).train", "w")

  for line in eachline(f)
    if rand(0:nfold)==k # test data
      write(ftest, line)     
    else # training data
      write(ftrain, line)
    end
  end

  close(f)
  close(ftest)
  close(ftrain)
end











