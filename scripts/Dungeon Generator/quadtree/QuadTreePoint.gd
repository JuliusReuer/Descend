class_name QuadTreePoint

var position: Vector2
var meta_data: DungeonRoom


static func from_room(room: DungeonRoom) -> QuadTreePoint:
	var point = QuadTreePoint.new()
	point.position = room.get_center()
	point.meta_data = room
	return point
