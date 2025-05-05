from pygomas.actions import Action

class calcular_ruta_segura(Action):
    """
    Acción interna personalizada para calcular rutas evitando enemigos.
    Hereda de la clase Action de pyGOMAS.
    """
    def __init__(self):
        super().__init__()
        self.safe_distance = 15  # Distancia mínima para evitar enemigos

    def execute(self, agent, dest):
        """
        Calcula una ruta segura hacia el destino, evitando enemigos cercanos.
        
        Args:
            agent: Instancia del agente BDITroop.
            dest: Lista [x, y, z] con las coordenadas de destino.
            
        Returns:
            Lista de waypoints para la navegación segura.
        """
        enemies = agent.get_enemies_in_sight()
        
        if not enemies:
            return agent.navigation.calculate_route(dest)
        else:
            # Estrategia: Desviarse 10 unidades en X si hay enemigos
            safe_pos = [dest[0] + 10, dest[1], dest[2]]
            agent.print(f"¡Enemigos detectados! Recalculando ruta a {safe_pos}")
            return agent.navigation.calculate_route(safe_pos)