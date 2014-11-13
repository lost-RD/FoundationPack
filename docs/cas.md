Input
```
require'cas'

local example=cas.parse'5 x^2+3*x-1'
print(example:derive'x')
print(example{x=5})
print(example:derive'x'{x=5})

print(cas.parse'5ysin(x^x+y/(9x-6))+12':derive'x'{x=3,y=4}) --and later, :solve'y`'
```
Output:
```
> ((5*x^(2+-1)*2)+3)
> 139
> 53
> ((5*y`*0.88376947941016)+(-9.3584508817024*(56.662531794039+(y`*0.047619047619048)+-0.081632653061224)))
```