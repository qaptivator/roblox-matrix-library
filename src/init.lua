--!strict
local matrixclass = {}
matrixclass.__index = matrixclass
type matrix = {{number}}

function matrixclass.new(mat: matrix)
	return setmetatable(mat, matrixclass)
end

--[|=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=|]--

-- roblox-matrix-library
-- Roblox Library to perform basic matrix operations.

-- Link to GitHub repository:
-- https://github.com/qaptivator/roblox-matrix-library

--[|=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=|]--

local function istable(arg: any)
	return typeof(arg) == 'table'
end

local function ismatrix(mat: matrix)
	return getmetatable(mat).__index == matrixclass
end

local function tableEquality(a: {}, b: {})
	for i,v in next, a do 
		if b[i]~=v then 
			return false 
		end 
	end
	for i,v in next, b do 
		if a[i]~=v then 
			return false 
		end 
	end
	return true
end

local function matrixEquality(a: matrix, b: matrix)
	for i,v in next, a do
		 if not tableEquality(b[i],v) then 
			return false 
		end 
	end
	for i,v in next, b do 
		if not tableEquality(a[i],v) then 
			return false
		end 
	end
	return true
end

local function reverse(t: {})
	for i = 1, math.floor(#t/2) do
		local j = #t - i + 1
		t[i], t[j] = t[j], t[i]
	end
	return t
end

local function size(mat: matrix)
	local result = {}
	table.insert(result,#mat)
	table.insert(result,#mat[1])
	return result
end

local function dimensions(mat: matrix)
	return #size(mat)
end

local function interchange(mat: matrix, ind1: number, ind2: number)
	mat[ind1], mat[ind2] = mat[ind2], mat[ind1]
	return mat
end

local function map(mat: matrix, funct: (any, {number}, matrix) -> (any)) -- (element, {row, column}, matrix)
	local result = {}
	for i,_ in ipairs(mat) do
		if istable(mat[i]) then
			result[i] = {}
			for j,_ in ipairs(mat[i]) do
				result[i][j] = funct(mat[i][j], {i,j}, mat)
			end
		else
			result[i] = funct(mat[i], {i,0}, mat)
		end
	end
	return result
end

local function rationalize(mat: matrix)
	return matrixclass.new(map(mat,function(elem)
		return rational(elem) -- get this from ration.js in the repo
	end))
end

local function derationalize(mat: matrix)
	return matrixclass.new(map(mat,function(elem)
		return elem.num/elem.den --??
	end))
end

local function extractRange(mat: matrix, starts: number, ends: number)
	if #starts > 2 or #starts == 1 then
		return mat
	elseif #starts == 2 then
		local reverse = starts[1] > starts[2]
		local first, last
		if not reverse then
			first, last = starts[1], starts[2]
		else
			first, last = starts[2], starts[1]
		end
		if dimensions(mat) > 1 and ends > 1 then
			return map(mat, function(elem)
				if reverse then
					return reverse(string.sub(elem,first,last+1))
				end
				return string.sub(elem,first,last+1)
			end)
		else
			mat = string.sub(mat,first,last+1)
			return reverse and reverse(mat) or mat
		end
	end
end

local function extract(mat: matrix, args: {})
	for i,_ in ipairs(mat) do
		local d = args[i]
		if not d then
			break
		end
		if istable(d) then
			mat = extractRange(mat, d, i)
		elseif typeof(d) == 'number' then
			if dimensions(mat) > 1	and i > 1 then
				mat = map(mat, function(elem)
					return elem[d]
				end)
			else
				mat = mat[d]
			end
		end
	end
	return mat
end

local function add(a: matrix, b: matrix)
	if tableEquality(size(a), size(b)) then
		return matrixclass.new(map(a, function(elem, ind)
			return elem+b[ind[1]][ind[2]]
		end))
	else
		return error("Input matrices should be the same size")
	end
end

local function sub(a: matrix, b: matrix)
	if tableEquality(size(a), size(b)) then
		return matrixclass.new(map(a, function(elem, ind)
			return elem-b[ind[1]][ind[2]]
		end))
	else
		return error("Input matrices should be the same size")
	end
end

local function mul(a: matrix, b: matrix)
	local size1 = size(a)
	local size2 = size(b)
	local result = {}
	if size1[2] == size2[1] then
		for i=1, size1[1], 1 do
			result[i] = {}
			for j=1, size2[2], 1 do
				for k=1, size1[2], 1 do
					if not result[i][j] then
						result[i][j] = 0
					end
					result[i][j] += a[i][k]*b[k][j]
				end
			end
		end
	end
	return matrixclass.new(result)
end

local function mulnum(a: matrix | number, b: matrix | number)
	local mat = matrixclass.new({})
	local num = 0
	if typeof(a) == "number" and typeof(b) ~= "number" then
		mat, num = b, a
	else
		mat, num = a, b
	end
	return matrixclass.new(map(mat, function(elem)
		return elem*num
	end))
end

local function transpose(mat: matrix)
	local s = size(mat)
	local output = {}
	for i=1, s[1], 1 do
		for j=1, s[2], 1 do
			if istable(output[j]) then
				table.insert(output[j], mat[i][j])
			else
				output[j] = {mat[i][j]}
			end
		end
	end
	return matrixclass.new(output)
end

function matrixclass:size()
	return size(self)
end

function matrixclass:map(funct)
	return map(self, funct)
end

function matrixclass:add(arg)
	return add(self,arg)
end

function matrixclass:sub(arg)
	return sub(self,arg)
end

function matrixclass:mul(arg: matrix | number)
	if typeof(self) ~= "number" and typeof(arg) ~= "number" then
		return mul(self,arg)
	else
		return mulnum(self,arg)
	end
end	

function matrixclass:transpose()
	return transpose(self)
end

function matrixclass:populate(value: number)
	return matrixclass.new(map(self, function(elem)
		elem = value
		return elem
	end))
end

function matrixclass.identity(size: number)
	local result = {}
	for i=0, size, 1 do
		if not result[i] then
			result[i] = {}
		end
		for j=0, size, 1 do
			if i == j then
				result[i][j] = 1
			else
				result[i][j] = 0
			end
		end
	end
	return matrixclass.new(result)
end

function matrixclass.generate(size: {number}, value: number)
	local result = {}
	for i=0, size, 1 do
		if not result[i] then
			result[i] = {}
		end
		for j=0, size, 1 do
			result[i][j] = value
		end
	end
	return matrixclass.new(result)
end

function matrixclass:equals(mat: matrix)
	return matrixEquality(self, mat)
end

function matrixclass:stringify()
	local result = {}
	for _,v in ipairs(self) do
		table.insert(result,"\n	")
		for _,el in pairs(v) do
			table.insert(result,el)
		end
	end
	return table.concat(result," ")
end

matrixclass.__call = function(mat: matrix, args: number | {})
	if not args then
		return mat
	else
		return extract(mat, args)
	end
end

--matrixclass.__tostring = function(t)
	--local result = {}
	--for _,v in ipairs(t) do
		--table.insert(result,"\n	")
		--for _,el in pairs(v) do
			--table.insert(result,el)
		--end
	--end
	--return table.concat(result," ")
--end

return matrixclass