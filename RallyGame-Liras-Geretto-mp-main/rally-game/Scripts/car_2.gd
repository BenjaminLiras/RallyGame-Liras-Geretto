extends PathFollow2D
@export var velocidad: float = 300
@export var avanzando: bool = true
@export var calculo_velocidad: float = 1.0
@export var velocidad_defaul: float = 1.0
@export_range(1.0, 40.0, 1.0) var castigo_base_atacar: float = 12.0
@export_range(5.0, 120.0, 1.0) var castigo_por_exceso_velocidad: float = 45.0

var decision_pendiente: int = 0
var danio: float = 100.0
var descalificado: bool = false
var factor_velocidad_actual: float = 1.0
var factor_velocidad_objetivo: float = 1.0
var velocidad_segura_actual: float = 1.0
var zonas_procesadas: Array = []

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed:
		return
	if event.keycode == KEY_W:
		decision_pendiente = 0
		print("J2: ATACAR")
	elif event.keycode == KEY_S:
		decision_pendiente = 1
		print("J2: MODERAR")
	elif event.keycode == KEY_D:
		decision_pendiente = 2
		print("J2: CONSERVAR")

func _ready() -> void:
	loop = true
	factor_velocidad_actual = velocidad_defaul
	factor_velocidad_objetivo = velocidad_defaul

func _process(delta: float) -> void:
	if not avanzando or descalificado:
		return

	# Suavizado de velocidad
	factor_velocidad_actual = move_toward(factor_velocidad_actual, factor_velocidad_objetivo, 3.0 * delta)
	progress += velocidad * factor_velocidad_actual * delta

	# Detectar zonas cercanas por posicion
	var stage = get_parent()
	for child in stage.get_children():
		if not (child is Area2D):
			continue
		var dist = global_position.distance_to(child.global_position)
		if dist < 60.0 and not child in zonas_procesadas:
			zonas_procesadas.append(child)
			_on_zona(child)
		elif dist > 120.0 and child in zonas_procesadas:
			zonas_procesadas.erase(child)

func _on_zona(area: Area2D) -> void:
	var tipo = area.get("tipo_punto")
	if tipo == null:
		return
	var vel_obj = area.get("velocidad_objetivo")
	if vel_obj == null:
		vel_obj = velocidad_defaul
	if tipo == 1:
		factor_velocidad_objetivo = float(vel_obj)
		return
	# Zona de decision
	velocidad_segura_actual = float(vel_obj)
	_resolver(decision_pendiente)
	decision_pendiente = 0

func _resolver(dec: int) -> void:
	match dec:
		0:  # ATACAR
			factor_velocidad_objetivo = 1.2
			var exceso = max(0.0, factor_velocidad_actual - velocidad_segura_actual)
			var dmg = castigo_base_atacar + exceso * castigo_por_exceso_velocidad
			danio -= dmg
		1:  # MODERAR
			factor_velocidad_objetivo = 0.7
			danio -= 5.0
		2:  # CONSERVAR
			factor_velocidad_objetivo = 0.6
	if danio <= 0.0:
		danio = 0.0
		descalificado = true
		factor_velocidad_actual = 0.0
		factor_velocidad_objetivo = 0.0
		# Si la camara esta en Car2, volver a prota
		var prota = get_tree().root.get_node_or_null("Main/Stage/prota")
		if prota:
			var cam = prota.get_node_or_null("Camera2D")
			if cam == null:
				cam = get_node_or_null("Camera2D")
				if cam:
					cam.reparent(prota)
		var tw = create_tween()
		tw.tween_property(self, "v_offset", 220.0, 0.6)

