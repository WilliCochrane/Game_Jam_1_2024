extends CharacterBody2D

signal shoot
signal shoot_stop

@export var anim_player : AnimationPlayer
@export var sprite : Sprite2D
@export var tile_map : TileMap
@export var weapon : CharacterBody2D
@export var health_bar : TextureProgressBar
@export var damaged_bar : TextureProgressBar
@export var mana_bar : TextureProgressBar
@export var mana_usage_bar : TextureProgressBar
@export var damaged_timer : Timer
@export var mana_usage_timer : Timer
@export var mana_regen_timer : Timer

var rotation_speed : float = 10
var move_direction : Vector2 = Vector2.ZERO
var move_speed : float = 100
var current_health : float = 100
var max_health : float = 100
var current_mana : float = 150
var max_mana : float = 150

var damadged_bar_catchup : bool = false
var mana_usage_bar_catchup : bool = false
var mana_regen : bool = false
var current_mana_usage : float


func _ready():
	mana_bar.value = max_mana
	health_bar.value = max_health 

func _physics_process(delta):
	move_direction = Input.get_vector("ui_left", "ui_right","ui_up","ui_down")
	velocity = move_direction * move_speed  * delta
	position += velocity
	if move_direction != Vector2.ZERO:
		anim_player.play("Run")
	else:
		anim_player.play("Idle")
	
	mana_bar.value = current_mana
	mana_usage_bar.value = current_mana_usage
	health_bar.value = current_health
	
	if current_mana > max_mana:
		mana_regen = false
		current_mana = max_mana
	
	if mana_regen == true:
		current_mana += .25
	
	if current_mana_usage < current_mana:
		current_mana_usage = current_mana
		mana_usage_bar_catchup = false
	elif current_mana_usage > current_mana && mana_usage_bar_catchup == false && weapon.shooting == true:
		mana_usage_timer.start()
	elif current_mana_usage > current_mana && mana_usage_bar_catchup == true:
		if weapon.shooting == false && weapon.full_auto == true:
			current_mana_usage -= .5
		elif weapon.shooting == true && weapon.full_auto == false:
			mana_usage_timer.start()
			mana_usage_bar_catchup = false
		elif weapon.shooting == false && weapon.full_auto == false:
			current_mana_usage -= .5
	elif current_mana_usage == current_mana && mana_usage_bar_catchup == true:
		mana_usage_bar_catchup = false
		
	if damaged_bar.value < health_bar.value:
		damaged_bar.value = current_health
	
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


func _on_damage_recieved(damage : float) -> void:
	current_health -= damage


func _on_mana_regen_timeout():
	mana_regen = true


func _on_mana_usage_timeout():
	mana_usage_bar_catchup = true
	mana_regen_timer.start()


func _on_damaged_timeout():
	damadged_bar_catchup = true


func _on_weapon_mana_used():
	current_mana -= weapon.mana_cost
	mana_regen = false
