class_name PropietatsExplosiu
extends Resource

enum TIPUS_EXPLOSIU { Petit, Mitja, Gran, }

## Tipus d'explosiu, com a mode d'identificació
@export var tipus_explosiu: TIPUS_EXPLOSIU
## Radi d'explosio d'aquest explosiu, en distància del taxista
@export var radi_explosio: int
## Rang de possibles durades de la metxa d'aquest explosiu en forma de Vector2i (mínim, màxim)
@export var rang_durades: Vector2i
