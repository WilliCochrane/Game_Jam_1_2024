extends StaticBody2D

@export var anim_player : AnimationPlayer
@export var collision_shape : CollisionShape2D

var open_animation_finished : bool = false
var closest_room : Rect2
var first_update : bool = true

func _ready():
	anim_player.play("x_facing_idle")


func _process(_delta):
	if first_update == true:
		find_closest_room()
		first_update = false
	
	if get_parent().gates_up == true && open_animation_finished == false:
		anim_player.play("x_facing_open")
		open_animation_finished = true
		adjust_z_axis()
	elif get_parent().gates_up == false && open_animation_finished == true:
		anim_player.play("x_facing_close")
		open_animation_finished = false

func find_closest_room():
	closest_room = get_parent().room_areas[0]
	for room in get_parent().room_areas:
		if abs(position - Vector2(closest_room.position.x*16 + closest_room.size.x * 8,closest_room.position.y*16 + closest_room.size.y * 8)) > abs(position - Vector2(room.position.x*16 + room.size.x * 8,room.position.y*16 + room.size.y * 8)):
			closest_room = room
		#print(Vector2(closest_room.position.x * 16 + closest_room.size.x * 8,closest_room.position.y*16 + closest_room.size.y * 8))
		#print(Vector2(room.position.x*16 + room.size.x * 8,room.position.y*16 + room.size.y * 8))
		#print("p")
		#print(position)


func adjust_z_axis():
	if position.y == closest_room.position.y*16 + closest_room.size.y * 16 + 16:
		z_index = 1
		print('yes')
	else:
		z_index = 0
