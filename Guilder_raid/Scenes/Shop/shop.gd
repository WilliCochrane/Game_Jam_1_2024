extends Control

signal shop_closed

@export var reroll_button : Button
@export var shop_item1 : Panel
@export var shop_item2 : Panel
@export var shop_item3 : Panel
@export var money : Label
@export var avalable_abilities : Array[Ability]

var current_avalable_abilities : Array[Ability]
var player : CharacterBody2D
var is_open : bool = false
var reroll_cost : int
var item1 : Ability
var item2 : Ability
var item3 : Ability 

func open():
	visible = true
	is_open = true
	reroll_cost = 0
	get_tree().paused = true
	update_money()
	reset_shop()

func close():
	visible = false
	is_open = false
	get_tree().paused = false
	shop_closed.emit()
	player.update_abilities()
	player.health_bar.value = player.max_health
	player.current_health = player.max_health


func _ready():
	player = get_tree().get_first_node_in_group("Player")
	reset()


func dir_contents(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() == false:
				current_avalable_abilities.push_back(load("res://Scenes/Abilities/Ability/" + file_name))
			file_name = dir.get_next()

func reroll_shop():
	if reroll_cost <= player.gold:
		player.gold -= reroll_cost
		reroll_cost += 5
		item1 = current_avalable_abilities.pick_random()
		shop_item1.load_item(item1)
		item2 = current_avalable_abilities.pick_random()
		while item2 == item1:
			item2 = current_avalable_abilities.pick_random()
		shop_item2.load_item(item2)
		item3 =  current_avalable_abilities.pick_random()
		while item3 == item1 or item3 == item2:
			item3 =  current_avalable_abilities.pick_random()
		shop_item3.load_item(item3)
		reroll_button.text = "Reroll: " + str(reroll_cost)
		update_money()

func reset_shop():
	reroll_button.disabled = false
	item1 = current_avalable_abilities.pick_random()
	shop_item1.load_item(item1)
	item2 = current_avalable_abilities.pick_random()
	while item2 == item1:
		item2 = current_avalable_abilities.pick_random()
	shop_item2.load_item(item2)
	item3 =  current_avalable_abilities.pick_random()
	while item3 == item1 or item3 == item2:
		item3 =  current_avalable_abilities.pick_random()
	shop_item3.load_item(item3)
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


func reset():
	for ability in avalable_abilities:
		current_avalable_abilities.push_back(ability)
	reroll_shop()
	update_money()


func _on_reroll_button_pressed():
	reroll_shop()


func _on_next_floor_pressed():
	close()
