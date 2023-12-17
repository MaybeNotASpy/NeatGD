extends Spatial

var cartImpulse = 2.0  # Adjust as needed

onready var Pole1AngleInput = $"Input GUI/Inputs/Pole 1 Angle/Value"
onready var Pole2AngleInput = $"Input GUI/Inputs/Pole 2 Angle/Value"
onready var PoleAngleLimit = $"Input GUI/Inputs/Pole Angle Limit/Value"

onready var pole1AngleOut = $"Output GUI/Outputs/Pole 1 Angle/Value"
onready var pole2AngleOut = $"Output GUI/Outputs/Pole 2 Angle/Value"
onready var pole1AngularVelocityOut = $"Output GUI/Outputs/Pole 1 Angular Velocity/Value"
onready var pole2AngularVelocityOut = $"Output GUI/Outputs/Pole 2 Angular Velocity/Value"
onready var cartPositionOut = $"Output GUI/Outputs/Cart Position/Value"
onready var cartVelocityOut = $"Output GUI/Outputs/Cart Velocity/Value"

onready var cart = $"Cart"
onready var hinge1: HingeJoint = $"HingePole1"
onready var pole1 = $"HingePole1/Pole1"
onready var hinge2: HingeJoint = $"HingePole2"
onready var pole2 = $"HingePole2/Pole2"


enum GameState {
	MENU,
	PLAYING,
}

var gameState = GameState.MENU
var cartPosition : float = 0.0
var lastCartPosition : float = 0.0
var cartVelocity : float = 0.0
var pole1Angle : float = 0.0
var pole2Angle : float = 0.0
var lastPole1Angle : float = 0.0
var lastPole2Angle : float = 0.0
var pole1AngularVelocity : float = 0.0
var pole2AngularVelocity : float = 0.0

onready var startCartMatrix : Transform = cart.transform
onready var startPole1Matrix : Transform = pole1.transform
onready var startPole2Matrix : Transform = pole2.transform
onready var startHinge1Matrix : Transform = hinge1.transform
onready var startHinge2Matrix : Transform = hinge2.transform
var startPole1Angle : float = 0.0
var startPole2Angle : float = 0.0

func set_pole_1_angle(val: float) -> void :
	val = deg2rad(val) # Convert to radians
	startPole1Angle = val
	reset()
func set_pole_2_angle(val: float) -> void:
	val = deg2rad(val) # Convert to radians
	startPole2Angle = val
	reset()
func set_pole_angle_limit(val: float) -> void:
	hinge1._set_upper_limit(val)
	hinge1._set_lower_limit(-val)
	hinge2._set_upper_limit(val)
	hinge2._set_lower_limit(-val)
	reset()
	
func _on_enable_toggle(val: bool) -> void:
	if val:
		reset()
		PhysicsServer.set_active(true)
		gameState = GameState.PLAYING
	else:
		reset()
		gameState = GameState.MENU

func _ready() -> void:
	Pole1AngleInput.connect("value_changed", self, "set_pole_1_angle")
	Pole2AngleInput.connect("value_changed", self, "set_pole_2_angle")
	PoleAngleLimit.connect("value_changed", self, "set_pole_angle_limit")
	startPole1Angle = deg2rad(Pole1AngleInput.value)
	startPole2Angle = deg2rad(Pole2AngleInput.value)
	reset()

# 
func rad2deg_output(val: float) -> String:
	var deg = rad2deg(val)
	# Limit between -180 and 180
	if deg > 180:
		deg = deg - 360
	elif deg < -180:
		deg = deg + 360
	return str(deg).pad_decimals(2)

func reset() -> void:
	gameState = GameState.MENU
	lastPole1Angle = deg2rad(Pole1AngleInput.value)
	lastPole2Angle = deg2rad(Pole2AngleInput.value)
	cart.transform = startCartMatrix
	# Rotate pole 1 to the desired angle
	pole1.transform = startPole1Matrix
	hinge1.transform = startHinge1Matrix
	hinge1.rotate_object_local(Vector3(0,0,1), startPole1Angle)
	# Rotate pole 2 to the desired angle
	pole2.transform = startPole2Matrix
	hinge2.transform = startHinge2Matrix
	hinge2.rotate_object_local(Vector3(0,0,1), startPole2Angle)
	lastCartPosition = 0
	# Disable physics
	PhysicsServer.set_active(false)
	
	# Set GUI outputs to 0
	pole1AngleOut.text = rad2deg_output(startPole1Angle)
	pole2AngleOut.text = rad2deg_output(startPole2Angle)
	pole1AngularVelocityOut.text = "0.00"
	pole2AngularVelocityOut.text = "0.00"
	cartPositionOut.text = "0.00"
	cartVelocityOut.text = "0.00"
	


