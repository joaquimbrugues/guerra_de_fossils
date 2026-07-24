class_name Explosiu
extends Item

## Propietats de l'explosiu
@export var propietats: PropietatsExplosiu

# Indica quin és el darrer personatge que ha agafat aquest explosiu (0 a l'esquerra, 1 a la dreta)
var darrer_propietari: int = -1
var compte_enrere: int = 3

signal temps_restant_bomba(temps: int, propietari: int)
signal explosio_bomba(explosiu: Explosiu)

func _ready() -> void:
	# Creem un temporitzador amb 3 segons menys del normal
	var durada = randi_range(propietats.rang_durades.x, propietats.rang_durades.y)
	get_tree().create_timer(durada - 3, false).timeout.connect(temporitzador_acabat)

func temporitzador_acabat() -> void:
	if compte_enrere == 0:
		# EXPLOSIÓ!
		#TODO
		print("Explosió!")
	else:
		# COMPTE ENRERE
		#TODO
		print(str(compte_enrere) + "!")
		compte_enrere -= 1
		get_tree().create_timer(1, false).timeout.connect(temporitzador_acabat)

#TODO: Quan s'acabi el temporitzador, enviar una senyal d'explosio a l'escena responsable
#TODO: Quan s'acabi el temporitzador, fer l'animació d'explosió
#TODO: Enviar senyals a 3, 2 i 1 del temporitzador per fer efectes a l'escena corresponent
