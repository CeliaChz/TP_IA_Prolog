/*********************************
	DESCRIPTION DU JEU DU TIC-TAC-TOE
	*********************************/

	/*
	Une situation est decrite par une matrice 3x3.
	Chaque case est soit un emplacement libre (Variable LIBRE), soit contient le symbole d'un des 2 joueurs (o ou x)

	Contrairement a la convention du tp precedent, pour modeliser une case libre
	dans une matrice on n'utilise pas une constante speciale (ex : nil, 'vide', 'libre','inoccupee' ...);
	On utilise plut�t un identificateur de variable, qui n'est pas unifiee (ex : X, A, ... ou _) .
	La situation initiale est une "matrice" 3x3 (liste de 3 listes de 3 termes chacune)
	o� chaque terme est une variable libre.	
	Chaque coup d'un des 2 joureurs consiste a donner une valeur (symbole x ou o) a une case libre de la grille
	et non a deplacer des symboles deja presents sur la grille.		
	
	Pour placer un symbole dans une grille S1, il suffit d'unifier une des variables encore libres de la matrice S1,
	soit en ecrivant directement Case=o ou Case=x, ou bien en accedant a cette case avec les predicats member, nth1, ...
	La grille S1 a change d'etat, mais on n'a pas besoin de 2 arguments representant la grille avant et apres le coup,
	un seul suffit.
	Ainsi si on joue un coup en S, S perd une variable libre, mais peut continuer a s'appeler S (on n'a pas besoin de la designer
	par un nouvel identificateur).
	*/

situation_initiale([ [_,_,_],
                     [_,_,_],
                     [_,_,_] ]).

situation_initiale_test([ [o,x,_],
                     [x,o,x],
                     [_,_,o] ]).

	% Convention (arbitraire) : c'est x qui commence

joueur_initial(x).


	% Definition de la relation adversaire/2

adversaire(x,o).
adversaire(o,x).


	/****************************************************
	 DEFINIR ICI a l'aide du predicat ground/1 comment
	 reconnaitre une situation terminale dans laquelle il
	 n'y a aucun emplacement libre : aucun joueur ne peut
	 continuer a jouer (quel qu'il soit).
	 ****************************************************/

% situation_terminale(_Joueur, Situation) :-   ? ? ? ? ?

	/***************************
	DEFINITIONS D'UN ALIGNEMENT
	***************************/

alignement(L, Matrix) :- ligne(    L,Matrix).
alignement(C, Matrix) :- colonne(  C,Matrix).
alignement(D, Matrix) :- diagonale(D,Matrix).

	/********************************************
	 DEFINIR ICI chaque type d'alignement maximal 
 	 existant dans une matrice carree NxN.
	 ********************************************/

ligne(L, M) :- nth1(_, M, L).

 
colonne(C, M) :- colonne_aux(C, M, _).

colonne_aux([], [], _).

colonne_aux([HC|RC], [HM|RM], N) :-
    nth1(N, HM, HC), 
    colonne_aux(RC, RM, N).


	/* Definition de la relation liant une diagonale D a la matrice M dans laquelle elle se trouve.
		il y en a 2 sortes de diagonales dans une matrice carree(https://fr.wikipedia.org/wiki/Diagonale) :
		- la premiere diagonale (principale)  : (A I)
		- la seconde diagonale                : (Z R)
		A . . . . . . . Z
		. \ . . . . . / .
		. . \ . . . / . .
		. . . \ . / . . .
		. . . . X . . .
		. . . / . \ . . . 
		. . / . . . \ . .
		. / . . . . . \ .
		R . . . . . . . I
	*/
		
diagonale(D, M) :- 
	premiere_diag(1,D,M).

diagonale(D, M) :- 
    length(M, N), 
    seconde_diag(N, D, M).

premiere_diag(_,[],[]).
premiere_diag(K,[E|D],[Ligne|M]) :-
	nth1(K,Ligne,E),
	K1 is K+1,
	premiere_diag(K1,D,M).

seconde_diag(_,[],[]).
seconde_diag(K,[E|D],[Ligne|M]) :- 
    nth1(K,Ligne,E),
	K1 is K-1,
	seconde_diag(K1,D,M).


	/*****************************
	TESTS DES PREDICATS LIGNE, 
	COLONNE ET DIAGONALE
	*****************************/

test_ligne(L) :-
	situation_initiale_test(M), 
	ligne(L, M).
/* On doit obtenir chacune des lignes de la matrice test :
[ [o,x,_],
  [x,o,x],
  [_,_,o] ]

C'est bien ce qu'on a :
L = [o, x, _3000] ;
L = [x, o, x] ;
L = [_3036, _3042, o].*/


test_colonne(C) :-
	situation_initiale_test(M), 
	colonne(C, M).
/* On doit obtenir chacune des colonnes de la matrice test :
[ [o,x,_],
  [x,o,x],
  [_,_,o] ]

C'est bien ce qu'on a :
C = [o, x, _3048] ;
C = [x, o, _3054] ;
C = [_3012, x, o].*/


test_diagonale(D) :-
	situation_initiale_test(M), 
	diagonale(D, M).
/* On doit obtenir chacune des diagonales de la matrice test :
[ [o,x,_],
  [x,o,x],
  [_,_,o] ]

C'est bien ce qu'on a :
D = [o, o, o] ;
D = [_3632, o, _3668] ;*/


	/*****************************
	 DEFINITION D'UN ALIGNEMENT 
	 POSSIBLE POUR UN JOUEUR DONNE
	 *****************************/

