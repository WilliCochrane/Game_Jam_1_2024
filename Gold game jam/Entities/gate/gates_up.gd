extends Area2D

signal close_gates
signal open_gates

@onready var area : CollisionShape2D = $CollisionShape2D
@onready var nav_region : NavigationRegion2D = $NavigationRegion2D

var first_activation : bool = true
var enemies_spawned : bool = false
var summon_wave : bool = false
var alive_enemies : int = 0

func _ready():
	get_parent().connect("clear_floor",on_clear_floor)


func _physics_process(_delta):
	if summon_wave == true:
		summon_enemies()
	if enemies_spawned == true && alive_enemies == 0:
		emit_signal("open_gates")
		alive_enemies = 1
	


func summon_enemies():
	summon_wave = false
	enemies_spawned = true
	nav_region.bake_navigation_polygon()
	for i in range(0,randi_range(5,7)):
		var e = get_parent().enemy.instantiate()
		e.scale.x *= 1/scale.x
		e.scale.y *= 1/scale.y
		add_child(e)
		e.global_position.x = randf_range(position.x-scale.x*8,position.x+scale.x*8)
		e.global_position.y = randf_range(position.y-scale.y*8,position.y+scale.y*8)
		
		alive_enemies += 1


func _on_body_entered(body):
	if body.is_in_group("Player") && first_activation == true:
		emit_signal("close_gates")
		summon_wave = true
		first_activation = false


func on_clear_floor():
	queue_free()
