% Ratatouille
%modelo mi base de conocimientos
viveEn(remy, gusteaus).
viveEn(emile, chezMilleBar).
viveEn(django, pizzeriaJeSuis).

trabajaEn(linguini, gusteaus).
trabajaEn(colette, gusteaus).
trabajaEn(horst, gusteaus).
trabajaEn(skinner, gusteaus).
trabajaEn(amelie, des2Moulins).

sabeCocinar(linguini, ratatouille, 3).
sabeCocinar(colette, ratatouille, 1).
sabeCocinar(skinner, ratatouille, 1).
sabeCocinar(horst, ratatouille, 1).
sabeCocinar(linguini, sopa, 5).
sabeCocinar(colette, salmonAsado, 9).
sabeCocinar(horst, ensaladaRusa, 8).

%Punto 1 
estaEnElMenu(Plato, Restaurante):-
    sabeCocinar(Chef,Plato,_),
    trabajaEn(Chef, Restaurante).

%Punto 2
cocinaBien(Persona, Plato):-
    sabeCocinar(Persona, Plato, Experiencia),
    Experiencia > 7.
cocinaBien(Persona, Plato):-
    %sabeCocinar(Persona, Plato, _), % tiene que saberlo cocinar para ver si lo hace bien o mal no? pero a su vez hace que no tenga ningun chef
    tieneTutorqueCocinaBien(Persona, Plato).
cocinaBien(remy, Plato):-
    sabeCocinar(_, Plato, _). %plato existente

tieneTutorqueCocinaBien(Persona, Plato):-
    esTutorDe(Tutor, Persona),
    cocinaBien(Tutor, Plato).

esTutorDe(Rata, linguini):- 
    trabajaEn(linguini, Restaurante),
    viveEn(Rata, Restaurante).

esTutorDe(amelie, skinner).

%Punto 3
esChefDe(Alguien,Resto):-
    trabajaEn(Alguien,Resto),
    cocinaBienTodosLosPlatosOSumaExperienciaDe20(Alguien,Resto).
    
cocinaBienTodosLosPlatosOSumaExperienciaDe20(Alguien, Resto):-
    estaEnElMenu(_,Resto),
    forall(estaEnElMenu(Plato,Resto), cocinaBien(Alguien, Plato)).
cocinaBienTodosLosPlatosOSumaExperienciaDe20(Alguien, _):-
    findall(Experiencia,sabeCocinar(Alguien,_,Experiencia),Experiencias),
    sum_list(Experiencias, TotalExperiencia),
    TotalExperiencia > 20.


%Punto 4
esEncargadoDe(Persona, Plato, Restaurante):-
    trabajaEn(Persona, Restaurante),
    estaEnElMenu(Plato, Restaurante),
    forall((trabajaEn(OtraPersona, Restaurante), OtraPersona \= Persona), tieneMasExprienciaPreparando(Persona, OtraPersona, Plato)).
%si no es otra persona y es la unica que trabaja ahi, es falsa la hipotesis y por lo tanto verdadera la proposicion
tieneMasExprienciaPreparando(Persona, OtraPersona, Plato):-
    sabeCocinar(Persona, Plato, Experiencia),
    sabeCocinar(OtraPersona, Plato, ExperienciaMenor),
    Experiencia > ExperienciaMenor.
/*
esEncargadoDe(Persona, Plato, Restaurante):-
    trabajaEn(Persona,Restaurante),
    sabeCocinar(Persona, Plato, Experiencia),
    forall((compaDeTrabajoQueCocina(OtraPersona,Restaurante,Plato), OtraPersona \= Persona), OtraExperiencia < Experiencia).

compaDeTrabajoQueCocina(Persona,Restaurante,Plato):-
    trabajaEn(OtraPersona,Restaurante),
    sabeCocinar(OtraPersona,Plato,OtraExperiencia).*/

%Punto 5
plato(ensaladaRusa, entrada([papa, zanahoria, arvejas, huevo, mayonesa])).
plato(bifeDeChorizo, principal(pure, 20)).
plato(frutillasConCrema, postre(265)).

esPlatoSaludable(Plato):-
    plato(Plato, Detalle),
    calcularCalorias(Detalle, Calorias),
    Calorias < 75.

calcularCalorias(entrada(Ingredientes), Calorias):-
    length(Ingredientes,Cantidad),
    Calorias is Cantidad * 15.
calcularCalorias(principal(Acompania,Minutos), Calorias):-
    caloriasGuarnicion(Acompania, CaloriasGuarnicion),
    Calorias is CaloriasGuarnicion + Minutos * 5.
calcularCalorias(postre(Calorias), Calorias).

caloriasGuarnicion(pure, 20).
caloriasGuarnicion(papasFritas, 50).


%Punto 6
hizoReseniaPositiva(Critico, Restaurante):-
    nohayRatas(Restaurante),
    cumpleCriterioDelCritico(Critico,Restaurante).

nohayRatas(Restaurante):-
    trabajaEn(_,Restaurante),
    not(viveEn(_,Restaurante)). %el vive en solo tenia ratas y donde vivian

cumpleCriterioDelCritico(antonEgo, Restaurante):-
    seaEspecialistaEn(Restaurante, ratatouille).
cumpleCriterioDelCritico(cormillot, Restaurante):-
    estaEnElMenu(_,Restaurante),
    forall((trabajaEn(Persona,Restaurante), sabeCocinar(Persona, Plato, _)), esPlatoSaludable(Plato)).
cumpleCriterioDelCritico(martiniano, Restaurante):-
    esChefDe(Chef,Restaruante),
    forall((trabajaEn(OtraPersona,Restaruante), Chef \= OtraPersona), not(esChefDe(OtraPersona,Restaurante))).

seaEspecialistaEn(Restaurante, Plato):-
    estaEnElMenu(Plato,Restaurante),
    forall(esChefDe(Persona, Restaurante), cocinaBien(Persona, Plato)).