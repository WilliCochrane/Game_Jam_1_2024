extends Node2D

signal clear_floor

@export var level_size : Vector2
@export var main_rooms_size : Vector2
@export var main_rooms_max : int
@export var player : CharacterBody2D
@export var ladder : StaticBody2D
@export var gate : PackedScene
@export var debug_timer : Timer
@export var gate_perimeter : PackedScene
@export var enemy : PackedScene

@onready var level : TileMap = $Level
@onready var treasue : CharacterBody2D = $Treasure

var level_data : Array = []
var room_areas : Array = []
var spawn_room : Rect2 = Rect2(0, 0, 16, 16)
var end_room : Rect2 = Rect2(80, 80, 16, 16)
var treasure_room : Rect2

var gates_up : bool = false


func _ready() -> void:
	_generate_rooms()
	_generate_structures()
	_generate_gates_close_perimeter()


func _generate_structures():
	ladder.position = Vector2(1408,1408)


func _generate_rooms() -> void:
	_generate_data()
	player.position = Vector2(128,128)
	level.clear()
	level.set_cells_terrain_connect(0,level_data,1,0)
	level.set_cells_terrain_connect(1,_generate_top_data(),1,1)
	_generate_corners()
	_generate_gateways()
	_generate_treasure_room()   


func _generate_data():
	room_areas = []
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var data := {}
	var connections := []
	@warning_ignore("narrowing_conversion")
	treasure_room = Rect2(rng.randi_range(level_size.x/2, level_size.x - 20), rng.randi_range(level_size.y/2, level_size.y - 20), 15, 15)
	@warning_ignore("narrowing_conversion")
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
	var mst = find_min_span_tree(rooms)
	for point in mst.get_point_ids():
		var p = mst.get_closest_point(Vector2(mst.get_point_position(point).x, mst.get_point_position(point).y))
		for conn in mst.get_point_connections(p):
			if not conn in connections:
				var start = Vector2(mst.get_point_position(p).x, mst.get_point_position(p).y)
				var end = Vector2(mst.get_point_position(conn).x, mst.get_point_position(conn).y)
				_add_connection(data, start, end)
		connections.push_back(p)
	level_data = data.keys()


func _generate_top_data() -> Array:
	var top_data : Array = []
	for cell in level_data:
		if level.get_cell_atlas_coords(0,Vector2i(cell.x,cell.y-1)) == Vector2i(-1, -1):
			top_data.push_back(Vector2(cell.x,cell.y-1))
	return top_data


func _generate_corners():
	for cell in level_data:
		if level.get_cell_atlas_coords(0,cell) == Vector2i(4,2):
			level.set_cell(1,Vector2i(cell.x,cell.y-1),0,Vector2i(5,4))
		elif level.get_cell_atlas_coords(0,cell) == Vector2i(4,1):
			level.set_cell(1,Vector2i(cell.x,cell.y-1),0,Vector2i(0,4))
		elif level.get_cell_atlas_coords(0,cell) == Vector2i(0,1):
			level.set_cell(1,Vector2i(cell.x,cell.y-1),0,Vector2i(0,0))
		elif level.get_cell_atlas_coords(0,cell) == Vector2i(5,1):
			level.set_cell(1,Vector2i(cell.x,cell.y-1),0,Vector2i(5,0))


func _generate_gateways() -> void:
	var tile_list : Array = [Vector2i(1,2),Vector2i(1,3),Vector2i(2,2),Vector2i(2,3),Vector2i(3,2),Vector2i(3,3),Vector2i(0,5),Vector2i(5,5)]
	for room in room_areas:
		if room.size.x > 16:
			for xcell in range(room.position.x,room.position.x + room.size.x):
				for tile in tile_list:
					if level.get_cell_atlas_coords(0,Vector2i(xcell,room.position.y)) == tile:
						_spawn_gate(xcell, room.position.y+1)
					if level.get_cell_atlas_coords(0,Vector2i(xcell,room.position.y + room.size.y)) == tile:
						_spawn_gate(xcell, room.position.y + room.size.y+1)
			
			for ycell in range(room.position.y,room.position.y + room.size.y):
				for tile in tile_list:
					if level.get_cell_atlas_coords(0,Vector2i(room.position.x,ycell)) == tile:
						_spawn_gate(room.position.x, ycell+1)
					if level.get_cell_atlas_coords(0,Vector2i(room.position.x + room.size.x-1,ycell)) == tile:
						_spawn_gate(room.position.x + room.size.x-1, ycell+1)


