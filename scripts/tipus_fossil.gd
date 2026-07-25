class_name TipusFossil
extends Resource

@export_enum("crani", "potes_davanteres", "potes_posteriors", "caixa_toracica", "cua") var part_cos
@export_enum("Triceracops", "Diplodocus", "Estegosaurus", "Alosaurus", "Ictiosaurus", "Pterodactyl") var especie

func genera_aleatori() -> TipusFossil:
	var tipus = new()
	tipus.part_cos = randi_range(0,4)
	tipus.especie = randi_range(0,5)
	return tipus
