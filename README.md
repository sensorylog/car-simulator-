# Project Velocity

A lightweight PC driving-simulator project built with **Godot 3.6.3** and the GLES2 compatibility renderer.

## First playable build

This first repository build establishes a runnable driving prototype:

- Procedurally generated vehicle and test-road scene (no external asset downloads required).
- Rear-wheel-drive vehicle using Godot VehicleBody / VehicleWheel physics.
- Automatic 5-speed forward gearing and reverse.
- Front steering, service braking and rear handbrake.
- Cockpit and chase-camera perspectives.
- Basic cockpit/dashboard geometry.
- Keyboard controls and standard gamepad axis input.
- Speed, gear and RPM HUD.
- Main menu, controls dialog, pause and reset.
- Lightweight procedural environment intended for older hardware.

This is the **first playable foundation**, not yet the finished open-world game. The current vehicle is a procedural placeholder model; production-quality licensed car models, detailed interiors, traffic, pedestrians, weather, customization assets, sound design and a streaming open world are future milestones.

## Engine

Use the official **Godot 3.6.3 Standard** Windows build. The project uses GDScript and does not require the .NET build.

Official downloads:
- https://godotengine.org/download/archive/3.6.3-stable/
- Choose Windows x86_32 if the 64-bit editor has trouble on the laptop; Windows x86_64 is also available for 64-bit Windows.

The project targets the GLES2 renderer and OpenGL 2.1-class hardware. Actual compatibility still depends on the Radeon driver exposing the required OpenGL features.

## Run on Windows 10

1. Download and extract Godot 3.6.3 Standard for Windows.
2. Open the Godot executable.
3. Choose Import and select this repository's project.godot.
4. Let Godot scan the project, then press F6 to run the main scene or F5 to run the project.
5. Start the drive from the main menu.

## Controls

| Action | Keyboard | Gamepad |
|---|---|---|
| Accelerate | W | Right trigger (standard axis 5) |
| Reverse | S | Keyboard in this first build |
| Steering | A / D | Left stick X (axis 0) |
| Brake | Space | Left trigger (standard axis 4) |
| Handbrake | Shift | Not mapped yet |
| Change camera | C | Y / Triangle (button index 3) |
| Reset car | R | Not mapped yet |
| Pause | Escape | Start / Options (button index 6) |

Generic gamepads vary in how they expose triggers and button numbering. This build reads common SDL-style axis/button mappings; a controller remapping screen is planned.

## Performance notes

The world uses simple meshes, disabled real-time shadows and modest draw-call counts. Start at 1024x640. If performance is poor, lower the window resolution and close background applications.

## Known first-build limitations

- The car model and environment are procedural placeholders.
- VehicleBody physics are a starting point and require real driving tests and tuning.
- The first test area is a long straight road, not a complete open world.
- Gamepad trigger conventions differ between controller models.
- No packaged Windows executable is committed yet; export it from Godot after installing the matching export templates.
