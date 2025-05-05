// Inicialización
+flag(_): team(T)
  <-
  .register_service("medic");
  .register_service("urgencias");  // Servicio personalizado
  if (T == 100) {
    +equipo_aliado;
  } else {
    +equipo_eje;
  }.

// Contract-Net para urgencias
+ayuda_medica(Pos)[source(A)]: 
  not ocupado & (equipo_aliado | equipo_eje)
  <-
  ?position(MiPos);
  .distance(MiPos, Pos, Dist);
  if (Dist < 25) {  // Solo responde si está cerca
    .send(A, tell, propuesta_ayuda(MiPos));
    +ocupado(A, Pos);
    .print(f"Enviando propuesta de ayuda a {A}");
  }.

// Movimiento y curación
+acceptproposal[source(A)]: ocupado(A, Pos)
  <-
  .goto(Pos);
  .print(f"Yendo a curar a {A} en {Pos}").

+target_reached(T): ocupado(_, T)
  <-
  .cure;
  -ocupado(_, T);
  .print("¡Paquete médico creado!");
  ?base(B);
  .goto(B).  // Vuelve a base tras curar