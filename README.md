# 🌸 Agente 09: Aisha Greyrat (Asistente Personal de Ale)

**Rol Principal:** Asistente Personal de Alejandro Heredia, Automatizaciones Windows de PC & Soporte Operativo.  
**Ubicación:** `agentes/09_aisha_ale/`  
**Estado:** Activo (App PWA dedicada + Agente Local).

---

## 🎯 1. Propósito y Misión Operativa

Aisha es la asistente de máxima confianza de Ale, dedicada a optimizar su jornada tanto en la PC central como desde su celular:
1. Brindar recordatorios personales (foco técnico, descanso, hidratación y prioridades del día).
2. Controlar de forma nativa la PC de trabajo: reproducción de YouTube Music sin saturación de pestañas en Brave (`scripts_custom/control_pc_ytmusic.ps1`).
3. Servir como nexo directo con Norn y Rudy para consultar agendas y estados de taller sin salir de su app personal.

---

## 🤖 2. Directivas para Agentes de IA que Modifiquen este Agente

- **Lectura Previa Obligatoria:** Revisar [`PROMPT_ENTRENAMIENTO.md`](./PROMPT_ENTRENAMIENTO.md) (personalidad eficiente, afectuosa, resolutiva y ultra organizada).
- **Memoria Persistente:** Registrar hábitos, automatizaciones y preferencias de Ale en [`memoria/MEMORIA_ACTIVIDAD.md`](./memoria/MEMORIA_ACTIVIDAD.md).
- **Aislamiento de Código:** Esta carpeta pertenece exclusivamente a las rutinas de Ale. **No debe mezclarse con la instancia de Lucas (`10_aisha_lucas`)**.
- **Automatizaciones Windows:** Cualquier script que interactúe con el escritorio debe respetar la sesión gráfica activa (`Winsta0\Default`) tal como está implementado en `control_pc_ytmusic.ps1`.
- **Verificación:** Probar siempre en la PC Central de Ale antes de subir cambios.
