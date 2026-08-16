# Sistema Pre-Decisión - Multijugador Local

## Cambio de Mecánica

El sistema ha sido **completamente rediseñado** desde la versión anterior.

### Antes (Ahora Deprecado)
- ⏸️ El juego se pausa cuando se llega a una curva
- ⏱️ Ventana de 1.5 segundos para decidir
- Timer en pantalla contando hacia atrás

### Ahora (Pre-Decisión)
- ✅ Los jugadores **deciden en cualquier momento** usando 3 botones por jugador
- 🚗 El auto **NO se pausa** al llegar a una curva
- ⚡ La decisión se **aplica inmediatamente** al alcanzar la curva
- ❌ Si no han decidido, automáticamente se aplica **penalización** (NINGUNA)

---

## Controles

### Jugador 1 (Arriba)
- **↑ (Flecha Arriba)** → ATACAR (1.2x velocidad, daño alto)
- **↓ (Flecha Abajo)** → MODERAR (0.7x velocidad, daño bajo)
- **Espacio** → CONSERVAR (0.6x velocidad, sin daño)

### Jugador 2 (Abajo)
- **W** → ATACAR (1.2x velocidad, daño alto)
- **S** → MODERAR (0.6x velocidad, sin daño)
- **Espacio** → CONSERVAR (0.6x velocidad, sin daño)

---

## Flujo de Juego

```
┌─────────────────────────────────────────┐
│  1. AMBOS CORREN LIBREMENTE             │
│     (No hay presión de tiempo)          │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  2. AMBOS PUEDEN PRESIONAR BOTONES      │
│     (Decidir en cualquier momento)      │
│     J1: ↑/↓/Espacio                     │
│     J2: W/S/Espacio                     │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│  3. AUTO LLEGA A CURVA/ZONA             │
│     (Colisión con Area2D)               │
└────────────────┬────────────────────────┘
                 │
                 ├─ ¿Decidió? ─┬─ SÍ → Aplicar decisión
                 │             │
                 │             └─ NO → Aplicar NINGUNA (penalización)
                 ▼
┌─────────────────────────────────────────┐
│  4. DECISIÓN SE APLICA                  │
│     - Velocidad objetivo cambia         │
│     - Daño se resta                     │
│     - Contador de HP se actualiza       │
│     - Si HP ≤ 0 → Descalificado        │
└─────────────────────────────────────────┘
```

---

## Tipos de Decisión

| Decisión | Teclas (J1/J2) | Velocidad | Daño | Situación |
|----------|----------------|-----------|------|-----------|
| **ATACAR** | ↑ / W | 1.2x | 12 + (exceso × 45) | Alto riesgo, alta recompensa |
| **MODERAR** | ↓ (J1) / S (J2) | 0.7x / 0.6x | 5 | Seguro, daño mínimo |
| **CONSERVAR** | Espacio / Espacio | 0.6x | 0 | Máxima seguridad |
| **NINGUNA** (Auto) | (No presionó) | 0.5x | 10 | Penalización por no decidir |

---

## Implementación Técnica

### Archivos Principales

1. **multiplayer_manager.gd**
   - Controla estado de ambos jugadores
   - Detecta inputs (W/S/↑/↓)
   - Guarda decisión en `decision_previa`
   - Aplica decisión al detectar zona

2. **area_2d.gd**
   - Detecta colisión cuando jugador entra en zona
   - Llama a `check_zona_colision()` del manager
   - Triggered por `area_entered` signal

3. **multiplayer_ui.gd**
   - Muestra HP de ambos jugadores
   - Muestra velocidad actual
   - Muestra última decisión
   - Actualiza cada frame

4. **stage.gd**
   - Instancia MultiplayerManager si no existe
   - Inicializa jugadores (prota y Car2)
   - Conecta con input_setup.gd

### Flujo de Ejecución

```
Area2D detecta colisión
    ↓
_on_area_detectada(area)
    ↓
manager.check_zona_colision(p)
    ↓
if not p.decidio:
    p.decision_previa = NINGUNA  // Penalización auto
    ↓
exec_decision(p)
    ↓
match p.decision_previa:
    ATACARR → velocidad 1.2x + daño
    MODERARR → velocidad 0.7x + daño bajo
    CONSERVARR → velocidad 0.6x + sin daño
    NINGUNA → velocidad 0.5x + daño penalización
    ↓
p.ya_proceso_zona = true  // Evitar doble-proceso
```

---

## Requerimientos para Funcionar

✅ MultiplayerManager instanciado (automático en stage.gd)
✅ Input map con acciones: "w_key", "s_key", "ui_up", "ui_down", "ui_select"
✅ Dos PathFollow2D: prota y Car2
✅ Area2D zones con área_2d.gd script
✅ Main escena con CanvasLayer/Cartel (UI)

---

## Pruebas Rápidas

1. **Verificar que teclas funcionan:**
   - Abre consola (F12 en Godot)
   - Presiona W/S/↑/↓
   - Deberías ver "J1 decidió..." o "J2 decidió..."

2. **Verificar que zona funciona:**
   - Corre el auto hasta que toque una zona
   - Verifica en consola que aparece el mensaje de decisión aplicada
   - Verifica que HP cambió

3. **Verificar que UI actualiza:**
   - Los paneles azul (J1) y rojo (J2) muestran HP y velocidad
   - Números cambian cuando se aplica decisión

---

## Notas de Diseño

- **No hay pausa:** El juego continúa mientras el jugador decide
- **Decisión persistente:** Si decidiste una vez, esa decisión se mantiene hasta llegar a zona
- **Penalización automática:** Si llegas a zona sin decidir, automáticamente NINGUNA
- **Velocidad suavizada:** Los cambios de velocidad son graduales (2.5x aceleración, 4.0x frenado)
- **Dead reckoning:** El daño solo se aplica si el jugador no está muerto

---

## Debugging

Si algo no funciona:

1. **Busca en consola por errores:** Debe decir "✓ Sistema multijugador listo"
2. **Verifica que stage.gd imprime:** "jugador 1 listo", "jugador 2 listo"
3. **Si no hay decisión:** Verifica que input_setup.gd registró las teclas
4. **Si no se aplica decisión:** Verifica que area_2d.gd está en las zonas
5. **Si no aparece UI:** Verifica que CanvasLayer/Cartel existe

---

## Futuras Mejoras

- [ ] Mostrar indicador visual de qué decisión fue elegida
- [ ] Sonidos al presionar botones
- [ ] Animaciones de daño
- [ ] Final de carrera con ganador/perdedor
- [ ] Replay system
