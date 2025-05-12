class_name DungeonGenerator
extends Node2D

enum GenerationCycleState {
	CIRCLE,
	SEPERATION,
	DISCARD_SMALL_ROOMS,
	DISCARD_BORDERING_ROOMS,
	TRIANGULATION,
	SPANNING_TREE_ALGORITHM,
	CORRIDORS,
	DONE
}

@export var debug_draw: bool = true
@export var is_slowly_generating: bool
var rooms: Array[DungeonRoom] = []

var _is_generating: bool
var _current_seed: int  #TODO: Implementation

var _center: Vector2 = Vector2(300, 300)
var _init_radius: int = 100
var _init_room_count: int = 200
var _room_size_bounds: Vector2 = Vector2(4, 40)
var _room_size_threshold: int = 30
var _cur_triangulate_room: int

var _debug_rooms: Array[DungeonRoom]
var _minimum_spanning_tree: Array[Edge]

var _triangulation: DelaunaryTriangulation = DelaunaryTriangulation.new()
var _current_generation_state: GenerationCycleState


func _init():
	pass


func _ready() -> void:
	seed(1)
	generate_dungeon()


func _physics_process(_delta: float) -> void:
	update()
	queue_redraw()


#region private functions
func _create_rooms_in_circle():
	for i in _init_room_count:
		_create_room_in_circle()


func _create_room_in_circle():
	var r = _init_radius * sqrt(randf_range(0.0, 1.0))  #TODO:RNGImplementation
	var theta = randf_range(0.0, 1.0) * 2 * PI  #TODO:RNGImplementation
	var pos = Vector2i(floori(r * cos(theta)), floori(r * sin(theta)))
	var size = Vector2i(
		randi_range(int(_room_size_bounds.x), int(_room_size_bounds.y)),
		randi_range(int(_room_size_bounds.x), int(_room_size_bounds.y))
	)
	var room_color = Color.RED
	rooms.push_back(DungeonRoom.new(Vector2i(_center) + pos, size, room_color))


func _seperate_rooms() -> bool:  #TODO:Speed this up somhow (pereprocessing) Quadtree
	var max_speed = 3
	var is_every_room_seperated = true

	var quadtree_boundary = QuadTree.get_boundary(rooms)
	var quadtree = QuadTree.new(quadtree_boundary)

	for room in rooms:
		if !quadtree.insert(QuadTreePoint.from_room(room)):
			push_warning("Room:"+str(room.get_center())+" was not inserted")
	var avg_querryed_data = 0
	var start_time = Time.get_unix_time_from_system()
	for room in rooms:
		var seperation_direction: Vector2 = Vector2.ZERO
		var querry = QuadTree.create_querry(room, self)
		var querried_data: Array[QuadTreePoint] = quadtree.querry(
			querry
		)
		avg_querryed_data += len(querried_data)
		for querryed_point in querried_data:
			var other_room = querryed_point.meta_data

			if room == other_room:
				continue
			if !room.is_overlapping(other_room):
				continue

			is_every_room_seperated = false

			var cur_direction: Vector2 = room.get_center() - other_room.get_center()
			cur_direction = cur_direction.normalized()
			cur_direction *= max_speed

			seperation_direction += cur_direction

		room.move(seperation_direction)
	var end_time = Time.get_unix_time_from_system()
	print("Total:",avg_querryed_data," Durchschnitt:",avg_querryed_data / len(rooms))
	print("TotalTime:",end_time-start_time," DurchschnittTime:",(end_time-start_time) / len(rooms))
	return is_every_room_seperated


func _discard_small_rooms(debug: bool):
	for i in range(len(rooms) - 1, -1, -1):
		var room = rooms[i]
		if room.get_size().x < _room_size_threshold or room.get_size().y < _room_size_threshold:
			_debug_rooms.push_back(room)
			rooms.erase(room)
			if debug:
				return false
	return true


func _discard_bordering_rooms(debug: bool):  #TODO:Optimize evl. ???
	var min_corridor_size: int = 10
	for i in range(len(rooms) - 1, -1, -1):
		var room = rooms[i]
		for j in range(len(rooms) - 1, -1, -1):
			if i == j:
				continue
			var other = rooms[j]
			var distance: Vector2 = room.get_center() - other.get_center()
			var room_dist = abs(distance)

			var min_corridor_size_space = (
				room.get_size() / 2
				+ other.get_size() / 2
				+ Vector2(min_corridor_size, min_corridor_size)
			)

			var is_corridor_flat: bool = room_dist.x > room_dist.y

			if (
				(is_corridor_flat and room_dist.x < min_corridor_size_space.x)
				or (!is_corridor_flat and room_dist.y < min_corridor_size_space.y)
			):
				_debug_rooms.push_back(room)
				rooms.erase(room)
				if debug:
					return false
				break
	return true


