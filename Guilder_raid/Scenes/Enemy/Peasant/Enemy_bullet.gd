extends CharacterBody2D

var player : CharacterBody2D
var speed = 80
var damage = 1
var scale_factor = 1

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	scale.x *= 1/get_parent().scale.x
	scale.y *= 1/get_parent().scale.y
	scale *= scale_factor
	
func _physics_process(delta):
	position += transform.x * speed * delta
	z_index = 1


func _on_area_2d_area_entered(area):
	if area.is_in_group("Player_hitbox"):
		if player.dash.is_dashing() == false:
			player.current_health -= damage
			player.hit = true
			queue_free()


func _on_area_2d_body_entered(body):
	if !body.is_in_group("Enemy") && !body.is_in_group("Player"):
		queue_free()
