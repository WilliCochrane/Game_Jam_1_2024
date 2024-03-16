extends CharacterBody2D

signal shoot
signal shoot_stop
signal restart_game

@onready var you_died = $ui/You_died

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
@export var camera : Camera2D
@export var ui_sprite : Sprite2D
@export var ui_anim_player : AnimationPlayer
@export var low_health_indicator : Sprite2D
@export var gold_lable : Label
@export var ability_inventory : Ability_Inventory
@export var dash : Node2D

var move_direction : Vector2 = Vector2.ZERO
var current_damage : float = 5
var rotation_speed : float = 10
var current_health : float = 5
var current_mana : float = 150
var dash_duration : float = .15
var move_speed : float = 100
var dash_speed : float = 300
var max_health : float = 5
var max_mana : float = 150
var gold : int = 0

var mana_usage_bar_catchup : bool = false
var damadged_bar_catchup : bool = false
var current_mana_usage : float
var mana_regen : bool = false
var hit : bool = false

var shake_strength : float = 0.0
var shake_fade : float = 5.0


func _ready():
	ui_sprite.hide()
	mana_bar.value = max_mana
	mana_bar.max_value = max_mana
	mana_usage_bar.value = max_mana
	mana_bar.max_value = max_mana
	current_mana = max_mana
	
	health_bar.value = max_health
	health_bar.max_value = max_health 
	damaged_bar.value = max_health
	damaged_bar.max_value = max_health
	current_health = max_health
	

func _physics_process(delta):
	var speed = dash_speed if dash.is_dashing() else move_speed
	move_direction = Input.get_vector("ui_left", "ui_right","ui_up","ui_down")
	velocity = move_direction * speed  * delta
	position += velocity
	if move_direction != Vector2.ZERO:
		anim_player.play("gob_run")
	else:
		anim_player.play("gob_idle")
	
	if current_health <= 0:
		you_died.visible = true
		get_tree().paused = true
	
	low_health_indicator.modulate.a = 1 - (current_health*3/max_health)
	
	gold_lable.text = str(gold)
	
	if hit == true:
		ui_sprite.show()
		ui_anim_player.play("Player_hit")
		hit = false
	
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength,0,shake_fade*delta)
		
		camera.offset = random_offset()
	
	bar_management()
	weapon_rotate_to_mouse(get_global_mouse_position(),delta)
	move_and_slide()


func random_offset():
	return Vector2(randf_range(-shake_strength,shake_strength),randf_range(-shake_strength,shake_strength))


func weapon_rotate_to_mouse(target, delta):
	var direction = (target - weapon.global_position) #target global position if is an entity
	var angleTo = weapon.transform.x.angle_to(direction)
	weapon.rotation += (sign(angleTo) * min(delta * rotation_speed, abs(angleTo)))
	if direction.x > 0:
		sprite.flip_h = false
		weapon.get_child(0).scale.y = 1
	elif direction.x < 0:
		sprite.flip_h = true
		weapon.get_child(0).scale.y = -1
	weapon.rotation_degrees = round_to_dec(weapon.rotation_degrees,-1)


func _input(event):
	if event.is_action_pressed("ui_shoot"):
		emit_signal("shoot")
	if event.is_action_released("ui_shoot"):
		emit_signal("shoot_stop")
	if event.is_action("ui_accept") && dash.can_dash && !dash.is_dashing():
		dash.start_dash(sprite, dash_duration)


func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)


func _on_damage_recieved(damage : float) -> void:
	current_health -= damage


func bar_management():
	mana_bar.value = current_mana
	mana_usage_bar.value = current_mana_usage
	health_bar.value = current_health
	damaged_bar.value = current_damage
	
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
			current_mana_usage -= .75
		elif weapon.shooting == true && weapon.full_auto == false:
			mana_usage_timer.start()
			mana_usage_bar_catchup = false
		elif weapon.shooting == false && weapon.full_auto == false:
			current_mana_usage -= .75
	elif current_mana_usage <= current_mana:
		mana_usage_bar_catchup = false
		if mana_regen_timer.is_stopped():
			mana_regen_timer.start()
	
	if current_damage <= current_health:
		current_damage = current_health
		damadged_bar_catchup = false
	elif current_damage > current_health && damadged_bar_catchup == false:
		if damaged_timer.is_stopped():
			damaged_timer.start()
	elif current_damage > current_health && damadged_bar_catchup == true:
		current_damage -= .01


func _on_mana_regen_timeout():
	mana_regen = true


func _on_mana_usage_timeout():
	mana_usage_bar_catchup = true


func _on_damaged_timeout():
	damadged_bar_catchup = true


func _on_weapon_mana_used():
	current_mana -= weapon.mana_cost
	mana_regen = false


func _on_restart_pressed():
	emit_signal("restart_game")
	current_health = max_health
	current_mana = max_mana
	you_died.visible = false
	get_tree().paused = false
