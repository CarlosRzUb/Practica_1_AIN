import json
import random
import math
from loguru import logger
from spade.behaviour import OneShotBehaviour
from spade.template import Template
from spade.message import Message
from pygomas.bditroop import BDITroop
from pygomas.bdisoldier import BDISoldier
from pygomas.bdimedic import BDIMedic
from pygomas.bdifieldop import BDIFieldOp
from agentspeak import Actions
from agentspeak import grounded
from agentspeak.stdlib import actions as asp_action
import pygomas.ontology as ontology

class BDISuperSoldier(BDISoldier):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
    
    def add_custom_actions(self, actions):
        super().add_custom_actions(actions)

        @actions.add_function(".abs", (float, ))
        def _abs(x):
            return float(abs(float(x)))

        @actions.add_function(".calculate_flanking_position", (tuple, tuple, float, ))
        def _calculate_flanking_position(agent_pos, enemy_pos, distance):
            """Calcula una posición de flanqueo óptima"""
            dx = enemy_pos[0] - agent_pos[0]
            dz = enemy_pos[2] - agent_pos[2]
            angle = math.atan2(float(dz), float(dx)) + math.pi/2
            flank_x = enemy_pos[0] + distance * math.cos(angle)
            flank_z = enemy_pos[2] + distance * math.sin(angle)
            return (float(flank_x), float(agent_pos[1]), float(flank_z))

        @actions.add_function(".circle", (tuple, tuple, float, ))
        def _circle(agent_pos, center, radius):
            dx = agent_pos[0] - center[0]
            dz = agent_pos[2] - center[2]
            current_angle = math.atan2(float(dz), float(dx))
            next_angle = current_angle + math.radians(15)
            x = center[0] + radius * math.cos(next_angle)
            z = center[2] + radius * math.sin(next_angle)
            y = center[1]
            return (float(x), float(y), float(z))
        
        @actions.add_function(".rand_int_three_to_five", ())
        def _rand_int_three_to_five():
            return random.choice([3000, 4000, 5000])

        @actions.add_function(".safe_distance_check", (tuple, tuple, float, ))
        def _safe_distance_check(agent_pos, friend_pos, min_distance):
            """Verifica si hay distancia segura entre agente y aliado"""
            dx = agent_pos[0] - friend_pos[0]
            dz = agent_pos[2] - friend_pos[2]
            distance = math.sqrt(float(dx*dx) + float(dz*dz))
            return float(distance) >= float(min_distance)
        
        @actions.add_function(".is_number", (object, ))
        def _is_number(value):
            """Verifica si el valor es un número"""
            return isinstance(value, (int, float))
        
class BDISuperMedic(BDIMedic):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
     
    def add_custom_actions(self, actions):
        super().add_custom_actions(actions)

        @actions.add_function(".abs", (float))
        def _abs(x):
            return float(abs(float(x)))

        @actions.add_function(".calculate_flanking_position", (tuple, tuple, float, ))
        def _calculate_flanking_position(agent_pos, enemy_pos, distance):
            """Calcula una posición de flanqueo óptima"""
            dx = enemy_pos[0] - agent_pos[0]
            dz = enemy_pos[2] - agent_pos[2]
            angle = math.atan2(float(dz), float(dx)) + math.pi/2
            flank_x = enemy_pos[0] + distance * math.cos(angle)
            flank_z = enemy_pos[2] + distance * math.sin(angle)
            return (float(flank_x), float(agent_pos[1]), float(flank_z))

        @actions.add_function(".circle", (tuple, tuple, float, ))
        def _circle(agent_pos, center, radius):
            dx = agent_pos[0] - center[0]
            dz = agent_pos[2] - center[2]
            current_angle = math.atan2(float(dz), float(dx))
            next_angle = current_angle + math.radians(15)
            x = center[0] + radius * math.cos(next_angle)
            z = center[2] + radius * math.sin(next_angle)
            y = center[1]
            return (float(x), float(y), float(z))
        
        @actions.add_function(".rand_int_three_to_five", ())
        def _rand_int_three_to_five():
            return random.choice([3000, 4000, 5000])

        @actions.add_function(".safe_distance_check", (tuple, tuple, float, ))
        def _safe_distance_check(agent_pos, friend_pos, min_distance):
            """Verifica si hay distancia segura entre agente y aliado"""
            dx = agent_pos[0] - friend_pos[0]
            dz = agent_pos[2] - friend_pos[2]
            distance = math.sqrt(float(dx*dx) + float(dz*dz))
            return float(distance) >= float(min_distance)

class BDISuperFieldOP(BDIFieldOp):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
     
    def add_custom_actions(self, actions):
        super().add_custom_actions(actions)

        @actions.add_function(".abs", (float))
        def _abs(x):
            return float(abs(float(x)))
        
        @actions.add_function(".calculate_flanking_position", (tuple, tuple, float, ))
        def _calculate_flanking_position(agent_pos, enemy_pos, distance):
            """Calcula una posición de flanqueo óptima"""
            dx = enemy_pos[0] - agent_pos[0]
            dz = enemy_pos[2] - agent_pos[2]
            angle = math.atan2(float(dz), float(dx)) + math.pi/2
            flank_x = enemy_pos[0] + distance * math.cos(angle)
            flank_z = enemy_pos[2] + distance * math.sin(angle)
            return (float(flank_x), float(agent_pos[1]), float(flank_z))

        @actions.add_function(".circle", (tuple, tuple, float, ))
        def _circle(agent_pos, center, radius):
            dx = agent_pos[0] - center[0]
            dz = agent_pos[2] - center[2]
            current_angle = math.atan2(float(dz), float(dx))
            next_angle = current_angle + math.radians(15)
            x = center[0] + radius * math.cos(next_angle)
            z = center[2] + radius * math.sin(next_angle)
            y = center[1]
            return (float(x), float(y), float(z))
        
        @actions.add_function(".rand_int_three_to_five", ())
        def _rand_int_three_to_five():
            return random.choice([3000, 4000, 5000])

        @actions.add_function(".safe_distance_check", (tuple, tuple, float, ))
        def _safe_distance_check(agent_pos, friend_pos, min_distance):
            """Verifica si hay distancia segura entre agente y aliado"""
            dx = agent_pos[0] - friend_pos[0]
            dz = agent_pos[2] - friend_pos[2]
            distance = math.sqrt(float(dx*dx) + float(dz*dz))
            return float(distance) >= float(min_distance)