#=
Adapted from Higgs-Boson ML competition on Kaggle

=#

function ams(s,b)
  #=
  Calculate the Approximate Median Significance defined as:
  
  AMS = sqrt( 2 * { (s + b + b_r) * log[1+(s/(b+b_r))] - s} )

  where b_r = 10, b = background, s = signal
  
  =#
  br = 10.0
  radicand = 2 * ((s+b+br) * log(1.0 + s/(b+br)) - s)
  if radicand < 0
    println("radicand is negative. Exiting.")
  else
    return sqrt(radicand)
  end
end
