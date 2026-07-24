extends CharacterBody2D

@onready var posicio_objecte: Marker2D = $PosicioObjecte

## Velocitat de moviment horitzontal
@export var rapidesa_x: float
## Velocitat de moviment d'escalada vertical
@export var rapidesa_y: float
## Velocitat de salt
@export var velocitat_salt: float
## Controls dels personatge
@export var controls: ControlsJugador = null

# Conjunt d'objectes agafables (fem servir un Diccionari com a forma "bruta" de substituir un Set, per evitar repeticions accidentals)
var objectes_agafables: Dictionary[Item, Variant] = {}
var objecte_en_ma: Item = null

# Si el personatge no té cap objecte a la mà i, a més, hi ha objectes al conjunt `objectes_agafables`, llavors tria el més proper, insereix-lo a `objecte_agafat` i mou-lo al marcador d'objectes en mà
# Retorna `true` si hem pres un objecte a la mà, `false` altrament
func agafar_objecte() -> bool:
	if objecte_en_ma == null and not objectes_agafables.is_empty():
		var proper: Item = null
		var min_dist: float = 10000000
		var own_position = get_global_position()
		for item in objectes_agafables.keys():
			var dist = own_position.distance_squared_to(item.get_global_position())
			if dist < min_dist:
				proper = item
		objecte_en_ma = proper as Item
		objecte_en_ma.reparent(posicio_objecte)
		objecte_en_ma.position = posicio_objecte.position
		objecte_en_ma.agafat = true	# Això inclou una crida a Item.set_agafat(), que desactiva la física de l'objecte
	return false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(controls.mou_avall) and is_on_floor():
		agafar_objecte()

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

# Si un ítem entra a l'àrea on podem agafar objectes, introduïm-lo a la col·lecció d'objectes agafables
func _on_area_afagar_objectes_body_entered(body: Node2D) -> void:
	if body is Item and not body.agafat:
		# Inserta body al diccionari
		objectes_agafables[body as Item] = null

# Si un ítem surt de l'àrea d'objectes agafables, treiem-lo de la col·lecció de candidats
func _on_area_afagar_objectes_body_exited(body: Node2D) -> void:
	if body is Item and body in objectes_agafables:
		objectes_agafables.erase(body)
		print(objectes_agafables)
