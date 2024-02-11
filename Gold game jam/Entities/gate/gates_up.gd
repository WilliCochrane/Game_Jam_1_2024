extends Area2D

signal close_gates

var first_activation : bool = true

func _on_body_entered(body):
	if body.is_in_group("Player") && first_activation == true:
		emit_signal("close_gates")
		first_activation = false
