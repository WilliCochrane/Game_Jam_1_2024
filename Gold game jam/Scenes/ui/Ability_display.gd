extends Control

@onready var ability_inventory : Ability_Inventory = preload("res://Scenes/Abilities/Ability_inventory.tres")
@onready var grid_container : GridContainer = $GridContainer
@export var ability_slot : PackedScene

func _ready():
	update()

func update():
	for i in range(ability_inventory.abilities.size()):
		var ab = ability_slot.instantiate()
		grid_container.add_child(ab)
		ab.update(ability_inventory.abilities[i])
