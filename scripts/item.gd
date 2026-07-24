class_name Item
extends RigidBody2D

func _init() -> void:
	lock_rotation = true

var agafat: bool = false:
	set(nou_agafat):
		agafat = nou_agafat
		set_deferred("freeze", agafat)
		#set_freeze_enabled(agafat)
