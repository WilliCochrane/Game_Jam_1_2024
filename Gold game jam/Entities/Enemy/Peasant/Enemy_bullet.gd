extends CharacterBody2D

var player : CharacterBody2D
var speed = 75
var damage = 15
var scale_factor = 1

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	scale.x *= 1/get_parent().scale.x
	scale.y *= 1/get_parent().scale.y
	scale *= scale_factor
	
func _physics_process(delta):
	position += transform.x * speed * delta


func _on_area_2d_body_entered(body):
	if body.is_in_group("Enemy") == false:
		if body.is_in_group("Player"):
			player.current_health -= damage
			player.hit = true
		queue_free()
		
