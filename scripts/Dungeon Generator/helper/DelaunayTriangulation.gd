class_name DelaunayTriangulation
extends Triangulation


func start_triangulation() -> void:
	_add_vertex(Vector2(-3000, -3000), -1)
	_add_vertex(Vector2(-3000, 9500), -1)
	_add_vertex(Vector2(9000, -3500), -1)

	_add_triangle(0, 1, 2)


func add_point(point: Vector2, dungeon_room_idx: int) -> void:
	var new_indece = _add_vertex(point, dungeon_room_idx)

	var intersecting_polygon: Array[int] = []

	for i in range(len(_triangles) - 1, -1, -1):
		var index = i
		if !_is_inside_circumcircle(_triangles[index], new_indece):
			continue

		if !intersecting_polygon.is_empty():
			var has_first: bool = false
			var has_second: bool = false
			var has_third: bool = false

			for polygon_idx in len(intersecting_polygon):
				if intersecting_polygon[polygon_idx] == _triangles[index].first:
					has_first = true
				if intersecting_polygon[polygon_idx] == _triangles[index].second:
					has_second = true
				if intersecting_polygon[polygon_idx] == _triangles[index].third:
					has_third = true

			if !has_first:
				intersecting_polygon.push_back(_triangles[index].first)
			if !has_second:
				intersecting_polygon.push_back(_triangles[index].second)
			if !has_third:
				intersecting_polygon.push_back(_triangles[index].third)
		else:
			intersecting_polygon.push_back(_triangles[index].first)
			intersecting_polygon.push_back(_triangles[index].second)
			intersecting_polygon.push_back(_triangles[index].third)

		_remove_triangle(index)

	var polygon_sort = func(indice0: int, indice1: int):
		var vector0: Vector2 = _vertices[indice0].vertex - point
		var vector1: Vector2 = _vertices[indice1].vertex - point

		var angle0: float = atan2(vector0.y, vector0.x)
		var angle1: float = atan2(vector1.y, vector1.x)

		if angle0 < 0:
			angle0 = angle0 + 2 * PI
		if angle1 < 0:
			angle1 = angle1 + 2 * PI

		return angle0 < angle1

	intersecting_polygon.sort_custom(polygon_sort)

	for i in len(intersecting_polygon):
		_add_triangle(
			intersecting_polygon[i],
			intersecting_polygon[(i + 1) % len(intersecting_polygon)],
			new_indece
		)


func finish_triangulation():
	#Clear Super Triangle

	for i in range(len(_triangles) - 1, -1, -1):
		var index = i
		for indece in 3:
			if (
				_triangles[index].first == indece
				|| _triangles[index].second == indece
				|| _triangles[indece].third == indece
			):
				_remove_triangle(index)
				break


func clear():
	_triangles.clear()
	_vertices.clear()


func get_size():
	return len(_vertices) - 3


func _is_inside_circumcircle(triangle: Triangle, indice: int) -> bool:
	const EPSILON = 0.0000000000001
	var v0 = _vertices[triangle.first].vertex
	var v1 = _vertices[triangle.second].vertex
	var v2 = _vertices[triangle.third].vertex
	var v_test = _vertices[indice].vertex

	var perp_slope0 = (v0.x - v1.x) / float(v1.y - v0.y + EPSILON)
	var perp_slope1 = (v0.x - v2.x) / float(v2.y - v0.y + EPSILON)

	var edge01_center = (v0 + v1) / 2
	var edge02_center = (v0 + v2) / 2

	var intercept0 = edge01_center.y - perp_slope0 * edge01_center.x
	var intercept1 = edge02_center.y - perp_slope1 * edge02_center.x

	var x: int = int((intercept1 - intercept0) / (perp_slope0 - perp_slope1))
	var y: int = int(perp_slope0 * x + intercept0)

	var r: int = (x - v1.x) * (x - v1.x) + (y - v1.y) * (y - v1.y)
	var r_point: int = (x - v_test.x) * (x - v_test.x) + (y - v_test.y) * (y - v_test.y)

	return r_point < r