func _process(delta):
	if gameState == GameState.MENU:
		return
	# Update the GUI. Limit to 2 decimal places
	pole1AngleOut.text = rad2deg_output(pole1Angle)
	pole2AngleOut.text = rad2deg_output(pole2Angle)
	pole1AngularVelocityOut.text = str(rad2deg(pole1AngularVelocity)).pad_decimals(2)
	pole2AngularVelocityOut.text = str(rad2deg(pole2AngularVelocity)).pad_decimals(2)
	cartPositionOut.text = str(cartPosition).pad_decimals(2)
	cartVelocityOut.text = str(cartVelocity).pad_decimals(2)


func _physics_process(delta):
	# Move the cart based on input
	if Input.get_action_strength("ui_right"):
		$Cart.apply_impulse(global_transform.origin, Vector3(0,0,cartImpulse))
	elif Input.get_action_strength("ui_left"):
		$Cart.apply_impulse(global_transform.origin, Vector3(0,0,-cartImpulse))

	# Update the pole angles
	pole1Angle = pole1.global_transform.basis.get_euler().x
	pole2Angle = pole2.global_transform.basis.get_euler().x
	
	# Update the pole angular velocities
	pole1AngularVelocity = pole1.angular_velocity.x
	pole2AngularVelocity = pole2.angular_velocity.x

	# Update the cart position and velocity
	cartPosition = cart.global_transform.origin.z
	cartVelocity = cart.linear_velocity.z


#func get_observation() -> Array :
#	var currentCartPosition = cartPosition
#	var cartVelocity = currentCartPosition - lastCartPosition
#	var currentPole1Angle = pole1Angle
#	var currentPole2Angle = pole2Angle
#	var pole1Velocity = currentPole1Angle - lastPole1Angle
#	var pole2Velocity = currentPole2Angle - lastPole2Angle
#	lastCartPosition = cartPosition
#	lastPole1Angle = pole1Angle
#	lastPole2Angle = pole2Angle
#	return [currentCartPosition, cartVelocity, currentPole1Angle, pole1Velocity, currentPole2Angle, pole2Velocity]


#func reset() -> void :
#	isDone = false
#	$Cart.linear_velocity = Vector3(0,0,0)
#	$Cart.transform.origin = Vector3(0,0,0)
#	$HingeJoint1/Pendulum1.linear_velocity = Vector3(0,0,0)
#	$HingeJoint1/Pendulum1.transform.origin = Vector3(0,6,0)
#	$HingeJoint1/Pendulum1.rotation = Vector3(0,0,0)
#	$HingeJoint1/Pendulum1.angular_velocity = Vector3(0,0,0)
#	$HingeJoint2/Pendulum2.linear_velocity = Vector3(0,0,0)
#	$HingeJoint2/Pendulum2.transform.origin = Vector3(0,6,0)
#	$HingeJoint2/Pendulum2.rotation = Vector3(0,0,0)
#	$HingeJoint2/Pendulum2.angular_velocity = Vector3(0,0,0)
#	lastCartPosition = 0
#	lastPole1Angle = Pole1AngleInput.value
#	lastPole2Angle = Pole2AngleInput.value
#	_physics_process(0)
#

#func _physics_process(_delta: float) -> void:
#	# Uncomment this code & disable GymGodot node to control with mouse buttons
#	#if Input.is_mouse_button_pressed(1):
#	#	apply_action([0])
#	#if Input.is_mouse_button_pressed(2):
#	#	apply_action([1])
#	# If cartpole z-position > 40 or < 40 then episode ends
#	cartPosition = $Cart.global_transform.origin.z
#	if abs(cartPosition) > 28 :
#		isDone = true
#	# If pendulum angle is > pi/5 or < pi/5 then episode ends
#	var pendulum1_vec = $HingeJoint1/Pendulum1/TopCylinder.global_transform.origin - \
#						$HingeJoint1/Pendulum1/BottomCylinder.global_transform.origin
#	var pendulum2_vec = $HingeJoint2/Pendulum2/TopCylinder.global_transform.origin - \
#						$HingeJoint2/Pendulum2/BottomCylinder.global_transform.origin
#	pole1Angle = Vector3(0,1,0).angle_to(pendulum1_vec)
#	pole2Angle = Vector3(0,1,0).angle_to(pendulum2_vec)
#	pole1Angle = pole1Angle * sign($HingeJoint1/Pendulum1/TopCylinder.global_transform.origin.z - \
#															$Cart.global_transform.origin.z)
#	pole2Angle = pole2Angle * sign($HingeJoint2/Pendulum2/TopCylinder.global_transform.origin.z - \
#															$Cart.global_transform.origin.z)
#	if abs(pole1Angle) > PI/5 or abs(pole2Angle) > PI/5:
#		isDone = true
