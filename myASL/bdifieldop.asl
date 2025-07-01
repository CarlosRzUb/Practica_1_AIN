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

+heading(H): returning
  <-
  .print("Volviendo a la base").

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

+target_reached(T): team(100) & not returning
  <- 
  .print("target_reached");
  +exploring;
  .turn(0.375).

+target_reached(T): returning & team(100)
  <-
  ?base(B);
  .print("Quiero volver a la base");
  .goto(B);
  -target_reached(T).

+enemies_in_fov(_,_,_,_,_,_): returning
  <-
  ?base(B);
  .print("Volviendo a la base");
  .goto(B).

//COMPORTAMIENTO MEJORADO: Evitar fuego amigo
+enemies_in_fov(IDE,TypeE,AngE,DistanceE,HealthE,[Xe, Ye, Ze]): friends_in_fov(IDA,TypeA,AngA,DistanceA,HealthA,[Xa, Ya, Za]) & position([Xs, Ys, Zs]) & not returning
  <-
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

+enemies_in_fov(IDE,TypeE,AngE,DistanceE,HealthE,[Xe, Ye, Ze]): not friends_in_fov(_,_,_,_,_,_) & position([Xs, Ys, Zs]) & not returning
  <-
  .print("Campo libre, disparando al enemigo");
  .look_at([Xe, Ye, Ze]);
  .shoot(4, [Xe, Ye, Ze]).

//COORDINACIoN: Responder a ordenes del lider si no tiene la bandera
+tactical_support(LeaderPos)[source(Leader)]: not returning
  <-
  .print("Recibida orden de apoyo tactico del lider");
  .goto(LeaderPos);
  .reload;
  .wait(4000);
  ?flag(F);
  .goto(F);
  -tactical_support(LeaderPos).
