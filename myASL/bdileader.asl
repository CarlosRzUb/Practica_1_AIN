// Inicialización de variables
+myBackups([]).
+myMedics([]).
+myFieldops([]).

//TEAM_ALLIED - Establecer líder y coordinación
+flag(F): team(100)
  <-
  .wait(500);
  .get_service("follow_leader");
  .print("Soy el líder del equipo");
  .goto(F).


//Coordinación del líder
+follow_leader(C): team(100)
  <-
  .get_backups;
  .get_medics;
  .get_fieldops;
  .wait(20000);
  ?position(MyPos);
  .send(C, tell, follow_leader(MyPos));
  if(myMedics(M) & M \== []){
    .send(M, tell, support_position(MyPos))
  };
  if(myFieldops(F) & F \== []){
    .send(F, tell, tactical_support(MyPos))
  };
  +follow_leader(C).

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
  .wait(2000);
  .turn(0.375).

+heading(H): returning
  <-
  .print("returning").

+target_reached(T): team(100)
  <-
  .print("target_reached");
  +exploring;
  .turn(0.375).

//COMPORTAMIENTO MEJORADO: Evitar fuego amigo con flanqueo
+enemies_in_fov(IDE,TypeE,AngE,DistanceE,HealthE,[Xe, Ye, Ze]): friends_in_fov(IDA,TypeA,AngA,DistanceA,HealthA,[Xa, Ya, Za]) & position([Xs, Ys, Zs])
  <-
  .safe_distance_check([Xs, Ys, Zs], [Xa, Ya, Za], 10, SafeDistance);
  if(AngA == AngE & AngA > 0 & DistanceA < DistanceE & SafeDistance == false){
    .print("Aliado en línea de fuego, usando flanqueo táctico");
    FlankPos = .calculate_flanking_position([Xs, Ys, Zs], [Xe, Ye, Ze], 20);
    .goto(FlankPos)
  }
  else {
    AngDiff = AngA - AngE;
    Ang = .abs(AngDiff);
    if(Ang < 0.3 & DistanceA < DistanceE){
      .print("Riesgo de fuego amigo, rodeando enemigo");
      CirclePoint = .circle([Xs, Ys, Zs], [Xe, Ye, Ze], DistanceE);
      .print("Mi posición: ", [Xs, Ys, Zs], "Centro: ", [Xe, Ye, Ze], "Siguiente punto: ", CirclePoint);
      .goto(CirclePoint)
    }
    else {
      .print("Disparando al enemigo en posición segura");
      .look_at([Xe, Ye, Ze]);
      .shoot(3, [Xe, Ye, Ze])
    }
  }.

+enemies_in_fov(IDE,TypeE,AngE,DistanceE,HealthE,[Xe, Ye, Ze]): not friends_in_fov(_,_,_,_,_,_) & position([Xs, Ys, Zs])
  <-
  .print("Campo libre, disparando al enemigo");
  .look_at([Xe, Ye, Ze]);
  .shoot(3, [Xe, Ye, Ze]).

+threshold_health(30)
  <-
  .get_medics;
  ?position(P);
  if(myMedics(M_list) & M_list \== []){
    .print("Necesito curación!");
    .send(M_list, tell, heal_me(P))
  }.
