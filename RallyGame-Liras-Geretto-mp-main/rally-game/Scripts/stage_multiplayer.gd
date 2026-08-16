extends Path2D
## Script de la escena Stage con soporte para multijugador
## Coordina el flujo del juego y la detección de zonas

@onready var multiplayer_manager: Node = get_node_or_null("MultiplayerManager")

func _ready() -> void:
	# Inicializar el sistema de multijugador si existe
	if multiplayer_manager and multiplayer_manager.has_method("inicializar_jugadores"):
		var car_paths = []
		
		# Obtener referencias a los PathFollow2D de los jugadores
		var pathfollow_1 = get_node_or_null("prota")
		var pathfollow_2 = get_node_or_null("Car2")
		
		if pathfollow_1:
			car_paths.append(pathfollow_1)
			print("✓ Jugador 1 (prota) conectado")
		else:
			push_error("No se encontró prota (Jugador 1)")
		
		if pathfollow_2:
			car_paths.append(pathfollow_2)
			print("✓ Jugador 2 (Car2) conectado")
		else:
			push_error("No se encontró Car2 (Jugador 2)")
		
		if car_paths.size() == 2:
			multiplayer_manager.inicializar_jugadores(car_paths)
			print("✓ Sistema multijugador inicializado")
		else:
			push_error("No se pudieron inicializar ambos jugadores")
	else:
		print("ℹ Modo single-player (sin MultiplayerManager)")

func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Este método puede conectarse a las zonas de curva para notificar al MultiplayerManager
	if multiplayer_manager and multiplayer_manager.has_method("zona_curva_detectada"):
		multiplayer_manager.zona_curva_detectada(body)
