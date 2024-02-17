extends CharacterBody2D

signal player_damage

@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D

@export var move_speed : float

var player : CharacterBody2D
var health : float = 50
var attack_1_damage : float = 30

func _ready():
	player = get_tree().get_first_node_in_group("Player")


func _physics_process(_delta: float) -> void:
	var direction = (nav_agent.get_next_path_position() - global_position).normalized()
	velocity = direction * move_speed
	player = get_tree().get_first_node_in_group("Player")


	var dir = player.global_position - global_position
	if dir.length() > 200:
		pass

func make_path():
	nav_agent.target_position = player.global_position

func _on_nav_timer_timeout():
	make_path()


func _on_attack_1_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("player_damage",attack_1_damage)