func _create_minimum_spanning_tree():
	var forest: Array[DungeonTree] = []
	var edges: Array[Edge] = _triangulation.create_set_of_edges()
	var edgy_sort = func(edge: Edge, other_edge: Edge): return edge.less(other_edge)
	edges.sort_custom(edgy_sort)

	var nr_vertices = _triangulation.get_size()

	while !edges.is_empty() && (forest.is_empty() || forest[0].edges.size() < nr_vertices - 1):
		var cur_edge: Edge = edges[0]
		edges.erase(cur_edge)

		var creates_loop: bool = false

		var connected_tree_idx = -1

		for i in len(forest):
			var tree = forest[i]
			var connection := tree.is_edge_connected(cur_edge)

			if connection == DungeonTree.DungeonTreeConnectionState.LOOP:
				creates_loop = true
				break

			if connection != DungeonTree.DungeonTreeConnectionState.CONNECTED:
				continue

			if connected_tree_idx == -1:
				connected_tree_idx = i
			else:
				forest[connected_tree_idx].merge(tree)
				forest.remove_at(i)
				break
		if creates_loop:
			continue

		if connected_tree_idx == -1:
			forest.push_back(DungeonTree.new(cur_edge))
		else:
			forest[connected_tree_idx].add(cur_edge)

	_minimum_spanning_tree = forest[0].edges


func _create_corridors():
	var min_size: int = 20
	var corridor_color = Color8(255, 127, 127)
	for edge in _minimum_spanning_tree:
		var room0 = rooms[edge.p0.dungeon_room_idx]
		var room1 = rooms[edge.p1.dungeon_room_idx]

		var direction_x01: bool
		var direction_y01: bool

		var bottom_left: Vector2

		if room0.get_center().x < room1.get_center().x:
			bottom_left.x = room0.get_center().x
			direction_x01 = true
		else:
			bottom_left.x = room1.get_center().x

		if room0.get_center().y < room1.get_center().y:
			bottom_left.y = room0.get_center().y
			direction_y01 = true
		else:
			bottom_left.y = room1.get_center().y

		var size = abs(room0.get_center() - room1.get_center())

		if size.x < min_size:
			var size_grow = min_size - size.x
			size.x = min_size
			bottom_left.x -= size_grow / 2

		if size.y < min_size:
			var size_grow = min_size - size.y
			size.y = min_size
			bottom_left.y -= size_grow / 2

		var left_displacement: float = 0
		var right_displacement: float = 0
		var bottom_displacement: float = 0
		var top_displacement: float = 0

		var is_horizontal_corridor = size.x > size.y

		if is_horizontal_corridor:
			if direction_x01:
				left_displacement = (room0.get_center() + room0.get_size() / 2).x - bottom_left.x
				right_displacement = (
					bottom_left.x + size.x - (room1.get_center() - room1.get_size() / 2).x
				)
			else:
				left_displacement = (room1.get_center() + room1.get_size() / 2).x - bottom_left.x
				right_displacement = (
					bottom_left.x + size.x - (room0.get_center() - room0.get_size() / 2).x
				)
		else:
			if direction_y01:
				bottom_displacement = (room0.get_center() + room0.get_size() / 2).y - bottom_left.y
				top_displacement = (
					bottom_left.y + size.y - (room1.get_center() - room1.get_size() / 2).y
				)
			else:
				bottom_displacement = (room1.get_center() + room1.get_size() / 2).y - bottom_left.y
				top_displacement = (
					bottom_left.y + size.y - (room0.get_center() - room0.get_size() / 2).y
				)

		bottom_left.x += left_displacement
		size.x -= left_displacement
		size.x -= right_displacement
		bottom_left.y += bottom_displacement
		size.y -= bottom_displacement
		size.y -= top_displacement

		if size.x <= 0 or size.y <= 0:
			continue

		var new_room = DungeonRoom.new(bottom_left, size, corridor_color)

		new_room.add_connection(edge.p0.dungeon_room_idx)
		new_room.add_connection(edge.p1.dungeon_room_idx)

		rooms.push_back(new_room)

		room0.add_connection(len(rooms) - 1)
		room1.add_connection(len(rooms) - 1)


