extends Control

signal opened
signal closed

@onready var ability_display : Control = $Ability_display
@export var canvas : WorldEnvironment
@export var minimap : TileMap

var is_open : bool = false

func _ready():
	$VBoxContainer/Gama_Slider.value = 100
	$VBoxContainer/Minimap_slider.value = 50


func open():
	visible = true
	is_open = true
	opened.emit()
	get_tree().paused = true
	$Level_indicator.text = "Level "+str(get_parent().get_parent().level)+ " Floor " + str(get_parent().get_parent().dungeon_floor)


func close():
	visible = false
	is_open = false
	closed.emit()
	get_tree().paused = false


func _on_shop_shop_closed():
	ability_display.update()


func _on_h_slider_value_changed(value):
	canvas.environment.adjustment_brightness = value/100


func _on_return_pressed():
	close()
	get_parent().start_menu.open()


func _on_resume_pressed():
	close()


func _on_minimap_slider_value_changed(value):
	minimap.modulate.a = value/100
	minimap.get_child(0).modulate.a = value/100
