extends RigidBody

var speed = 10.0  # Adjust the speed as needed

func _physics_process(delta):
	# Move the cart based on input
	if Input.get_action_strength("ui_right"):
		apply_impulse(global_transform.origin, Vector3(0,0,2))
	elif Input.get_action_strength("ui_left"):
		apply_impulse(global_transform.origin, Vector3(0,0,-2))
