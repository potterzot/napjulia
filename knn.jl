#Modules
using Distances

@everywhere function assign_label(x, y, k, i)
  #=
  This function assigns a label to the ith point according to
  the labels of the k nearest neighbors. The training
  data is stored in the X matrix, and its labels are stored in y.
  =#
  
  ###Initialize some variables
  #label with the highest count.
  highestCount = 0
  mostPopularLabel = 0
  
  #Dictionary to save counts of labels
  # Dict{}() is also right .
  # Int,Int indicates the dictionary to expect integer values 
  counts = Dict{Int, Int}() 

  # Get the k-nearest neighbors for each image
  kNearestNeighbors = get_k_nearest_neighbors(x, i, k, euclidean)
  
  #Iterating over the labels of the k nearest neighbors
  for n in kNearestNeighbors
    # get the label of this neighbor
    labelOfN = y[n]
    
    #Add the current label to our dictionary
    #if it's not already there
    if !haskey(counts, labelOfN)
      counts[labelOfN] = 0
    end

    #Add one to the count
    counts[labelOfN] += 1 
  
    #Set the new highest count/most popular if it is the highest
    if counts[labelOfN] > highestCount
      highestCount = counts[labelOfN]
      mostPopularLabel = labelOfN
    end 
  end

  return mostPopularLabel
end

@everywhere function get_k_nearest_neighbors(x, i, k, distance)
  #=
  Find the k nearest neighbors of data point i
  =#
    
  # number of rows and columns
  nRows, nCols = size(x)

  #=
  Let's initialize a vector image_i. We do this so that 
  the image ith is accessed only once from the main X matrix.
  The program saves time because no repeated work is done.
  Also, creating an empty vector and filling it with each 
  element at a time is faster than copying the entire vector at once.
  Creating empty array (vector) of nRows elements of type Float32(decimal)
  =#
  imageI = Array(Float32, nRows) 

  for index in 1:nRows
    imageI[index] = x[index, i]
  end

  #For the same previous reasons, we initialize an empty vector 
  #that will contain the jth data point
  imageJ = Array(Float32, nRows)

  #Distances between the ith data point and each data point in the X matrix
  distances = Array(Float32, nCols)

  for j in 1:nCols #iterating over columns is faster than rows
    #The next for loop fills the vector image_j with the jth data point 
    #from the main matrix. Copying element one by one is faster
    #than copying the entire vector at once.
    for index in 1:nRows
      imageJ[index] = x[index, j]
    end
    
    #Calculate the n-dimensional distance between the two images
    distances[j] = distance(imageI, imageJ)
  end

  #Sort the distances
  sortedNeighbors = sortperm(distances)

  #Select the k nearest. We don't want the first one b/c it is the image itself
  kNearestNeighbors = sortedNeighbors[2:k+1]

  return kNearestNeighbors
end

@everywhere function knn(xTrain, yTrain, k)
  #=
  K-Nearest Neighbor(KNN) Algorithm
  =#
  # Transpose matrices (because iteration over columns is faster in Julia than over rows)
  xTrain = xTrain'
  yTrain = yTrain'
  
  # Get predictions
  # Non-parallel version:yPredictions = [assign_label(xTrain, yTrain, k, i) for i in 1:size(xTrain, 2)] 
  yPredictions = @parallel (vcat) for i in 1:size(xTrain, 2)
    assign_label(xTrain, yTrain, k, i)
  end
  return yPredictions

  #Alternative non-vector implementation
  #=
  sumValues = @parallel (+) for i in 1:size(xTrain, 2)
    assign_label(xTrain, yTrain, k, i) == yTrain[i,1]
  end
  accuracy = sumValues / size(xTrain, 2)
  =#
  return yPredictions
  

end

@everywhere function loofcv(yPredictions, yTrain)
  #=
  Leave-One-Out-Fold Cross Validation (LOOF-CV)
  =#

  # the . makes it an element-wise comparison
  return mean(yPredictions .== yTrain)
end




