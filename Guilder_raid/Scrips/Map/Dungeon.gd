extends Node2D

signal clear_floor

@export var player : CharacterBody2D
@export var ladder : StaticBody2D
@export var gate : PackedScene
@export var new_floor_timer : Timer
@export var gate_perimeter : PackedScene
@export var enemy : PackedScene
@export var shop : Control
@export var torch_light : PackedScene
@export var room_light : PackedScene

@onready var tile_map : TileMap = $Level
@onready var treasue : CharacterBody2D = $Treasure


var gates_up : bool = false
var dungeon = {}
var room_size : Vector2


func _ready():
	tile_map.clear()
	dungeon = dungeon_generation.generate(randf_range(-10,10))
	load_map()
	

func load_map():
	var cdor_x_st = tile_map.tile_set.get_pattern(0)
	var cdor_x_md = tile_map.tile_set.get_pattern(1)
	var cdor_x_en = tile_map.tile_set.get_pattern(2)
	
	var cdor_y_st = tile_map.tile_set.get_pattern(3)
	var cdor_y_md = tile_map.tile_set.get_pattern(4)
	var cdor_y_en = tile_map.tile_set.get_pattern(5)
	
	for child in get_children():
		if child.is_in_group("gate") or child.is_in_group("Gate") or child.is_in_group("light") or child.is_in_group("enemy") or child.is_in_group("clear"):
			child.free()
	
	for i in dungeon:
		var rl = room_light.instantiate()
		if dungeon.get(i).start:
			tile_map.set_pattern(0, Vector2(34, 26)*i, tile_map.tile_set.get_pattern(6))
			player.position = Vector2((34*i.x+16)*16,(26*i.y+13)*16)
			add_child(rl)
			rl.position = Vector2((34*i.x+16)*16,(26*i.y+13)*16)
			rl.scale = Vector2(16,16)
		elif dungeon.get(i).treasure:
			tile_map.set_pattern(0, Vector2(34, 26)*i, tile_map.tile_set.get_pattern(6))
			treasue.position = Vector2((34*i.x+16)*16,(26*i.y+13)*16)
			add_child(rl)
			rl.position = Vector2((34*i.x+16)*16,(26*i.y+13)*16)
			rl.scale = Vector2(16,16)
		elif dungeon.get(i).end:
			tile_map.set_pattern(0, Vector2(34, 26)*i, tile_map.tile_set.get_pattern(6))
			ladder.position = Vector2((34*i.x+16)*16,(26*i.y+13)*16)
			add_child(rl)
			rl.position = Vector2((34*i.x+16)*16,(26*i.y+13)*16)
			rl.scale = Vector2(16,16)
		else:
			var rooms = tile_map.tile_set.get_pattern(randi_range(7,12))
			room_size = Vector2(-5,-6)
			tile_map.set_pattern(0, Vector2(34, 26)*i, rooms)
			for l in range(0,35):
				if tile_map.get_cell_atlas_coords(0,Vector2i(34*i.x+l,26*i.y+13)) != Vector2i(4,3):
					room_size.x += 1
			for l in range(0,27):
				if tile_map.get_cell_atlas_coords(0,Vector2i(34*i.x+16,26*i.y+l)) != Vector2i(4,3):
					room_size.y += 1
			_add_gate_perimeter(i.x,i.y,room_size)
	
	for i in dungeon.keys():
		
		var c_rooms = dungeon.get(i).connected_rooms
		var mid_pos = Vector2i(34*i.x+14,26*i.y+10)
		var count = 0
		
		if c_rooms.get(Vector2(1, 0)) != null:
			count = 0
			while true:
				if tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x+count,mid_pos.y)) == Vector2i(5,1):
					tile_map.set_pattern(0,Vector2i(mid_pos.x+count,mid_pos.y),cdor_x_st)
					_spawn_gate(mid_pos.x+count,mid_pos.y+3,true)
					_spawn_gate(mid_pos.x+count,mid_pos.y+4,true)
				elif tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x+count,mid_pos.y)) == Vector2i(-1,-1) or tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x+count,mid_pos.y)) == Vector2i(4,3):
					tile_map.set_pattern(0,Vector2i(mid_pos.x+count,mid_pos.y),cdor_x_md)
				elif tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x+count,mid_pos.y)) == Vector2i(0,1):
					tile_map.set_pattern(0,Vector2i(mid_pos.x+count,mid_pos.y),cdor_x_en)
					_spawn_gate(mid_pos.x+count,mid_pos.y+3,true)
					_spawn_gate(mid_pos.x+count,mid_pos.y+4,true)
					break
				count += 1
	
		if c_rooms.get(Vector2(0, 1)) != null:
			count = 0
			while true:
				if tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x,mid_pos.y+count)) == Vector2i(1,7) or tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x,mid_pos.y+count)) == Vector2i(4,7):
					tile_map.set_pattern(0,Vector2i(mid_pos.x,mid_pos.y+count),cdor_y_st)
					_spawn_gate(mid_pos.x+1,mid_pos.y+count+2,false)
					_spawn_gate(mid_pos.x+2,mid_pos.y+count+2,false)
				elif tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x,mid_pos.y+count)) == Vector2i(-1,-1) or tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x,mid_pos.y+count)) == Vector2i(4,3):
					tile_map.set_pattern(0,Vector2i(mid_pos.x,mid_pos.y+count),cdor_y_md)
				elif tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x,mid_pos.y+count)) == Vector2i(1,0):
					tile_map.set_pattern(0,Vector2i(mid_pos.x,mid_pos.y+count),cdor_y_en)
					_spawn_gate(mid_pos.x+1,mid_pos.y+count+2,false)
					_spawn_gate(mid_pos.x+2,mid_pos.y+count+2,false)
					break
				count += 1
		
	for i in tile_map.get_used_cells(0):
		if tile_map.get_cell_atlas_coords(0,i) == Vector2i(1,6):
			var tl = torch_light.instantiate()
			add_child(tl)
			tl.position = Vector2(i.x*16+8,i.y*16+6)

func _add_gate_perimeter(x,y,s):
	var gp = gate_perimeter.instantiate()
	add_child(gp)
	gp.position = Vector2((34*x+16)*16,(26*y+12.5)*16)
	gp.scale = Vector2(s.x,s.y)
	gp.connect('close_gates',_on_player_enter_perimeter)
	gp.connect('open_gates',_on_enemies_cleared)
	

func _spawn_gate(x,y,side_facing:bool):
	var g = gate.instantiate()
	add_child(g)
	g.position = Vector2(x*16, y*16)
	g.side_facing = side_facing


func _on_player_enter_perimeter():
	gates_up = true


func _on_enemies_cleared():
	gates_up = false


func _on_ladder_next_floor():
	emit_signal("clear_floor")
	shop.open()
	load_map()


func _on_player_restart_game():
	emit_signal("clear_floor")
	tile_map.clear()
	dungeon = dungeon_generation.generate(randf_range(-1000,1000))
	load_map()


func _on_timer_timeout():
	pass

func _on_pause_menu_closed():
	get_tree().paused = false

