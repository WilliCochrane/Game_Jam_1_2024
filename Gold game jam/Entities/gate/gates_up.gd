extends Area2D

signal close_gates

var first_activation : bool = true

func _ready():
	get_parent().connect("clear_floor",on_clear_floor)

func _on_body_entered(body):
	if body.is_in_group("Player") && first_activation == true:
		emit_signal("close_gates")
		first_activation = false

func on_clear_floor():
	queue_free()
