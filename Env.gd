extends Spatial

var isDone : bool = false
var cartPosition : float = 0.0
var lastCartPosition : float = 0.0
var pole1Angle : float = 0.0
var pole2Angle : float = 0.0
var lastPole1Angle : float = 0.0
var lastPole2Angle : float = 0.0

onready var Pole1AngleInput = $"GUI/Inputs/Pole 1 Angle/Value"
func set_pole_1_angle(val: float) -> void :
	pole1Angle = val
onready var Pole2AngleInput = $"GUI/Inputs/Pole 2 Angle/Value"
func set_pole_2_angle(val: float) -> void:
	pole2Angle = val


func _ready() -> void:
	Pole1AngleInput.connect("value_changed", self, "set_pole_1_angle")
	Pole2AngleInput.connect("value_changed", self, "set_pole_2_angle")
	reset()

func apply_action(action : Array) -> void :
	if action[0] == 0 :
		$Cart.apply_impulse($Cart.global_transform.origin, Vector3(0,0,-2))
	else :
		$Cart.apply_impulse($Cart.global_transform.origin, Vector3(0,0,2))

func get_observation() -> Array :
	var currentCartPosition = cartPosition
	var cartVelocity = currentCartPosition - lastCartPosition
	var currentPole1Angle = pole1Angle
	var currentPole2Angle = pole2Angle
	var pole1Velocity = currentPole1Angle - lastPole1Angle
	var pole2Velocity = currentPole2Angle - lastPole2Angle
	lastCartPosition = cartPosition
	lastPole1Angle = pole1Angle
	lastPole2Angle = pole2Angle
	return [currentCartPosition, cartVelocity, currentPole1Angle, pole1Velocity, currentPole2Angle, pole2Velocity]

func get_reward() -> float :
	return 1.0

func reset() -> void :
	isDone = false
	$Cart.linear_velocity = Vector3(0,0,0)
	$Cart.transform.origin = Vector3(0,0,0)
	$HingeJoint1/Pendulum1.linear_velocity = Vector3(0,0,0)
	$HingeJoint1/Pendulum1.transform.origin = Vector3(0,6,0)
	$HingeJoint1/Pendulum1.rotation = Vector3(0,0,0)
	$HingeJoint1/Pendulum1.angular_velocity = Vector3(0,0,0)
	$HingeJoint2/Pendulum2.linear_velocity = Vector3(0,0,0)
	$HingeJoint2/Pendulum2.transform.origin = Vector3(0,6,0)
	$HingeJoint2/Pendulum2.rotation = Vector3(0,0,0)
	$HingeJoint2/Pendulum2.angular_velocity = Vector3(0,0,0)
	lastCartPosition = 0
	lastPole1Angle = Pole1AngleInput.value
	lastPole2Angle = Pole2AngleInput.value
	_physics_process(0)
	
func is_done() -> bool :
	return isDone

func _physics_process(_delta: float) -> void:
	# Uncomment this code & disable GymGodot node to control with mouse buttons
	#if Input.is_mouse_button_pressed(1):
	#	apply_action([0])
	#if Input.is_mouse_button_pressed(2):
	#	apply_action([1])
	# If cartpole z-position > 40 or < 40 then episode ends
	cartPosition = $Cart.global_transform.origin.z
	if abs(cartPosition) > 28 :
		isDone = true
	# If pendulum angle is > pi/5 or < pi/5 then episode ends
	var pendulum1_vec = $HingeJoint1/Pendulum1/TopCylinder.global_transform.origin - \
						$HingeJoint1/Pendulum1/BottomCylinder.global_transform.origin
	var pendulum2_vec = $HingeJoint2/Pendulum2/TopCylinder.global_transform.origin - \
						$HingeJoint2/Pendulum2/BottomCylinder.global_transform.origin
	pole1Angle = Vector3(0,1,0).angle_to(pendulum1_vec)
	pole2Angle = Vector3(0,1,0).angle_to(pendulum2_vec)
	pole1Angle = pole1Angle * sign($HingeJoint1/Pendulum1/TopCylinder.global_transform.origin.z - \
															$Cart.global_transform.origin.z)
	pole2Angle = pole2Angle * sign($HingeJoint2/Pendulum2/TopCylinder.global_transform.origin.z - \
															$Cart.global_transform.origin.z)
	if abs(pole1Angle) > PI/5 or abs(pole2Angle) > PI/5:
		isDone = true
