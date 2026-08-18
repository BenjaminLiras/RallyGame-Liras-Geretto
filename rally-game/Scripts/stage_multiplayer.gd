extends Path2D

@onready var multiplayer_manager: Node = get_node_or_null("MultiplayerManager")

func _ready() -> void:
	if multiplayer_manager and multiplayer_manager.has_method("inicializar_jugadores"):
		var car_paths = []
		var pathfollow_1 = get_node_or_null("prota")
		var pathfollow_2 = get_node_or_null("Car2")

		if pathfollow_1:
			car_paths.append(pathfollow_1)
		else:
			push_error("No se encontro prota")

		if pathfollow_2:
			car_paths.append(pathfollow_2)
		else:
			push_error("No se encontro Car2")

		if car_paths.size() == 2:
			multiplayer_manager.inicializar_jugadores(car_paths)

func _process(_delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if multiplayer_manager and multiplayer_manager.has_method("zona_curva_detectada"):
		multiplayer_manager.zona_curva_detectada(body)
