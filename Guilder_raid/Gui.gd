extends CanvasLayer

@onready var pause_menu = $Pause_menu
@onready var start_menu = $Start_menu
@onready var credits = $Credits
@onready var shop = $Shop

func _ready(): 
	start_menu.close()
	pause_menu.close()
	shop.open()
	credits.close()
	get_tree().paused = true


func _input(event):
	if event.is_action_pressed("ui_cancel") && !shop.is_open:
		if !start_menu.is_open:
			if pause_menu.is_open == true:
				pause_menu.close()
			else:
				pause_menu.open()
		if credits.is_open:
			credits.close()


func _on_timer_timeout():
	if shop.is_open:
		get_tree().paused = true
