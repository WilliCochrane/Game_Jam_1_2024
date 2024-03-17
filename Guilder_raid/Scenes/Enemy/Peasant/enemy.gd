extends CharacterBody2D

signal player_damage

@onready var enemy_bullet : PackedScene = preload("res://Scenes/Enemy/Peasant/enemy_bullet.tscn")
@onready var gold : PackedScene = preload("res://Scenes/Treasure/gold.tscn")
@onready var alt_animation : AnimationPlayer = $hit_AnimationPlayer
@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
@onready var collision : CollisionShape2D = $CollisionShape2D
@onready var animation : AnimationPlayer = $AnimationPlayer
@onready var attack_timer : Timer = $Attack_timer
@onready var idle_timer : Timer = $Idle_timer
@onready var raycast : RayCast2D = $RayCast2D
@onready var nav_timer : Timer = $Nav_timer
@onready var sprite : Sprite2D = $Sprite2D
@onready var gun : Sprite2D = $Gun

var can_attack : bool = false
var target_position : Vector2
var player : CharacterBody2D
var move_speed : float = 75
var rotation_speed = 15
var spawn_value : float
var random_num : float
var hit : bool = false
var can_move : bool
var health : float 
var wander : bool
var spawn : bool

enum {
	APROACH,
	IDLE,
	RUN,
}

var state = IDLE


func _ready():
	health = 5
	player = get_tree().get_first_node_in_group("Player")
	attack_timer.start(randf_range(2,3))
	can_move = false
	spawn = true
	spawn_value = 1
	sprite.material.set_shader_parameter("progress", spawn_value)
	gun.material.set_shader_parameter("progress", spawn_value)
	if randi_range(0,1) == 1:
		wander = true
	else:
		wander = false
	


func _physics_process(delta: float) -> void:
	if spawn == true:
		spawn_value -= .015
		sprite.material.set_shader_parameter("progress", spawn_value)
		gun.material.set_shader_parameter("progress", spawn_value)
		can_move = false
		if spawn_value <= 0:
			spawn = false
			can_move = true
	
	
	match state:
		APROACH:
			target_position = Vector2(player.global_position.x + randf_range(-10,10),player.global_position.y + randf_range(-10,10))
		IDLE:
			if wander == false:
				target_position = global_position
				velocity = Vector2.ZERO
		RUN:
			target_position = global_position * 2 - player.global_position
			
	if health <= 0:
		die()
		
	if can_attack == true:
		if !raycast.is_colliding():
			shoot()
	
	if velocity == Vector2.ZERO:
		animation.play("p_idle")
	else:
		animation.play("p_run")
	
	if hit == true:
		alt_animation.play("hit")
		hit = false
	
	if can_move == true:
		var direction = (nav_agent.get_next_path_position() - global_position).normalized()
		var steering = ((direction * move_speed) - velocity) * delta * 1.2
		velocity += steering
	else:
		velocity = Vector2.ZERO
	
	var dir = player.global_position - global_position
	if dir.length() < 60:
		state = RUN
	elif dir.length() > 300:
		state = APROACH
	else: 
		state = IDLE
	
	
	z_index = 1
	rotate_to_player(delta)
	move_and_slide()


func rotate_to_player(delta):
	var direction = (player.position - gun.global_position) #target global position if is an entity
	var gunAngleTo = gun.transform.x.angle_to(direction)
	gun.rotation += (sign(gunAngleTo) * min(delta * rotation_speed, abs(gunAngleTo)))
	gun.rotation_degrees = round_to_dec(gun.rotation_degrees, -1)
	
	if direction.x > 0:
		sprite.flip_h = true
		gun.scale.y = 1
	elif direction.x < 0:
		sprite.flip_h = false
		gun.scale.y = -1


func round_to_dec(num, digit):
	return round(num * pow(20.0, digit)) / pow(20.0, digit)


func shoot():
	var eb = enemy_bullet.instantiate()
	get_parent().get_parent().add_child(eb)
	eb.rotation = gun.rotation
	eb.global_position = gun.global_position
	can_attack = false
	attack_timer.start(randf_range(2,3))


func die():
	get_parent().alive_enemies -= 1
	for i in range(0,randi_range(3,5)):
		var gd = gold.instantiate()
		get_parent().get_parent().add_child(gd)
		gd.global_position = Vector2(global_position.x,global_position.y+2)
	queue_free()


func _on_attack_timer_timeout():
	can_attack = true


func _on_nav_timer_timeout():
	nav_agent.target_position = target_position
	raycast.target_position = player.global_position - raycast.global_position


func _on_idle_timer_timeout():
	if wander == false:
		wander = true
		if state == IDLE:
			target_position = Vector2(global_position.x + randi_range(-100,100),global_position.y + randi_range(-100,100))
		idle_timer.start(randf_range(2,3))
	else:
		wander = false
		idle_timer.start(2)


func _on_collision_damage_area_entered(area):
	if area.is_in_group("Player_hitbox"):
		if player.dash.is_dashing() == false:
			player.current_health -= 1
			player.hit = true
