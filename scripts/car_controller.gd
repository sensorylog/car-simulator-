extends VehicleBody

const MAX_STEER_LOW_SPEED = 0.48
const MAX_STEER_HIGH_SPEED = 0.16
const MAX_ENGINE_FORCE = 1250.0
const MAX_BRAKE_FORCE = 52.0

var front_left = null
var front_right = null
var rear_left = null
var rear_right = null
var chase_camera = null
var cockpit_camera = null
var driving_enabled = false
var camera_mode = 0
var current_gear = 1
var engine_rpm = 850.0
var throttle_value = 0.0
var brake_value = 0.0
var steering_value = 0.0
var handbrake_value = 0.0

func _ready():
	mass = 1280.0
	linear_damp = 0.04
	angular_damp = 0.65
	sleeping = false
	_add_chassis()
	_add_interior()
	front_left = _add_wheel("FrontLeft", Vector3(-0.91, -0.15, -1.28), true, false)
	front_right = _add_wheel("FrontRight", Vector3(0.91, -0.15, -1.28), true, false)
	rear_left = _add_wheel("RearLeft", Vector3(-0.91, -0.15, 1.28), false, true)
	rear_right = _add_wheel("RearRight", Vector3(0.91, -0.15, 1.28), false, true)
	_add_cameras()

func _add_chassis():
	var collision = CollisionShape.new()
	var box = BoxShape.new()
	box.extents = Vector3(0.88, 0.28, 1.92)
	collision.shape = box
	collision.translation = Vector3(0, 0.30, 0)
	add_child(collision)

	_add_box(self, "LowerBody", Vector3(1.82, 0.48, 3.85), Vector3(0, 0.29, 0), Color(0.10, 0.28, 0.52), 0.45, 0.55)
	_add_box(self, "Bonnet", Vector3(1.76, 0.22, 1.05), Vector3(0, 0.52, -1.30), Color(0.12, 0.34, 0.62), 0.45, 0.55)
	_add_box(self, "Boot", Vector3(1.72, 0.20, 0.72), Vector3(0, 0.51, 1.48), Color(0.10, 0.28, 0.52), 0.45, 0.55)
	_add_box(self, "Roof", Vector3(1.48, 0.13, 1.62), Vector3(0, 1.00, 0.23), Color(0.08, 0.20, 0.34), 0.35, 0.35)
	_add_box(self, "FrontLeftPillar", Vector3(0.10, 0.68, 0.12), Vector3(-0.68, 0.72, -0.54), Color(0.08, 0.16, 0.23), 0.25, 0.2)
	_add_box(self, "FrontRightPillar", Vector3(0.10, 0.68, 0.12), Vector3(0.68, 0.72, -0.54), Color(0.08, 0.16, 0.23), 0.25, 0.2)
	_add_box(self, "RearLeftPillar", Vector3(0.10, 0.66, 0.12), Vector3(-0.68, 0.70, 0.95), Color(0.08, 0.16, 0.23), 0.25, 0.2)
	_add_box(self, "RearRightPillar", Vector3(0.10, 0.66, 0.12), Vector3(0.68, 0.70, 0.95), Color(0.08, 0.16, 0.23), 0.25, 0.2)
	_add_box(self, "FrontBumper", Vector3(1.88, 0.18, 0.18), Vector3(0, 0.18, -1.98), Color(0.06, 0.07, 0.08), 0.15, 0.1)
	_add_box(self, "RearBumper", Vector3(1.88, 0.18, 0.18), Vector3(0, 0.18, 1.98), Color(0.06, 0.07, 0.08), 0.15, 0.1)
	_add_box(self, "HeadlightLeft", Vector3(0.38, 0.12, 0.06), Vector3(-0.57, 0.48, -1.91), Color(0.88, 0.92, 1.0), 0.05, 0.1)
	_add_box(self, "HeadlightRight", Vector3(0.38, 0.12, 0.06), Vector3(0.57, 0.48, -1.91), Color(0.88, 0.92, 1.0), 0.05, 0.1)
	_add_box(self, "TailLightLeft", Vector3(0.42, 0.13, 0.06), Vector3(-0.57, 0.49, 1.94), Color(0.72, 0.025, 0.02), 0.05, 0.1)
	_add_box(self, "TailLightRight", Vector3(0.42, 0.13, 0.06), Vector3(0.57, 0.49, 1.94), Color(0.72, 0.025, 0.02), 0.05, 0.1)
	_add_box(self, "SideMirrorLeft", Vector3(0.20, 0.12, 0.25), Vector3(-0.98, 0.78, -0.55), Color(0.035, 0.045, 0.055), 0.15, 0.1)
	_add_box(self, "SideMirrorRight", Vector3(0.20, 0.12, 0.25), Vector3(0.98, 0.78, -0.55), Color(0.035, 0.045, 0.055), 0.15, 0.1)

