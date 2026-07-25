class_name Explosiu
extends Item

## Propietats de l'explosiu
@export var propietats: PropietatsExplosiu

func _init() -> void:
	z_index = 1

var plantilla_etiqueta_compte_enrere = preload("uid://brbsl25c07q5f")

# Indica quin és el darrer personatge que ha agafat aquest explosiu (0 a l'esquerra, 1 a la dreta)
var darrer_propietari: int = -1
var compte_enrere: int = 3

signal explosio_bomba(explosiu: Explosiu)

func _ready() -> void:
	# Creem un temporitzador amb 3 segons menys del normal
	var durada = randi_range(propietats.rang_durades.x, propietats.rang_durades.y)
	get_tree().create_timer(durada - 3, false).timeout.connect(temporitzador_acabat)

func temporitzador_acabat() -> void:
	if compte_enrere == 0:
		# EXPLOSIÓ!
		var animated_sprite = get_child(0) as AnimatedSprite2D	# Poc robust, però suficient si som consistents
		var collision_shape = get_child(1) as CollisionShape2D	# Poc robust, però si tot va bé ok
		animated_sprite.play("explotant")
		animated_sprite.animation_finished.connect(func ():
			match animated_sprite.animation:
				"explotant":
					explosio_bomba.emit(self)
					collision_shape.disabled = true
					set_deferred("freeze", true)
					match propietats.tipus_explosiu:
						PropietatsExplosiu.TIPUS_EXPLOSIU.Gran:
							animated_sprite.scale = Vector2.ONE
						PropietatsExplosiu.TIPUS_EXPLOSIU.Mitja:
							animated_sprite.scale = 0.75 * Vector2.ONE
					animated_sprite.play("explosio")
				"explosio":
					queue_free()
		)
	else:
		# COMPTE ENRERE
		afegeix_etiqueta_compte_enrere()
		compte_enrere -= 1
		var temps_restant = 1.0 if compte_enrere > 0 else 0.5
		get_tree().create_timer(temps_restant, false).timeout.connect(temporitzador_acabat)

func afegeix_etiqueta_compte_enrere() -> void:
	var etiqueta_compte_enrere = plantilla_etiqueta_compte_enrere.instantiate()
	etiqueta_compte_enrere.text = str(compte_enrere) + "!"
	add_child(etiqueta_compte_enrere)
	etiqueta_compte_enrere.position = Vector2(-100, -550)
	get_tree().create_timer(0.8, false).timeout.connect(func (): etiqueta_compte_enrere.queue_free())
