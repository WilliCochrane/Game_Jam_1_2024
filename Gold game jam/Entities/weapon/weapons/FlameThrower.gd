extends weapon_type
class_name FlameThrower


func _ready():
	full_auto = true
	flamethrow = true
	bullet_type = "Gradient"
	damage = .5
	fire_rate = 30
	mana_cost = 1
	crit_chance = 0
	bullet_size = .2
	bullet_speed = 2
	bullet_spread = 3


func Update(_delta):
	anim_player.play("FlameThrower")
