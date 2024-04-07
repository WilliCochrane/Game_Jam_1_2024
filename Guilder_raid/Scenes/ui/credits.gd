extends Control

var is_open : bool = false

func open():
	visible = true
	is_open = true


func close():
	visible = false
	is_open = false


func _on_return_pressed():
	close()
