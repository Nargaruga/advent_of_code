# Count the number of occurrences of pairs of "MAS" arranged in a cross.
# @param file [String] path to the file containing the word puzzle
# @return [Integer] the final result
def count_occurrences(file)
  matrix = []
  File.open(file).each do |line|
    matrix.append(line.strip)
  end

  occurrences = 0
  matrix.each_with_index do |line, i|
    line.each_char.with_index do |char, j|
      if char == "A"
        if check_diagonal(matrix, i, j, :main) && check_diagonal(matrix, i, j, :anti)
          occurrences += 1
        end
      end
    end
  end

  occurrences
end

# Check if a 3-long diagonal centered in the specified coordinates
#   spells the "MAS" word, either straight on or reversed.
# @param matrix [<Array<Array<String>>] the word matrix
# @param i [Integer] row index of the point crossed by the diagonal
# @param j [Integer] column index of the point crossed by the diagonal
# @param direction [Symbol] direction of the diagonal, either :main or :anti
# @return [Bool] true if the specified diagonal spells either "MAS" or "SAM", false otherwise
def check_diagonal(matrix, i, j, direction)
  i1, j1, i2, j2 = get_indices(i, j, direction)
  unless valid_indices?(matrix, i1, j1) && valid_indices?(matrix, i2, j2)
    return false
  end

  (matrix[i1][j1] == "M" && matrix[i2][j2] == "S") ||
    (matrix[i1][j1] == "S" && matrix[i2][j2] == "M")
end

# Compute the indices of the extremities of the specified diagonal.
# @param i [Integer] row index of the point crossed by the diagonal
# @param j [Integer] column index of the point crossed by the diagonal
# @param direction [Symbol] direction of the diagonal, either :main or :anti
# @return [Array<Integer>] the coordinates of the diagonal's extremities
def get_indices(i, j, direction)
  if direction == :main
    [i - 1, j - 1, i + 1, j + 1]
  elsif direction == :anti
    [i - 1, j + 1, i + 1, j - 1]
  end
end

# Check if two indices fall into the matrix's boundaries.
# @param matrix [Array<Array<Char>>] the matrix we want to check the indices against
# @param i [Integer] row index to check
# @param j [Integer] column index to check
# @return [Bool] true if the indices are valid, valse otherwise
def valid_indices?(matrix, i, j)
  i >= 0 && i < matrix.length && j >= 0 && j < matrix[0].length
end

puts "X-MAS occurrences: %d" % count_occurrences("input.txt")
