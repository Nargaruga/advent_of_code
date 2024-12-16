# Denotes a position on the map.
Position = Struct.new(:x, :y)

# Parse the map from the input file.
# @param file [String] path to the file
# @return [Array<String>] the map
def parse_map(file)
  map = []
  File.open(file).each do |line|
    map.push(line.strip)
  end
  map
end

# Locate all the antennas on the map.
# @param map [Array<String>] the map to inspect
# @return [Hash<String, Set<Position>>] a hash associating each frequency to the set
#   of positions of all antennas tuned to that specific frequency
def locate_antennas(map)
  antennas = Hash.new { |hash, key| hash[key] = Set.new }

  map.each_with_index do |line, y|
    line.each_char.with_index do |freq, x|
      unless freq == "."
        antennas[freq].add(Position.new(x, y))
      end
    end
  end

  antennas
end

# Count the number of unique antinode positions.
# @param antennas [Hash<String, Set<Position>>] antenna frequencies and associated positions
# @param map [Array<String>] the map to perform the search in
# @return [Integer] number of unique antinode positions
def count_antinodes(antennas, map)
  antinodes = Set.new

  antennas.each_key do |freq|
    antennas[freq].to_a.combination(2).each do |p1, p2|
      dx = p2.x - p1.x
      dy = p2.y - p1.y

      antinodes = antinodes | find_antinodes(p1, dx, dy, 1, map) | find_antinodes(p2, dx, dy, -1, map)
    end
  end

  antinodes.size
end

# Find all antinodes along a straight line appearing at set intervals from a certain point onwards.
# @param start [Position] the starting point on the line
# @param dx [Integer] the x-axis offset for each step
# @param dy [Integer] the y-axis offset for each step
# @param direction [Integer] direction in which to follow the line (either +1 or -1)
# @param map [Array<String>] the map to perform the search in
# @return [Set<Position>] the set of detected antinodes
def find_antinodes(start, dx, dy, direction, map)
  antinodes = Set.new

  i = 1
  loop do
    antinode = Position.new(start.x + dx * i * direction, start.y + dy * i * direction)
    unless valid?(antinode, map)
      break
    end

    antinodes.add(antinode)
    i += 1
  end

  antinodes
end

# Check if an antinode is falls within the map boundaries.
# @param pos [Position] the position of the antinode
# @param map [Array<String>] the map
# @return [Bool] true if the antinode is valid, false otherwise
def valid?(pos, map)
  pos.y.between?(0, map.length - 1) && pos.x.between?(0, map[0].length - 1)
end

map = parse_map("input.txt")
antennas = locate_antennas(map)
p "Unique antinode positions: #{count_antinodes(antennas, map)}"
