extends Node2D

@onready var items: Node2D = $Items
@onready var capa_roca: TileMapLayer = $Capes/CapaRoca
@onready var personatge_1: CharacterBody2D = $Personatge1
@onready var personatge_2: CharacterBody2D = $Personatge2

func assigna_item(item: Item) -> void:
	item.call_deferred("reparent", items)

func _on_personatge_1_objecte_alliberat(objecte: Item) -> void:
	assigna_item(objecte)

func _on_personatge_2_objecte_alliberat(objecte: Item) -> void:
	assigna_item(objecte)

func resol_explosio(bomba: Explosiu) -> void:
	var centre: Vector2 = to_local(bomba.get_global_position())
	var casella_centre: Vector2i = capa_roca.local_to_map(centre)
	var tipus_bomba: PropietatsExplosiu.TIPUS_EXPLOSIU = bomba.propietats.tipus_explosiu
	var caselles_radi: int = bomba.propietats.radi_explosio
	var casella_jugador_1: Vector2i = capa_roca.local_to_map(to_local(personatge_1.get_global_position()))
	var casella_jugador_2: Vector2i = capa_roca.local_to_map(to_local(personatge_2.get_global_position()))
	# Bucle a través de les caselles dins del "diamant" de radi de l'explosió
	for y in range(- caselles_radi, caselles_radi + 1):
		for x in range( maxi(y - caselles_radi, - y - caselles_radi), mini(caselles_radi - y, y + caselles_radi) + 1):
			var casella := Vector2i(x,y) + casella_centre
			var data: TileData = capa_roca.get_cell_tile_data(casella)
			if data != null:
				# Hem picat roca
				var terreny_casella: int = data.get_terrain()	# Si tot va bé, ens hauria de donar 0 per roca tova, 1 per roca dura, i 2 per roca impenetrable
				#TODO: Hi havia una manera d'alterar el tilemap per terrenys?
				match tipus_bomba:
					PropietatsExplosiu.TIPUS_EXPLOSIU.Petit:
						pass	#TODO quan hi hagi fòssils
					PropietatsExplosiu.TIPUS_EXPLOSIU.Mitja:
						if terreny_casella == 0:
							# Roca tova
							capa_roca.set_cell(casella, -1)	# Esborrem la casella del TileMap
					PropietatsExplosiu.TIPUS_EXPLOSIU.Gran:
						if terreny_casella != 2:
							# Roca tova o dura
							capa_roca.set_cell(casella, -1)	# Esborrem la casella del TileMap
			# Afectem els jugadors
			if casella == casella_jugador_1:
				personatge_1.calcinat = true
			if casella == casella_jugador_2:
				personatge_2.calcinat = true

func _on_personatge_1_explosio_bomba(bomba: Explosiu) -> void:
	resol_explosio(bomba)

func _on_personatge_2_explosio_bomba(bomba: Explosiu) -> void:
	resol_explosio(bomba)
