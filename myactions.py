from loguru import logger
from pygomas.bditroop import BDITroop
from agentspeak import Actions
from agentspeak import grounded
from agentspeak.stdlib import actions as asp_actions

class TacticalFlanker(BDITroop):
    def add_custom_actions(self, actions):
        super().add_custom_actions(actions)
        
        @actions.add(".tactical_flank", 1)  # 1 argumento: posición objetivo
        def _tactical_flank(agent, term, intention):
            """Calcula una ruta de flanqueo para atacar por los laterales."""
            target_pos = grounded(term[0], intention.scope)  # Obtiene la posición objetivo desde ASL
            current_pos = (self.movement.position.x, 0, self.movement.position.z)
            
            # Calcular puntos de flanqueo (izquierda/derecha)
            flank_dist = 15  # Distancia de flanqueo
            dx = target_pos[0] - current_pos[0]
            dz = target_pos[2] - current_pos[2]
            
            # Puntos de flanqueo (45 grados)
            left_flank = [
                target_pos[0] + dz * 0.7, 
                0, 
                target_pos[2] - dx * 0.7
            ]
            right_flank = [
                target_pos[0] - dz * 0.7, 
                0, 
                target_pos[2] + dx * 0.7
            ]
            
            # Elegir el punto válido más cercano
            for flank in [left_flank, right_flank]:
                if self.map.can_walk(flank[0], flank[2]):
                    logger.info(f"Flanqueando hacia {flank}")
                    yield self.navigation.calculate_route(flank)
                    return
            
            logger.warning("No se encontró una ruta de flanqueo válida. Moviéndose directamente al objetivo.")
            yield self.navigation.calculate_route(target_pos)  # Fallback: ruta directa