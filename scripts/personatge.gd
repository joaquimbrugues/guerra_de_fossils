extends CharacterBody2D

enum ORIENTACIO { ESQUERRA, DRETA, }

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var posicio_objecte_esquerra: Marker2D = $PosicioObjecteEsquerra
@onready var posicio_objecte_dreta: Marker2D = $PosicioObjecteDreta
@onready var posicio_objecte_dalt: Marker2D = $PosicioObjecteDalt


## Velocitat de moviment horitzontal
@export var rapidesa_x: float
## Velocitat de moviment d'escalada vertical
@export var rapidesa_y: float
## Velocitat de salt
@export var velocitat_salt: float
## Controls dels personatge (s'assignen a l'escena on col·loquem els personatges)
@export var controls: ControlsJugador = null
## Força mínima de llançament d'objectes, sense mantenir premut el botó
@export var força_minima: float
## Força màxima de llançament d'objectes per part del jugador
@export var força_maxima: float
## Temps (en segons) fins que el personatge adquireix la força màxima
@export var temps_força_maxima: float
## Temps (en segons) màxim sense tenir un explosiu a les mans
@export var temps_maxim_sense_explosiu: float

## Aquesta senyal indica que el Personatge ha deixat anar un objecte.
## És responsabilitat de qui inclogui aquest node donar un nou pare al node `objecte`
signal objecte_alliberat(objecte: Item)

## Senyal d'explosió de la bomba
signal explosio_bomba(bomba: Explosiu)

# Conjunt d'objectes agafables (fem servir un Diccionari com a forma "bruta" de substituir un Set, per evitar repeticions accidentals)
var objectes_agafables: Dictionary[Item, Variant] = {}
# Posicio de l'objecte a la mà (o on apareixerà)
var posicio_objecte_ma: Vector2:
	set(nova_posicio):
		if objecte_en_ma != null:
			objecte_en_ma.position = nova_posicio
		posicio_objecte_ma = nova_posicio
# Objecte actualment a la mà
var objecte_en_ma: Item = null:
	set(nou_objecte):
		objecte_en_ma = nou_objecte
		# Adapta l'animació al nou objecte/falta d'objecte
		actualitza_animacio(estat)
		if objecte_en_ma != null:
			var pare = objecte_en_ma.get_parent()
			if pare != null:
				pare.call_deferred("remove_child", objecte_en_ma)
			call_deferred("add_child", objecte_en_ma)
			objecte_en_ma.position = posicio_objecte_ma
			objecte_en_ma.agafat = true	# Això inclou una crida a Item.set_agafat(), que congela la física i col·lisions de l'objecte
			if objecte_en_ma is Explosiu:
				# Donem propietari a l'explosiu
				objecte_en_ma.darrer_propietari = controls.index_jugador
				# Resetegem el comptador sense explosiu en mà
				temps_sense_explosius = 0.0

# Indica si el personatge es troba escalant o no ara mateix
var escalant: bool = false:
	set(nou_escalant):
		escalant = nou_escalant
		if escalant:
			posicio_objecte_ma = posicio_objecte_dalt.position
		else:
			match orientacio:
				ORIENTACIO.DRETA:
					posicio_objecte_ma = posicio_objecte_dreta.position
				ORIENTACIO.ESQUERRA:
					posicio_objecte_ma = posicio_objecte_esquerra.position

# Orientació actual del personatge
var orientacio: ORIENTACIO = ORIENTACIO.DRETA:
	set(nova_orientacio):
		orientacio = nova_orientacio
		# Canviar l'orientació de l'animatedsprite sempre que canviï l'orientació del personatge
		# A més, si hi ha un objecte, moure'l a la nova posició
		match orientacio:
			ORIENTACIO.DRETA:
				animated_sprite_2d.flip_h = false
				if estat != ESTAT_ANIMACIO.ESCALANT:
					posicio_objecte_ma = posicio_objecte_dreta.position
			ORIENTACIO.ESQUERRA:
				animated_sprite_2d.flip_h = true
				if estat != ESTAT_ANIMACIO.ESCALANT:
					posicio_objecte_ma = posicio_objecte_esquerra.position
# Força acumulada pel personatge
var força: float = força_minima
# Temps acumulat sense explosius pel personatge
var temps_sense_explosius: float = 0.0

# Plantilles de les escenes d'explosiu petit, mitjà i gran
var explosiu_petit = preload("uid://btvstk0pkiw34")
var explosiu_mitjà = preload("uid://d3405s7yxiabh")
var explosiu_gran = preload("uid://b3x4ysaenup5i")
var plantilles_explosius := [explosiu_petit, explosiu_mitjà, explosiu_gran]

