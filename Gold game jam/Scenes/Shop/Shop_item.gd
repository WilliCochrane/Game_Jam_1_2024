extends Panel

@onready var ability_inventory : Ability_Inventory = preload("res://Scenes/Abilities/Ability_inventory.tres")
@onready var description : RichTextLabel = $Description
@onready var ability_icon : Sprite2D = $ability_icon
@onready var price : Label = $Buy_button/Price
@onready var ability_name : Label = $Name

var player : CharacterBody2D
var can_buy : bool
var current_ability : Ability

func _ready():
	player = get_tree().get_first_node_in_group("Player")

func load_item(ability : Ability):
	current_ability = ability
	visible = true
	can_buy = true
	ability_icon.texture = ability.texture
	ability_name.text = ability.ability_name
	description.text = ability.description
	price.text = str(int(randf_range(.85,1.15)*ability.cost))
	


func _on_buy_button_pressed():
	player.gold -= int(price.text)
	visible = false
	can_buy = false
	ability_inventory.abilities.push_front(current_ability)
	get_parent().get_parent().update_money()
