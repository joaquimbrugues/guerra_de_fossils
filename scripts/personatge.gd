extends CharacterBody2D

## Velocitat de moviment horitzontal
@export var rapidesa_x: float
## Velocitat de moviment d'escalada vertical
@export var rapidesa_y: float
## Velocitat de salt
@export var velocitat_salt: float
## Controls dels personatge
@export var controls: ControlsJugador = null

func _physics_process(delta: float) -> void:
	# Input horitzontal, o frena
	var direccio_x: float = Input.get_axis(controls.mou_esquerra, controls.mou_dreta)
	if direccio_x:
		velocity.x = direccio_x * rapidesa_x
	else:
		velocity.x = move_toward(velocity.x, 0, rapidesa_x)

	var escalant: bool = false

	if is_on_wall():
		var normal: Vector2 = get_wall_normal()
		if direccio_x == - normal.x:
			# Estem "prement contra la paret". Escalem
			escalant = true
			var direccio_y: float = Input.get_axis(controls.mou_amunt, controls.mou_avall)
			if direccio_y:
				velocity.y = direccio_y * rapidesa_y
			else:
				velocity.y = move_toward(velocity.y, 0, rapidesa_y)
		if direccio_x == normal.x:
			# Estem empenyent contra la paret: saltem!
			escalant = true
			velocity.y = velocitat_salt

	if not escalant:
		# Afegeix la gravetat
		if not is_on_floor():
			velocity += get_gravity() * delta
		# Salt
		if Input.is_action_just_pressed(controls.mou_amunt) and is_on_floor():
			velocity.y = velocitat_salt

	move_and_slide()