func _add_interior():
	var dark = Color(0.035, 0.045, 0.055)
	var trim = Color(0.12, 0.13, 0.14)
	_add_box(self, "Dashboard", Vector3(1.60, 0.30, 0.34), Vector3(0, 0.72, -1.02), dark, 0.05, 0.05)
	_add_box(self, "CenterConsole", Vector3(0.38, 0.38, 0.62), Vector3(0, 0.48, -0.34), trim, 0.05, 0.05)
	_add_box(self, "DriverSeatBase", Vector3(0.68, 0.22, 0.72), Vector3(-0.43, 0.30, 0.52), dark, 0.0, 0.0)
	_add_box(self, "DriverSeatBack", Vector3(0.68, 0.78, 0.20), Vector3(-0.43, 0.73, 0.88), dark, 0.0, 0.0)
	_add_box(self, "PassengerSeatBase", Vector3(0.68, 0.22, 0.72), Vector3(0.43, 0.30, 0.52), dark, 0.0, 0.0)
	_add_box(self, "PassengerSeatBack", Vector3(0.68, 0.78, 0.20), Vector3(0.43, 0.73, 0.88), dark, 0.0, 0.0)
	_add_box(self, "InstrumentPanel", Vector3(0.56, 0.15, 0.08), Vector3(-0.47, 0.83, -0.83), Color(0.02, 0.025, 0.03), 0.0, 0.0)
	_add_box(self, "CenterDisplay", Vector3(0.26, 0.18, 0.035), Vector3(0, 0.78, -0.83), Color(0.025, 0.12, 0.16), 0.1, 0.0)
	var steering = MeshInstance.new()
	steering.name = "SteeringWheel"
	var steering_mesh = CylinderMesh.new()
	steering_mesh.top_radius = 0.24
	steering_mesh.bottom_radius = 0.24
	steering_mesh.height = 0.045
	steering.mesh = steering_mesh
	steering.rotation_degrees.x = 90
	steering.translation = Vector3(-0.48, 0.79, -0.50)
	steering.material_override = _material(Color(0.025, 0.03, 0.035), 0.0, 0.1)
	add_child(steering)

func _add_wheel(wheel_name, wheel_position, steering, traction):
	var wheel = VehicleWheel.new()
	wheel.name = wheel_name
	wheel.translation = wheel_position
	wheel.use_as_steering = steering
	wheel.use_as_traction = traction
	wheel.wheel_radius = 0.36
	wheel.wheel_rest_length = 0.18
	wheel.suspension_travel = 0.22
	wheel.suspension_stiffness = 25.0
	wheel.suspension_max_force = 7000.0
	wheel.damping_compression = 0.35
	wheel.damping_relaxation = 0.55
	wheel.wheel_friction_slip = 2.4
	add_child(wheel)

	var tyre = MeshInstance.new()
	var tyre_mesh = CylinderMesh.new()
	tyre_mesh.top_radius = 0.36
	tyre_mesh.bottom_radius = 0.36
	tyre_mesh.height = 0.23
	tyre_mesh.radial_segments = 12
	tyre.mesh = tyre_mesh
	tyre.rotation_degrees.z = 90
	tyre.material_override = _material(Color(0.025, 0.028, 0.03), 0.0, 0.0)
	wheel.add_child(tyre)

	var hub = MeshInstance.new()
	var hub_mesh = CylinderMesh.new()
	hub_mesh.top_radius = 0.17
	hub_mesh.bottom_radius = 0.17
	hub_mesh.height = 0.245
	hub_mesh.radial_segments = 12
	hub.mesh = hub_mesh
	hub.rotation_degrees.z = 90
	hub.material_override = _material(Color(0.48, 0.50, 0.53), 0.72, 0.35)
	wheel.add_child(hub)
	return wheel

func _add_cameras():
	chase_camera = Camera.new()
	chase_camera.name = "ChaseCamera"
	chase_camera.fov = 72
	chase_camera.translation = Vector3(0, 3.1, 7.2)
	add_child(chase_camera)
	chase_camera.current = true

	cockpit_camera = Camera.new()
	cockpit_camera.name = "CockpitCamera"
	cockpit_camera.fov = 78
	cockpit_camera.translation = Vector3(-0.12, 0.91, 0.20)
	add_child(cockpit_camera)
	cockpit_camera.current = false

