extends CharacterBody2D

signal player_damage

@onready var attack_area_1 : CollisionShape2D = $Attack_1/Attack_area_1
@onready var attack_area_3 : CollisionShape2D = $Attack_3/Attack_area_3
@onready var health_bar : TextureProgressBar = $TextureProgressBar
@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
@onready var collision : CollisionShape2D = $CollisionShape2D
@onready var animation : AnimationPlayer = $AnimationPlayer
@onready var attack_timer : Timer = $Attack_timer
@onready var sprite : Sprite2D = $Sprite2D

var rng = RandomNumberGenerator.new()
var death_anim_played : bool = false
var attack_1_damage : float = 10
var player : CharacterBody2D
var move_speed : float = 75
var health : float = 50
var random_num : float
var invincible : bool 


enum {
	SURROUND,
	ATTACK,
	DEAD,
	HIT,
}

var state = SURROUND

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	rng.randomize()
	random_num = rng.randf()
	animation.play("spawn")
	health_bar.hide()
	invincible = true


func _physics_process(delta: float) -> void:
	match state:
		SURROUND:
			if animation.is_playing() == false:
				animation.play("walk")
			if animation.get_current_animation() == "walk":
				move(delta)
			
		ATTACK:
			rng.randomize()
			random_num = rng.randf()
			get_circle_position(random_num)
			if animation.is_playing() == false:
				animation.play("walk")
			if animation.get_current_animation() == "walk":
				move(delta)
			
		HIT:
			if invincible == false:
				animation.play("attack_1")
		
		DEAD:
			if death_anim_played == false:
				animation.play("die")
				death_anim_played = true
				get_parent().alive_enemies -= 1
				collision.disabled = true
				health_bar.hide()
			velocity = Vector2.ZERO
			attack_1_damage = 0
			
	health_bar.value = health
	
	if health <= 0:
		state = DEAD
	
	if state != DEAD:
		if player.global_position.x > global_position.x && sprite.flip_h == true:
			sprite.flip_h = false
			attack_area_1.position *= -1
			attack_area_3.position *= -1
		elif player.global_position.x <= global_position.x && sprite.flip_h == false:
			sprite.flip_h = true
			attack_area_1.position *= -1
			attack_area_3.position *= -1
	
	move_and_slide()


func move(delta):
	var direction = (nav_agent.get_next_path_position() - global_position).normalized()
	var steering = ((direction * move_speed) - velocity) * delta * 2.5
	velocity += steering


func get_circle_position(random):
	var kill_circle_center = player.global_position
	var radius = 60
	var angle = random * PI * 2
	var x = kill_circle_center.x + cos(angle) * radius
	var y = kill_circle_center.y + sin(angle) * radius
	
	return Vector2(x, y)


func make_path():
	match state:
		SURROUND:
			nav_agent.target_position = get_circle_position(random_num)
		
		ATTACK:
			nav_agent.target_position = player.global_position
		
		HIT:
			pass
		






func _on_nav_timer_timeout():
	make_path()


func _on_attack_1_body_entered(body):
	if body.is_in_group("Player") && invincible == false: # if the enemy is invincible it can't attack
		body.current_health -= attack_1_damage


func _on_attack_timer_timeout():
	state = ATTACK


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "spawn":
		health_bar.show()
		invincible = false
