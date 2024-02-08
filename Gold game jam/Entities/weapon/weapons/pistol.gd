extends weapon_type
class_name pistol


func _ready():
	full_auto = false
	bullet_type = "small"
	damage = 4
	fire_rate = 3
	mana_cost = 3
	crit_chance = 20
	bullet_size = .75
	bullet_speed = 14
	bullet_spread = 7


func Update(_delta):
	anim_player.play("pistol")
