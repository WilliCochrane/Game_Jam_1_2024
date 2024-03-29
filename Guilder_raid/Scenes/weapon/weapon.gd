extends CharacterBody2D

signal mana_used

@export var bullet : PackedScene
@export var cooldown_timer : Timer
@export var weapon_machine : Node
@export var raycast : RayCast2D
@export var shot_interval : Timer

var b_rotation : float
var crit : bool

var bullet_spread : float 
var bullet_type : String
var bullet_speed : float 
var bullet_size : float 
var crit_chance : float
var damage : float
var piercing : int
var bounces : int 
var explotion_size : float
var explotion_type : String

var fire_rate : float
var mana_cost : float
var flamethrow : bool
var projectiles : int
var full_auto : bool
var money_shot : bool

var projectiles_left : int = 0
var shooting : bool = false
var can_shoot : bool = true
var colliding : bool

var bullet_spread_modifier : float = 1
var projectiles_modifier : float = 1
var crit_chance_modifier : float = 0
var bullet_size_modifier : float = 1
var fire_rate_modifier : float = 1
var damage_modifier : float = 1


func _ready():
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
	if money_shot:
		if get_parent().gold > 0 or get_parent().current_mana == get_parent().max_mana:
			shooting = true
			if can_shoot == true && colliding == false:
				cooldown_timer.start()
				can_shoot = false
				emit_signal("mana_used")
				if randi_range(0,100) <= crit_chance:
					crit = true
				else: 
					crit = false
				if !flamethrow:
					get_parent().shake_strength = (weapon_machine.current_weapon.damage/5) * weapon_machine.current_weapon.projectiles + (weapon_machine.current_weapon.fire_rate/10)
				if projectiles == 1:
					spawn_bullet()
				else:
					shoot_projectiles()

	elif get_parent().current_mana > 0:
		shooting = true
		if can_shoot == true && colliding == false:
			cooldown_timer.start()
			can_shoot = false
			emit_signal("mana_used")
			if randi_range(0,100) <= crit_chance:
				crit = true
			else: 
				crit = false
			if !flamethrow:
				get_parent().shake_strength = (weapon_machine.current_weapon.damage/5) * weapon_machine.current_weapon.projectiles + (weapon_machine.current_weapon.fire_rate/10)
			if projectiles == 1:
				spawn_bullet()
			else:
				shoot_projectiles()


func _on_player_shoot_stop():
	shooting = false


func shoot_projectiles():
	projectiles_left = projectiles
	spawn_bullet()
	projectiles_left -= 1
	shot_interval.start(randf_range(.005,.01))


func spawn_bullet():
	var b = bullet.instantiate()
	owner.owner.add_child(b)
	b.anim_player.play(bullet_type)
	b.position = $Muzzle.global_position
	b.sprite.scale.y *= $Sprite2D.scale.y
	b.rotation = b_rotation
	b.crit = crit


func reset():
	weapon_machine.current_weapon = weapon_machine.initial_weapon


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
	piercing = weapon_machine.current_weapon.piercing
	bounces = weapon_machine.current_weapon.bounces
	explotion_size = weapon_machine.current_weapon.explotion_size
	explotion_type = weapon_machine.current_weapon.explotion_type
	money_shot = weapon_machine.current_weapon.money_shot
	
	cooldown_timer.wait_time = 1/fire_rate * fire_rate_modifier
	
	
	if weapon_machine.current_weapon.flamethrow:
		flamethrow = true
	else:
		flamethrow = false


func _on_cooldown_timeout():
	can_shoot = true
	if full_auto == true && shooting == true:
		_on_player_shoot()



func _on_shot_interval_timeout():
	if projectiles_left > 0:
		spawn_bullet()
		projectiles_left -= 1
		shot_interval.start(randf_range(.005,.01))
