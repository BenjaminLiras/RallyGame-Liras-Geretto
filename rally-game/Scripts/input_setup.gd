extends Node

func _enter_tree() -> void:
	agregar_acciones_entrada()

func agregar_acciones_entrada() -> void:
	# W (Jugador 2 - subir)
	if not InputMap.has_action("w_key"):
		InputMap.add_action("w_key")
		var event_w = InputEventKey.new()
		event_w.keycode = KEY_W
		InputMap.action_add_event("w_key", event_w)

	# S (Jugador 2 - bajar)
	if not InputMap.has_action("s_key"):
		InputMap.add_action("s_key")
		var event_s = InputEventKey.new()
		event_s.keycode = KEY_S
		InputMap.action_add_event("s_key", event_s)
