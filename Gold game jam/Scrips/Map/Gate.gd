extends StaticBody2D

@export var anim_player : AnimationPlayer
@export var collision_shape : CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play("x_facing_idle")
	collision_shape.disabled = true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_parent().
