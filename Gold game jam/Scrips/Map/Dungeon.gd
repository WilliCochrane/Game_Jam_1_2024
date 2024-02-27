extends Node2D

signal clear_floor

@export var player : CharacterBody2D
@export var ladder : StaticBody2D
@export var gate : PackedScene
@export var new_floor_timer : Timer
@export var gate_perimeter : PackedScene
@export var enemy : PackedScene
@export var shop : Control

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
	
	
	for i in dungeon.keys():
		var room = tile_map.tile_set.get_pattern(randi_range(6,7))
		var gp = gate_perimeter.instantiate()
		room_size = Vector2(0,0)
		tile_map.set_pattern(0, Vector2(34, 26)*i, room)
		for l in range(1,34):
			if tile_map.get_cell_atlas_coords(0,Vector2i(34*i.x+l,26*i.y+13)) == Vector2i(3,3):
				room_size.x += 1
		for l in range(1,26):
			if tile_map.get_cell_atlas_coords(0,Vector2i(34*i.x+16,26*i.y+l)) == Vector2i(3,3):
				room_size.y += 1
		
		add_child(gp)
		gp.position = Vector2((34*i.x+16)*16,(26*i.y+12.5)*16)
		gp.scale = room_size
		gp.connect('close_gates',_on_player_enter_perimeter)
		gp.connect('open_gates',_on_enemies_cleared)
		
	for i in dungeon.keys():
		var c_rooms = dungeon.get(i).connected_rooms
		var mid_pos = Vector2i(34*i.x+14,26*i.y+10)
		var count = 0
		if c_rooms.get(Vector2(1, 0)) != null:
			count = 0
			while true:
				if tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x+count,mid_pos.y)) == Vector2i(5,1):
					tile_map.set_pattern(0,Vector2i(mid_pos.x+count,mid_pos.y),cdor_x_st)
				elif tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x+count,mid_pos.y)) == Vector2i(-1,-1) or tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x+count,mid_pos.y)) == Vector2i(4,3):
					tile_map.set_pattern(0,Vector2i(mid_pos.x+count,mid_pos.y),cdor_x_md)
				elif tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x+count,mid_pos.y)) == Vector2i(0,1):
					tile_map.set_pattern(0,Vector2i(mid_pos.x+count,mid_pos.y),cdor_x_en)
					break
				count += 1

		if c_rooms.get(Vector2(0, 1)) != null:
			count = 0
			while true:
				if tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x,mid_pos.y+count)) == Vector2i(1,7) or tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x,mid_pos.y+count)) == Vector2i(4,7):
					tile_map.set_pattern(0,Vector2i(mid_pos.x,mid_pos.y+count),cdor_y_st)
				elif tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x,mid_pos.y+count)) == Vector2i(-1,-1) or tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x,mid_pos.y+count)) == Vector2i(4,3):
					tile_map.set_pattern(0,Vector2i(mid_pos.x,mid_pos.y+count),cdor_y_md)
				elif tile_map.get_cell_atlas_coords(0,Vector2i(mid_pos.x,mid_pos.y+count)) == Vector2i(1,0):
					tile_map.set_pattern(0,Vector2i(mid_pos.x,mid_pos.y+count),cdor_y_en)
					break
				count += 1


func _on_button_pressed():
	tile_map.clear()
	randomize()
	dungeon = dungeon_generation.generate(randf_range(-1000, 1000))
	load_map()


func _spawn_gate(x,y):
	var g = gate.instantiate()
	add_child(g)
	g.position = Vector2(x*16, y*16)


func _on_player_enter_perimeter():
	gates_up = true


func _on_enemies_cleared():
	gates_up = false


func _on_ladder_next_floor():
	shop.open()
	new_floor_timer.start()


func _on_player_restart_game():
	new_floor_timer.start()

func _on_timer_timeout():
	tile_map.clear()
	dungeon = dungeon_generation.generate(randf_range(-10,10))
	load_map()


func _on_pause_menu_closed():
	get_tree().paused = false

