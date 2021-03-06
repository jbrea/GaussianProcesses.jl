abstract type PairKernel{K1<:Kernel,K2<:Kernel} <: CompositeKernel end

leftkern(k::PairKernel) = throw(MethodError(leftkern, (k,)))
rightkern(k::PairKernel) = throw(MethodError(rightkern, (k,)))
components(k::PairKernel) = [leftkern(k), rightkern(k)]

function Base.show(io::IO, pairkern::PairKernel, depth::Int = 0)
    pad = repeat(" ", 2 * depth)
    println(io, "$(pad)Type: $(typeof(pairkern))")
    show(io, leftkern(pairkern), depth+1)
    show(io, rightkern(pairkern), depth+1)
end

num_params(pairkern::PairKernel) = num_params(leftkern(pairkern))+num_params(rightkern(pairkern))
get_params(pairkern::PairKernel) = vcat(get_params(leftkern(pairkern)), get_params(rightkern(pairkern)))
get_param_names(pairkern::PairKernel) = composite_param_names([leftkern(pairkern), rightkern(pairkern)], :sk)

function set_params!(pairkern::PairKernel, hyp::Vector{Float64})
    npl = num_params(leftkern(pairkern))
    hyp_left = hyp[1:npl]
    hyp_right = hyp[npl+1:end]
    set_params!(leftkern(pairkern), hyp_left)
    set_params!(rightkern(pairkern), hyp_right)
end

##########
# Priors #
##########

function set_priors!(pairkern::PairKernel, priors::Array)
    npl = num_params(leftkern(pairkern))
    priors_left = priors[1:npl]
    priors_right = priors[npl+1:end]
    set_priors!(leftkern(pairkern), priors_left)
    set_priors!(rightkern(pairkern), priors_right)
end

get_priors(pairkern::PairKernel) = vcat(get_priors(leftkern(pairkern)), get_priors(rightkern(pairkern)))

#################
# PairData      #
#################

struct PairData{KD1 <: KernelData, KD2 <: KernelData} <: KernelData
    data1::KD1
    data2::KD2
end
function KernelData(pairkern::PairKernel, X::MatF64)
    kl = leftkern(pairkern)
    kr = rightkern(pairkern)
    # this is a bit broken:
    if kernel_data_key(kl, X) == kernel_data_key(kr, X)
        kdata = KernelData(kl, X)
        return PairData(kdata, kdata)
    else
        return PairData(
                KernelData(kl, X),
                KernelData(kr, X)
               )
    end
end

function kernel_data_key(pairkern::PairKernel, X::MatF64)
    kl = leftkern(pairkern)
    kr = rightkern(pairkern)
    @sprintf("PairData:%s+%s", kernel_data_key(kl, X), kernel_data_key(kr, X))
end
