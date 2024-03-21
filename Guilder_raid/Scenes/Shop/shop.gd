extends Control

signal shop_closed

@export var grid_container : GridContainer
@export var reroll_button : Button
@export var shop_item1 : Panel
@export var shop_item2 : Panel
@export var shop_item3 : Panel
@export var money : Label
@export var avalable_abilities : Array[Ability]

var player : CharacterBody2D
var is_open : bool = false
var reroll_cost : int

func open():
	visible = true
	is_open = true
	reroll_cost = 0
	update_money()
	reset_shop()

func close():
	visible = false
	is_open = false
	get_tree().paused = false
	shop_closed.emit()


func _ready():
	player = get_tree().get_first_node_in_group("Player")
	reroll_shop()
	update_money()

func dir_contents(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() == false:
				avalable_abilities.push_back(load("res://Scenes/Abilities/Ability/" + file_name))
			file_name = dir.get_next()

func reroll_shop():
	if reroll_cost <= player.gold:
		player.gold -= reroll_cost
		reroll_cost += 5
		shop_item1.load_item(avalable_abilities.pick_random())
		shop_item2.load_item(avalable_abilities.pick_random())
		shop_item3.load_item(avalable_abilities.pick_random())
		reroll_button.text = "Reroll: " + str(reroll_cost)
		update_money()

func reset_shop():
	reroll_button.disabled = false
	shop_item1.load_item(avalable_abilities.pick_random())
	shop_item2.load_item(avalable_abilities.pick_random())
	shop_item3.load_item(avalable_abilities.pick_random())
	reroll_button.text = "Reroll: " + str(reroll_cost)
	update_money()

func update_money():
	money.text = str(player.gold)
	if reroll_cost > player.gold:
		reroll_button.disabled = true
	if shop_item1.price > player.gold:
		shop_item1.price_label.self_modulate = Color(0.749, 0, 0.059)
	if shop_item2.price > player.gold:
		shop_item2.price_label.self_modulate = Color(0.749, 0, 0.059)
	if shop_item3.price > player.gold:
		shop_item3.price_label.self_modulate = Color(0.749, 0, 0.059)


func _on_reroll_button_pressed():
	reroll_shop()


func _on_next_floor_pressed():
	close()
