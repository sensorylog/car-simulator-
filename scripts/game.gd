extends Spatial

var car = null
var ui_layer = null
var menu_overlay = null
var hud = null
var speed_label = null
var gear_label = null
var rpm_label = null
var status_label = null
var help_label = null
var is_paused = false
var menu_visible = true
var spawn_transform = Transform()
var camera_button_was_down = false
var pause_button_was_down = false

func _ready():
	_setup_input()
	_create_environment()
	_create_world()
	_create_vehicle()
	_create_ui()
	_show_menu(true)

func _setup_input():
	_add_key_action("accelerate", KEY_W)
	_add_key_action("reverse", KEY_S)
	_add_key_action("steer_left", KEY_A)
	_add_key_action("steer_right", KEY_D)
	_add_key_action("brake", KEY_SPACE)
	_add_key_action("handbrake", KEY_SHIFT)
	_add_key_action("camera_toggle", KEY_C)
	_add_key_action("reset_vehicle", KEY_R)
	_add_key_action("pause", KEY_ESCAPE)

func _add_key_action(action_name, key_code):
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	var event = InputEventKey.new()
	event.scancode = key_code
	if not InputMap.action_has_event(action_name, event):
		InputMap.action_add_event(action_name, event)

func _create_environment():
	var world_env = WorldEnvironment.new()
	var environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.43, 0.62, 0.79)
	environment.ambient_light_color = Color(0.72, 0.75, 0.80)
	environment.ambient_light_energy = 0.65
	environment.fog_enabled = true
	environment.fog_color = Color(0.60, 0.70, 0.77)
	environment.fog_depth_begin = 90.0
	environment.fog_depth_end = 260.0
	world_env.environment = environment
	add_child(world_env)

	var sun = DirectionalLight.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-52, -28, 0)
	sun.light_color = Color(1.0, 0.94, 0.82)
	sun.light_energy = 0.85
	sun.shadow_enabled = false
	add_child(sun)

func _create_world():
	var ground = MeshInstance.new()
	ground.name = "Terrain"
	var ground_mesh = PlaneMesh.new()
	ground_mesh.size = Vector2(360, 360)
	ground.mesh = ground_mesh
	ground.translation.y = -0.12
	ground.material_override = _make_material(Color(0.20, 0.31, 0.19), 0.0, 1.0)
	add_child(ground)

	var ground_body = StaticBody.new()
	ground_body.name = "GroundCollision"
	var ground_shape = CollisionShape.new()
	ground_shape.shape = PlaneShape.new()
	ground_body.add_child(ground_shape)
	add_child(ground_body)

	var road = MeshInstance.new()
	road.name = "TestRoad"
	var road_mesh = PlaneMesh.new()
	road_mesh.size = Vector2(14, 230)
	road.mesh = road_mesh
	road.translation = Vector3(0, 0.012, -35)
	road.material_override = _make_material(Color(0.075, 0.082, 0.09), 0.0, 0.94)
	add_child(road)

	var shoulder_left = _make_box("LeftShoulder", Vector3(1.2, 0.04, 230), Vector3(-7.55, 0.015, -35), Color(0.34, 0.34, 0.30))
	var shoulder_right = _make_box("RightShoulder", Vector3(1.2, 0.04, 230), Vector3(7.55, 0.015, -35), Color(0.34, 0.34, 0.30))
	add_child(shoulder_left)
	add_child(shoulder_right)

	for z in range(0, 24):
		var line = _make_box("CenterLine_%02d" % z, Vector3(0.16, 0.025, 4.0), Vector3(0, 0.035, -z * 9.0 - 2.0), Color(0.88, 0.86, 0.70))
		add_child(line)

	for side in [-1, 1]:
		var rail = _make_box("SafetyRail_%s" % str(side), Vector3(0.18, 0.55, 220), Vector3(side * 8.5, 0.48, -35), Color(0.42, 0.45, 0.47))
		add_child(rail)
		for post_index in range(0, 22):
			var post = _make_box("RailPost_%s_%02d" % [str(side), post_index], Vector3(0.22, 0.8, 0.22), Vector3(side * 8.5, 0.36, -post_index * 10.0), Color(0.32, 0.34, 0.36))
			add_child(post)

	_create_landmarks()

