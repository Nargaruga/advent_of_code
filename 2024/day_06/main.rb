# Denotes the contents of a particular location in the room.
class RoomTile
  OBSTACLE = "#"
  FLOOR = "."
end

# Marks the direction a tile was traversed in.
class DirectionTile
  UP = "^"
  DOWN = "v"
  LEFT = "<"
  RIGHT = ">"

  def self.rotate_clockwise(tile)
    case tile
    when DirectionTile::UP
      DirectionTile::RIGHT
    when DirectionTile::DOWN
      DirectionTile::LEFT
    when DirectionTile::LEFT
      DirectionTile::UP
    when DirectionTile::RIGHT
      DirectionTile::DOWN
    end
  end
end

# A guard patrolling the laboratory.
class Guard
  @x = 0
  @y = 0
  @direction = DirectionTile::UP

  # Obtain the guard's x position.
  # @return the x coordinate of the guard
  def get_x
    @x
  end

  def get_y
    @y
  end

  def get_direction
    @direction
  end

  def initialize(x, y, direction)
    @x = x
    @y = y
    @direction = direction
  end

  # Carry out an action based on the contents of the next tile.
  # @param map [Array<String>] map of the environment
  # @param next_x [Integer] x coordinate of the next tile
  # @param next_y [Integer] y coordinate of the next tile
  def act(map, next_x, next_y)
    if map[next_y][next_x] == RoomTile::OBSTACLE
      turn_clockwise
    else
      move(next_x, next_y)
    end
  end

  # Get the location of the next tile based on where the guard is facing.
  # @return [Integer, Integer] the coordinates of the next tile
  def look_ahead
    case @direction
    when DirectionTile::UP
      [@x, @y - 1]
    when DirectionTile::DOWN
      [@x, @y + 1]
    when DirectionTile::LEFT
      [@x - 1, @y]
    when DirectionTile::RIGHT
      [@x + 1, @y]
    end
  end

  # Move to the next tile.
  # @param next_x [Integer] x coordinate of the tile to move to
  # @param next_y [Integer] y coordinate of the tile to move to
  def move(next_x, next_y)
    @x = next_x
    @y = next_y
  end

  # Turn 90 degrees clockwise.
  def turn_clockwise
    @direction = DirectionTile.rotate_clockwise(@direction)
  end
end

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

# Have the guard patrol around the map.
# @param map [Array<String>] the map to patrol
# @param guard [Guard] the guard to be moved around
# @return [Set, Bool] the set of explored tiles and whether a loop was found
def patrol(map, guard)
  unique_positions = Set.new
  unique_positions.add([guard.get_x, guard.get_y])

  directions_history = Hash.new { |hash, key| hash[key] = Set.new }
  directions_history[[guard.get_x, guard.get_y]].add(guard.get_direction)

  until is_at_border?(map, guard)
    next_x, next_y = guard.look_ahead
    guard.act(map, next_x, next_y)
    guard_pos = [guard.get_x, guard.get_y]

    if unique_positions.include?(guard_pos) &&
        directions_history[guard_pos].include?(guard.get_direction)
      return [unique_positions, true]
    end

    unique_positions.add(guard_pos)
    directions_history[guard_pos].add(guard.get_direction)
  end

  [unique_positions, false]
end

# Check if the guard is at the map's borders.
# @param map [Array<String>] the map
# @param guard [Guard] the guard
# @return [Bool] true if the guard is at the border, false otherwise
def is_at_border?(map, guard)
  next_x, next_y = guard.look_ahead
  if next_y < 0 || next_y >= map.length || next_x < 0 || next_x >= map[0].length
    return true
  end

  false
end

# Create a guard at the position marked on the map.
# @param map [Array<String>] the map containing the location marking
# @return [Guard] the newly instantiated guard
def create_guard(map)
  map.each_with_index do |row, i|
    row.chars.each_with_index do |tile, j|
      if tile == DirectionTile::UP ||
          tile == DirectionTile::LEFT ||
          tile == DirectionTile::DOWN ||
          tile == DirectionTile::RIGHT
        return Guard.new(j, i, tile)
      end
    end
  end
end

# Attempt to place obstacles around the map to lead the guard into a loop.
# @param map [Array<String>] the map to place obstacles in
# @param guard [Guard] the guard patrolling the map
# @param patrolled_tiles [Set] the guard's patrol route
# @return [Integer] the number of obstacle placements
#         that would lead to guard into a loop
def place_obstacles(map, guard, patrolled_tiles)
  potential_obstacles = 0

  patrolled_tiles.each do |tile|
    x = tile[0]
    y = tile[1]
    prev = map[y][x]
    map[y][x] = RoomTile::OBSTACLE

    _, loop = patrol(map, guard.clone)

    if loop
      potential_obstacles += 1
    end

    map[y][x] = prev
  end

  potential_obstacles
end

map = parse_map("input.txt")
guard = create_guard(map)
patrolled_tiles, _ = patrol(map, guard.clone)
puts "Patrolled tiles: #{patrolled_tiles.length}"
potential_obstacles = place_obstacles(map, guard.clone, patrolled_tiles)
puts "Potential obstacle positions: #{potential_obstacles}"
