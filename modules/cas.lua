--Lua Computer Algebra System (LuCAS) By xXxMoNkEyMaNxXx
local cas={}
cas._URL = 'http://love2d.org/forums/viewtopic.php?f=5&t=27765'
function cas.cst(value)
	return setmetatable({type="cst",value},cas)
end
function cas.var(name)
	return setmetatable({type="var",name},cas)
end

function cas.pow(base,power)
	local u=base
	if type(base)=="number" then
		u=cas.cst(base)
	elseif type(base)=="string" then
		u=cas.var(base)
	end
	local v=power
	if type(power)=="number" then
		if power==0 then
			return cas.cst(1)
		elseif power==1 then
			return u
		else
			v=cas.cst(power)
		end
	elseif type(power)=="string" then
		v=cas.var(power)
	end
	return setmetatable({type="pow",u,v},cas)
end
function cas.prod(list)
	local cont={type="prod"}
	for i=1,#list do
		if type(list[i])=="table" then
			if list[i].type==cont.type then
				for i2=1,#list[i] do
					if list[i][i2]==0 then
						return cas.cst(0)
					else
						cont[#cont+1]=list[i][i2]
					end
				end
			elseif list[i].type=="cst" then
				if list[i][1]==0 then
					return cas.cst(0)
				elseif list[i][1]~=1 then
					cont[#cont+1]=list[i]
				end
			else
				cont[#cont+1]=list[i]
			end
		elseif type(list[i])=="string" then
			cont[#cont+1]=cas.var(list[i])
		elseif type(list[i])=="number" then
			if list[i]==0 then
				return cas.cst(0)
			elseif list[i]~=1 then
				cont[#cont+1]=cas.cst(list[i])
			end
		end
	end
	if #cont==1 then
		return cont[1]
	else
		return setmetatable(cont,cas)
	end
end
function cas.sum(list)
	local cont={type="sum"}
	for i=1,#list do
		if type(list[i])=="table" then
			if list[i].type==cont.type then
				for i2=1,#list[i] do
					cont[#cont+1]=list[i][i2]
				end
			elseif list[i].type~="cst" or list[i][1]~=0 then
				cont[#cont+1]=list[i]
			end
		elseif type(list[i])=="string" then
			cont[#cont+1]=cas.var(list[i])
		elseif type(list[i])=="number" and list[i]~=0 then
			cont[#cont+1]=cas.cst(list[i])
		end
	end
	if #cont==1 then
		return cont[1]
	elseif #cont>1 then
		return setmetatable(cont,cas)
	end
	return cas.cst(0)
end

local myfuncs={}
function cas.func(argv,func)--func must be an cas object
	if func and type(func)=="table" and func.type then
		return function(...)
			return setmetatable({type="myfunc",func=func,argv=argv,args={...}},cas)
		end
	else
		error'Invalid function, must be an cas object.'
	end
end

local function func(names,func,rules)
	return function(...)
		return setmetatable({type="func",names=type(names)=="table" and names or {names},func=func,rules=rules,...},cas)
	end
end

function cas:__unm()
	return cas.prod{self,-1}
end
function cas:__add(item)
	return cas.sum{self,item}
end
function cas:__sub(item)
	return cas.sum{self,cas.prod{item,-1}}
end
function cas:__mul(item)
	return cas.prod{self,item}
end
function cas:__div(item)
	return cas.prod{self,cas.pow(item,-1)}
end
function cas:__pow(item)
	return cas.pow(self,item)
end


local funcs={}
local funcdefs={
	log={names={"log","ln"},func=math.log,rules={
		derive=function(self,rel) return self[1]:derive(rel)/self[1] end,
		expand=function(self)
			if self[1].type=="pow" then
				return self[1][2]*funcs.log(self[1][1])
			elseif self[1].type=="prod" then
				local cont={}
				for i=1,#self[1] do
					cont[i]=funcs.log(self[1][i])
				end
				return cas.sum(cont)
			end
		end,
	}},
	sin={names={"sin"},func=math.sin,rules={}},
	cos={names={"cos"},func=math.cos,rules={}},
	tan={names={"tan"},func=math.tan,rules={}},
	asin={names={"asin"},func=math.asin,rules={derive=function(self,rel) return self[1]:derive(rel)/(1-self[1]^2)^0.5 end}},
	acos={names={"acos"},func=math.acos,rules={derive=function(self,rel) return -self[1]:derive(rel)/(1-self[1]^2)^0.5 end}},
	atan={names={"atan"},func=math.atan,rules={derive=function(self,rel) return self[1]:derive(rel)/(self[1]^2+1) end}},
	atan2={names={"atan2"},func=math.atan2,rules={derive=function(self,rel) return (self[1]:derive(rel)*self[2]-self[1]*self[2]:derive(rel))/(self[1]^2+self[2]^2) end}},
}
for i,v in next,funcdefs do
	funcs[i]=func(v.names,v.func,v.rules)
end

myfuncs.sqrt=cas.func({"x"},cas.var'x'^0.5)
myfuncs.csc=cas.func({"x"},1/funcs.sin(cas.var'x'))
myfuncs.sec=cas.func({"x"},1/funcs.cos(cas.var'x'))
myfuncs.cot=cas.func({"x"},1/funcs.tan(cas.var'x'))
funcdefs.sin.rules.derive=function(self,rel) return funcs.cos(self[1])*self[1]:derive(rel) end
funcdefs.cos.rules.derive=function(self,rel) return -funcs.sin(self[1])*self[1]:derive(rel) end
funcdefs.tan.rules.derive=function(self,rel) return self[1]:derive(rel)*myfuncs.sec(self[1])^2 end

for i,v in next,funcs do
	cas[i]=funcs[i]
end
local derive,expand={},{}
local rules={derive=derive,expand=expand}
--Derivative--
function derive:func(rel)
	if self.rules and self.rules.derive then
		return self.rules.derive(self,rel)
	else
		error("Cannot differentiate: no derivative provided for built-in function '"..self.names[1].."'")
	end
end
function derive:myfunc(rel)
	local args={}
	for i=1,#self.args do
		args[self.argv[i].."`"]=self.args[i]:derive(rel)
	end
	return self.func:derive()(args)
end
function derive:pow(rel)
	return self[1]^(self[2]-1)*(self[1]:derive(rel)*self[2]+self[1]*cas.log(self[1])*self[2]:derive(rel))
end
function derive:prod(rel)
	local Sigma={}
	for i=1,#self do
		local Pi={}
		for i2=1,#self do
			if i==i2 then
				Pi[i2]=self[i2]:derive(rel)
			else
				Pi[i2]=self[i2]
			end
		end
		Sigma[i]=cas.prod(Pi)
	end
	return cas.sum(Sigma)
end
function derive:sum(rel)
	local Sigma={}
	for i=1,#self do
		Sigma[i]=self[i]:derive(rel)
	end
	return cas.sum(Sigma)
end
function derive:var(rel)
	if rel==self[1] then
		return cas.cst(1)
	else
		local test=self()
		if test==self then
			return cas.var(self[1].."`")
		else
			return test
		end
	end
end
function derive:cst(rel)
	return cas.cst(0)
end
----------

--Expand--
function expand:func()
	if self.rules and self.rules.expand then
		return self.rules.expand(self) or self
	end
	return self
end
function expand:myfunc()
	local args={}
	for i=1,#self.args do
		args[self.argv[i]]=self.args[i]
	end
	return self.func(args)
end
function expand:pow()
	if self[1].type=="cst" and self[2].type=="cst" then
		return cas.cst(self())
	elseif self[2].type=="cst" and self[2][1]>=1 and self[2][1]<=100 and self[2][1]%1==0 then-- <=100, don't get carried away folks
		local cont={}
		for i=1,self[2][1] do
			cont[i]=self[1]
		end
		return cas.prod(cont):expand()
	elseif self[2].type=="sum" then
		local cont={}
		for i=1,#self[2] do
			cont[i]=cas.pow(self[1],self[2][i])
		end
		return cas.prod(cont):expand()
	end
	return self
end
function expand:prod()
	local all=true
	for i1=1,#self do
		if self[i1].type=="sum" then
			local cont0={}
			for i2=1,#self[i1] do
				local cont1={[i1]=self[i1][i2]}
				for i3=1,#self do
					if i1~=i3 then
						cont1[i3]=self[i3]
					end
				end
				cont0[i2]=cas.prod(cont1):expand()
			end
			return cas.sum(cont0)
		end
		all=all and self[i1].type=="cst"
	end
	if all then
		return cas.cst(self())
	end
	return self
end
function expand:sum()
	local all=true
	local cont={}
	for i=1,#self do
		cont[i]=self[i]:expand()
		all=all and cont[i].type=="cst"
	end
	if all then
		return cas.cst(self())
	else
		return cas.sum(cont)
	end
end
function expand:var()
	return self()
end
function expand:cst()
	return self
end
----------

function cas:__index(index)
	local test1=rules[index]
	if test1 then
		return test1[self.type]
	end
end

function cas:__call(env)
	env=env or {}
	if self.type=="func" then
		local all=true
		local args={}
		for i=1,#self do
			local arg=self[i](env)
			args[i]=arg
			all=all and type(arg)=="number"
		end
		if all then
			return self.func(unpack(args))
		else
			return funcs[self.names[1]](unpack(args))
		end
	elseif self.type=="myfunc" then
		local args={}
		for i=1,#self.args do
			local arg=self.args[i](env)
			args[self.argv[i]]=arg
		end
		return self.func(args)--New env
	elseif self.type=="pow" then
	return self[1](env)^self[2](env)
	elseif self.type=="prod" then
		local product=1
		for i=1,#self do
			product=product*self[i](env)
		end
		return product
	elseif self.type=="sum" then
		local sum=0
		for i=1,#self do
			sum=sum+self[i](env)
		end
		return sum
	elseif self.type=="var" then
		local def=env[self[1]] or getfenv()[self[1]] or _G[self[1]]
		if type(def)=="table" then
			if def.type then
				local ran,ret=pcall(function() return def(env) end)
				if ran then
					return ret
				else
					print(ret)
				end
			end
		elseif type(def)=="number" then
			return def
		end
		return self
	elseif self.type=="cst" then
		return self[1]
	end
end

function cas:__tostring()
	if self.type=="func" then
		local args=tostring(self[1])
		for i=2,#self do
			args=args..","..tostring(self[i])
		end
		return self.names[1].."("..args..")"
	elseif self.type=="myfunc" then
		return tostring(self.func)
	elseif self.type=="pow" then
		return tostring(self[1]).."^"..tostring(self[2])
	elseif self.type=="prod" then
		local cont=tostring(self[1])
		for i=2,#self do
			cont=cont.."*"..tostring(self[i])
		end
		return "("..cont..")"
	elseif self.type=="sum" then
		local cont=tostring(self[1])
		for i=2,#self do
			cont=cont.."+"..tostring(self[i])
		end
		return "("..cont..")"
	elseif self.type=="var" then
		return self[1]
	elseif self.type=="cst" then
		return tostring(self[1])
	end
end

function cas.parse(exp)
	--cas.parse all brackets first
	local parsed={}
	local num

	--Functions
	exp,num=exp:gsub("([%a_][%w_]*`*)%s*(%b())",function(pre,arglist)
		local best
		for n,f in next,funcdefs do
			for _,name in next,f.names do
				if pre:find(name,-#name) and (not best or #best<#name) then
					best=n
				end
			end
		end
		if best then
			local n=#parsed+1
			parsed[n]=funcs[best](cas.parse(arglist:sub(2,-2)))
			return pre:sub(1,-#best-1).."["..n.."]"
		else
			for n,f in next,myfuncs do
				if pre:find(n,-#n) and (not best or #best<#n) then
					best=n
				end
			end
			if best then
				local n=#parsed+1
				parsed[n]=myfuncs[best](cas.parse(arglist))
				return pre:sub(1,-#best-1).."["..n.."]"
			end
		end
	end)
	--print(exp)

	--Brackets
	exp,num=exp:gsub("%b()",function(exp)
		local n=#parsed+1
		parsed[n]=cas.parse(exp:sub(2,-2))
		return "["..n.."]"
	end)
	--print(exp)

	--Variables
	exp,num=exp:gsub("[%a_][%w_]*`*",function(var)
		local n=#parsed+1
		parsed[n]=cas.var(var)
		return "["..n.."]"
	end)
	--print(exp)

	--Constants
	exp,num=exp:gsub("()%f[%d%.]%s*(%d*%.?%d*)%s*%f[^%]%d%.]()",function(_0,cst,_1)
		local v=tonumber(cst)
		if v and exp:sub(_0,_0)~="[" and exp:sub(_1,_1)~="]" then
			local n=#parsed+1
			parsed[n]=cas.cst(v)
			return "["..n.."]"
		else
			return cst
		end
	end)
	--print(exp)

	--unm
	repeat
		local bad=0
		exp,num=exp:gsub("()%s*%-%s*%[(%d+)%]",function(_0,s1)
			local n1=tonumber(s1)
			if n1 and exp:sub(_0-1,_0-1)~="]" then
				local n=#parsed+1
				parsed[n]=-parsed[n1]
				return "["..n.."]"
			else
				bad=bad+1
				return "-["..s1.."]"
			end
		end)
	until num-bad<=0
	--print(exp)

	--pow
	repeat
		exp,num=exp:gsub("%[(%d+)%]%s*%^%s*%[(%d+)%]",function(s1,s2)
			local n1,n2=tonumber(s1),tonumber(s2)
			local n=#parsed+1
			parsed[n]=parsed[n1]^parsed[n2]
			return "["..n.."]"
		end,1)
	until num==0
	--print(exp)

	--div
	repeat
		exp,num=exp:gsub("%[(%d+)%]%s*%/%s*%[(%d+)%]",function(s1,s2)
			local n1,n2=tonumber(s1),tonumber(s2)
			local n=#parsed+1
			parsed[n]=parsed[n1]/parsed[n2]
			return "["..n.."]"
		end,1)
	until num==0
	--print(exp)

	--mul
	repeat
		exp,num=exp:gsub("%[(%d+)%]%s*%*?%s*%[(%d+)%]",function(s1,s2)
			local n1,n2=tonumber(s1),tonumber(s2)
			local n=#parsed+1
			parsed[n]=parsed[n1]*parsed[n2]
			return "["..n.."]"
		end,1)
	until num==0
	--print(exp)

	--add
	repeat
		exp,num=exp:gsub("%[(%d+)%]%s*%+%s*%[(%d+)%]",function(s1,s2)
			local n1,n2=tonumber(s1),tonumber(s2)
			local n=#parsed+1
			parsed[n]=parsed[n1]+parsed[n2]
			return "["..n.."]"
		end,1)
	until num==0
	--print(exp)

	--sub
	repeat
		exp,num=exp:gsub("%[(%d+)%]%s*%-%s*%[(%d+)%]",function(s1,s2)
			local n1,n2=tonumber(s1),tonumber(s2)
			local n=#parsed+1
			parsed[n]=parsed[n1]-parsed[n2]
			return "["..n.."]"
		end,1)
	until num==0
	--print(exp)

	--Return everything left
	local explist={}
	for s in exp:gmatch'%[(%d+)%]' do
		explist[#explist+1]=parsed[tonumber(s)]
	end
	return unpack(explist)
end

_G.cas=cas
return cas