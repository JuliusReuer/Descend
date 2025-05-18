class_name Triangulation

var _triangles: Array[Triangle] = []
var _vertices: Array[Vertex] = []


func draw(renderer: Node2D) -> void:
	var draw_color: Color = Color8(0, 255, 0)
	for triangle in _triangles:
		var v0: Vector2 = _vertices[triangle.first].vertex
		var v1: Vector2 = _vertices[triangle.second].vertex
		var v2: Vector2 = _vertices[triangle.third].vertex

		renderer.draw_line(v0, v1, draw_color)
		renderer.draw_line(v0, v2, draw_color)
		renderer.draw_line(v2, v1, draw_color)


func create_set_of_edges() -> Array[Edge]:
	var edges: Array[Edge] = []
	for triangle in _triangles:
		for i in 3:
			var edge: Edge = Edge.new()
			match i:
				0:
					edge.p0 = _vertices[triangle.first]
					edge.p1 = _vertices[triangle.second]
				1:
					edge.p0 = _vertices[triangle.second]
					edge.p1 = _vertices[triangle.third]
				2:
					edge.p0 = _vertices[triangle.third]
					edge.p1 = _vertices[triangle.first]
			edges.append(edge)
	return edges


func get_size() -> int:
	return len(_vertices)


func _add_vertex(vertex: Vector2, dungeon_room_idx: int) -> int:
	_vertices.push_back(Vertex.new(vertex, dungeon_room_idx))
	return len(_vertices) - 1


func _add_triangle(first: int, second: int, third: int) -> void:
	_triangles.push_back(Triangle.new(first, second, third))


func _remove_triangle(index: int) -> void:
	_triangles.remove_at(index)
