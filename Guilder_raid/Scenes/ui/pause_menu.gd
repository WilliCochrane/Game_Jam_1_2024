extends Control

signal opened
signal closed

@onready var ability_display : Control = $NinePatchRect/Ability_display

var is_open : bool = false

func open():
	visible = true
	is_open = true
	opened.emit()

func close():
	visible = false
	is_open = false
	closed.emit()


func _on_shop_shop_closed():
	ability_display.update()