func _create_landmarks():
	for i in range(0, 18):
		var z = -12.0 - i * 10.5
		for side in [-1, 1]:
			var x = side * (13.0 + float(i % 3) * 2.0)
			if i % 3 == 0:
				_create_tree(Vector3(x, 0, z))
			elif i % 3 == 1:
				var height = 5.0 + float(i % 4)
				var building = _make_box("LowPolyBuilding_%02d_%s" % [i, str(side)], Vector3(5.0, height, 6.0), Vector3(x, height * 0.5, z), Color(0.42 + float(i % 3) * 0.06, 0.43, 0.44))
				add_child(building)
			else:
				_create_tree(Vector3(x, 0, z))

func _create_tree(position):
	var trunk = MeshInstance.new()
	var trunk_mesh = CylinderMesh.new()
	trunk_mesh.top_radius = 0.18
	trunk_mesh.bottom_radius = 0.25
	trunk_mesh.height = 2.0
	trunk.mesh = trunk_mesh
	trunk.translation = position + Vector3(0, 1.0, 0)
	trunk.material_override = _make_material(Color(0.22, 0.13, 0.07), 0.0, 1.0)
	add_child(trunk)

	var crown = MeshInstance.new()
	var crown_mesh = SphereMesh.new()
	crown_mesh.radius = 1.25
	crown_mesh.height = 2.4
	crown.mesh = crown_mesh
	crown.translation = position + Vector3(0, 2.55, 0)
	crown.material_override = _make_material(Color(0.12, 0.28, 0.12), 0.0, 1.0)
	add_child(crown)

func _create_vehicle():
	var vehicle_script = load("res://scripts/car_controller.gd")
	car = vehicle_script.new()
	car.name = "PlayerCar"
	car.translation = Vector3(0, 0.72, 4)
	add_child(car)
	spawn_transform = car.global_transform

func _create_ui():
	ui_layer = CanvasLayer.new()
	ui_layer.layer = 10
	add_child(ui_layer)

	var root = Control.new()
	root.name = "UI"
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	ui_layer.add_child(root)

	hud = Control.new()
	hud.anchor_right = 1.0
	hud.anchor_bottom = 1.0
	root.add_child(hud)

	speed_label = _make_label(hud, "SpeedLabel", "000 km/h", Vector2(24, 20), Vector2(210, 44), 26, Color(1, 1, 1))
	gear_label = _make_label(hud, "GearLabel", "GEAR 1", Vector2(24, 65), Vector2(150, 28), 18, Color(0.85, 0.92, 1))
	rpm_label = _make_label(hud, "RPMLabel", "RPM 0850", Vector2(24, 94), Vector2(180, 26), 15, Color(0.78, 0.84, 0.88))
	status_label = _make_label(hud, "StatusLabel", "CHASE CAMERA", Vector2(24, 126), Vector2(220, 24), 13, Color(0.75, 0.88, 1))
	help_label = _make_label(hud, "HelpLabel", "WASD drive  |  SPACE brake  |  SHIFT handbrake  |  C camera  |  R reset  |  ESC pause", Vector2(20, 0), Vector2(980, 28), 12, Color(0.88, 0.91, 0.94))
	help_label.anchor_top = 1.0
	help_label.anchor_bottom = 1.0
	help_label.margin_top = -36
	help_label.margin_bottom = -8
	_create_menu(root)

func _create_menu(root):
	menu_overlay = ColorRect.new()
	menu_overlay.name = "MenuOverlay"
	menu_overlay.color = Color(0.015, 0.025, 0.04, 0.88)
	menu_overlay.anchor_right = 1.0
	menu_overlay.anchor_bottom = 1.0
	root.add_child(menu_overlay)

	var panel = Panel.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.margin_left = -215
	panel.margin_top = -220
	panel.margin_right = 215
	panel.margin_bottom = 220
	menu_overlay.add_child(panel)

	_make_label(panel, "Title", "PROJECT VELOCITY", Vector2(28, 28), Vector2(370, 52), 30, Color(0.88, 0.94, 1))
	_make_label(panel, "Subtitle", "OPEN ROAD  •  FIRST PLAYABLE BUILD", Vector2(30, 82), Vector2(370, 26), 13, Color(0.50, 0.75, 0.94))
	var drive_button = _make_button(panel, "DriveButton", "START DRIVING", Vector2(45, 145), Vector2(340, 52))
	drive_button.connect("pressed", self, "_on_drive_pressed")
	var controls_button = _make_button(panel, "ControlsButton", "CONTROLS & GAMEPAD", Vector2(45, 210), Vector2(340, 46))
	controls_button.connect("pressed", self, "_on_controls_pressed")
	var quit_button = _make_button(panel, "QuitButton", "QUIT", Vector2(45, 268), Vector2(340, 42))
	quit_button.connect("pressed", self, "_on_quit_pressed")
	_make_label(panel, "BuildNote", "Prototype build • procedural test environment", Vector2(30, 365), Vector2(370, 24), 12, Color(0.60, 0.66, 0.72))
	drive_button.grab_focus()

