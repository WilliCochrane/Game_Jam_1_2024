extends Node2D

signal clear_floor

@export var player : CharacterBody2D
@export var ladder : StaticBody2D
@export var gate : PackedScene
@export var new_floor_timer : Timer
@export var gate_perimeter : PackedScene
@export var enemies : Array[PackedScene]
@export var shop : Control
@export var torch_light : PackedScene
@export var room_light : PackedScene
@export var minimap_item : PackedScene

@export var barrel : PackedScene
@export var pot : PackedScene
@export var pillar : PackedScene
@export var bookshelf : PackedScene
@export var tall_pillar : PackedScene

@onready var tile_map : TileMap = $Level
@onready var treasure : StaticBody2D = $Treasure
@onready var minimap : TileMap = $Minimap/Container/MiniMap


var gates_up : bool = false
var dungeon = {}
var room_size : Vector2


func _ready():
	tile_map.clear()
	dungeon = dungeon_generation.generate(randf_range(-1000,1000))
	load_map()

func _physics_process(_delta):
	minimap.position = Vector2(-player.global_position.x/16+64,-player.global_position.y/16+64)


func load_map():
	var cdor_x_st = tile_map.tile_set.get_pattern(0)
	var cdor_x_md = tile_map.tile_set.get_pattern(1)
	var cdor_x_en = tile_map.tile_set.get_pattern(2)
	
	var cdor_y_st = tile_map.tile_set.get_pattern(3)
	var cdor_y_md = tile_map.tile_set.get_pattern(4)
	var cdor_y_en = tile_map.tile_set.get_pattern(5)
	
	for child in get_children():
		if child.is_in_group("clear"):
			child.queue_free()
	
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
			treasure.position = Vector2((34*i.x+16)*16,(26*i.y+13)*16)
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
			var rooms = tile_map.tile_set.get_pattern(randi_range(7,13))
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
		
		if tile_map.get_cell_tile_data(0,i).get_custom_data("minimap") == 1:
			minimap.set_cell(0,i,0,Vector2i(0,0))
		elif tile_map.get_cell_tile_data(0,i).get_custom_data("minimap") == 2:
			minimap.set_cell(0,i,0,Vector2i(1,0))
		
		if tile_map.get_cell_atlas_coords(0,i) == Vector2i(1,6):
			var tl = torch_light.instantiate()
			add_child(tl)
			tl.position = Vector2(i.x*16+8,i.y*16+6)  
		elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(3, 3):
			tile_map.set_cells_terrain_path(0,[i],0,0)
		elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(1, 0):
			tile_map.set_cells_terrain_path(0,[i],0,1)
		elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(1, 7):
			tile_map.set_cells_terrain_path(0,[i],0,2)
		elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(5, 1):
			tile_map.set_cells_terrain_path(0,[i],0,3)
		elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(0, 1):
			tile_map.set_cells_terrain_path(0,[i],0,4)
		elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(1, 1):
			tile_map.set_cells_terrain_path(0,[i],0,5)
		elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(4, 7):
			pass
		elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(5, 7):
			pass
		elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(0, 7):
			pass
		elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(0, 0):
			pass
		elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(5, 0):
			pass
		elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(5, 4):
			pass
		elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(5, 5):
			pass
		elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(0, 5):
			pass
		elif tile_map.get_cell_atlas_coords(0,i) == Vector2i(0, 4):
			pass
		
		#if tile_map.get_cell_tile_data(0,i).get_custom_data("object") == "barrel":
			#var brl = barrel.instantiate()
			#add_child(brl)
			#brl.position = Vector2(i.x*16+7,i.y*16+7)
		#elif tile_map.get_cell_tile_data(0,i).get_custom_data("object") == "pot":
			#var pt = pot.instantiate()
			#add_child(pt)
			#pt.position = Vector2(i.x*16+7,i.y*16+7)
		#elif tile_map.get_cell_tile_data(0,i).get_custom_data("object") == "bookshelf":
			#var brl = bookshelf.instantiate()
			#add_child(brl)
			#brl.position = Vector2(i.x*16+7,i.y*16+7)
		#elif tile_map.get_cell_tile_data(0,i).get_custom_data("object") == "pillar":
			#var brl = pillar.instantiate()
			#add_child(brl)
			#brl.position = Vector2(i.x*16+7,i.y*16+7)
		#elif tile_map.get_cell_tile_data(0,i).get_custom_data("object") == "tall_pillar":
			#var brl = tall_pillar.instantiate()
			#add_child(brl)
			#brl.position = Vector2(i.x*16+7,i.y*16+7)
	$NavigationRegion2D.bake_navigation_polygon()
	load_minimap()


func load_minimap():
	$Minimap/Container/MiniMap/minimap_chest.position = Vector2(treasure.position.x/16+.5,treasure.position.y/16+.5)
	$Minimap/Container/MiniMap/minimap_ladder.position = Vector2(ladder.position.x/16+.5,ladder.position.y/16+.5)


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
	tile_map.clear()
	minimap.clear()
	dungeon = dungeon_generation.generate(randf_range(-10,10))
	load_map()
	shop.open()
	treasure.reset()


func _on_player_restart_game():
	emit_signal("clear_floor")
	tile_map.clear()
	minimap.clear()
	dungeon = dungeon_generation.generate(randf_range(-10,10))
	load_map()
	treasure.reset()


func _on_timer_timeout():
	pass


func _on_pause_menu_closed():
	get_tree().paused = false

