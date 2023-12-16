extends RigidBody

var parent_node
var pole_length = 5.0  # Adjust the length as needed

func set_pole_size(size):
	# Access the CollisionShape child node
	var collision_shape = $CollisionShape
	var mesh = $MeshInstance.mesh

	collision_shape.shape.extents = size / 2.0
	mesh.set_size(Vector3(2.0, pole_length, 2.0))

	# Add more conditions based on the shape types you use

func _ready():
	pass
