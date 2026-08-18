extends Node

class_name MultiplayerManager

@export var velocidad_defaul: float = 1.0
@export_range(0.5, 8.0, 0.1) var suavizado_aceleracion: float = 2.5
@export_range(0.5, 8.0, 0.1) var suavizado_frenado: float = 4.0

enum TipoDecision {
	ATACARR,
	MODERARR,
	CONSERVARR,
	NINGUNA
}

class Jugador:
	var id: int
	var pathfollow: PathFollow2D
	var decision_previa: int = 3
	var decidio: bool = false
	var spd_act: float = 1.0
	var spd_obj: float = 1.0
	var spd_safe: float = 1.0
	var hp: float = 100.0
	var dead: bool = false
	var ya_proceso_zona: bool = false

	func _init(pid: int, pf: PathFollow2D) -> void:
		id = pid
		pathfollow = pf

var players: Array[Jugador] = []

func _ready() -> void:
	pass

func inicializar_jugadores(pathfollows: Array[PathFollow2D]) -> void:
	if pathfollows.size() < 2:
		push_error("ERROR: necesito 2 paths")
		return
	players.append(Jugador.new(1, pathfollows[0]))
	players.append(Jugador.new(2, pathfollows[1]))
        for p in players:
                p.spd_act = velocidad_defaul
                p.spd_obj = velocidad_defaul
                p.spd_safe = velocidad_defaulfunc _process(delta: float) -> void:
	for p in players:
		if not p.dead:
			mov_jugador(p, delta)

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed:
		return
	for p in players:
		if p.dead:
			continue
		if p.id == 1:
			if event.keycode == KEY_UP:
				p.decision_previa = 0
				p.decidio = true
				print("J1 ATACAR")
				return
			elif event.keycode == KEY_DOWN:
				p.decision_previa = 1
				p.decidio = true
				print("J1 MODERAR")
				return
		if p.id == 2:
			if event.keycode == KEY_W:
				p.decision_previa = 0
				p.decidio = true
				print("J2 ATACAR")
				return
			elif event.keycode == KEY_S:
				p.decision_previa = 1
				p.decidio = true
				print("J2 MODERAR")
				return

func check_zona_colision(p: Jugador) -> void:
	if p.ya_proceso_zona:
		return
	if not p.decidio:
		p.decision_previa = 3
	p.ya_proceso_zona = true
	exec_decision(p)

func exec_decision(p: Jugador) -> void:
	if p.dead:
		return
	match p.decision_previa:
		0:
			p.spd_obj = 1.2
			hurt(p, calc_dmg_attack(p))
		1:
			p.spd_obj = 0.7
			hurt(p, 5.0)
		2:
			p.spd_obj = 0.6
		3:
			p.spd_obj = 0.5
			hurt(p, 10.0)
	p.decidio = false

func calc_dmg_attack(p: Jugador) -> float:
	var excess = max(0.0, p.spd_act - p.spd_safe)
	return 12.0 + (excess * 45.0)

func hurt(p: Jugador, dmg: float) -> void:
	p.hp -= dmg
	if p.hp < 0.0:
		p.hp = 0.0
	if p.hp <= 0.0:
		die(p)

func die(p: Jugador) -> void:
	if p.dead:
		return
	p.dead = true
	p.spd_act = 0.0
	p.spd_obj = 0.0
	var tw = create_tween()
	tw.tween_property(p.pathfollow, "v_offset", 220.0, 0.6)

func mov_jugador(p: Jugador, dt: float) -> void:
	var smooth = suavizado_frenado
	if p.spd_obj > p.spd_act:
		smooth = suavizado_aceleracion
	p.spd_act = move_toward(p.spd_act, p.spd_obj, smooth * dt)
	p.pathfollow.progress += 300 * p.spd_act * dt

func get_p_state(pid: int) -> Dictionary:
	for p in players:
		if p.id == pid:
			return {"id": p.id, "hp": p.hp, "vel": p.spd_act, "muerto": p.dead, "decision": p.decision_previa}
	return {}

func get_state() -> Dictionary:
	return {"p1": get_p_state(1), "p2": get_p_state(2)}