func _physics_process(delta):
	var speed_kmh = linear_velocity.length() * 3.6
	var keyboard_steer = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	var keyboard_throttle = Input.get_action_strength("accelerate")
	var keyboard_reverse = Input.get_action_strength("reverse")
	var keyboard_brake = Input.get_action_strength("brake")
	var keyboard_handbrake = Input.get_action_strength("handbrake")

	steering_value = keyboard_steer
	throttle_value = keyboard_throttle
	brake_value = keyboard_brake
	handbrake_value = keyboard_handbrake

	var pads = Input.get_connected_joypads()
	if pads.size() > 0:
		var joy = pads[0]
		var axis_steer = Input.get_joy_axis(joy, JOY_AXIS_0)
		var axis_throttle = _trigger_value(Input.get_joy_axis(joy, JOY_AXIS_5))
		var axis_brake = _trigger_value(Input.get_joy_axis(joy, JOY_AXIS_4))
		if abs(axis_steer) > 0.08:
			steering_value = axis_steer
		if axis_throttle > 0.04:
			throttle_value = axis_throttle
		if axis_brake > 0.04:
			brake_value = axis_brake

	if not driving_enabled:
		throttle_value = 0.0
		brake_value = 1.0
		steering_value = 0.0
		handbrake_value = 1.0

	var reverse_request = keyboard_reverse > 0.1
	if reverse_request and speed_kmh < 4.0 and throttle_value < 0.05:
		throttle_value = keyboard_reverse
		current_gear = -1
	else:
		_select_gear(speed_kmh)
		if reverse_request and speed_kmh >= 4.0:
			brake_value = max(brake_value, keyboard_reverse)

	var steer_limit = lerp(MAX_STEER_LOW_SPEED, MAX_STEER_HIGH_SPEED, clamp(speed_kmh / 120.0, 0.0, 1.0))
	var steering_angle = steering_value * steer_limit
	var gear_ratios = {1: 2.8, 2: 1.9, 3: 1.38, 4: 1.05, 5: 0.82, -1: 2.4}
	var ratio = gear_ratios.get(current_gear, 1.0)
	var engine_output = throttle_value * MAX_ENGINE_FORCE * ratio
	if current_gear == -1:
		engine_output = -engine_output

	front_left.steering = steering_angle
	front_right.steering = steering_angle
	rear_left.steering = 0.0
	rear_right.steering = 0.0
	rear_left.engine_force = engine_output
	rear_right.engine_force = engine_output
	front_left.engine_force = 0.0
	front_right.engine_force = 0.0

	var service_brake = brake_value * MAX_BRAKE_FORCE
	front_left.brake = service_brake
	front_right.brake = service_brake
	rear_left.brake = service_brake + handbrake_value * MAX_BRAKE_FORCE * 0.75
	rear_right.brake = service_brake + handbrake_value * MAX_BRAKE_FORCE * 0.75

	var target_rpm = 850.0 + throttle_value * 5600.0
	engine_rpm = lerp(engine_rpm, target_rpm, clamp(delta * 5.0, 0.0, 1.0))

func _process(delta):
	if chase_camera != null and camera_mode == 0:
		var desired = global_transform.origin + global_transform.basis.xform(Vector3(0, 3.0, 7.2))
		chase_camera.global_transform.origin = chase_camera.global_transform.origin.linear_interpolate(desired, clamp(delta * 5.0, 0.0, 1.0))
		chase_camera.look_at(global_transform.origin + Vector3(0, 0.85, 0), Vector3.UP)

func _trigger_value(value):
	if value < -0.1:
		return clamp((value + 1.0) * 0.5, 0.0, 1.0)
	return clamp(value, 0.0, 1.0)

func _select_gear(speed_kmh):
	if speed_kmh < 24.0:
		current_gear = 1
	elif speed_kmh < 48.0:
		current_gear = 2
	elif speed_kmh < 76.0:
		current_gear = 3
	elif speed_kmh < 112.0:
		current_gear = 4
	else:
		current_gear = 5

func set_driving_enabled(enabled):
	driving_enabled = enabled
	if not enabled and rear_left != null:
		rear_left.engine_force = 0.0
		rear_right.engine_force = 0.0

func toggle_camera():
	camera_mode = 1 - camera_mode
	chase_camera.current = camera_mode == 0
	cockpit_camera.current = camera_mode == 1

func reset_vehicle(spawn_transform):
	global_transform = spawn_transform
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	sleeping = false

func get_speed_kmh():
	return linear_velocity.length() * 3.6

func _add_box(parent, box_name, size, position, color, metallic, roughness):
	var instance = MeshInstance.new()
	instance.name = box_name
	var mesh = BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.translation = position
	instance.material_override = _material(color, metallic, roughness)
	parent.add_child(instance)
	return instance

func _material(color, metallic, roughness):
	var material = SpatialMaterial.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	return material
