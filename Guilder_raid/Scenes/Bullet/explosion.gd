extends Area2D

var player : CharacterBody2D
var damage : float
var size : float
var type : String
var first_frame : bool = true

func _ready():
	player = get_tree().get_first_node_in_group("Player")


func _process(_delta):
	if first_frame:
		scale = Vector2(size,size)
		player.shake_strength = damage/10 * size
		$AnimationPlayer.play(type)


func _on_area_entered(area):
	if area.is_in_group("Enemy"):
		area.get_parent().health -= damage
		area.get_parent().hit = true


func _on_animation_player_animation_finished(_anim_name):
	queue_free()