func _choose_begin_and_end_room():
	var start_idx = -1
	var distance_from_start = 0
	var end_idx = -1

	for i in len(rooms):
		var nr_connections = 0

		for edge in _minimum_spanning_tree:
			if edge.p0.dungeon_room_idx == i || edge.p1.dungeon_room_idx == i:
				nr_connections += 1

		if nr_connections != 1:
			continue

		if start_idx == -1:
			start_idx = i
		else:
			var cur_distance_from_start = rooms[i].get_position().distance_squared_to(
				rooms[start_idx].get_position()
			)

			if cur_distance_from_start > distance_from_start:
				distance_from_start = cur_distance_from_start
				end_idx = i

	rooms[start_idx].set_color(Color8(255, 215, 0))
	rooms[start_idx].set_room_type(DungeonRoom.DungeonRoomType.START)
	rooms[end_idx].set_color(Color8(50, 50, 50))
	rooms[end_idx].set_room_type(DungeonRoom.DungeonRoomType.END)


#endregion
#region public functions
func generate_dungeon() -> Array[DungeonRoom]:
	_debug_rooms.clear()
	rooms.clear()

	_triangulation.clear()
	_cur_triangulate_room = 0

	_minimum_spanning_tree.clear()

	if is_slowly_generating:
		_current_generation_state = GenerationCycleState.CIRCLE
		_is_generating = true
	else:
		_is_generating = false

	return []


func update():
	if !is_slowly_generating:
		return
	if !_is_generating:
		return
	match _current_generation_state:
		GenerationCycleState.CIRCLE:
			_create_room_in_circle()

			if len(rooms) == _init_room_count:
				_current_generation_state = GenerationCycleState.SEPERATION
		GenerationCycleState.SEPERATION:
			if _seperate_rooms():
				_current_generation_state = GenerationCycleState.DISCARD_SMALL_ROOMS
		GenerationCycleState.DISCARD_SMALL_ROOMS:
			if _discard_small_rooms(true):
				if rooms.is_empty():
					generate_dungeon()
				else:
					_current_generation_state = GenerationCycleState.DISCARD_BORDERING_ROOMS
		GenerationCycleState.DISCARD_BORDERING_ROOMS:
			if _discard_bordering_rooms(true):
				if rooms.is_empty():
					generate_dungeon()
				else:
					_current_generation_state = GenerationCycleState.TRIANGULATION
					_triangulation.start_triangulation()
		GenerationCycleState.TRIANGULATION:
			if _cur_triangulate_room < len(rooms):
				var pos = rooms[_cur_triangulate_room].get_center()
				_triangulation.add_point(pos, _cur_triangulate_room)
				_cur_triangulate_room += 1
			else:
				_triangulation.finish_triangulation()

				if _triangulation.get_size() < 3:
					generate_dungeon()
				else:
					_current_generation_state = GenerationCycleState.SPANNING_TREE_ALGORITHM
		GenerationCycleState.SPANNING_TREE_ALGORITHM:
			_create_minimum_spanning_tree()
			_current_generation_state = GenerationCycleState.CORRIDORS
		GenerationCycleState.CORRIDORS:
			_create_corridors()

			_choose_begin_and_end_room()
			_current_generation_state = GenerationCycleState.DONE


#region setter
func set_seed():
	pass


#endregion
func _draw():
	if !debug_draw:
		return
	if _current_generation_state != GenerationCycleState.DONE:
		for room in _debug_rooms:
			room.draw(self, true)
	for room in rooms:
		room.draw(self)
	match _current_generation_state:
		GenerationCycleState.CIRCLE:
			draw_circle(_center, _init_radius, Color.RED, false, 2)
		GenerationCycleState.TRIANGULATION:
			_triangulation.draw(self)
		GenerationCycleState.SPANNING_TREE_ALGORITHM, GenerationCycleState.CORRIDORS:
			var draw_color = Color8(0, 0, 255)
			for edge in _minimum_spanning_tree:
				draw_line(edge.p0.vertex, edge.p1.vertex, draw_color, 3)

#endregion
