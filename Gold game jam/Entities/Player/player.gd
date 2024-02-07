extends CharacterBody2D

signal shoot
signal shoot_stop

@export var anim_player : AnimationPlayer
@export var sprite : Sprite2D
@export var tile_map : TileMap
@export var weapon : CharacterBody2D

var rotation_speed : float = 10
var move_direction : Vector2 = Vector2.ZERO
var move_speed : float = 150


func _physics_process(delta):
	move_direction = Input.get_vector("ui_left", "ui_right","ui_up","ui_down")
	velocity = move_direction * move_speed  * delta
	position += velocity
	if move_direction != Vector2.ZERO:
		anim_player.play("Run")
	else:
		anim_player.play("Idle")
	
	weapon_rotate_to_mouse(get_global_mouse_position(),delta)
	move_and_slide()

func weapon_rotate_to_mouse(target, delta):
	var direction = (target - weapon.global_position) #target global position if is an entity
	var angleTo = weapon.transform.x.angle_to(direction)
	weapon.rotate(sign(angleTo) * min(delta * rotation_speed, abs(angleTo)))
	if direction.x > 0:
		sprite.flip_h = true
		weapon.get_child(0).scale.y = 1
	elif direction.x < 0:
		sprite.flip_h = false
		weapon.get_child(0).scale.y = -1


func _input(event):
	if event.is_action_pressed("ui_shoot"):
		emit_signal("shoot")
	if event.is_action_released("ui_shoot"):
		emit_signal("shoot_stop")



