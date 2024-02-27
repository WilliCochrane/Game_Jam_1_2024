extends StaticBody2D

@export var anim_player : AnimationPlayer
@export var collision_shape : CollisionShape2D

var open_animation_finished : bool = false
var parent_room : Rect2
var first_update : bool = true
var side_facing = false


func _ready():
	get_parent().connect("clear_floor",on_clear_floor)


func _process(_delta):
	if first_update == true:
		
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
		
	elif get_parent().gates_up == false && open_animation_finished == true:
		if side_facing == true:
			anim_player.play("side_gate_close")
		else:
			anim_player.play("x_facing_close")
		open_animation_finished = false


func on_clear_floor():
	queue_free()
