extends CanvasLayer

@onready var pause_menu = $Pause_menu
@onready var start_menu = $Start_menu
@onready var shop = $Shop

func _ready(): 
	start_menu.open()
	pause_menu.close()
	shop.close()
	get_tree().paused = true


func _input(event):
	if event.is_action_pressed("ui_cancel") && shop.is_open == false:
		if pause_menu.is_open == true:
			pause_menu.close()
		else:
			pause_menu.open()


func _on_timer_timeout():
	if shop.is_open:
		get_tree().paused = true
