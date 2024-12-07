# Parses updates and ordering rules for the safety manual.
# @param [String] path to a file containing both the rules and the updates
# @return [Array<Array<Integer>>, Hash<Integer, Set>] updates and rules
def parse_updates(file)
  rules = Hash.new { |hash, key| hash[key] = Set.new }
  updates = []
  parsing_rules = true
  File.open(file).each do |line|
    if line == "\n"
      parsing_rules = false
      next
    end

    if parsing_rules
      rule = line.strip.split("|")
      first_page_n = rule[0].to_i
      second_page_n = rule[1].to_i
      # map each page to all the pages that need to occur before it
      rules[second_page_n] = rules[second_page_n].add(first_page_n)
    else
      updates.push(line.strip.split(",").map { |el| el.to_i })
    end
  end

  [updates, rules]
end

# Splits the updates in good or bad based on whether they satisfy the rules.
# @param updates [Array<Array<Integer>>] the updates to check
# @param rules [Hash<Integer, Set>] the set of ordering rules
# @return [Array<Integer>, Array<Integer>] correct updates and bad updates
def split_updates(updates, rules)
  correct_updates = []
  bad_updates = []

  updates.each do |update|
    if correct_order?(update, rules)
      correct_updates.push(update)
    else
      bad_updates.push(update)
    end
  end

  [correct_updates, bad_updates]
end

# Checks whether a specific update has all of its pages in the correct order.
# @param update [Array<Integer>] the update to check
# @param rules [Hash<Integer, Set>] the set of ordering rules
# @return [Bool] true if the update is correct, false otherwise
def correct_order?(update, rules)
  forbidden = Set.new
  update.each do |page_n|
    if forbidden.include?(page_n)
      return false
    end

    forbidden = forbidden.union(rules[page_n])
  end

  true
end

# Fixes badly-sorted updates.
# @param updates [Array<Array<Integer>>] the updates to fix
# @param rules [Hash<Integer, Set>] the set of ordering rules
# @return [Array<Array<Integer>>] the input updates, now correctly sorted
def fix_updates(updates, rules)
  updates.map { |update|
    update.sort { |a, b|
      if rules[a].include?(b)
        1
      elsif rules[b].include?(a)
        -1
      end
    }
  }
end

# Sums up all the middle numbers of the input updates.
# @param updates [Array<Array<Integer>>] the updates we are interested in
# @return [Integer] the computed sum
def sum_middle_numbers(updates)
  sum = 0
  updates.each do |update|
    sum += update[(update.length / 2).floor]
  end
  sum
end

updates, rules = parse_updates("input.txt")
correct_updates, bad_updates = split_updates(updates, rules)
fixed_updates = fix_updates(bad_updates, rules)
puts "Sum of middle page numbers: #{sum_middle_numbers(correct_updates)} (correct updates) #{sum_middle_numbers(fixed_updates)} (fixed updates)"
