# Parses incomplete expressions from a file and sums up the results
#   of the ones that can be fixed by placing +, * and || (concatenation) operators.
# @param file [String] path to the file containing the operations
# @return [Integer] the sum of all the valid results
def sum_valid_results(file)
  sum = 0

  File.open(file).each do |line|
    res = line.split(":")[0].strip.to_i
    operands = line.split(":")[1].split(" ").map { |op| op.strip.to_i }

    if valid?(res, operands, 0)
      sum += res
    end
  end

  sum
end

# Recursively checks if an incomplete expression can be fixed by
#   attempting to place one of the available operators in each slot.
# @param res [Integer] the desired result
# @param operands [Array<Integer>] the operands making up the expression
# @param partial [Integer] the current partial result
# @return [Bool] true if the final result is equal to the expected result, false otherwise
def valid?(res, operands, partial)
  if partial > res
    return false
  end

  if operands.empty?
    return partial == res
  end

  # Quite slow!
  valid?(res, operands[1..], apply_op(:plus, operands.first, partial)) ||
    valid?(res, operands[1..], apply_op(:times, operands.first, partial)) ||
    valid?(res, operands[1..], apply_op(:concat, operands.first, partial))
end

# Applies a binary arithmetic operator.
# @param op [Symbol] the operator to apply, can be :plus, :minus or :concat
# @param a [Integer] the first operand
# @param b [Integer] the second operand
# @return [Integer] the result of applying the operator to the two operands
def apply_op(op, a, b)
  if op == :plus
    a + b
  elsif op == :times
    a * b
  elsif op == :concat
    (b.to_s + a.to_s).to_i
  end
end

p sum_valid_results("input.txt")
