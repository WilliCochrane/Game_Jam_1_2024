extends Sprite2D

var opacity = 1

func _physics_process(_delta):
	if opacity >= 0:
		opacity -= .03
		modulate.a = opacity
	else:
		queue_free()
