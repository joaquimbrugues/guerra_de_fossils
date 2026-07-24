extends Node2D

@onready var items: Node2D = $Items

func assigna_item(item: Item) -> void:
	item.call_deferred("reparent", items)

func _on_personatge_1_objecte_alliberat(objecte: Item) -> void:
	assigna_item(objecte)

func _on_personatge_2_objecte_alliberat(objecte: Item) -> void:
	assigna_item(objecte)

func resol_explosio(bomba: Explosiu) -> void:
	#TODO:
	# 1- Aconseguir localització de la bomba, tipus i radi
	# 2- Traduir-ho a coordenades del TileMap de roca
	# 3- Eliminar les caselles que correspongui
	print("BUM!")

func _on_personatge_1_explosio_bomba(bomba: Explosiu) -> void:
	resol_explosio(bomba)

func _on_personatge_2_explosio_bomba(bomba: Explosiu) -> void:
	resol_explosio(bomba)
