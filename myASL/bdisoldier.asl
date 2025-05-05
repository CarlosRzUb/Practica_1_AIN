//TEAM_AXIS

+flag (F): team(200)
  <-
  .create_control_points(F,25,3,C);
  +control_points(C);
  .length(C,L);
  +total_control_points(L);
  
  // Dividir agentes en dos grupos (5 y 5)
  ?my_id(ID);
  .mod(ID, 2, Remainder);
  if (Remainder == 0) {
    // Grupo 1: Ir a la bandera y pararse
    .goto(F);
    +axis_group1;
  } else {
    // Grupo 2: Patrullar alrededor de la bandera
    +patrolling;
    +patroll_point(0);
    +axis_group2;
  }
  .print("Axis agents divided into two groups").

+target_reached(T): axis_group1
  <-
  .print("Axis group1 reached flag position");
  // Se quedan parados en la bandera
  -axis_group1.

+target_reached(T): patrolling & axis_group2
  <-
  ?patroll_point(P);
  -+patroll_point(P+1);
  -target_reached(T).

+patroll_point(P): total_control_points(T) & P<T & axis_group2
  <-
  ?control_points(C);
  .nth(P,C,A);
  .goto(A).

+patroll_point(P): total_control_points(T) & P==T & axis_group2
  <-
  -patroll_point(P);
  +patroll_point(0).


//TEAM_ALLIED

+flag (F): team(100)
  <-
  // Dividir agentes en dos grupos (5 y 5)
  ?my_id(ID);
  .mod(ID, 2, Remainder);
  if (Remainder == 0) {
    // Grupo 1: Ir a posición fija y pararse
    .goto([50, 0, 50]);  // Posición de ejemplo
    +allied_group1;
  } else {
    // Grupo 2: Ir a por la bandera
    .goto(F);
    +allied_group2;
  }
  .print("Allied agents divided into two groups").

+target_reached(T): allied_group1
  <-
  .print("Allied group1 reached fixed position");
  // Se quedan parados en la posición
  -allied_group1.

+flag_taken: allied_group2
  <-
  .print("In ASL, TEAM_ALLIED flag_taken");
  ?base(B);
  +returning;
  .goto(B);
  -exploring.

+target_reached(T): returning & allied_group2
  <-
  .print("Allied group2 returned to base");
  -returning;
  +exploring.

+enemies_in_fov(ID,Type,Angle,Distance,Health,Position)
  <-
  .shoot(3,Position).