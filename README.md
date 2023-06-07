# roblox-matrix-library

Roblox Library to perform basic matrix operations

I inspired from this repository: https://github.com/RaghavCodeHub/matrix/tree/master

## Installation

Put this inside your `wally.toml` file:

```toml
roblox-matrix-library = "qaptivator/roblox-matrix-library@0.1.0"
```

## Usage

To create new matrix, use `Matrix.new()`
Here is example of how to make a matrix:

```lua
local Matrix = require(game:GetService("ReplicatedStorage").Packages["roblox-matrix-library"])

local exampleMatrix = Matrix.new({
    {2, 3},
    {7, 5}
})

print(exampleMatrix)
```

This library supports multiple math operations:

- Matrix to matrix:
  - Matrix + Matrix - Adds every item inside matrices to each other. They should be equal size.
  - Matrix - Matrix - Subtracts every item inside matrices to each other. They should be equal size.
  - Matrix \* Matrix - Multiplies every item inside matrices to each other using Dot Product. They can be different sizes.
  - Matrix / Matrix - Divides every item inside matrices to each other. They should be equal size.
  - Matrix ^ Matrix - Exponentiates every item inside matrices to each other. They should be equal size.
  - Matrix % Matrix - Divides every item inside matrices to each other and returns remainders of them. They should be equal size.
- Matrix to number:
  - Matrix + Matrix - Adds every item inside matrices to the number.
  - Matrix - Matrix - Subtracts every item inside matrices to the number.
  - Matrix \* Matrix - Multiplies every item inside matrices to the number.
  - Matrix / Matrix - Divides every item inside matrices to the number.
  - Matrix ^ Matrix - Exponentiates every item inside matrices to the number.
  - Matrix % Matrix - Divides every item inside matrix to the number and returns remainders of them.

It also supports comparison operators:

- Matrix == Matrix - Returns `true` if every item inside first matrix is equal to another item in second matrix. Or else it returns `false`
- Matrix < Matrix - Returns `true` if every item inside first matrix is less than another item in second matrix. Or else it returns `false`
- Matrix <= Matrix - Returns `true` if every item inside first matrix is less than or equal to another item in second matrix. Or else it returns `false`

There are methods for the matrices too:

- Size() - Returns size of the matrix. First index is amountf of rows and second is amount of columns
- IsSquare() - Returns `true` if matrix is square. Or else it returns `false`
- Foreach(callback) - Loops through every item inside matrix. It calls `callback` at every iteration and also gives parameters: `item`, `row`, `column`
- Map(callback) - Loops through every item inside matrix, modifies it and returns the result as new matrix. It calls `callback` at every iteration and also gives parameters: `item`, `row`, `column`, `matrix` (current result)
- Filter(callback) - Loops through every item inside matrix and if it matches condition, adds it to new matrix and returns it. It calls `callback` at every iteration and also gives parameters: `item`, `row`, `column`. You should return `true` for it to pass the condition.
- Transpose() - [Transposes](https://en.wikipedia.org/wiki/Transpose) the matrix.

You can also make matrices using multiple constructors:

- Matrix.new(matrix) - Generates matrix from matrix table.
- Matrix.identity() - Generates an [identity matrix](https://en.wikipedia.org/wiki/Identity_matrix).
- Matrix.generate(size, value) - Generates matrix with the specified size filled with values you have provided.