possible([X|L], J) :- 
    unifiable(X,J), 
    possible(L,J).

possible([],_).

	/* Attention 
	il faut juste verifier le caractere unifiable
	de chaque emplacement de la liste, mais il ne
	faut pas realiser l'unification.
	*/
 
unifiable(X,J) :-
    ground(X),
	X == J; 
    var(X).

	/**********************************
	 DEFINITION D'UN ALIGNEMENT GAGNANT
	 OU PERDANT POUR UN JOUEUR DONNE J
	 **********************************/
	/*
	Un alignement gagnant pour J est un alignement
possible pour J qui n'a aucun element encore libre.
	*/
	
	/*
	Remarque : le predicat ground(X) permet de verifier qu'un terme
	prolog quelconque ne contient aucune partie variable (libre).
	exemples :
		?- ground(Var).
		no
		?- ground([1,2]).
		yes
		?- ground(toto(nil)).
		yes
		?- ground( [1, toto(nil), foo(a,B,c)] ).
		no
	*/
		
	/* Un alignement perdant pour J est un alignement gagnant pour son adversaire. */

alignement_gagnant(Ali, J) :- 
    ground(Ali), 
    possible(Ali, J).

% alignement gagnant pour son adversaire
alignement_perdant(Ali, J) :- 
    adversaire(J, I),
    alignement_gagnant(Ali,I).
	
	/*****************************
	TESTS DES PREDICATS POSSIBLE, 
	ALIGNEMENT_GAGNANT ET 
	ALIGNEMENT_PERDANT
	*****************************/
%test avec des alignements possibles pour le joueur 'x'
%renvoie vrai
test_possible_cas1() :-
	possible([_,_,_], x),
	possible([x, _, _], x),
	possible([x, x, x], x).

%test avec un alignement pas possible pour le joueur 'x'
%renvoie faux
test_possible_cas2() :-
	possible([x, o, _], x).

%test d'alignement gagnant avec un alignement gagnant 
%pour le joueur 'x'
%renvoie vrai
test_alignement_gagnant_cas1() :-
	alignement_gagnant([x, x, x], x).

%test d'alignement gagnant avec un alignement pas gagnant 
%pour le joueur 'x'
%renvoie faux
test_alignement_gagnant_cas2() :-
	alignement_gagnant([x, _, _], x).

%test d'alignement perdant avec un alignement gagnant 
%pour le joueur 'o'
%renvoie vrai
test_alignement_perdant_cas1() :-
	alignement_perdant([o, o, o], x).

%test d'alignement perdant avec un alignement pas perdant 
%pour le joueur 'x'
%renvoie faux
test_alignement_perdant_cas2() :-
	alignement_perdant([x, _, o], x).


	/* ****************************
	DEFINITION D'UN ETAT SUCCESSEUR
	****************************** */

	/* 
	Il faut definir quelle operation subit la matrice
	M representant l'Etat courant
	lorsqu'un joueur J joue en coordonnees [L,C]
	*/	

% A FAIRE
successeur(J, Etat,[L,C]) :-
	nth1(L,Etat,Lig), 
    nth1(C,Lig,Marque),
    var(Marque),
    nth1(L,Etat,Lig), 
    nth1(C,Lig,J).

	/**************************************
   	 EVALUATION HEURISTIQUE D'UNE SITUATION
  	 **************************************/

	/*
	1/ l'heuristique est +infini si la situation S est gagnante pour J
	2/ l'heuristique est -infini si la situation S est perdante pour J
	3/ sinon, on fait la difference entre :
	   le nombre d'alignements possibles pour J
	moins
 	   le nombre d'alignements possibles pour l'adversaire de J
*/


heuristique(J,Situation,H) :-		% cas 1
   H = 10000,				% grand nombre approximant +infini
   alignement(Alig,Situation),
   alignement_gagnant(Alig,J), !.
	
heuristique(J,Situation,H) :-		% cas 2
   H = -10000,				% grand nombre approximant -infini
   alignement(Alig,Situation),
   alignement_perdant(Alig,J), !.	


% on ne vient ici que si les cut precedents n'ont pas fonctionne,
% c-a-d si Situation n'est ni perdante ni gagnante.

% A FAIRE 					cas 3
heuristique(J,Situation,H) :-
    findall(AligJ,(alignement(AligJ,Situation),possible(AligJ,J)),ListePos),
    adversaire(J,I),
    findall(AligI,(alignement(AligI,Situation), possible(AligI,I)),ListePosAdv),
    length(ListePos,L1),
    length(ListePosAdv,L2),
    H is L1 - L2.
    
	/*****************************
	TESTS DU PREDICAT HEURISTIQUE
	*****************************/

test_heuristique(H1, H2, H3, H4) :-
	%cas où le joueur 'x' est perdant : renvoie bien -10000
	heuristique(x,[[o,o,o],[x,o,x],[x,_,x]],H1),
	%cas où le joueur 'x' est gagnant : renvoie bien 10000
    heuristique(x,[[o,_,o],[x,o,x],[x,x,x]],H2),
	%cas avec matrice vide (situation initiale) : renvoie bien 0
	situation_initiale(M),
	heuristique(x,M,H3),
	%cas avec 1 alignement possible pour le joueur 'x'
	%et aucun pour 'o' -> renvoie bien 1-0=1
	heuristique(x,[[o,x,o],[x,o,x], [x,_,x]],H4).