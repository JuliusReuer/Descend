class_name Edge
var p0: Vertex
var p1: Vertex


func equals(other: Edge) -> bool:
	return (p0 == other.p0 || p0 == other.p1) && (p1 == other.p0 || p1 == other.p1)


func less(other: Edge) -> bool:
	return (
		p0.vertex.distance_squared_to(p1.vertex)
		< other.p0.vertex.distance_squared_to(other.p1.vertex)
	)
