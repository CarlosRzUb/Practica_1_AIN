import json
import random
import math
from loguru import logger
from spade.behaviour import OneShotBehaviour
from spade.template import Template
from spade.message import Message
from pygomas.bditroop import BDITroop
from pygomas.bdisoldier import BDISoldier
from agentspeak import Actions
from agentspeak import grounded
from agentspeak.stdlib import actions as asp_action
import pygomas.ontology as ontology

class BDISuperSoldier(BDISoldier):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
     

    def add_custom_actions(self, actions):
        super().add_custom_actions(actions)

        @actions.add_function(".circle", (tuple, tuple, float, ))
        def _circle(agent_pos, center, radius):
            # Diferencia entre agente y centro
            dx = agent_pos[0] - center[0]
            dz = agent_pos[2] - center[2]

            # Ángulo actual del agente respecto al centro
            current_angle = math.atan2(dz, dx)  # atan2 devuelve ángulo en radianes

            # Avanzamos 10° (en radianes)
            next_angle = current_angle + math.radians(10)

            # Nueva posición
            x = center[0] + radius * math.cos(next_angle)
            z = center[2] + radius * math.sin(next_angle)
            y = center[1]  # misma altura

            return (x, y, z)
        
        @actions.add_function(".rand_int_three_to_five", ())
        def _rand_int_three_to_five():
            return random.choice([3000, 4000, 5000])
                

         