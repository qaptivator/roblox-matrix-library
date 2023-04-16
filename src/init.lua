--!strict
local Matrix = {}
Matrix.__index = Matrix

--[|=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=|]--

-- roblox-matrix-library
-- Roblox Library to perform basic matrix operations.

-- Link to GitHub repository:
-- https://github.com/qaptivator/roblox-matrix-library

--[|=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=|]--

type matrix = {{number}}

--[ Functions ]--
function Matrix.new(mat: matrix)
	return setmetatable(mat, Matrix)
end

function Matrix.identity(size: number)
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
	return Matrix.new(result)
end

function Matrix.generate(size: {number}, value: number)
	local result = {}
	for i=0, size, 1 do
		if not result[i] then
			result[i] = {}
		end
		for j=0, size, 1 do
			result[i][j] = value
		end
	end
	return Matrix.new(result)
end

function Matrix.fromVector3(vector: Vector3)
	return Matrix.new({
		{ vector.X },
		{ vector.Y },
		{ vector.Z }
	})
end

function Matrix.fromVector2(vector: Vector2)
	return Matrix.new({
		{ vector.X },
		{ vector.Y }
	})
end

function Matrix.fromUDim2(udim2: UDim2)
	return Matrix.new({
		{ udim2.Height.Scale, udim2.Width.Scale },
		{ udim2.Height.Offset, udim2.Width.Offset }
	})
end

--[ Local Functions ]--
local function isMatrix(mat: matrix)
	return getmetatable(mat).__index == Matrix
end

local function sign(num: number)
	if num > 0 then
		return 1
	elseif num < 0 then
		return -1
	else
		return num
	end
end

local function tableEquality(a: {}, b: {})
	for i,v in next, a do 
		if b[i] ~= v then 
			return false 
		end 
	end
	for i,v in next, b do 
		if a[i] ~= v then 
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
	table.insert(result, #mat)
	table.insert(result, #mat[1])
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
		if type(mat[i]) == "table" then
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
	local dim = dimensions(mat)
	for i = 1, dim, 1 do
		local d = args[i]

		if d == nil then
			break
		end
		
		if type(d) == "table" then
			mat = extractRange(mat, d, i)
		elseif type(d) == "number" then
			if dim > 1 and i > 1 then
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

local function multiplyMatrices(matrixA: matrix, matrixB: matrix)
	local size1 = size(matrixA)
	local size2 = size(matrixB)
	local result = {}
	if size1[2] == size2[1] then
		for i=1, size1[1], 1 do
			result[i] = {}
			for j=1, size2[2], 1 do
				for k=1, size1[2], 1 do
					if not result[i][j] then
						result[i][j] = 0
					end
					result[i][j] += matrixA[i][k]*matrixB[k][j]
				end
			end
		end
	end

	return Matrix.new(result)
end

local function multiplyMatrixWithNumber(matrixA: matrix | number, matrixB: matrix | number)
	local mat = Matrix.new( if type(matrixB) == "number" then matrixA else matrixB )
	local num = if type(matrixA) == "number" then matrixA else matrixB

	return Matrix.new(map(mat, function(elem)
		return elem*num
	end))
end

local function transpose(mat: matrix)
	local s = size(mat)
	local output = {}
	for i=1, s[1], 1 do
		for j=1, s[2], 1 do
			if type(output[j]) == "table" then
				table.insert(output[j], mat[i][j])
			else
				output[j] = { mat[i][j] }
			end
		end
	end
	return Matrix.new(output)
end

-- [ Rational ] --

-- coming soon

--[ Methods ]--

function Matrix:size()
	return size(self)
end

function Matrix:map(funct)
	return map(self, funct)
end

function Matrix:add(matrixB: matrix)
	print(matrixB)
	if tableEquality(size(self), size(matrixB)) then
		return Matrix.new(map(self, function(elem, ind)
			return elem + matrixB[ind[1]][ind[2]]
		end))
	else
		return error("Input matrices should be the same size")
	end
end

function Matrix:subtract(matrixB: matrix)
	if tableEquality(size(self), size(b)) then
		return Matrix.new(map(self, function(elem, ind)
			return elem - matrixB[ind[1]][ind[2]]
		end))
	else
		return error("Input matrices should be the same size")
	end
end

function Matrix:multiply(mat: matrix | number)
	if type(self) ~= "number" and type(mat) ~= "number" then
		return multiplyMatrices(self, mat)
	else
		return multiplyMatrixWithNumber(self, mat)
	end
end

function Matrix:exponentMatrix(power: number)
	if power == 0 then
		return 1
	elseif power % 2 == 0 then -- power is even
		return Matrix.exponentMatrix(self * self, power / 2)
	else -- power is odd
		return self * Matrix.exponentMatrix(self * self, (power - 1) / 2)
	end
end

function Matrix:populate(value: number)
	return Matrix.new(map(self, function(elem)
		elem = value
		return elem
	end))
end

function Matrix:equals(mat: matrix)
	return matrixEquality(self, mat)
end

function Matrix:stringify()
	local result = {}
	for _,v in ipairs(self) do
		table.insert(result,"\n	")
		for _,el in pairs(v) do
			table.insert(result,el)
		end
	end	
	return table.concat(result," ")
end

Matrix.transpose = transpose

--[ Metamethods ]--
Matrix.__call = function(mat: matrix, x: number | {}, y: number | {})
	if not x or not y then
		return mat
	else
		return extract(mat, {x, y})
	end
end

Matrix.__eq = matrixEquality

Matrix.__add = Matrix.add

Matrix.__sub = Matrix.subtract

Matrix.__mul = Matrix.multiply

Matrix.__pow = Matrix.exponentMatrix

return Matrix