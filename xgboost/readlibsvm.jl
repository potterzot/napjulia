function readlibsvm(filename::ASCIIString, shape)
  #=
  Read in an libsvm formatted ascii file.
  =#
  data = zeros(Float32, shape)
  label = Float32[]

  f = open(filename, "r")

  count = 1
  for line in eachline(f)
    line = split(line, " ")
    push!(label, float(line[1]))
    line = line[2:end]
    for item in line
      itm = split(itm, ":")
      data[count, int(item[1])+1] = float(int(itm[2]))
    end
    count += 1
  end
  close(f)

  return (data, label)
end

