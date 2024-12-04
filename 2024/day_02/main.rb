# Counts the number of safe reports.
# @param file [String] path to the file containing the reports
# @return [Integer] the number of safe reports
def count_safe_reports(file)
  safe_reports = 0
  File.open("input.txt").each do |report|
    levels = report.split.map { |str| str.to_i }
    if safe?(levels, true)
      safe_reports += 1
    end
  end
  safe_reports
end

# Checks if a report is safe.
# @param levels [Array<Integer>] levels recorded in the report
# @param tolerant [Bool] whether we will tolerate a bad level or not
# @return [Bool] true if the report is safe, false otherwise
def safe?(levels, tolerant)
  if levels.length <= 1
    return true
  end

  global_trend = get_global_trend(levels)
  prev = levels[0]

  levels[1..].each_with_index do |level, idx|
    i = idx + 1

    if bad?(prev, level, global_trend)
      unless tolerant
        return false
      end

      skip_curr = if i == levels.length - 1
        levels[..i - 1]
      else
        levels[..i - 1] + levels[i + 1..]
      end
      skip_prev = if i == 1
        levels[i..]
      else
        levels[..i - 2] + levels[i..]
      end

      return safe?(skip_curr, false) || safe?(skip_prev, false)
    end

    prev = level
  end

  true
end

# Checks if adjacent levels respect safety parameters.
# @params prev [Integer] the previous level
# @params curr [Integer] the current level
# @params trend [Symbol] the overall ordering of levels
# @return [Bool] true if adjacent levels are within safety parameters, false otherwise.
def bad?(prev, curr, trend)
  unless (curr - prev).abs.between?(1, 3) &&
      get_local_trend(prev, curr) == trend
    true
  end
end

# Determines the overall ordering direction of the report.
# @param levels [Array<Integer>] the levels to check the ordering of
# @return [Symbol] the ordering direction (:increasing or :decreasing)
def get_global_trend(levels)
  increasing_steps = 0
  decreasing_steps = 0
  prev = levels[0]
  levels[1..].each do |level|
    if prev <= level
      increasing_steps += 1
    else
      decreasing_steps += 1
    end

    prev = level
  end

  if increasing_steps >= decreasing_steps
    :increasing
  else
    :decreasing
  end
end

# Determine the ordering of two levels.
# @param prev [Integer] the previous level
# @param curr [Integer] the current level
# @return [Symbol] the ordering direction (:increasing or :decreasing)
def get_local_trend(prev, curr)
  if prev <= curr
    :increasing
  else
    :decreasing
  end
end

puts "Safe reports: %d" % count_safe_reports("input.txt")
