extends Control

signal opened
signal closed

@onready var ability_display : Control = $Ability_display
@export var canvas_modulate : CanvasModulate

var is_open : bool = false

func _ready():
	$Gama_Slider.value = canvas_modulate.color.r/100


func open():
	visible = true
	is_open = true
	opened.emit()
	get_tree().paused = true


func close():
	visible = false
	is_open = false
	closed.emit()
	get_tree().paused = false


func _on_shop_shop_closed():
	ability_display.update()


func _on_h_slider_value_changed(value):
	canvas_modulate.color = Color(value/100,value/100,value/100)
