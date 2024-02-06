extends Node2D


@export var level_size : Vector2
@export var main_rooms_size : Vector2
@export var main_rooms_max : int
@export var player : CharacterBody2D

@onready var level: TileMap = $Level


func _ready() -> void:
	_generate_rooms()
	_generate_structures()


func _generate_structures():
	var ladder := level.tile_set.get_pattern(0)
	level.set_pattern(1,Vector2i(87,87),ladder)

func _generate_gateways(room : Rect2) -> void:
	if room.size == Vector2(16,16):
		return
	else:
		pass


func _generate_rooms() -> void:
	player.position = Vector2(128,128)
	level.clear()
	level.set_cells_terrain_connect(0,_generate_data() ,0 ,0 ,false)


func _generate_data() -> Array:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var data := {}
	var connections := []
	var spawn_room : Rect2 = Rect2(0, 0, 16, 16)
	var end_room : Rect2 = Rect2(80, 80, 16, 16)
	@warning_ignore("narrowing_conversion")
	var treasure_room : Rect2 = Rect2(rng.randi_range(level_size.x/2, level_size.x - 20), rng.randi_range(level_size.y/2, level_size.y - 20), 15, 15)
	var room_areas : Array = []
	var rooms := [spawn_room, end_room, treasure_room]
	_add_room(data, rooms, spawn_room)
	_add_room(data, rooms, end_room)
	_add_room(data, rooms, treasure_room)
	for r in range(main_rooms_max):
		var room := _get_random_room(rng)
		if _intersects(rooms, room):
			continue
		_add_room(data, rooms, room)
	for room in rooms:
		room_areas.push_front(room)
	var mst = find_min_span_tree(room_areas)
	for point in mst.get_point_ids():
		var p = mst.get_closest_point(Vector2(mst.get_point_position(point).x, mst.get_point_position(point).y))
		for conn in mst.get_point_connections(p):
			if not conn in connections:
				var start = Vector2(mst.get_point_position(p).x, mst.get_point_position(p).y)
				var end = Vector2(mst.get_point_position(conn).x, mst.get_point_position(conn).y)
				_add_connection(data, start, end)
		connections.push_back(p)

	return data.keys()


func _get_random_room(rng: RandomNumberGenerator) -> Rect2:
	@warning_ignore("narrowing_conversion")
	var width := rng.randi_range(main_rooms_size.x, main_rooms_size.y)
	@warning_ignore("narrowing_conversion")
	var height := rng.randi_range(main_rooms_size.x, main_rooms_size.y)
	@warning_ignore("narrowing_conversion")
	var x := rng.randi_range(0, level_size.x - width - 1)
	@warning_ignore("narrowing_conversion")
	var y := rng.randi_range(0, level_size.y - height - 1)
	return Rect2(x, y, width, height)


func _add_room(data: Dictionary, rooms: Array, room: Rect2) -> void:
	rooms.push_back(room)
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			data[Vector2(x, y,)] = null


func _add_connection(data: Dictionary, room_center1: Vector2, room_center2: Vector2,) -> void:

	if room_center1.x > room_center2.x:
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.x, room_center2.x, room_center1.y, Vector2.AXIS_X)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.y, room_center2.y, room_center2.x, Vector2.AXIS_Y)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.x+1, room_center2.x-1, room_center1.y+1, Vector2.AXIS_X)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.y, room_center2.y, room_center2.x+1, Vector2.AXIS_Y)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.x+1, room_center2.x-1, room_center1.y-1, Vector2.AXIS_X)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.y, room_center2.y, room_center2.x-1, Vector2.AXIS_Y)
	else:
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.y, room_center2.y, room_center1.x, Vector2.AXIS_Y)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.x, room_center2.x, room_center2.y, Vector2.AXIS_X)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.y, room_center2.y, room_center1.x+1, Vector2.AXIS_Y)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.x-1, room_center2.x+1, room_center2.y+1, Vector2.AXIS_X)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.y, room_center2.y, room_center1.x-1, Vector2.AXIS_Y)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.x-1, room_center2.x+1, room_center2.y-1, Vector2.AXIS_X)

func _add_corridor(data: Dictionary, start: int, end: int, constant: int, axis: int) -> void:
	for t in range(min(start, end), max(start, end) + 1):
		var point := Vector2.ZERO
		match axis:
			Vector2.AXIS_X: point = Vector2(t, constant)
			Vector2.AXIS_Y: point = Vector2(constant,t)
		data[point] = null


func _intersects(rooms: Array, room: Rect2) -> bool:
	var out := false
	for room_other in rooms:
		if room.grow(3).intersects(room_other):
			out = true
			break
	return out


func find_min_span_tree(areas: Array):
	#Prim's algorithm
	var path = AStar2D.new()
	var first_room = areas.pop_front()
	var room_center : Vector2 = first_room.position + first_room.size/2
	path.add_point(path.get_available_point_id(), room_center)
	
	while areas:
		var min_dist = INF # Min distance so far
		var min_pos = null # Pos of room
		var min_pos_room = null # Actual room
		var pos = null # Current pos
		for point in path.get_point_ids():
			var point1 = path.get_point_position(point)
			for point2 in areas:
				if point1.distance_to(point2.position) < min_dist:
					min_dist = point1.distance_to(point2.position)
					min_pos = point2.position + point2.size/2
					min_pos_room = point2
					pos = point1
		var n = path.get_available_point_id()
		path.add_point(n, min_pos)
		path.connect_points(path.get_closest_point(pos), n)
		areas.erase(min_pos_room)
	return path


func _on_timer_timeout():
	_generate_data()
	_generate_rooms()
