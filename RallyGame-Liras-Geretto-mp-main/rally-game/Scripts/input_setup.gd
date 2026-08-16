extends Node
## Script de inicialización del sistema de entrada para multijugador

func _enter_tree() -> void:
	agregar_acciones_entrada()

func agregar_acciones_entrada() -> void:
	"""Agrega las acciones de entrada necesarias para el multijugador"""
	
	# Acción para W (Jugador 2 - Arriba/Acelerar)
	if not InputMap.has_action("w_key"):
		InputMap.add_action("w_key")
		var event_w = InputEventKey.new()
		event_w.keycode = KEY_W
		InputMap.action_add_event("w_key", event_w)
	
	# Acción para S (Jugador 2 - Abajo/Frenar)
	if not InputMap.has_action("s_key"):
		InputMap.add_action("s_key")
		var event_s = InputEventKey.new()
		event_s.keycode = KEY_S
		InputMap.action_add_event("s_key", event_s)
