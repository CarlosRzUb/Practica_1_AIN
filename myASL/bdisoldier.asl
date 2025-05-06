// TEAM_AXIS (DEFENSA)
+flag(F): team(200)
<-
    .register_service("axis");
    .register_service("backup");
    .register_service("defensor");
    .register_service("flanker");
    
    ?my_id(ID);
    if (ID < 2) {
        // Grupo 1: Flanqueadores tácticos
        +flanker_axis;
        .add_internal_action("tactical_flank", "myactions.TacticalFlanker._tactical_flank");
        .tactical_flank(F);
        .print("Soy flanqueador defensivo");
    } if (ID < 5) {
        // Grupo 2: Vigías estáticos
        +vigia;
        .look_at(F);
        
        // Extraer componentes de posición (forma compatible)
        ?position(F, X, Y, Z);
        NewZ = Z + 25;
        .goto([X, Y, NewZ]);
        .print("Vigía en posición con cobertura amplia");
    } else {
        // Grupo 3: Patrullas dinámicas
        .create_control_points(F, 35, 6, C);
        +control_points(C);
        +patrolling;
        +patroll_point(0);
        .print("Patrulla defensiva activada");
    }.

// TEAM_ALLIED (ATAQUE)
+flag(F): team(100)
<-
    .register_service("allied");
    .register_service("backup");
    .register_service("asalto");
    .register_service("flanker");
    
    ?my_id(ID);
    if (ID < 3) {
        // Grupo 1: Flanqueadores ofensivos
        +flanker_allied;
        .add_internal_action("tactical_flank", "myactions.TacticalFlanker._tactical_flank");
        .tactical_flank(F);
        .print("Iniciando flanqueo ofensivo");
    } if (ID < 6) {
        // Grupo 2: Exploradores
        +explorador;
        .look_at(F);
        .goto([15, 0, 15]);  // Coordenadas como parámetros separados
        .print("Explorando flanco izquierdo");
    } else {
        // Grupo 3: Ataque directo
        .add_internal_action("ruta_segura", "myactions.calcular_ruta_segura");
        .ruta_segura(F);
        +atacante;
        .print("Atacando frontalmente");
    }.

// COMPORTAMIENTOS COMUNES
+enemies_in_fov(ID, _, _, Dist, _, Pos): 
    Dist < 25 & not friends_in_fov(ID, _, _, _, _, _)
<-
    if (flanker_allied | flanker_axis) {
        .tactical_flank(Pos);
        .wait(1000);
    };
    .shoot(3, Pos).  // Asegúrate de que Pos esté ligado

+friends_in_fov(_, _, _, Dist, Health, Pos): 
    Health < 50 & Dist < 20
<-
    if (not helping) {
        +helping;
        .get_medics;
        .send(myMedics, achieve, ayuda_medica(Pos, urgent));
    }.

+target_reached(T): flanker_allied | flanker_axis
<-
    .print("Posición de flanqueo alcanzada");
    .look_at(T);
    -flanker_allied;
    -flanker_axis.