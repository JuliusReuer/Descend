class_name QuadTree

var _booundary: Rect2
var _capacity: int
var _points: Array[QuadTreePoint] = []
var _subdivided: bool

var _nw: QuadTree
var _ne: QuadTree
var _sw: QuadTree
var _se: QuadTree


static func get_boundary(rooms: Array[DungeonRoom]) -> Rect2:
	var rect: Rect2 = Rect2(0, 0, -1, -1)
	for room in rooms:
		if rect.size == Vector2(-1, -1):
			rect = Rect2(room.get_center(), Vector2(0, 0))
		else:
			rect = rect.expand(room.get_center())
	rect.size += Vector2(1, 1)
	return rect


static func create_querry(room: DungeonRoom, generator: DungeonGenerator):
	var max_room_size: float = generator._room_size_bounds.y
	return Rect2(
		room.get_position() - Vector2(max_room_size, max_room_size),
		room.get_size() + Vector2(max_room_size, max_room_size) * 2
	)
	#return Rect2(room.get_position(),room.get_size())


func _init(boundary: Rect2, capacity: int = 1):
	_booundary = boundary
	_capacity = capacity


func _subdivide():
	_nw = QuadTree.new(Rect2(_booundary.position, _booundary.size / 2), _capacity)
	_ne = QuadTree.new(
		Rect2(
			Vector2(_booundary.position.x + (_booundary.size / 2).x, _booundary.position.y),
			_booundary.size / 2
		),
		_capacity
	)
	_sw = QuadTree.new(
		Rect2(
			Vector2(_booundary.position.x, _booundary.position.y + (_booundary.size / 2).y),
			_booundary.size / 2
		),
		_capacity
	)
	_se = QuadTree.new(
		Rect2(_booundary.position + _booundary.size / 2, _booundary.size / 2), _capacity
	)

	_subdivided = true

	#while len(_points) > 0:
	#	insert(_points.pop_back())


func _insert_children(point: QuadTreePoint) -> bool:
	if _nw.insert(point):
		return true
	if _ne.insert(point):
		return true
	if _sw.insert(point):
		return true
	if _se.insert(point):
		return true
	return false


func insert(point: QuadTreePoint) -> bool:
	if !_booundary.has_point(point.position):
		return false

	if len(_points) < _capacity:
		_points.push_back(point)
		return true

	if !_subdivided:
		_subdivide()

	return _insert_children(point)


func querry(querry_range: Rect2) -> Array[QuadTreePoint]:  # 1.5 * max_room_size
	var found: Array[QuadTreePoint] = []
	if !_booundary.intersects(querry_range, true):
		return found

	for p in _points:
		if querry_range.has_point(p.position):
			found.push_back(p)

	if _subdivided:
		found.append_array(_nw.querry(querry_range))
		found.append_array(_ne.querry(querry_range))
		found.append_array(_sw.querry(querry_range))
		found.append_array(_se.querry(querry_range))

	return found
