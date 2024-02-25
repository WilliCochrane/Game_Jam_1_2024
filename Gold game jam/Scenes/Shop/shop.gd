extends Control

signal shop_closed

@export var reroll_button : Button
@export var shop_item1 : Panel
@export var shop_item2 : Panel
@export var shop_item3 : Panel
@export var money : Label

var avalable_abilities : Array[Ability]
var player : CharacterBody2D
var is_open : bool = false
var reroll_cost : int

func open():
	visible = true
	is_open = true
	reroll_cost = 5
	update_money()
	reset_shop()

func close():
	visible = false
	is_open = false
	get_tree().paused = false
	shop_closed.emit()


func _ready():
	dir_contents("res://Scenes/Abilities/Ability/")
	player = get_tree().get_first_node_in_group("Player")
	reroll_shop()
	update_money()
	player.gold += 100

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
		reroll_button.text = str(reroll_cost) + " Reroll"
		update_money()

func reset_shop():
	shop_item1.load_item(avalable_abilities.pick_random())
	shop_item2.load_item(avalable_abilities.pick_random())
	shop_item3.load_item(avalable_abilities.pick_random())
	reroll_button.text = str(reroll_cost) + " Reroll"
	update_money()

func update_money():
	money.text = str(player.gold)


func _on_reroll_button_pressed():
	reroll_shop()


func _on_next_floor_pressed():
	close()
