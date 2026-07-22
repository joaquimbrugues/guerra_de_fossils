extends CharacterBody2D

## Velocitat de moviment horitzontal
@export var rapidesa_x: float
## Velocitat de moviment d'escalada vertical
@export var rapidesa_y: float
## Velocitat de salt
@export var velocitat_salt: float
## Identificador del personatge (pot ser només 0 - esquerra o 1 - dreta)
@export_range(0,1) var id_personatge: int

# Identifica moviment horitzontal amb la ID del personatge corresponent
func input_horitzontal() -> float:
	if id_personatge == 0:
		return Input.get_axis("p1_esquerra", "p1_dreta")
	else:
		return Input.get_axis("p2_esquerra", "p2_dreta")

# Identifica moviment vertical amb la ID del personatge corresponent
func input_vertical() -> float:
	if id_personatge == 0:
		return Input.get_axis("p1_amunt", "p1_avall")
	else:
		return Input.get_axis("p2_amunt", "p2_avall")

# Identifica si estem prement amunt amb la ID de personatge corresponent
func amunt_premut() -> bool:
	return (id_personatge == 0 and Input.is_action_just_pressed("p1_amunt")) or (id_personatge == 1 and Input.is_action_just_pressed("p2_amunt"))

func _physics_process(delta: float) -> void:
	# Input horitzontal, o frena
	var direccio_x: float = input_horitzontal()
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
			var direccio_y: float = input_vertical()
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
		if amunt_premut() and is_on_floor():
			velocity.y = velocitat_salt

	move_and_slide()
