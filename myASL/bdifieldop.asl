// Inicialización
+flag(_): team(T)
  <-
  .register_service("fieldops");
  .register_service("suministros");  // Servicio personalizado
  if (T == 100) {
    .goto([50, 0, 50]);  // Aliados: Punto de reunión
  } else {
    // Eje: Patrulla alrededor de la bandera
    ?flag(F);
    .create_control_points(F, 20, 4, C);
    +control_points(C);
    +patrolling;
    +patroll_point(0);
  }.

// Suministro a aliados
+friends_in_fov(_, _, _, Dist, _, Pos): 
  Dist < 15 & not packs_in_fov(_, 1002, _, _, _, _)  // AMMOPACK id=1002
  <-
  .goto(Pos);
  .reload;
  .print("¡Suministrando munición!").

// Comportamiento Axis
+target_reached(T): patrolling & team(200)
  <-
  .reload;
  ?patroll_point(P);
  -+patroll_point(P+1);
  .print("Recargando en punto de patrulla");