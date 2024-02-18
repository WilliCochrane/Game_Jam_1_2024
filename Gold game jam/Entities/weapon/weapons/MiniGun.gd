extends weapon_type
class_name MiniGun


func _ready():
	full_auto = true
	bullet_type = "small"
	damage = 4
	fire_rate = 15
	mana_cost = 1
	projectiles = 1
	crit_chance = 10
	bullet_size = .5
	bullet_speed = 10
	bullet_spread = 10


func Update(_delta):
	anim_player.play("MiniGun")
