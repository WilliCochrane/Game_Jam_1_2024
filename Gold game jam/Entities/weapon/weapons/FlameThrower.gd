extends weapon_type
class_name FlameThrower


func _ready():
	full_auto = true
	flamethrow = true
	bullet_type = "Gradient"
	damage = .25
	fire_rate = 60
	mana_cost = .5
	crit_chance = 0
	bullet_size = .2
	bullet_speed = 4
	bullet_spread = 1.5


func Update(_delta):
	anim_player.play("FlameThrower")