func _generate_gates_close_perimeter() -> void:
	for room in room_areas:
		if room.size.x > 16:
			var gp = gate_perimeter.instantiate()
			add_child(gp)
			gp.position = Vector2(room.position.x*16 + room.size.x * 8,room.position.y*16 + room.size.y * 8)
			gp.scale = room.grow(-1).size
			gp.connect('close_gates',_on_player_enter_perimeter)
			gp.connect('open_gates',_on_enemies_cleared)
			

@warning_ignore("shadowed_variable")
func _generate_treasure_room() -> void:
	treasue.position = Vector2(treasure_room.position.x * 16 + 120, treasure_room.position.y * 16 + 120)



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
		_add_corridor(data, room_center1.x+2, room_center2.x-2, room_center1.y, Vector2.AXIS_X)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.y, room_center2.y, room_center2.x, Vector2.AXIS_Y)
		
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.x+2, room_center2.x-2, room_center1.y+1, Vector2.AXIS_X)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.y, room_center2.y, room_center2.x+1, Vector2.AXIS_Y)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.x+2, room_center2.x-2, room_center1.y-1, Vector2.AXIS_X)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.y, room_center2.y, room_center2.x-1, Vector2.AXIS_Y)
		
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.x+2, room_center2.x-2, room_center1.y+2, Vector2.AXIS_X)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.y+2, room_center2.y-2, room_center2.x+2, Vector2.AXIS_Y)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.x+2, room_center2.x-2, room_center1.y-2, Vector2.AXIS_X)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.y+2, room_center2.y-2, room_center2.x-2, Vector2.AXIS_Y)
		
	else:
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.y, room_center2.y, room_center1.x, Vector2.AXIS_Y)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.x-2, room_center2.x+2, room_center2.y, Vector2.AXIS_X)
		
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.y, room_center2.y, room_center1.x+1, Vector2.AXIS_Y)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.x-2, room_center2.x+2, room_center2.y+1, Vector2.AXIS_X)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.y, room_center2.y, room_center1.x-1, Vector2.AXIS_Y)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.x-2, room_center2.x+2, room_center2.y-1, Vector2.AXIS_X)
		
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.y-2, room_center2.y+2, room_center1.x+2, Vector2.AXIS_Y)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.x-2, room_center2.x+2, room_center2.y+2, Vector2.AXIS_X )
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.y-2, room_center2.y+2, room_center1.x-2, Vector2.AXIS_Y)
		@warning_ignore("narrowing_conversion")
		_add_corridor(data, room_center1.x-2, room_center2.x+2, room_center2.y-2, Vector2.AXIS_X)
		

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
		if room.grow(5).intersects(room_other):
			out = true
			break
	return out


func _spawn_gate(x,y):
	var g = gate.instantiate()
	add_child(g)
	g.position = Vector2(x*16, y*16)


func _on_player_enter_perimeter():
	gates_up = true


func _on_enemies_cleared():
	gates_up = false


func find_min_span_tree(areas: Array):
	#Prim's algorithm
	var path = AStar2D.new()
	var first_room = areas.pop_front()
	var room_center : Vector2 = first_room.position + first_room.size/2
	path.add_point(path.get_available_point_id(), room_center)
	
	while areas:
		var min_dist = INF 
		var min_pos = null 
		var min_pos_room = null 
		var pos = null 
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


func _on_ladder_next_floor():
	player.camera.position_smoothing_enabled = false
	emit_signal("clear_floor")
	_generate_rooms()
	_generate_structures()
	_generate_gates_close_perimeter()
	player.camera.position_smoothing_enabled = true


func _on_player_restart_game():
	player.camera.position_smoothing_enabled = false
	emit_signal("clear_floor")
	_generate_rooms()
	_generate_structures()
	_generate_gates_close_perimeter()
	player.camera.position_smoothing_enabled = true
