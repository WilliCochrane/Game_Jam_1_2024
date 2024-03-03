extends Control

signal opened
signal closed

@onready var u_sure : NinePatchRect = $"u_sure?"

var is_open : bool = false

func _ready():
	u_sure.visible = false

func open():
	get_tree().paused = true
	visible = true
	is_open = true
	opened.emit()

func close():
	get_tree().paused = false
	visible = false
	is_open = false
	closed.emit()


func _on_start_pressed():
	close()


func _on_quit_pressed():
	u_sure.visible = true


func _on_yes_pressed():
	get_tree().quit()


func _on_no_pressed():
	u_sure.visible = false
