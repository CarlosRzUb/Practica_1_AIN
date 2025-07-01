// Inicializacion de variables
+myBackups([]).
+myMedics([]).
+myFieldops([]).

//TEAM_ALLIED - Establecer lider y coordinacion
+flag(F): team(100)
  <-
  .register_service("follow_leader");
  .register_service("backup_medics");
  .goto(F).

//Plan para seguir formacion del lider
+follow_leader(LeaderPos)[source(Leader)]: not returning
  <-
  .print("Recibida orden de formacion del lider");
  .goto(LeaderPos);
  .wait(4000);
  ?flag(F);
  .goto(F);
  -follow_leader(LeaderPos).

//TEAM_AXIS - Coordinacion defensiva
+flag (F): team(200)
  <-
  .create_control_points(F,25,3,C);
  +control_points(C);
  .length(C,L);
  +total_control_points(L);
  +patrolling;
  +patroll_point(0);
  .print("Got control points").

+target_reached(T): patrolling & team(200)
  <-
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

+flag_taken: team(100)
  <-
  .print("In ASL, TEAM_ALLIED flag_taken");
  ?base(B);
  +returning;
  .goto(B);
  -exploring.

+heading(H): returning
  <-
  .print("Volviendo a la base").

+heading(H): exploring
  <-
  .wait(2000);
  .turn(0.375).

+target_reached(T): team(100) & not returning
  <-
  .print("target_reached");
  +exploring;
  .turn(0.375).

+enemies_in_fov(_,_,_,_,_,_): returning
  <-
  ?base(B);
  .print("Volviendo a la base");
  .goto(B).

//COMPORTAMIENTO MEJORADO: Evitar fuego amigo con flanqueo
+enemies_in_fov(IDE,TypeE,AngE,DistanceE,HealthE,[Xe, Ye, Ze]): friends_in_fov(IDA,TypeA,AngA,DistanceA,HealthA,[Xa, Ya, Za]) & position([Xs, Ys, Zs]) & not returning
  <-
  .safe_distance_check([Xs, Ys, Zs], [Xa, Ya, Za], 10, SafeDistance);
  if(AngA == AngE & AngA > 0 & DistanceA < DistanceE & SafeDistance == false){
    .print("Aliado en linea de fuego, usando flanqueo tactico");
    .calculate_flanking_position([Xs, Ys, Zs], [Xe, Ye, Ze], 20, FlankPos);
    .goto(FlankPos)
  }
  else {
    AngDiff = AngA - AngE;
    .abs(AngDiff, Ang);
    if(Ang < 0.30 & DistanceA < DistanceE){
      .print("Riesgo de fuego amigo, rodeando enemigo");
      .circle([Xs, Ys, Zs], [Xe, Ye, Ze], DistanceE, CirclePoint);
      .print("Mi posicion: ", [Xs, Ys, Zs], "Centro: ", [Xe, Ye, Ze], "Siguiente punto: ", CirclePoint);
      .goto(CirclePoint)
    }
    else {
      .print("Disparando al enemigo en posicion segura");
      .look_at([Xe, Ye, Ze]);
      .shoot(4, [Xe, Ye, Ze])
    }
  }.

+enemies_in_fov(IDE,TypeE,AngE,DistanceE,HealthE,[Xe, Ye, Ze]): not friends_in_fov(_,_,_,_,_,_) & position([Xs, Ys, Zs]) & not returning
  <-
  .print("Campo libre, disparando al enemigo");
  .look_at([Xe, Ye, Ze]);
  .shoot(4, [Xe, Ye, Ze]).

+threshold_health(30): not enemies_in_fov(_,_,_,_,_,_)
  <-
  .get_medics;
  ?position(P);
  if(myMedics(M_list) & M_list \== []){
    .print("Necesito curacion!");
    .send(M_list, tell, heal_me(P))
  }.

//SERVICIO: Responder a peticiones de cobertura si no tiene la bandera
+cover_request(Area)[source(A)]: not returning
  <-
  .print("Mision de cobertura en area ", Area, " solicitada por ", A);
  .goto(Area);
  .wait(4000);
  ?flag(F);
  .goto(F);
  -cover_request(Area).
