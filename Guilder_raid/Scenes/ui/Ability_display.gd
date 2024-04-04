extends Control

@onready var ability_inventory : Ability_Inventory = preload("res://Scenes/Abilities/Ability_inventory.tres")
@onready var grid_container : GridContainer = $GridContainer
@export var ability_slot : PackedScene

var is_new : bool 
var first : bool = true

func update():
	for child in grid_container.get_children():
		child.queue_free()
	for ability in ability_inventory.abilities:
		is_new = true
		for i in grid_container.get_children():
			if i.current_ability == ability:
				is_new = false
		if is_new:
			var ab = ability_slot.instantiate()
			grid_container.add_child(ab)
			ab.update(ability)


func _on_pause_menu_opened():
	if first:
		first = false
	else:
		update()


func _on_pause_menu_closed():
	update()
