extends CharacterBody2D


@export var rapidesa_x: float
@export var rapidesa_y: float
@export var velocitat_salt: float

var escalant: bool = false


func _physics_process(delta: float) -> void:
	
	if is_on_floor():
		# Si arribem a terra, considera que deixem d'escalar
		escalant = false
	elif escalant:
		#TODO
		# Escalem amunt o avall
		var direccio_y: float = Input.get_axis("p1_amunt", "p1_avall")
		if direccio_y:
			velocity.y = direccio_y * rapidesa_y
		else:
			velocity.y = move_toward(velocity.y, 0, rapidesa_y)
	else:
		# Afegeix la gravetat
		velocity += get_gravity() * delta

	# Salt
	if Input.is_action_just_pressed("p1_amunt") and is_on_floor():
		velocity.y = velocitat_salt

	# Input horitzontal, o frena
	var direction := Input.get_axis("p1_esquerra", "p1_dreta")
	if direction:
		velocity.x = direction * rapidesa_x
	else:
		velocity.x = move_toward(velocity.x, 0, rapidesa_x)

	if move_and_slide() and direction and not is_on_floor():
		print("Paret!")
		escalant = true
