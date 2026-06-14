# Checkpoint de Sesión — Prototipo Activo

**Concepto:** DRAKWN — Combat Dragonpunk
**Fecha:** 2026-06-13
**Fase actual:** Phase 5 — Implement

## Hipótesis

"Si el jugador puede moverse, atacar con espada, y lanzar un hechizo de fuego que se recarga con el tiempo, empezará a encadenar ambos por su cuenta sin que nadie le explique que debe hacerlo — dentro de los primeros 5 minutos de juego."

## Suposición más riesgosa

¿Moverse y atacar en Godot 4.6.3 se siente fluido con impacto? Si la respuesta es no, el combate del juego no funciona.

## Camino elegido

Engine — Godot 4.6.3, GDScript

## Alcance del prototipo

- Personaje: caminar, saltar, ataque de espada
- Hechizo de fuego recargable (~3 segundos de recarga)
- 1-2 enemigos simples que se acercan al jugador y reciben daño
- Feedback visual: colores y flashes (no arte real)
- Barra de salud visible

## Fuera del alcance (deliberado)

- Menú, pantalla Game Over, guardado
- Historia, diálogos
- Música, efectos de sonido
- Arte real
- Múltiples zonas
- Sistema Fractura Sagrada

## Directorio del prototipo

`prototypes/combat-dragonpunk-concept/`

## Estado

Implementación iniciada. Continuar desde Phase 5 si se interrumpe la sesión.
