// TEAM_AXIS (DEFENSA)
+flag(F): team(200)
  <-
  .register_service("axis");
  .register_service("backup");
  .register_service("defensor");  // Servicio personalizado
  
  // Estrategia: 30% vigías, 70% patrullas
  ?my_id(ID);
  if (ID < 3) {
    // Grupo 1: Vigías estáticos en posiciones clave
    +vigia;
    .goto([F[0], F[1], F[2] + 20]);  // 20 unidades arriba de la bandera
    .print("Soy vigía en posición defensiva");
  } else {
    // Grupo 2: Patrullas dinámicas
    .create_control_points(F, 30, 5, C);  // 5 puntos a 30 unidades de la bandera
    +control_points(C);
    +patrolling;
    +patroll_point(0);
    .print("Iniciando patrulla defensiva");
  }.

// TEAM_ALLIED (ATAQUE)
+flag(F): team(100)
  <-
  .register_service("allied");
  .register_service("backup");
  .register_service("asalto");  // Servicio personalizado
  
  // Estrategia: 40% exploradores, 60% atacantes
  ?my_id(ID);
  if (ID < 4) {
    // Grupo 1: Exploradores (mapean esquinas)
    +explorador;
    .goto([15, 0, 15]);  // Esquina inferior izquierda
  } else {
    // Grupo 2: Ataque directo
    .add_internal_action("ruta_segura", "myactions.calcular_ruta_segura");
    .ruta_segura(F);  // Usa acción interna para ruta segura
    +atacante;
  }.

// Comportamiento común
+enemies_in_fov(ID, _, _, Dist, _, Pos): 
  Dist < 20 & not friends_in_fov(ID, _, _, _, _, _)  // Evita fuego amigo
  <-
  .shoot(3, Pos).  // Soldados disparan 3 veces (daño doble)

+friends_in_fov(_, _, _, Dist, Health, Pos): 
  Health < 40 & Dist < 15
  <-
  .get_medics;
  .send(myMedics, achieve, ayuda_medica(Pos)).  // Pide ayuda médica