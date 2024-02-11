extends CharacterBody2D

@export var instructions : Sprite2D
@export var anim_player : AnimationPlayer

var show_instrusctions : bool = false


func _process(_delta):
	if show_instrusctions == false:
		instructions.hide()
	elif show_instrusctions == true:
		instructions.show()
		anim_player.play("Instructions")


func _on_area_2d_body_entered(body):
	show_instrusctions = true
	


func _on_area_2d_body_exited(body):
	show_instrusctions = false
