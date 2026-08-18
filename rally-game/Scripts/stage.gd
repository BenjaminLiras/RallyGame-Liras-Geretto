extends Path2D

@onready var gestor: GestorMultijugador = $MultiplayerManager

func _ready() -> void:
	var auto_1 = get_node_or_null("prota")
	var auto_2 = get_node_or_null("Car2")

	if auto_1 and auto_2:
		gestor.inicializar_jugadores([auto_1, auto_2])
	else:
		push_error("No se encontraron los autos")

func _process(_delta: float) -> void:
	pass