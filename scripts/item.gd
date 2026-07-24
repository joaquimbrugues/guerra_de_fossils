class_name Item
extends RigidBody2D

var agafat: bool = false:
	set(nou_agafat):
		agafat = nou_agafat
		set_freeze_enabled(agafat)
