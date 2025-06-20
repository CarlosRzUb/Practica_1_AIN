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
  .register_service("ammo_specialist");    // SERVICIO NUEVO
  .register_service("tactical_support");  // SERVICIO NUEVO
  .print("Servicios de apoyo táctico registrados").

+flag (F): team(100) 
  <-
  .register_service("ammo_specialist");    // SERVICIO NUEVO
  .register_service("tactical_support");  // SERVICIO NUEVO
  .goto(F).

//SERVICIO: Suministro de munición crítica (NUEVO)
+critical_ammo_request(P, AmmoLevel)[source(A)]
  <-
  .print("¡Petición crítica de munición de ", A, " con munición ", AmmoLevel, "!");
  if(AmmoLevel < 10){
    ?position(MyPos);
    .send(A, tell, priority_ammo_coming(MyPos));
    .goto(P);
    +priority_resupply(A)
  }
  else{
    .goto(P);
    .reload
  }.

+target_reached(T): patrolling & team(200) 
  <-
  .print("AMMOPACK!");
  .reload;
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
  .reload;
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
    .circle([Xs, Ys, Zs], [Xe, Ye, Ze], DistanceE, CirclePoint);
    .goto(CirclePoint)
  }
  else{
    .print("Disparando al enemigo");
    .shoot(3, [Xe, Ye, Ze])
  }.

//COORDINACIÓN: Responder a órdenes del líder
+tactical_support(LeaderPos)[source(Leader)]
  <-
  .print("Recibida orden de apoyo táctico del líder");
  +supporting_leader;
  .goto(LeaderPos);
  .reload.
