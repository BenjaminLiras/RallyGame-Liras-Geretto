extends PathFollow2D

@export var velocidad: float = 300
@export_range(0.0, 2.0, 0.05) var velocidad_defaul: float = 1.0

func _ready() -> void:
	loop = true
