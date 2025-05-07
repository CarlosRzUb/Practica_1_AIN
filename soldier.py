import json
import time
import random
from loguru import logger
from spade.behaviour import OneShotBehaviour
from spade.template import Template
from spade.message import Message
from pygomas.bditroop import BDITroop
from pygomas.bdifieldop import BDISoldier
from agentspeak import Actions
from agentspeak import grounded
from agentspeak.stdlib import actions as asp_action
import pygomas.ontology as ontology

class BDISniper(BDISoldier):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.velocity_value = 5 #Se mueven más rápido que los soldados
        self.ammo = 20 # Munición inicial menor que los soldados
        self.power = 500 # Poder inicial mayor que los soldados

    async def setup(self):
        await super().setup()
        self.bdi_agent.add_belief("rank", "BDISniper")  # Define el rango como BDISniper 

    def add_custom_actions(self, actions):
        @actions.add_function(".sniper_shot", tuple)
        def _sniper_shot(target):
            """
            Disparo de francotirador a un objetivo.
            :param term: Posición del objetivo a disparar.
            """
            if target is None:
                logger.warning("No hay objetivo para disparar.")
                return False

            if self.ammo <= 0:
                logger.warning("Sin munición para disparar.")
                return False

            # Simula el disparo
            logger.info(f"{self.name} dispara al objetivo en {target} con daño {self.power}.")
            self.decrease_ammo(1)  # Reduce la munición en 1
            self.shoot(1, target)
            time.sleep(3)  # Espera 3 segundos tras disparar
            return True
                

         