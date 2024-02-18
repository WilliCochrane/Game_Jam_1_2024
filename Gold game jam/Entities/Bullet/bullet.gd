extends CharacterBody2D

@onready var anim_player : AnimationPlayer = $AnimationPlayer

@onready var weapon : CharacterBody2D = get_tree().get_first_node_in_group("Player").get_child(4)
var damage : float 
var speed : float 
var crit_chance : float  
var size : float
var spread : float
var type : String 

var flamethrow : bool

var rotated : bool = false

func _ready():
	weapon = get_tree().get_first_node_in_group("Player").get_child(4)
	
	damage = weapon.damage
	speed = weapon.bullet_speed
	crit_chance = weapon.crit_chance
	size = weapon.bullet_size
	spread = weapon.bullet_spread
	type = weapon.bullet_type
	flamethrow = weapon.flamethrow
	anim_player.play(type)
	
	z_index = -5
	


func _physics_process(delta):
	if flamethrow == true && size < 5:
		size += .03
		speed -= .03
			
	if rotated == false:
		rotation_degrees += randf_range(-spread,spread)
		rotated = true
	position += transform.x * speed * delta
	scale = Vector2(size,size)/3
	z_index = 1



func _on_area_2d_body_entered(body):
	if body.is_in_group("Player") == false:
		if body.is_in_group("Enemy"):
			body.health -= damage
		queue_free()
