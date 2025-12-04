extends CharacterBody3D

@export_range(1.0, 30.0) var speed : float = 5.0
@export_range(2.0, 10.0) var jump_velocity : float = 6.0
@export_range(1.0, 5.0) var mouse_sensitivity : float = 3.0
@export_range(5.0, 25.0) var gravity : float = 15.0
@export_range(1.0, 10.0) var ground_acceleration : float = 4.0
@export_range(0.0, 5.0) var air_acceleration : float = 0.5

@onready var camera_pivot: Node3D = $camera_pivot

# --- NUEVO: Referencia al componente de minado ---
# Ajusta la ruta si tu RayCast tiene otro nombre
@onready var ray_cast_3d: RayCast3D = $camera_pivot/Camera3D/RayCast3D


var mouse_motion : Vector2 = Vector2.ZERO
var pitch : float = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouse_motion = event.relative

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# --- NUEVO: Input para romper terreno ---
	# Asumiendo que configuraste "fire" en el Mapa de Entradas (Project Settings)
	# Usamos 'pressed' para que rompa continuo mientras mantienes clic
	if Input.is_action_pressed("fire"):
			if ray_cast_3d: 
				# Asegúrate de que el script del RayCast tenga la función 'try_dig'
				if ray_cast_3d.has_method("try_dig"):
					ray_cast_3d.try_dig()

	# Movimiento
	var input_dir = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	)

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var accel = ground_acceleration if is_on_floor() else air_acceleration

	if direction != Vector3.ZERO:
		velocity.x = move_toward(velocity.x, direction.x * speed, accel)
		velocity.z = move_toward(velocity.z, direction.z * speed, accel)
	else:
		velocity.x = move_toward(velocity.x, 0, accel)
		velocity.z = move_toward(velocity.z, 0, accel)

	move_and_slide()

	rotate_y(-mouse_motion.x * mouse_sensitivity / 1000.0)
	pitch -= mouse_motion.y * mouse_sensitivity / 1000.0
	pitch = clamp(pitch, -1.35, 1.35)
	#SI tu nombre de de nodo antes de la camara es diferente tambialo aqui
	camera_pivot.rotation.x = pitch

	mouse_motion = Vector2.ZERO
