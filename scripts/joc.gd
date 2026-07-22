extends Control

# Creem una estructura per desar totes les entitats necessàries: (1) viewports, (2) càmeres, i (3) jugadors
@onready var jugadors: Array[Dictionary] = [
	{
		sub_viewport = %SubViewportEsquerra,
		camera = %CameraEsquerra,
		jugador = %Nivell/Personatge1,
	},
	{
		sub_viewport = %SubViewportDreta,
		camera = %CameraDreta,
		jugador = %Nivell/Personatge2,
	},
]
func _ready() -> void:
	
	# Compartim el world2d del viewport esquerre (que ja el té pel fet d'incloure el Nivell com a fill) amb el viewport de la dreta
	jugadors[1].sub_viewport.world_2d = jugadors[0].sub_viewport.world_2d
	
	# Per a cada jugador, creem una transformació 2D per col·locar-li la càmera al damunt
	for info in jugadors:
		var remote_transform := RemoteTransform2D.new()
		remote_transform.remote_path = info.camera.get_path()
		info.jugador.add_child(remote_transform)
