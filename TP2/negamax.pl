	/*
	Ce programme met en oeuvre l'algorithme Minmax (avec convention
	negamax) et l'illustre sur le jeu du TicTacToe (morpion 3x3)
	*/
	
:- [tictactoe].


	/****************************************************
  	ALGORITHME MINMAX avec convention NEGAMAX : negamax/5
  	*****************************************************/

	/*
	negamax(+J, +Etat, +P, +Pmax, [?Coup, ?Val])

	SPECIFICATIONS :

	retourne pour un joueur J donne, devant jouer dans
	une situation donnee Etat, de profondeur donnee P,
	le meilleur couple [Coup, Valeur] apres une analyse
	pouvant aller jusqu'a la profondeur Pmax.

	Il y a 3 cas a decrire (donc 3 clauses pour negamax/5)
	
	1/ la profondeur maximale est atteinte : on ne peut pas
	developper cet Etat ; 
	il n'y a donc pas de coup possible a jouer (Coup = rien)
	et l'evaluation de Etat est faite par l'heuristique.

	2/ la profondeur maximale n'est pas  atteinte mais J ne
	peut pas jouer ; au TicTacToe un joueur ne peut pas jouer
	quand le tableau est complet (totalement instancie) ;
	il n'y a pas de coup a jouer (Coup = rien)
	et l'evaluation de Etat est faite par l'heuristique.

	3/ la profondeur maxi n'est pas atteinte et J peut encore
	jouer. Il faut evaluer le sous-arbre complet issu de Etat ; 

	- on determine d'abord la liste de tous les couples
	[Coup_possible, Situation_suivante] via le predicat
	 successeurs/3 (deja fourni, voir plus bas).

	- cette liste est passee a un predicat intermediaire :
	loop_negamax/5, charge d'appliquer negamax sur chaque
	Situation_suivante ; loop_negamax/5 retourne une liste de
	couples [Coup_possible, Valeur]

	- parmi cette liste, on garde le meilleur couple, c-a-d celui
	qui a la plus petite valeur (cf. predicat meilleur/2);
	soit [C1,V1] ce couple optimal. Le predicat meilleur/2
	effectue cette selection.

	- finalement le couple retourne par negamax est [Coup, V2]
	avec : V2 is -V1 (cf. convention negamax vue en cours).

A FAIRE : ECRIRE ici les clauses de negamax/5 (ecrire negamax)
.....................................
*/

negamax(J, Etat, P, Pmax, [Coup, Val]):-
	P==Pmax,
	Coup = [],
	heuristique(J,Etat,Val), !.

negamax(J, Etat, _P, _Pmax, [Coup, Val]):-
	ground(Etat),
	write(Etat),
	nl,
	Coup = [],
	heuristique(J,Etat,Val), !.

negamax(J, Etat, P, Pmax, [Coup, Val]):-
	successeurs(J,Etat,Succ),
	loop_negamax(J,P,Pmax,Succ,L), % L = liste de couples renvoyée par loop_negamax
	meilleur(L,[Coup,V]),
	Val is -V.

/*****************************
TESTS DU PREDICAT NEGAMAX
*****************************/
%si on teste avec la situation initiale (grille vide), on ne peut pas 
%arriver jusqu'à la fin de la partie car on a un stack limit. On a donc
%testé avec des grilles déjà pré remplies

%on teste le prédicat negamax avec une situation perdante
%On obtient bien une heuristique de -10000
test_negamax_perdant([B, V]) :-
	M=[[x,x,_],[o,o,o],[o,x,o]], 
	joueur_initial(J),
	negamax(J, M, 1, 8,[B, V]).   

%on teste le prédicat negamax avec une situation ganante
%On obtient bien une heuristique de 10000
test_negamax_gagnant([B, V]) :-
	M=[[x,x,_],[o,x,o],[o,x,o]], 
	joueur_initial(J),
	negamax(J, M, 1, 8,[B, V]).   

%on teste le prédicat negamax avec une situation ni gagnante ni perdante
%On obtient bien une heuristique de 0
test_negamax_egalite([B, V]) :-
	M=[[x,o,_],[o,x,o],[o,x,o]], 
	joueur_initial(J),
	negamax(J, M, 1, 8,[B, V]).



    /*******************************************
     DEVELOPPEMENT D'UNE SITUATION NON TERMINALE
     successeurs/3 
     *******************************************/

	 /*
   	 successeurs(+J,+Etat, ?Succ)

   	 retourne la liste des couples [Coup, Etat_Suivant]
 	 pour un joueur donne dans une situation donnee 
	 */

