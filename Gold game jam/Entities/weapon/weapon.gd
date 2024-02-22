extends CharacterBody2D

signal mana_used

@export var bullet : PackedScene
@export var cooldown_timer : Timer
@export var weapon_machine : Node
@export var first_bullet : CharacterBody2D
@export var raycast : RayCast2D

var bullet_type : String
var bullet_speed : float 
var bullet_size : float 
var bullet_spread : float 
var damage : float
var crit_chance : float

var projectile_interval : float
var fire_rate : float 
var mana_cost : float
var flamethrow : bool
var projectiles : int
var full_auto : bool

var projectiles_left : int = 0
var shooting : bool = false
var can_shoot : bool = true
var colliding : bool

var camera_shake_strength : float = 10
var shake_fade : float = 5

func _ready():
	first_bullet.queue_free()
	raycast.add_exception(get_parent())

func _physics_process(_delta):
	var collider = raycast.get_collider()
	if collider is Node:
		if collider.is_in_group("dungeon"):
			colliding = true
		else:
			colliding = false
			if can_shoot == true:
				_on_cooldown_timeout()
	else:
		colliding = false
		if can_shoot == true:
				_on_cooldown_timeout()
	
	update_weapon_parameters()


func _on_player_shoot():
	if get_parent().current_mana > 0:
		shooting = true
		if can_shoot == true && colliding == false:
			cooldown_timer.start()
			can_shoot = false
			emit_signal("mana_used")
			if projectiles == 1:
				spawn_bullet()
			else:
				shoot_projectiles()


func _on_player_shoot_stop():
	shooting = false


func shoot_projectiles():
	projectiles_left = projectiles
	while projectiles_left > 0:
		spawn_bullet()
		projectiles_left -= 1


func spawn_bullet():
	var b = bullet.instantiate()
	owner.owner.add_child(b)
	b.anim_player.play(bullet_type)
	b.transform = $Muzzle.global_transform
	



func update_weapon_parameters():	
	bullet_type = weapon_machine.current_weapon.bullet_type
	full_auto = weapon_machine.current_weapon.full_auto
	damage = weapon_machine.current_weapon.damage
	bullet_speed = weapon_machine.current_weapon.bullet_speed * 100
	bullet_size = weapon_machine.current_weapon.bullet_size
	bullet_spread = weapon_machine.current_weapon.bullet_spread
	bullet_type = weapon_machine.current_weapon.bullet_type
	crit_chance = weapon_machine.current_weapon.crit_chance
	fire_rate = weapon_machine.current_weapon.fire_rate
	mana_cost = weapon_machine.current_weapon.mana_cost
	full_auto = weapon_machine.current_weapon.full_auto
	projectiles = weapon_machine.current_weapon.projectiles
	
	cooldown_timer.wait_time = 1/fire_rate
	
	
	if weapon_machine.current_weapon.flamethrow:
		flamethrow = true
	else:
		flamethrow = false


func _on_cooldown_timeout():
	can_shoot = true
	if full_auto == true && shooting == true:
		_on_player_shoot()

