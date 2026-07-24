extends Node2D

@onready var items: Node2D = $Items
@onready var capa_roca: TileMapLayer = $Capes/CapaRoca


func assigna_item(item: Item) -> void:
	item.call_deferred("reparent", items)

func _on_personatge_1_objecte_alliberat(objecte: Item) -> void:
	assigna_item(objecte)

func _on_personatge_2_objecte_alliberat(objecte: Item) -> void:
	assigna_item(objecte)

func resol_explosio(bomba: Explosiu) -> void:
	#TODO:
	# 2- Traduir-ho a coordenades del TileMap de roca
	# 3- Eliminar les caselles que correspongui
	var centre: Vector2 = to_local(bomba.get_global_position())
	var tipus_bomba: PropietatsExplosiu.TIPUS_EXPLOSIU = bomba.propietats.tipus_explosiu
	var caselles_radi: int = bomba.propietats.radi_explosio
	print("BUM! a " + str(centre))

func _on_personatge_1_explosio_bomba(bomba: Explosiu) -> void:
	resol_explosio(bomba)

func _on_personatge_2_explosio_bomba(bomba: Explosiu) -> void:
	resol_explosio(bomba)
