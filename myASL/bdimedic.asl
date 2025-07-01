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

+flag_taken: team(100) 
  <-
  -exploring;
  .print("In ASL, TEAM_ALLIED flag_taken");
  ?base(B);
  .goto(B);
  +returning.


//Cuando recibe una peticion de curacion normal
+heal_me(P)[source(A)]
  <-
  .print("¡Peticion de cura de ", A, "!");
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

+target_reached(T): returning & team(100)
  <-
  ?base(B);
  .print("Quiero volver a la base");
  .goto(B);
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

+heading(H): exploring
  <-
  .cure;
  .wait(2000);
  .turn(0.375).

+target_reached(T): team(100) & not returning
  <- 
  .print("target_reached");
  +exploring;
  .turn(0.375).

+heading(H): returning
  <-
  .print("Volviendo a la base").

//Al ver a un enemigo, piden cobertura a soldados y esperan 10 segundos antes de poder pedirlo de nuevo
+backup_medics(C): not returning
  <-
  ?position(MyPos);
  .send(C, tell, cover_request(MyPos));
  .print("Solicitando cobertura a un soldado");
  .wait(10000);
  -backup_medics(C).

//Si encuentran enemigos, piden cobertura a un soldado y evitan fuego amigo (equipo aliado)
+enemies_in_fov(IDE,TypeE,AngE,DistanceE,HealthE,[Xe, Ye, Ze]): friends_in_fov(IDA,TypeA,AngA,DistanceA,HealthA,[Xa, Ya, Za]) & position([Xs, Ys, Zs]) & team(100) & not returning
  <-
  .get_service("backup_medics");
  if(AngA == AngE & AngA > 0 & DistanceA < DistanceE){
    .print("Aliado en linea de fuego, rodeando enemigo");
    .circle([Xs, Ys, Zs], [Xe, Ye, Ze], DistanceE, CirclePoint);
    .goto(CirclePoint)
  }
  else{
    .print("Disparando al enemigo");
    .look_at([Xe, Ye, Ze]);
    .shoot(4, [Xe, Ye, Ze])
  }.

//Si encuentran enemigos, evitan fuego amigo (equipo eje)
+enemies_in_fov(IDE,TypeE,AngE,DistanceE,HealthE,[Xe, Ye, Ze]): friends_in_fov(IDA,TypeA,AngA,DistanceA,HealthA,[Xa, Ya, Za]) & position([Xs, Ys, Zs]) & team(200)
  <-
  if(AngA == AngE & AngA > 0 & DistanceA < DistanceE){
    .print("Aliado en linea de fuego, rodeando enemigo");
    CirclePoint = .circle([Xs, Ys, Zs], [Xe, Ye, Ze], DistanceE);
    .goto(CirclePoint)
  }
  else{
    .print("Disparando al enemigo");
    .look_at([Xe, Ye, Ze]);
    .shoot(4, [Xe, Ye, Ze])
  }.

+enemies_in_fov(_,_,_,_,_,_): returning
  <-
  ?base(B);
  .print("Volviendo a la base");
  .goto(B).


+enemies_in_fov(IDE,TypeE,AngE,DistanceE,HealthE,[Xe, Ye, Ze]): not friends_in_fov(_,_,_,_,_,_) & position([Xs, Ys, Zs]) & team(100) & not returning
  <-
  .get_service("backup_medics");
  .print("Campo libre, disparando al enemigo");
  .look_at([Xe, Ye, Ze]);
  .shoot(4, [Xe, Ye, Ze]).

+enemies_in_fov(IDE,TypeE,AngE,DistanceE,HealthE,[Xe, Ye, Ze]): not friends_in_fov(_,_,_,_,_,_) & position([Xs, Ys, Zs]) & team(200)
  <-
  .print("Campo libre, disparando al enemigo");
  .look_at([Xe, Ye, Ze]);
  .shoot(4, [Xe, Ye, Ze]).

//COORDINACIoN: Responder a ordenes del lider si no tiene la bandera
+support_position(LeaderPos)[source(Leader)]: not returning
  <-
  .print("Recibida orden de apoyo tactico del lider");
  .goto(LeaderPos);
  .cure;
  .wait(4000);
  ?flag(F);
  .goto(F);
  -support_position(LeaderPos).