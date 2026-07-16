# EXPERIENCE 9 — Living Canvas

## Visual System Delivered

- LivingCanvas now includes 5 visual layers: AmbientGradient, WatercolorLayer, AmbientLight, blur veil, and PaperTexture.
- Entrance timing standardized to 4 seconds for OrganicFade-style canvas reveal.
- Ultra-slow breathing motion implemented (max drift 8 px) with 30–60s cycles according to movement preference.
- CanvasTheme upgraded with environment palette tones and motion behavior.
- Added ODL hierarchy primitives:
	- OasisSurface
	- OasisPrimaryCard
	- OasisGlassCard
	- OasisSectionHeader
	- OasisDivider
	- ShadowSpec
	- CanvasSpec

## Settings Integration

- Modo de luz: Claro / Oscuro / Sistema.
- Ambiente: Bosque / Bruma / Lino / Costa / Noche Serena.
- Intensidad: Muy sutil / Sutil / Media.
- Movimiento: Activado / Reducido / Sin movimiento.

## Module Notes

- Per-screen default ambientes:
	- Home: Bosque
	- Journal: Bruma
	- Wellbeing: Bosque
	- Agenda: Lino
	- Settings: Costa
	- Notes: blue-gray family via Bruma
- Home hierarchy updated with depth levels:
	- Level 1: screen background atmosphere
	- Level 2: secondary surfaces and task rows
	- Level 3: primary Hoy card
	- Level 4: controls/actions with clear visual separation

## Validation

- flutter analyze --no-fatal-infos --no-fatal-warnings: 0 errors (infos/warnings remain from prior repo debt).
- flutter test: 27 passed.

## Screenshot Status

- Not captured in this environment because no browser/device page was shared for visual capture.

## Notes for Experience 10

- Reduce existing analyzer warnings in tests and lint debt files.
- Run visual QA with captures in mobile and desktop layouts using each ambiente.
