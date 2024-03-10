extends CharacterBody2D

@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var weapon : CharacterBody2D = get_tree().get_first_node_in_group("Player").get_child(4)

var damage : float 
var speed : float 
var crit_chance : float  
var size : float
var spread : float
var flamethrow : bool
var rotated : bool = false
var can_move : bool = true

func _ready():
	weapon = get_tree().get_first_node_in_group("Player").get_child(4)
	damage = weapon.damage * weapon.damage_modifier
	speed = weapon.bullet_speed
	crit_chance = weapon.crit_chance + weapon.crit_chance_modifier
	size = weapon.bullet_size * weapon.bullet_size_modifier
	spread = weapon.bullet_spread
	flamethrow = weapon.flamethrow
	$CPUParticles2D.scale *= 1/scale.x
	z_index = -5
	


func _physics_process(delta):
	if can_move:
		if flamethrow == true && size < 5:
			size += .03
			speed -= .1
				
		if rotated == false:
			rotation_degrees += randf_range(-spread,spread)
			rotated = true
		position += transform.x * speed * delta
		scale = Vector2(size,size)/3
		z_index = 1
		$CPUParticles2D.restart()



func _on_area_2d_body_entered(body):
	if body.is_in_group("Player") == false:
		if body.is_in_group("Enemy"):
			body.health -= damage
			body.hit = true
			can_move = false
			
			$CPUParticles2D.emitting = true
			$Sprite2D.visible = false
			$Timer.start()
			if flamethrow == false:
				pass
		else:
			queue_free()




func _on_timer_timeout():
	queue_free()


func _on_area_2d_area_entered(area):
	if area.is_in_group("Enemy"):
		area.get_parent().health -= damage
		area.get_parent().hit = true
		can_move = false
	
		$CPUParticles2D.emitting = true
		$Sprite2D.visible = false
		$Timer.start()
		if flamethrow == false:
			pass
		else:
			queue_free()
