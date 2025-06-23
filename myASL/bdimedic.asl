//SERVICIOS NUEVOS: Registro de servicios especializados
+flag (F): team(200) 
  <-
  .create_control_points(F,25,3,C);
  +control_points(C);
  .length(C,L);
  +total_control_points(L);
  +patrolling;
  +patroll_point(0);
  .print("Got control points");
  .register_service("emergency_support");  // SERVICIO NUEVO
  .register_service("combat_medic");       // SERVICIO NUEVO
  .print("Servicios médicos especializados registrados").

+flag (F): team(100) 
  <-
  .register_service("emergency_support");  // SERVICIO NUEVO
  .register_service("combat_medic");       // SERVICIO NUEVO
  .goto(F).

//SERVICIO: Curación de emergencia (NUEVO)
+emergency_heal_request(P, HealthLevel)[source(A)]
  <-
  .print("¡Petición de curación de emergencia de ", A, " con salud ", HealthLevel, "!");
  if(HealthLevel < 20){
    ?position(MyPos);
    .send(A, tell, priority_medic_coming(MyPos));
    .goto(P);
    +emergency_healing(A)
  }
  else{
    .goto(P);
    .cure
  }.

//Cuando recibe una petición de curación normal
+heal_me(P)[source(A)]
  <-
  .print("¡Petición de cura de ", A, "!");
  ?position(MyPos);
  .send(A, tell, medic_coming(MyPos));
  .goto(P);
  .cure.

+target_reached(T): patrolling & team(200) 
  <-
  .print("MEDPACK!");
  .cure;
  ?patroll_point(P);
  -+patroll_point(P+1);
  -target_reached(T).

+patroll_point(P): total_control_points(T) & P<T 
  <-
  ?control_points(C);
  .nth(P,C,A);
  .goto(A).

+patroll_point(P): total_control_points(T) & P==T
  <-
  -patroll_point(P);
  +patroll_point(0).

+flag_taken: team(100) 
  <-
  .print("In ASL, TEAM_ALLIED flag_taken");
  ?base(B);
  +returning;
  .goto(B);
  -exploring.

+heading(H): exploring
  <-
  .cure;
  .wait(2000);
  .turn(0.375).

+target_reached(T): team(100)
  <- 
  .print("target_reached");
  +exploring;
  .turn(0.375).

//COMPORTAMIENTO MEJORADO: Evitar fuego amigo
+enemies_in_fov(IDE,TypeE,AngE,DistanceE,HealthE,[Xe, Ye, Ze]): friends_in_fov(IDA,TypeA,AngA,DistanceA,HealthA,[Xa, Ya, Za]) & position([Xs, Ys, Zs])
  <-
  if(AngA == AngE & AngA > 0 & DistanceA < DistanceE){
    .print("Aliado en línea de fuego, rodeando enemigo");
    CirclePoint = .circle([Xs, Ys, Zs], [Xe, Ye, Ze], DistanceE);
    .goto(CirclePoint)
  }
  else{
    .print("Disparando al enemigo");
    .shoot(3, [Xe, Ye, Ze])
  }.

//COORDINACIÓN: Responder a órdenes del líder
+support_position(LeaderPos)[source(Leader)]
  <-
  .print("Recibida orden de apoyo médico del líder");
  +supporting_leader;
  .goto(LeaderPos).
