immutable IdDataObject{T<:Real,V1<:AbstractArray{T},V2<:AbstractArray{T}}
  y::V1
  u::V2
  Ts::Float64
  N::Int
  nu::Int
  ny::Int

  @compat function (::Type{IdDataObject}){T}(y::AbstractArray{T}, u::AbstractArray{T}, Ts::Float64)
    N   = size(y, 2)
    ny  = size(y, 1)
    nu  = size(u, 1)

    # Validating amount of samples
    if size(y, 2) != size(u, 2)
      warn("Input and output need to have the same amount of samples")
      throw(DomainError())
    end

    # Validate sampling time
    if Ts < 0
      warn("Ts must be a real, positive number")
      throw(DomainError())
    end
    new{T,typeof(y),typeof(u)}(y, u, Ts, N, nu, ny)
  end

  @compat function (::Type{IdDataObject}){T}(y::AbstractVector{T}, u::AbstractVector{T}, Ts::Float64)
    N   = length(y)
    ny  = 1
    nu  = 1

    # Validating amount of samples
    if length(y) != length(u)
      warn("Input and output need to have the same amount of samples")
      throw(DomainError())
    end

    # Validate sampling time
    if Ts < 0
      warn("Ts must be a real, positive number")
      throw(DomainError())
    end
    new{T,typeof(y.'),typeof(u.')}(y.', u.', Ts, N, nu, ny)
  end
end

#####################################################################
##                      Constructor Functions                      ##
#####################################################################
"""
    `IdData = IdData(y, u, Ts=1)`

Creates an IdDataObject that can be used for System Identification. y and u should have the data arranged in columns.
Use for example sysIdentData = IdData(y1,[u1 u2],Ts,"Out",["In1" "In2"])
"""
function iddata(y::AbstractArray, u::AbstractArray, Ts::Real=1.)
    y,u = promote(y,u)
    return IdDataObject(y, u, convert(Float64,Ts))
end

#####################################################################
##                          Misc. Functions                        ##
#####################################################################
## INDEXING ##
Base.ndims(::IdDataObject) = 2
Base.size(d::IdDataObject) = (d.ny,d.nu)
Base.size(d::IdDataObject,i) = i<=2 ? size(d)[i] : 1
Base.length(d::IdDataObject) = size(d.y, 1)

#####################################################################
##                         Math Operators                          ##
#####################################################################

## EQUALITY ##
function ==(d1::IdDataObject, d2::IdDataObject)
    fields = [:Ts, :u, :y]
    for field in fields
        if getfield(d1,field) != getfield(d2,field)
            return false
        end
    end
    return true
end

#####################################################################
##                        Display Functions                        ##
#####################################################################
Base.print(io::IO, d::IdDataObject) = show(io, d)

function Base.show(io::IO, dat::IdDataObject)
    println(io, "Discrete-time data set with $(dat.N) samples.")
    println(io, "Sampling time: $(dat.Ts) seconds")
end
function Base.showall(io::IO, dat::IdDataObject)
    println(io, "Discrete-time data set with $(dat.N) samples.")
    println(io, "Sampling time: $(dat.Ts) seconds")
end