successeurs(J,Etat,Succ) :-
	copy_term(Etat, Etat_Suiv),
	findall([Coup,Etat_Suiv],
		    successeur(J,Etat_Suiv,Coup),
		    Succ).

	/*************************************
         Boucle permettant d'appliquer negamax 
         a chaque situation suivante :
	*************************************/

	/*
	loop_negamax(+J,+P,+Pmax,+Successeurs,?Liste_Couples)
	retourne la liste des couples [Coup, Valeur_Situation_Suivante]
	a partir de la liste des couples [Coup, Situation_Suivante]
	*/

loop_negamax(_,_, _  ,[],                []).
loop_negamax(J,P,Pmax,[[Coup,Suiv]|Succ],[[Coup,Vsuiv]|Reste_Couples]) :-
	loop_negamax(J,P,Pmax,Succ,Reste_Couples),% Recursivité de loop negamax
	adversaire(J,A),                          % On va appeler negamax pour le point de vue de l'adversaire car on alterne a chaque coup
	Pnew is P+1,                              % On va appeler negamax mais avec une profondeur plus avancé (+1)
	negamax(A,Suiv,Pnew,Pmax, [_,Vsuiv]).	  /*On appelle negamax pour tous les couples (Coup, valeur_situation)
											  % On appelle donc negamax du point de vue de l'adversaire A
											  % On lui indique le coup suivant
											  % La profondeur actuelle a deja été incrementée
											  % la profondeur max ne change pas
											  % et on recupere les informations [_,Vsuiv] : Vsuiv permet de donner la situation après 
											  que l'adversaire ait joué, ce qui correspondra a notre situation actuelle pour le prochain negamax
											  '_' correspondait au coup joué pour l'adversaire mais nous ne recuperons pas la valeur car information non utile. 
											  */


	/*

FAIT : commenter (fin de ligne) chaque litteral (une relation logique (qui est vrai ou fausse)) 
	de la 2eme clause de loop_negamax/5, en particulier la forme du terme [_,Vsuiv] dans le dernier
	litteral ?
	*/

	/*********************************
	 Selection du couple qui a la plus
	 petite valeur V 
	 *********************************/

	/*
	meilleur(+Liste_de_Couples, ?Meilleur_Couple)

	SPECIFICATIONS :
	On suppose que chaque element de la liste est du type [C,V]
	-  Si la liste a un seul élèment il est le meilleur
	- le meilleur dans une liste [X|L] avec L \= [], est obtenu en comparant
	  X et Y,le meilleur couple de L 
	  Entre X et Y on garde celui qui a la petite valeur de V.

FAIT : ECRIRE ici les clauses de meilleur/2
	*/
meilleur([X|[]], X).

meilleur([[C,V]|L],M) :-
	meilleur(L,[_,Vy]),
	V < Vy, 
	M = [C,V].

meilleur([[_C,V]|L],M) :-
	meilleur(L,[Cy,Vy]),
	V >= Vy, 
	M = [Cy,Vy].


/*****************************
TESTS DU PREDICAT MEILLEUR
*****************************/
%cas 1 : liste de plusieurs couples, trouve le couple avec
%la meilleure valeur de V càd [1,4]
%cas 2 : liste avec un seul couple -> renvoie ce couple
test_meilleur(M1, M2) :-
	meilleur([[1,7], [1,4], [1,8]], M1),
	meilleur([[1,7]], M2).


	/******************
  	PROGRAMME PRINCIPAL
  	*******************/

main(B,V, Pmax) :-
	situation_initiale(M), 
	joueur_initial(J),
	negamax(J, M, 1, Pmax,[B, V]).   


	/*
A FAIRE :
	Compl�ter puis tester le programme principal pour plusieurs valeurs de la profondeur maximale.
	Pmax = 1, 2, 3, 4 ...
	Commentez les r�sultats obtenus.
	*/
/*
?- main(B, V, 1).
B = [],
V = 0.

?- main(B, V, 2).
B = [2, 2],
V = 4 .

?- main(B, V, 3).
B = [2, 2],
V = 1 .

?- main(B, V, 4).
B = [2, 2],
V = 3 .

?- main(B, V, 5).
B = [2, 2],
V = 1 .

?- main(B, V, 6).
B = [2, 2],
V = 3 .

?- main(B, V, 7).
B = [2, 2],
V = 1 .

?- main(B, V, 8).
B = [2, 2],
V = 2 .

?- main(B, V, 9).
B = [3, 3],
V = 1 .



Quand on augmente la pronfondeur, on augmente la précision
de la recherche. B ne change pas mais V oui.*/