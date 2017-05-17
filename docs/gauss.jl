#This file tests the GP Monte Carlo function against the exact solution from GP regression

using Gadfly, GaussianProcesses

n = 20
X = linspace(-3,3,n)
sigma = 2.0
Y = sin(X) + sigma*randn(n)

#build the model
m = MeanZero()
k = Matern(3/2,0.0,0.0)
l = GaussLik(log(sigma))

gp1 = GP(X', vec(Y), m, k, log(sigma))
gp2 = GP(X', vec(Y), m, k, l)


#maximise the parameters wrt the target
optimize!(gp1)
optimize!(gp2)

#compare log-likelihoods
abs(gp2.target - gp1.target)>eps()

#MCMC
samples1 = mcmc(gp1)
samples2 = mcmc(gp2)

xtest = linspace(minimum(gp1.X),maximum(gp1.X),50);
y1 = predict_y(gp1,xtest)[1]
y2 = predict_y(gp2,xtest)[1]

plot(layer(x=X,y=Y,Geom.point),
     layer(x=xtest,y=y1,Geom.line),
     layer(x=xtest,y=y2,Geom.line))

