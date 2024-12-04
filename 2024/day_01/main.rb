# Computes the distance between two lists by comparing adjacent elements.
# @param left_list [Array<Integer>] the first list to compare
# @param right_list [Array<Integer>] the second list to compare
# @return [Integer] the overall distance
def compute_distance(left_list, right_list)
  distance = 0
  zipped = left_list.sort.zip(right_list.sort)
  zipped.each do |left, right|
    distance += (left - right).abs
  end

  distance
end

# Computes a similarity score between two lists.
# @param left_list [Array<Integer>] the first list to compare
# @param right_list [Array<Integer>] the second list to compare
# @return [Integer] the score
def compute_similarity(left_list, right_list)
  occurrences = Hash.new(0)
  right_list.each do |el|
    occurrences[el] += 1
  end

  score = 0
  left_list.each do |el|
    score += el * occurrences[el]
  end

  score
end

left_list = []
right_list = []
File.open("input.txt").each do |line|
  left_list.append(line.split[0].to_i)
  right_list.append(line.split[1].to_i)
end

puts "Distance: %d" % compute_distance(left_list, right_list)
puts "Similarity: %d" % compute_similarity(left_list, right_list)
