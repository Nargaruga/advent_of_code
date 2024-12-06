# Sum up the results of all the valid multiplication operations in the input memory dump.
# @param file [String] path to the file describing the memory contents
# @return [Integer] the final result
def evaluate_valid_ops(file)
  # Recognizes multiplications in the form mul(x1,x2) where x1 and x2 are integers
  op_regex = /mul\(([0-9]+),([0-9]+)\)/m
  # Recognizes areas delimited by a do() and a don't()
  valid_area_regex = /(?:do\(\)|\A).*?(?:don't\(\)|\z)/m

  input = File.read(file)

  res = 0
  input.scan(valid_area_regex).each do |area|
    area.scan(op_regex).each do |x1, x2|
      res += x1.to_i * x2.to_i
    end
  end

  res
end

puts "Final value: %d" % evaluate_valid_ops("input.txt")