# Variable per controlar el salt amb retard exigit per l'animació
var salt: bool = false

# Mètode per crear una instància d'un explosiu a l'atzar:
func instanciar_explosiu() -> Explosiu:
	var plantilla = plantilles_explosius.pick_random()
	var bomba: Explosiu = plantilla.instantiate()
	bomba.explosio_bomba.connect(func(b): explosio_bomba.emit(b))
	return bomba

# Agafa un explosiu, sigui acabat d'instanciar o llençat.
# Si ja hi havia un objecte a la mà, el deixem caure
func agafar_explosiu(explosiu: Explosiu, treient: bool) -> void:
	if objecte_en_ma != null:
		força = força_minima
		objecte_en_ma.agafat = false	#Això inclou ina crida a Item.set_agafat(), que descongela la física i les col·lisions de l'objecte
		objecte_alliberat.emit(objecte_en_ma)
	if treient and is_on_floor() and estat == ESTAT_ANIMACIO.QUIET:
		animated_sprite_2d.play("treure_objecte")
		animacio_bloquejada = true
		treient_explosiu = true
		await animated_sprite_2d.animation_changed
	treient_explosiu = false
	objecte_en_ma = explosiu	# Inclou la crida a la funció set de més amunt

# Si el personatge no té cap objecte a la mà i, a més, hi ha objectes al conjunt `objectes_agafables`, llavors tria el més proper, insereix-lo a `objecte_agafat` i mou-lo al marcador d'objectes en mà
# Retorna `true` si hem pres un objecte a la mà, `false` altrament
func agafar_objecte() -> void:
	if objecte_en_ma == null and not objectes_agafables.is_empty():
		var proper: Item = null
		var min_dist: float = 10000000
		var own_position = get_global_position()
		for item in objectes_agafables.keys():
			var dist = own_position.distance_squared_to(item.get_global_position())
			if dist < min_dist:
				proper = item
		objecte_en_ma = proper as Item	# Això inclou la crida a la funció set de més amunt

# Si tenim un objecte a la mà, llencem-lo amb l'impuls acumulat
func llençar_objecte() -> void:
	if objecte_en_ma != null:
		objecte_en_ma.agafat = false	# Això inclou una crida a Item.set_agafat(), que descongela la física i les col·lisions de l'objecte
		var direccio := Vector2.UP
		if orientacio == ORIENTACIO.DRETA:
			direccio = direccio.rotated(deg_to_rad(60))
		else:
			direccio = direccio.rotated(deg_to_rad(-60))
		var força_llançament: Vector2 = direccio * força / objecte_en_ma.mass
		objecte_alliberat.emit(objecte_en_ma)	# Enviem la senyal perquè el pare del node Personatge trobi un nou pare per a l'objecte
		objecte_en_ma.call_deferred("apply_central_impulse", força_llançament)
		objecte_en_ma = null	# Alliberem l'objecte de la mà

# Aquesta flag controla si estem en el procés de treure un explosiu
var treient_explosiu: bool = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed(controls.mou_avall) and is_on_floor():
		# Agafem l'ítem més proper, si existeix, només si estem al terra
		agafar_objecte()
	elif Input.is_action_just_released(controls.llença):
		# Si deixem de prémer el botó d'acumular força, llencem l'objecte a la mà i perdem tota la força
		llençar_objecte()
		força = força_minima
	elif Input.is_action_just_pressed(controls.mou_amunt) and is_on_floor():
		salta()
	elif Input.is_action_pressed(controls.llença) and objecte_en_ma != null:
		# Si tenim un objecte a la mà podem acumular força per llençar-lo
		var inc_força = força_maxima * delta / temps_força_maxima
		força = min(força_maxima, força + inc_força)
	if temps_sense_explosius >= temps_maxim_sense_explosiu and not treient_explosiu:
		#Instancia un explosiu i agafa'l
		var nou_explosiu: Explosiu = instanciar_explosiu()
		agafar_explosiu(nou_explosiu, true)	# El `temps_sense_explosius` es reseteja quan et cau un explosiu a les mans
	elif objecte_en_ma == null or objecte_en_ma is not Explosiu:
		# Si no tenim un explosiu a la mà, augmenta el comptador
		temps_sense_explosius += delta

