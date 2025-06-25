//SERVICIOS NUEVOS: Registro de servicios especializados
+flag (F): team(200) 
  <-
  .create_control_points(F,25,3,C);
  +control_points(C);
  .length(C,L);
  +total_control_points(L);
  +patrolling;
  +patroll_point(0);
  .print("Got control points").

+flag (F): team(100) 
  <-
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

+backup_medics(C)
  <-
  ?position(MyPos);
  .send(C, tell, cover_request(MyPos));
  .print("Solicitando cobertura a un soldado").

//Si encuentran enemigos, piden cobertura a un soldado y evitan fuego amigo
+enemies_in_fov(IDE,TypeE,AngE,DistanceE,HealthE,[Xe, Ye, Ze]): friends_in_fov(IDA,TypeA,AngA,DistanceA,HealthA,[Xa, Ya, Za]) & position([Xs, Ys, Zs])
  <-
  .get_service("backup_medics");
  if(AngA == AngE & AngA > 0 & DistanceA < DistanceE){
    .print("Aliado en línea de fuego, rodeando enemigo");
    CirclePoint = .circle([Xs, Ys, Zs], [Xe, Ye, Ze], DistanceE);
    .goto(CirclePoint)
  }
  else{
    .print("Disparando al enemigo");
    .look_at([Xe, Ye, Ze]);
    .shoot(3, [Xe, Ye, Ze])
  }.

+enemies_in_fov(IDE,TypeE,AngE,DistanceE,HealthE,[Xe, Ye, Ze]): not friends_in_fov(_,_,_,_,_,_) & position([Xs, Ys, Zs])
  <-
  .get_service("backup_medics");
  .print("Campo libre, disparando al enemigo");
  .look_at([Xe, Ye, Ze]);
  .shoot(3, [Xe, Ye, Ze]).

//COORDINACIÓN: Responder a órdenes del líder si no tiene la bandera
+support_position(LeaderPos)[source(Leader)]: not flag_taken
  <-
  .print("Recibida orden de apoyo táctico del líder");
  .goto(LeaderPos);
  .cure;
  ?flag(F);
  .goto(F).