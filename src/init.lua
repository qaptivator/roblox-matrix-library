--!strict

--[[

	roblox-matrix-library
	Roblox Library to perform basic matrix operations.

	Link to GitHub repository:
	https://github.com/qaptivator/roblox-matrix-library
	
--]]

-- matrix indexing:
-- {row (y), column (x)}

local Matrix = {}
Matrix.__index = Matrix

type matrix = { { number } }

local function size(matrix: matrix)
	return { #matrix, #matrix[1] }
end

local function ForeachM(matrix: matrix, callback: (item: number, row: number, col: number) -> any)
	for i, v in ipairs(matrix) do
		for j in ipairs(v) do
			callback(matrix[i][j], i, j)
		end
	end
end

local function MapM(matrix: matrix, callback: (item: number, row: number, col: number, matrix: matrix) -> any)
	local result = {}
	for i, v in ipairs(matrix) do
		result[i] = {}
		for j in ipairs(v) do
			result[i][j] = callback(matrix[i][j], i, j, result)
		end
	end
	return Matrix.new(result)
end

local function FilterM(matrix: matrix, callback: (item: number, row: number, col: number) -> any)
	local result = {}
	for i, v in ipairs(matrix) do
		for j in ipairs(v) do
			if callback(matrix[i][j], i, j) == true then
				result[i][j] = matrix[i][j]
			end
		end
	end
	return Matrix.new(result)
end

--local function dimension(matrix: matrix)
--	return #size(matrix)
--end

function Matrix.new(matrix: matrix)
	return setmetatable(matrix, Matrix)
end

function Matrix.identity(size: { number })
	local result = {}
	for i = 1, size[1] do
		result[i] = {}
		for j = 1, size[2] do
			if i == j then
				result[i][j] = 1
			else
				result[i][j] = 0
			end
		end
	end
	return Matrix.new(result)
end

function Matrix.generate(size: { number }, value: number)
	local result = {}
	for i = 1, size[1] do
		result[i] = {}
		for j = 1, size[2] do
			result[i][j] = value
		end
	end
	return Matrix.new(result)
end

function Matrix:Size()
	return size(self)
end

function Matrix:IsSquare()
	return size(self)[1] == size(self)[2]
end

function Matrix:Foreach(callback: (item: number, row: number, col: number) -> any)
	ForeachM(self, callback)
end

function Matrix:Map(callback: (item: number, row: number, col: number, matrix: matrix) -> any)
	MapM(self, callback)
end

function Matrix:Filter(callback: (item: number, row: number, col: number) -> any)
	FilterM(self, callback)
end

function Matrix:Transpose()
	local result = {}
	ForeachM(self, function(value, row, col)
		if type(result[col]) == "table" then
			table.insert(result[col], value)
		else
			result[col] = { value }
		end
		return
	end)
	return Matrix.new(result)
end

function Matrix:__call(row: number, col: number)
	return self[row][col] or nil
end

function Matrix:__unm()
	return MapM(self, function(item)
		return -item
	end)
end

function Matrix:__add(matrixB: matrix | number)
	if type(matrixB) == "number" then
		return MapM(self, function(item: number, row, col)
			return item + matrixB
		end)
	else
		if size(self) == size(matrixB) then
			return MapM(self, function(item, row, col)
				return item :: number + matrixB[row][col]
			end)
		else
			error("Matrices should be equal size!")
		end
	end
end

function Matrix:__sub(matrixB: matrix | number)
	if type(matrixB) == "number" then
		return MapM(self, function(item: number, row, col)
			return item - matrixB
		end)
	else
		if size(self) == size(matrixB) then
			return MapM(self, function(item, row, col)
				return item :: number - matrixB[row][col]
			end)
		else
			error("Matrices should be equal size!")
		end
	end
end

function Matrix:__mul(matrixB: matrix | number)
	if type(matrixB) == "number" then
		return MapM(self, function(item: number)
			return item + matrixB
		end)
	else
		local result = {}
		for i in ipairs(self) do
			result[i] = {}
			for j in ipairs(matrixB[1]) do
				local sum = 0
				for k in ipairs(self[1]) do
					sum += self[i][k] :: number * matrixB[k][j]
				end
				result[i][j] = sum
			end
		end
		return Matrix.new(result)
	end
end

function Matrix:__div(matrixB: matrix | number)
	if type(matrixB) == "number" then
		return MapM(self, function(item: number, row, col)
			return item / matrixB
		end)
	else
		if size(self) == size(matrixB) then
			return MapM(self, function(item, row, col)
				return item :: number / matrixB[row][col]
			end)
		else
			error("Matrices should be equal size!")
		end
	end
end

function Matrix:__mod(matrixB: matrix | number)
	if type(matrixB) == "number" then
		return MapM(self, function(item: number, row, col)
			return item % matrixB
		end)
	else
		if size(self) == size(matrixB) then
			return MapM(self, function(item, row, col)
				return item :: number % matrixB[row][col]
			end)
		else
			error("Matrices should be equal size!")
		end
	end
end

function Matrix:__pow(matrixB: matrix | number)
	if type(matrixB) == "number" then
		return MapM(self, function(item: number, row, col)
			return item ^ matrixB
		end)
	else
		if size(self) == size(matrixB) then
			return MapM(self, function(item, row, col)
				return item :: number ^ matrixB[row][col]
			end)
		else
			error("Matrices should be equal size!")
		end
	end
end

function Matrix:__eq(matrixB: matrix)
	if size(self) ~= size(matrixB) then
		local result = FilterM(self, function(item, row, col)
			return item == matrixB[row][col]
		end)
		return (result and true) or false
	else
		error("Matrices should be equal size")
	end
end

function Matrix:__lt(matrixB: matrix)
	if size(self) ~= size(matrixB) then
		local result = FilterM(self, function(item, row, col)
			return item < matrixB[row][col]
		end)
		return (result and true) or false
	else
		error("Matrices should be equal size")
	end
end

function Matrix:__le(matrixB: matrix)
	if size(self) ~= size(matrixB) then
		local result = FilterM(self, function(item, row, col)
			return item <= matrixB[row][col]
		end)
		return (result and true) or false
	else
		error("Matrices should be equal size")
	end
end

function Matrix.__tostring(matrix: matrix)
	local result = "\n"

	for i, v in ipairs(matrix) do
		for j in ipairs(v) do
			result = result .. matrix[i][j] .. " "
		end
		result = result .. "\n"
	end

	return result
end

return Matrix