func _physics_process(delta: float) -> void:
	# Input horitzontal, o frena
	var direccio_x: float = Input.get_axis(controls.mou_esquerra, controls.mou_dreta)
	if direccio_x:
		velocity.x = direccio_x * rapidesa_x
		orientacio = ORIENTACIO.DRETA if direccio_x > 0.0 else ORIENTACIO.ESQUERRA

	else:
		velocity.x = move_toward(velocity.x, 0, rapidesa_x)

	if is_on_wall():
		var normal: Vector2 = get_wall_normal()
		if direccio_x == - normal.x:
			# Estem "prement contra la paret". Escalem
			escalant = true
			var direccio_y: float = Input.get_axis(controls.mou_amunt, controls.mou_avall)
			if direccio_y:
				velocity.y = direccio_y * rapidesa_y
				animated_sprite_2d.play()
			else:
				velocity.y = move_toward(velocity.y, 0, rapidesa_y)
				animated_sprite_2d.pause()
		elif direccio_x == normal.x:
			# Estem empenyent contra la paret: saltem!
			escalant = true
			velocity.y = velocitat_salt
		else:
			escalant = false
	else:
		escalant = false

	if escalant:
		# Adaptem l'animació
		estat = ESTAT_ANIMACIO.ESCALANT
	else:
		if is_on_floor():
			# Salt
			if salt:
				velocity.y = velocitat_salt
				salt = false
			else:
				estat = ESTAT_ANIMACIO.QUIET if direccio_x == 0.0 else ESTAT_ANIMACIO.CORRENTS
		else:
			# Caient
			estat = ESTAT_ANIMACIO.CAIENT
			# Afegeix la gravetat
			velocity += get_gravity() * delta

	move_and_slide()


### COSES RELACIONADES AMB LES ANIMACIONS
var animacio_bloquejada: bool = false
enum ESTAT_ANIMACIO { QUIET, CORRENTS, ESCALANT, CAIENT, }
var estat: ESTAT_ANIMACIO:
	set(nou_estat):
		if nou_estat != estat and not animacio_bloquejada:
			actualitza_animacio(nou_estat)
		estat = nou_estat

func actualitza_animacio(e: ESTAT_ANIMACIO) -> void:
	var te_objecte = objecte_en_ma != null
	match e:
		ESTAT_ANIMACIO.QUIET:
			if te_objecte:
				animated_sprite_2d.play("quiet_objecte")
			else:
				animated_sprite_2d.play("quiet")
		ESTAT_ANIMACIO.CORRENTS:
			if te_objecte:
				animated_sprite_2d.play("corrents_objecte")
			else:
				animated_sprite_2d.play("corrents")
		ESTAT_ANIMACIO.ESCALANT:
			if te_objecte:
				animated_sprite_2d.play("escalar_objecte")
			else:
				animated_sprite_2d.play("escalar")
		ESTAT_ANIMACIO.CAIENT:
			if te_objecte:
				animated_sprite_2d.play("caient_objecte")
			else:
				animated_sprite_2d.play("caient")

const cope = preload("uid://c6vhq2412811k") #"res://recursos/cope_sprite_frames.tres"
const wope = preload("uid://3c58negltxbs") #"res://recursos/wope_sprite_frames.tres"

func _ready() -> void:
	# Fem el setup del personatge: segons qui dels dos sigui, li donem els SpriteFrames corresponents
	match controls.index_jugador:
		0:	#Cope
			animated_sprite_2d.sprite_frames = cope
		1:	#Wope
			animated_sprite_2d.sprite_frames = wope
	pass

# Ens ajuda a enllaçar algunes animacions
func _on_animated_sprite_2d_animation_finished() -> void:
	animacio_bloquejada = false
	treient_explosiu = false
	actualitza_animacio(estat)

# Per arreglar algunes transicions estranyes entre animacions
func _on_animated_sprite_2d_animation_changed() -> void:
	animacio_bloquejada = false

func salta() -> void:
	if objecte_en_ma != null:
		animated_sprite_2d.play("saltar_objecte")
	else:
		animated_sprite_2d.play("saltar")
	animacio_bloquejada = true
	# Hem de crear un retard artifical per encaixar el salt amb l'animació
	get_tree().create_timer(0.15, false, true).timeout.connect(func(): salt = true)

### SENYALS
# Si un ítem entra a l'àrea on podem agafar objectes, introduïm-lo a la col·lecció d'objectes agafables
func _on_area_afagar_objectes_body_entered(body: Node2D) -> void:
	if body is Explosiu and not body.agafat and body.darrer_propietari != controls.index_jugador:
		agafar_explosiu(body as Explosiu, false)
	elif body is Item and not body.agafat:
		# Inserta body al diccionari
		objectes_agafables[body as Item] = null

# Si un ítem surt de l'àrea d'objectes agafables, treiem-lo de la col·lecció de candidats
func _on_area_afagar_objectes_body_exited(body: Node2D) -> void:
	if body is Item and body in objectes_agafables:
		objectes_agafables.erase(body)
