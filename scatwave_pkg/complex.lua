local complex = {}
require 'torch'
local tools= require 'tools'


function complex.unit_complex(alpha)
   assert(torch.isTensor(alpha),'You can only input a tensor to unit_complex')
   return torch.cat(torch.cos(alpha),torch.sin(alpha),alpha:nDimension()+1)
end


function complex.modulus_wise(U)
   for k=1,#U do
      U[k].signal=complex.abs_value(U[k].signal)
   end
   return U
end


function complex.abs_value(h)
   assert(tools.is_complex(h),'The number is not complex')
   local dim=h:size()
   local final_dim=torch.LongStorage(#dim-1)
   for i=1,h:nDimension()-1 do
      final_dim[i]=dim[i]   
   end
   local final_h=torch.pow(h,2)
   final_h=torch.sum(final_h,#dim)
   final_h:sqrt() 
   return final_h:view(final_dim)   
end

function complex.realize(x)
   assert(tools.is_complex(x),'The number is not complex')
   return ((x:select(x:dim(),1)):clone())
end


function complex.multiply_complex_tensor(x,y)
   
   assert(tools.is_complex(x),'The number is not complex')
   assert(tools.are_equal_dimension(x,y),'Dimensions of x and y differ')   
      
   local xr=x:select(x:dim(),1)
   local xi=x:select(x:dim(),2)
   local yr=y:select(y:dim(),1)
   local yi=y:select(y:dim(),2)
   
   local z=torch.Tensor(x:size()):fill(0)
   local z_real = z:select(z:dim(), 1)
   local z_imag = z:select(z:dim(), 2)
   
   torch.cmul(z_real, xr, yr)
   z_real:addcmul(-1, xi, yi)
   
   torch.cmul(z_imag, xr, yi)
   z_imag:addcmul(1, xi, yr)
   return z
end


function complex.multiply_real_and_complex_tensor(x,y)
   
   assert(tools.is_complex(x),'First input must be complex')
   assert(not tools.is_complex(y),'Second input must be real')
      
   local xr=x:select(x:dim(),1)
   local xi=x:select(x:dim(),2)
   local yr=y
   
   local z=torch.Tensor(x:size()):fill(0)
   local z_real = z:select(z:dim(), 1)
   local z_imag = z:select(z:dim(), 2)
   
   torch.cmul(z_real, xr, yr)
   torch.cmul(z_imag, xi, yr)
   return z
end


function complex.multiply_complex_number_and_real_tensor(x,y)
   
   assert(tools.is_complex(x),'First input must be complex')
   assert(not tools.is_complex(y),'Second input must be real')
      
   local xr=x[1]
   local xi=x[2]
   
   local fs=torch.LongStorage(y:nDimension()+1)
   for l=1,y:nDimension() do
      fs[l]=y:size(l)
   end
   fs[y:nDimension()+1]=2
   
   local z=torch.Tensor(fs):fill(0)
   local z_real = z:select(z:dim(), 1)
   local z_imag = z:select(z:dim(), 2)

   z_real:add(xr,y) 
   z_imag:add(xi,y)
   return z
end

return complex