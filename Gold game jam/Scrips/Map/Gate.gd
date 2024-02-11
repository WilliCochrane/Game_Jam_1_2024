extends StaticBody2D

@export var anim_player : AnimationPlayer
@export var collision_shape : CollisionShape2D

var open_animation_finished : bool = false
var parent_room : Rect2
var first_update : bool = true
var side_facing = false

func _process(_delta):
	if first_update == true:
		find_parent_room()
		position_parameters()
		
		if side_facing == true:
			anim_player.play("side_gate_idle")
		else:
			anim_player.play("x_facing_idle")
			
		first_update = false
	
	if get_parent().gates_up == true && open_animation_finished == false:
		if side_facing == true:
			anim_player.play("side_gate_open")
		else:
			anim_player.play("x_facing_open")
		open_animation_finished = true
		adjust_z_axis()
		
	elif get_parent().gates_up == false && open_animation_finished == true:
		if side_facing == true:
			anim_player.play("side_gate_close")
		else:
			anim_player.play("x_facing_close")
		open_animation_finished = false

func find_parent_room():
	for room in get_parent().room_areas:
		if room.size.x != 16:
			for xcell in range(room.position.x,room.position.x + room.size.x):
				if position == Vector2(xcell, room.position.y+1)*16 or position == Vector2(xcell, room.position.y + room.size.y+1)*16:
					parent_room = room
			
			for ycell in range(room.position.y,room.position.y + room.size.y):
				if position == Vector2(room.position.x, ycell+1)*16 or position == Vector2(room.position.x + room.size.x-1, ycell+1)*16:
					print(position)
					parent_room = room
					print(parent_room)


func adjust_z_axis():
	if position.y == parent_room.position.y*16 + parent_room.size.y * 16 + 16:
		z_index = 1
	else:
		z_index = 0

func position_parameters():
	if position.x == parent_room.position.x*16 or position.x == parent_room.position.x*16 + parent_room.size.x*16-16:
		collision_shape.rotation_degrees = 90
		side_facing = true
