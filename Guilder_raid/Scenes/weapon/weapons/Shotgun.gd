extends weapon_type
class_name Shotgun


func _ready():
	full_auto = false
	bullet_type = "Large"
	damage = 3
	fire_rate = 1.5
	mana_cost = 5
	projectiles = 6
	crit_chance = 10
	bullet_size = 2
	bullet_speed = 5
	bullet_spread = 15


func Update(_delta):
	anim_player.play("Shotgun")
