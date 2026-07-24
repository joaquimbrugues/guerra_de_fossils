extends Node2D

@onready var items: Node2D = $Items

func assigna_item(item: Item) -> void:
	item.reparent(items)

func _on_personatge_1_objecte_alliberat(objecte: Item) -> void:
	assigna_item(objecte)

func _on_personatge_2_objecte_alliberat(objecte: Item) -> void:
	assigna_item(objecte)
