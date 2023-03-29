--!strict

local matrixclass = {}
matrixclass.__index = matrixclass

matrixclass.__tostring = function(t)
	local result = {}
	for _,v in ipairs(t) do
		table.insert(result,"\n	")
		for _,el in pairs(v) do
			table.insert(result,el)
		end
	end
	return table.concat(result," ")
end

local function istable(arg)
	return typeof(arg) == 'table'
end

local function size(mat)
	local s = {}
	while typeof(mat) == 'table' do	
		table.insert(s,#mat)
		mat = mat[1]
	end
	return s
end

local function dimensions(mat : table)
	return #size(mat)
end

function matrixclass:size()
	return size(self)
end

function matrixclass.ismatrix(mat : table)
	return getmetatable(mat).__index == matrixclass
end

function matrixclass.new(mat : table)
	return setmetatable(mat, matrixclass)
end

-- roblox-matrix-library
-- Roblox Library to perform basic matrix operations
    
-- link to github repository
-- https://github.com/qaptivator/roblox-matrix-library

return matrixclass
