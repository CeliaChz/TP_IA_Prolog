%*******************************************************************************
%                                    AETOILE
%*******************************************************************************

/*
Rappels sur l'algorithme
 
- structures de donnees principales = 2 ensembles : P (etat pendants) et Q (etats clos)
- P est dedouble en 2 arbres binaires de recherche equilibres (AVL) : Pf et Pu
 
   Pf est l'ensemble des etats pendants (pending states), ordonnes selon
   f croissante (h croissante en cas d'egalite de f). Il permet de trouver
   rapidement le prochain etat a developper (celui qui a f(U) minimum).
   
   Pu est le meme ensemble mais ordonne lexicographiquement (selon la donnee de
   l'etat). Il permet de retrouver facilement n'importe quel etat pendant

   On gere les 2 ensembles de fa�on synchronisee : chaque fois qu'on modifie
   (ajout ou retrait d'un etat dans Pf) on fait la meme chose dans Pu.

   Q est l'ensemble des etats deja developpes. Comme Pu, il permet de retrouver
   facilement un etat par la donnee de sa situation.
   Q est modelise par un seul arbre binaire de recherche equilibre.

Predicat principal de l'algorithme :

   aetoile(Pf,Pu,Q)

   - reussit si Pf est vide ou bien contient un etat minimum terminal
   - sinon on prend un etat minimum U, on genere chaque successeur S et les valeurs g(S) et h(S)
	 et pour chacun
		si S appartient a Q, on l'oublie
		si S appartient a Ps (etat deja rencontre), on compare
			g(S)+h(S) avec la valeur deja calculee pour f(S)
			si g(S)+h(S) < f(S) on reclasse S dans Pf avec les nouvelles valeurs
				g et f 
			sinon on ne touche pas a Pf
		si S est entierement nouveau on l'insere dans Pf et dans Ps
	- appelle recursivement etoile avec les nouvelles valeurs NewPF, NewPs, NewQs

*/

%*******************************************************************************

:- ['avl.pl'].       % predicats pour gerer des arbres bin. de recherche   
:- ['taquin.pl'].    % predicats definissant le systeme a etudier

%*******************************************************************************

main :-
	% initialisations Pf, Pu et Q 
	initial_state(S0),

	heuristique(S0, H0),
	G0 is 0,
	F0 is (G0 + H0),

	empty(Pf_null),
	empty(Pu_null),
	empty(Q),

	insert([[F0,H0,G0],S0], Pf_null, Pf),
	insert([S0,[F0,H0,G0],nil,nil], Pu_null, Pu),

	% lancement de Aetoile
	aetoile(Pf,Pu,Q).


%*******************************************************************************
%CAS TRIVIAL N°1
aetoile(nil, nil, _) :-
	print("Pas de solution, l'état final n'est pas atteignable."), nl, !.

%CAS TRIVIAL N°2
aetoile(Pf,Pu,Q) :-
	%print("AETOILE - CAS TRIVIAL 2"), nl,
	final_state(Fin),
	%Pas grave de supprimer le min car on a toujours Pf intact. 
	suppress_min([[_F, _H, _G], U],Pf,_Pf_2),
	U = Fin,
	belongs([U,Vals,P,Apu],Pu),
	print("Voici la solution trouvée"), nl,
	affiche_solution([U,Vals,P, Apu ],Q), !.

aetoile(Pf, Ps, Qs) :-
	%print("AETOILE - CAS GENERAL"),
	nl,
	%Suppression le minimum de Pf contenant l'etat U a developper
	suppress_min([[_F, _H, _GU], U],Pf,Pf_aux),
	%Suppression du noeud frere dans Pu
	suppress([U,[F,H,GU],Pere,A],Ps,Pu_aux),	
	expand(U,GU,List_suiv),	
	loop_successors(List_suiv, U, Qs, Pf_aux, Pu_aux, Pf_new, Pu_new),
	insert([U,[F,H,GU],Pere,A],Qs,Q_new),
	aetoile(Pf_new, Pu_new, Q_new).
	

%cas trivial
affiche_solution([U,_Vals,_, _], _Q):-
	print("AFFICHE_SOLUTION - CAS TRIVIAL "), nl,
	initial_state(U),   % on est revenu dans l'etat initial
	write_state(U),nl,!.

affiche_solution([U,_Vals,P, Apu ],Q):-
	print("AFFICHE_SOLUTION - CAS GENERAL "),nl,
	belongs([P,ValsP,GP,AP], Q),
	affiche_solution([P,ValsP,GP,AP], Q),
	write("Action : "),
	write(Apu), nl, nl,
	write_state(U), nl.


%Determiner tous les etats ayant U pour pere
%et Calculer leurs évaluations 
expand(Upere,G,List_suiv):-
	%print("EXPAND"),nl,
	findall([USuiv,[Fs,Hs,Gs],X], (rule(X,Cout,Upere,USuiv),Gs is G+Cout, heuristique(USuiv,Hs), Fs is Hs+Gs), List_suiv).


%Traiter chaque noeud successeur
%% Cas trivial : liste vide
loop_successors([], _, _,Pf, Pu, Pf, Pu) :- 
	%write("LOOP_SUCCESSORS CAS VIDE"), nl, 
	!.

%Cas 1 : Si S est connu dans Q alors oublier cet etat
loop_successors([[S,_,_] | Tail], U, Q, Pf, Pu, Pf_new, Pu_new) :-
	%print("PROCESS_SUCCESSOR - CAS 1"), nl,
    belongs([S,_,_,_], Q),
    loop_successors(Tail, U, Q, Pf, Pu,Pf_new, Pu_new), !.

%Cas 2 : Si S est connu dans Pu et que S est mieux que l'ancienne valeurs dans l'arbre
loop_successors([[S,[Fs, Hs, Gs],A]|Tail], U, Q, Pf, Pu, Pf_new, Pu_new) :-
    %print("PROCESS_SUCCESSOR - CAS 2"), nl,
	belongs([S,[F, _, _],_,_],Pu),
	F > Fs,
    suppress([S,_,_,_], Pu, Pu_aux), 
    insert([S,[Fs,Hs,Gs],U,A], Pu_aux, Pu_aux2),
    suppress([S,_,_,_], Pf, Pf_aux), 
    insert([[Fs,Hs,Gs],S], Pf_aux, Pf_aux2),
	loop_successors(Tail, U, Q, Pf_aux2, Pu_aux2, Pf_new, Pu_new),!.

%Cas 3 : Si S est connu dans Pu et que S n'est pas mieux que l'ancienne valeurs dans l'arbre
loop_successors([[S,[Fs, _, _],_]|Tail], U,  Q,Pf, Pu, Pf_new, Pu_new) :-
	%print("PROCESS_SUCCESSOR - CAS 3"), nl,
    belongs([S,[F, _, _],_,_],Pu),
	F =< Fs,
	%On ne change pas le noeud dans pf et pu car pas mieux que le precedent
	loop_successors(Tail, U, Q, Pf, Pu, Pf_new, Pu_new),!.

%Cas 4 : Si S est une situation nouvelle
loop_successors([[S,[Fs, Hs, Gs],A]|Tail], U,  Q,Pf, Pu,Pf_new, Pu_new) :-
    %print("PROCESS_SUCCESSOR - CAS 4"), nl,
	insert([S,[Fs, Hs, Gs],U,A], Pu, Pu_aux), 
    insert([[Fs, Hs, Gs],S], Pf, Pf_aux),
	loop_successors(Tail, U, Q, Pf_aux, Pu_aux, Pf_new, Pu_new).







