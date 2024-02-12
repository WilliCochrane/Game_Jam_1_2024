extends CharacterBody2D

@export var instructions : Sprite2D
@export var anim_player : AnimationPlayer

var show_instrusctions : bool
var first_update : bool = true

func _process(_delta):
	pass
	
	#if first_update == true:
		#show_instrusctions = false
		#first_update = false
#
	#instructions.visible = show_instrusctions
	#if show_instrusctions == true:
		#anim_player.play("Instructions")
#
#func _on_area_2d_body_entered(body):
	#show_instrusctions = true
	#
#
#
#func _on_area_2d_body_exited(body):
	#show_instrusctions = false
