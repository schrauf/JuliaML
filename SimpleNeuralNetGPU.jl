# Julia simple neural net for Boston Housing Problem
# f(x) = c'h(x)
# h(x) = σ(Ax + b)
# problem: inaccurate prodiction

workspace()
using Flux, Flux.Tracker
using Flux: mse, throttle
using Base.Iterators: repeated
#using CuArrays

isfile("housing.data") ||
  download("https://raw.githubusercontent.com/MikeInnes/notebooks/master/housing.data",
           "housing.data")

rawdata = readdlm("housing.data")'

# The last feature is our target -- the price of the house.
x = rawdata[1:13,:]
y = rawdata[14:14,:]
# Normalise the data
x = (x .- mean(x,2)) ./ std(x,2)

N = 505 # number of training points
D = 13 # dimension of each x vector
hidden_units = 10
learning_rate = 0.5
repetitions = 10000

hiddenLayer = Dense(D, hidden_units, σ)
outputLayer = Dense(hidden_units,1)
model = Chain(hiddenLayer, outputLayer)

#for GPU support
#x,y = cu(x), cu(y)
#model = mapleaves(cu, model)

data = Iterators.repeated((x,y), repetitions)
opt = SGD(params(model), learning_rate)
E(x, y) = mse(model(x), y)
evalcb = () -> @show(E(x, y))

Flux.train!(E, data, opt, cb = throttle(evalcb, 5))
