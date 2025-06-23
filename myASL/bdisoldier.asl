// Inicialización de variables
+myBackups([]).
+myMedics([]).
+myFieldops([]).

//TEAM_ALLIED - Establecer líder y coordinación
+flag(F): team(100)
  <-
  .get_service("team_leader");
  .wait(1000);
  if(team_leader(L)){
    .print("Líder encontrado: ", L);
    +following_leader(L)
  }
  else{
    .register_service("team_leader");
    .register_service("scout");
    +i_am_leader;
    .print("Soy el líder del equipo")
  };
  .goto(F).

//Coordinación del líder
+i_am_leader: team(100)
  <-
  .get_backups;
  .get_medics;
  .get_fieldops;
  .wait(2000);
  ?position(MyPos);
  if(myBackups(B) & B \== []){
    .send(B, tell, follow_formation(MyPos))
  };
  if(myMedics(M) & M \== []){
    .send(M, tell, support_position(MyPos))
  };
  if(myFieldops(F) & F \== []){
    .send(F, tell, tactical_support(MyPos))
  }.

//Plan para seguir formación del líder
+follow_formation(LeaderPos)[source(Leader)]
  <-
  .print("Recibida orden de formación del líder");
  +in_formation;
  .goto(LeaderPos).

//TEAM_AXIS - Coordinación defensiva
+flag (F): team(200)
  <-
  .get_service("defense_coordinator");
  .wait(1000);
  if(defense_coordinator(C)){
    .print("Coordinador defensivo encontrado: ", C)
  }
  else {
      .register_service("defense_coordinator");
      .wait(500);
      .get_service("defense_coordinator");
      if(defense_coordinator(C2) & C2 == me) {
          .register_service("scout");
          +i_am_coordinator;
          .print("Soy el coordinador defensivo")
      }
      else {
          .print("C2 es: ", C2);
          .print("me es: ", me);
          .print("Otro agente se registró como coordinador: ", C2)
      }
  };
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
    .goto(FlankPos);
    +flanking_enemy([Xe, Ye, Ze])
  }
  else {
    if(abs(AngA - AngE) < 0.3 & DistanceA < DistanceE){
      .print("Riesgo de fuego amigo, rodeando enemigo");
      CirclePoint = .circle([Xs, Ys, Zs], [Xe, Ye, Ze], DistanceE);
      .print("Mi posición: ", [Xs, Ys, Zs], "Centro: ", [Xe, Ye, Ze], "Siguiente punto: ", CirclePoint);
      .goto(CirclePoint)
    }
    else {
      .print("Disparando al enemigo en posición segura");
      .shoot(3, [Xe, Ye, Ze])
    }
  }.

+enemies_in_fov(IDE,TypeE,AngE,DistanceE,HealthE,[Xe, Ye, Ze]): not friends_in_fov(_,_,_,_,_,_) & position([Xs, Ys, Zs])
  <-
  .print("Campo libre, disparando al enemigo");
  .shoot(3, [Xe, Ye, Ze]).

//GESTIÓN DE RECURSOS: Petición inteligente de curación
+threshold_health(30): enemies_in_fov(_,_,_,_,_,_)
  <-
  .print("Salud baja en combate, buscando cobertura médica");
  ?position(P);
  .get_service("emergency_support");
  .wait(500);
  if(emergency_support(E_list) & E_list \== []){
    .send(E_list, tell, emergency_heal_request(P, 30))
  }
  else{
    .get_medics;
    if(myMedics(M_list) & M_list \== []){
      .send(M_list, tell, heal_me(P))
    }
  }.

+threshold_health(30): not enemies_in_fov(_,_,_,_,_,_)
  <-
  .get_medics;
  ?position(P);
  if(myMedics(M_list) & M_list \== []){
    .send(M_list, tell, heal_me(P))
  }.

//SERVICIO: Responder a peticiones de scout
+scout_request(Area)[source(A)]
  <-
  .print("Misión de reconocimiento en área ", Area, " solicitada por ", A);
  +reconnaissance_mode;
  .goto(Area);
  .wait(3000);
  ?position(MyPos);
  .send(A, tell, scout_report(Area, MyPos)).
