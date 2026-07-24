class_name Explosiu
extends Item

## Propietats de l'explosiu
@export var propietats: PropietatsExplosiu

# Indica quin és el darrer personatge que ha agafat aquest explosiu (0 a l'esquerra, 1 a la dreta)
var darrer_propietari: int = -1

#TODO: Spawnejar dinàmicament a Personatge, fer que el Personatge perdi l'objecte en mà en agafar
#TODO: Fer que el Personatge SEMPRE agafi l'explosiu a l'aire
#TODO: A _ready, crear un temporitzador per l'explosio
#TODO: Quan s'acabi el temporitzador, enviar una senyal d'explosio a l'escena responsable
#TODO: Quan s'acabi el temporitzador, fer l'animació d'explosió
#TODO: Enviar senyals a 3, 2 i 1 del temporitzador per fer efectes a l'escena corresponent
