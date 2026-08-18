extends Node

class_name GestorMultijugador

@export var velocidad_defaul: float = 1.0
@export_range(0.5, 8.0, 0.1) var suavizado_aceleracion: float = 2.5
@export_range(0.5, 8.0, 0.1) var suavizado_frenado: float = 4.0

enum TipoDecision {
	ATACAR,
	MODERAR,
	CONSERVAR,
	NINGUNA
}

class Jugador:
	var id: int
	var nodo: PathFollow2D
	var decision_previa: int = 3
	var decidio: bool = false
	var vel_actual: float = 1.0
	var vel_objetivo: float = 1.0
	var vel_segura: float = 1.0
	var vida: float = 100.0
	var muerto: bool = false
	var zona_procesada: bool = false

	func _init(pid: int, pf: PathFollow2D) -> void:
		id = pid
		nodo = pf

var jugadores: Array[Jugador] = []

func _ready() -> void:
	pass

func inicializar_jugadores(nodos: Array[PathFollow2D]) -> void:
	if nodos.size() < 2:
		push_error("ERROR: se necesitan 2 autos")
		return
	jugadores.append(Jugador.new(1, nodos[0]))
	jugadores.append(Jugador.new(2, nodos[1]))
	for j in jugadores:
		j.vel_actual = velocidad_defaul
		j.vel_objetivo = velocidad_defaul
		j.vel_segura = velocidad_defaul

func _process(delta: float) -> void:
	for j in jugadores:
		if not j.muerto:
			mover_jugador(j, delta)

func _input(evento: InputEvent) -> void:
	if not (evento is InputEventKey) or not evento.pressed:
		return
	for j in jugadores:
		if j.muerto:
			continue
		if j.id == 1:
			if evento.keycode == KEY_UP:
				j.decision_previa = 0
				j.decidio = true
				return
			elif evento.keycode == KEY_DOWN:
				j.decision_previa = 1
				j.decidio = true
				return
		if j.id == 2:
			if evento.keycode == KEY_W:
				j.decision_previa = 0
				j.decidio = true
				return
			elif evento.keycode == KEY_S:
				j.decision_previa = 1
				j.decidio = true
				return

func revisar_zona(j: Jugador) -> void:
	if j.zona_procesada:
		return
	if not j.decidio:
		j.decision_previa = 3
	j.zona_procesada = true
	ejecutar_decision(j)

func ejecutar_decision(j: Jugador) -> void:
	if j.muerto:
		return
	match j.decision_previa:
		0:
			j.vel_objetivo = 1.2
			recibir_danio(j, calcular_danio_ataque(j))
		1:
			j.vel_objetivo = 0.7
			recibir_danio(j, 5.0)
		2:
			j.vel_objetivo = 0.6
		3:
			j.vel_objetivo = 0.5
			recibir_danio(j, 10.0)
	j.decidio = false

func calcular_danio_ataque(j: Jugador) -> float:
	var exceso = max(0.0, j.vel_actual - j.vel_segura)
	return 12.0 + (exceso * 45.0)

func recibir_danio(j: Jugador, cantidad: float) -> void:
	j.vida -= cantidad
	if j.vida < 0.0:
		j.vida = 0.0
	if j.vida <= 0.0:
		eliminar_jugador(j)

func eliminar_jugador(j: Jugador) -> void:
	if j.muerto:
		return
	j.muerto = true
	j.vel_actual = 0.0
	j.vel_objetivo = 0.0
	var animacion = create_tween()
	animacion.tween_property(j.nodo, "v_offset", 220.0, 0.6)

func mover_jugador(j: Jugador, delta: float) -> void:
	var suavizado = suavizado_frenado
	if j.vel_objetivo > j.vel_actual:
		suavizado = suavizado_aceleracion
	j.vel_actual = move_toward(j.vel_actual, j.vel_objetivo, suavizado * delta)
	j.nodo.progress += 300 * j.vel_actual * delta

func obtener_estado_jugador(pid: int) -> Dictionary:
	for j in jugadores:
		if j.id == pid:
			return {"id": j.id, "vida": j.vida, "velocidad": j.vel_actual, "muerto": j.muerto, "decision": j.decision_previa}
	return {}

func obtener_estado() -> Dictionary:
	return {"jugador1": obtener_estado_jugador(1), "jugador2": obtener_estado_jugador(2)}