func _make_label(parent, node_name, text_value, position, size, font_size, color):
	var label = Label.new()
	label.name = node_name
	label.text = text_value
	label.rect_position = position
	label.rect_size = size
	label.add_color_override("font_color", color)
	parent.add_child(label)
	return label

func _make_button(parent, node_name, text_value, position, size):
	var button = Button.new()
	button.name = node_name
	button.text = text_value
	button.rect_position = position
	button.rect_size = size
	button.focus_mode = Control.FOCUS_ALL
	parent.add_child(button)
	return button

func _show_menu(show_menu):
	menu_visible = show_menu
	menu_overlay.visible = show_menu
	hud.visible = not show_menu
	if car != null:
		car.set_driving_enabled(not show_menu)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if show_menu else Input.MOUSE_MODE_CAPTURED)

func _on_drive_pressed():
	is_paused = false
	_show_menu(false)
	get_tree().paused = false

func _on_controls_pressed():
	var dialog = AcceptDialog.new()
	dialog.window_title = "Driving controls"
	dialog.dialog_text = "KEYBOARD\nW accelerate  •  S reverse  •  A/D steer\nSPACE service brake  •  SHIFT handbrake\nC switch cockpit/chase camera  •  R reset  •  ESC pause\n\nGAMEPAD\nLeft stick: steering\nRight trigger: accelerate\nLeft trigger: brake\nY / Triangle (button 3): camera toggle\nStart / Options (button 6): pause\n\nGeneric controllers may report triggers differently; this build reads common SDL-style axes."
	add_child(dialog)
	dialog.popup_centered(Vector2(500, 360))

func _on_quit_pressed():
	get_tree().quit()

func _process(delta):
	if car == null:
		return
	if Input.is_action_just_pressed("camera_toggle"):
		car.toggle_camera()
	if Input.is_action_just_pressed("reset_vehicle"):
		car.reset_vehicle(spawn_transform)
	if Input.is_action_just_pressed("pause") and not menu_visible:
		_show_pause_menu()

	var pads = Input.get_connected_joypads()
	if pads.size() > 0:
		var joy = pads[0]
		var camera_down = Input.is_joy_button_pressed(joy, 3)
		var pause_down = Input.is_joy_button_pressed(joy, 6)
		if camera_down and not camera_button_was_down:
			car.toggle_camera()
		if pause_down and not pause_button_was_down and not menu_visible:
			_show_pause_menu()
		camera_button_was_down = camera_down
		pause_button_was_down = pause_down

	speed_label.text = "%03d km/h" % int(round(car.get_speed_kmh()))
	gear_label.text = "GEAR %s" % ("R" if car.current_gear == -1 else str(car.current_gear))
	rpm_label.text = "RPM %04d" % int(round(car.engine_rpm))
	status_label.text = "COCKPIT CAMERA" if car.camera_mode == 1 else "CHASE CAMERA"

func _show_pause_menu():
	if is_paused:
		return
	is_paused = true
	car.set_driving_enabled(false)
	get_tree().paused = true
	var dialog = AcceptDialog.new()
	dialog.window_title = "Paused"
	dialog.dialog_text = "Simulation paused. Press OK to resume driving."
	dialog.pause_mode = Node.PAUSE_MODE_PROCESS
	dialog.connect("confirmed", self, "_resume_game")
	add_child(dialog)
	dialog.popup_centered()

func _resume_game():
	get_tree().paused = false
	is_paused = false
	car.set_driving_enabled(true)

func _make_box(box_name, size, position, color):
	var mesh_instance = MeshInstance.new()
	mesh_instance.name = box_name
	var box_mesh = BoxMesh.new()
	box_mesh.size = size
	mesh_instance.mesh = box_mesh
	mesh_instance.translation = position
	mesh_instance.material_override = _make_material(color, 0.0, 0.95)
	return mesh_instance

func _make_material(color, metallic, roughness):
	var material = SpatialMaterial.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	return material
