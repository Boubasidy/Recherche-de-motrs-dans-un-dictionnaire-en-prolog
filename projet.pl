

%% Le dictionnaire (adpaté d'un sujet en Programmation fonctionnelle de Claire Lefèvre).

%% Un dictionnaire est un arbre de constructeur (ie. symbole de fonction) dic/3 de premier argument, un caractère, de deuxième argument, un booléen qui indique si le chemin depuis la racine est un mot du dictionnaire ou non, et un troisième argument, une liste de dictionnaires. 
%% Par exemple, le dictionnaire ci-dessous représente l'ensemble de mots «a», «an», «bac» et «bar».
%% Les mots sont lus depuis la racine jusqu'au noeuds étiquetés par un booléen true. Les noeuds étiquetés par un booléen false ne peuvent pas terminer un mot. Par exemple, «b» et «ba» ne sont pas des mots dans l'arbre. Par convention, la racine de l'arbre sera toujours étiquetée par le caractère '*'.

un_dico(dic('*', false, [
		dic('a', true, [
			dic('n', true, [])]),
		dic('b', false, [
			dic('a', false, [
				dic('c', true, []),
				dic('r', true, [])])]),
		dic('c', true, [])])).

%% 1. Définir le prédicat cherche/2 qui est tel que cherche(Mot, Dico) est vrai si la chaîne de caractères Mot est dans le dictionnaire Dico.
%% On utilisera le prédicat string_chars/2 qui est tel que string_chars(String, Chars) est vrai si Chars est la liste des caractères de la chaîne de caractères String (http://www.swi-prolog.org/pldoc/man?predicate=string_chars/2).
            %% -------------------------------- code --------------------------------------
cherche(Mot, dic('*',false,ListeDic)) :-
    string_chars(Mot, LC),
    recherche_mot(LC, ListeDic).

recherche_mot([X], [dic(X, true, _)|_]).
recherche_mot([Y|Reste], [dic(Y, _, Dico)|_]) :-
    recherche_mot(Reste, Dico).
recherche_mot([Y|Reste], [dic(Z, _, _)|RestD]) :-
    Y \= Z,
    recherche_mot([Y|Reste], RestD).

%% Exemples :
%% ?- un_dico(Dico), cherche("an", Dico).
%% Dico = dic(*,false,[dic(a,true,[dic(n,true,[])]),dic(b,false,[dic(a,false,[dic(c,true,[]),dic(r,true,[])])])]) ;
%% ;
%% false.
%% ?- un_dico(Dico), cherche("ba", Dico).
%% false.

%% 2. Définir le prédicat tous_les_mots/2 qui est tel que tous_les_mots(Dico, Liste_Mots) est vrai si la liste Liste_Mots est la liste de tous les mots du dictionnaire.
                   %% ----------------------------------  code -------------------------------------------------

insertion([], _, []). 
insertion([Y|Reste], X, [[X|Y]|Resultat]) :- 
    insertion(Reste, X, Resultat).

tous_les_mots(dic('*',false,Dico),SL) :- 
    mots_dico(Dico,L),
    convertir_en_ch(L,SL).

mots_dico([],[]). 
mots_dico([Dic|Reste],L) :- 
    mots_branche(Dic,Lb), 
    mots_dico(Reste,Ld),  
    append(Lb,Ld,L).      

mots_branche(dic(X,true,[]),[[X]]) :- !. 
mots_branche(dic(X,false,Dico),L) :- 
    mots_dico(Dico,Ldic),            
    insertion(Ldic,X,L). 

mots_branche(dic(X,true,Dico),L) :- 
    mots_dico(Dico,Ldic),            
    insertion(Ldic,X,Nld),             
    append([[X]],Nld,L).           

convertir_en_ch([],[]). 
convertir_en_ch([X|R],[SX|SR]) :- 
    string_chars(SX,X),     
    convertir_en_ch(R,SR).

%% Exemple :
%% ?- un_dico(Dico), tous_les_mots(Dico, L).
%% Dico = dic(*,false,[dic(a,true,[dic(n,true,[])]),dic(b,false,[dic(a,false,[dic(c,true,[]),dic(r,true,[])])])]),
%% L = ["a","an","bac","bar"] ;
%% ;
%% false.

%% 3. Définir le prédicat inserer/3 qui est tel que inserer(String, Dico, Dico_) est vrai si le dictionnaire Dico_ est le résultat de l'insertion de la chaîne de caractères String dans le dictionnaire Dico.
 %% --------------------------------------------- code ----------------------------
 inserer(String, dic('*', false, Dico), dic('*', false, Dico_)) :-
    string_chars(String, List),
    predicat_inserer(List, Dico, Dico_).

predicat_inserer([X|RestL], [dic(X, Bool, Dico)|RD], [dic(X, Bool, Dico_)|RD]) :-
    predicat_inserer(RestL, Dico, Dico_).

predicat_inserer([X|RestL], [dic(Y, Bool, Dico)|RD], [dic(Y, Bool, Dico)|RD_]) :-
    X \= Y,
    predicat_inserer([X|RestL], RD, RD_).

predicat_inserer([X|RestL], [dic(X,true,[])|RestD], [dic(X,true,[Ndic])|RestD]) :-
    creation_dico(RestL, Ndic).

predicat_inserer([X|RestL], [dic(Y, true, [])], [dic(Y,true,[]),Ndic]) :-
    X \= Y,
    creation_dico([X|RestL], Ndic).

creation_dico([X], dic(X, true, [])).
creation_dico([X|R], dic(X, false, [Dico])) :-
    creation_dico(R, Dico).


%% Exemple :
%% ?- un_dico(Dico), inserer("baie", Dico, Dico_).
%% Dico = dic(*,false,[dic(a,true,[dic(n,true,[])]),dic(b,false,[dic(a,false,[dic(c,true,[]),dic(r,true,[])])])]),
%% Dico_ = dic(*,false,[dic(a,true,[dic(n,true,[])]),dic(b,false,[dic(a,false,[dic(c,true,[]),dic(r,true,[]),dic(i,false,[dic(e,true,[])])])])]) ;
%% ;
%% false.

%% 4. Définir le prédicat suppimer_v1/3 qui est tel que supprimer_v1(String, Dico, Dico_) est vrai si le dictionnaire Dico_ est le résultat de la suppresion de la chaîne de caractère String dans le dictionnaire Dico simplement en modifiant les étiquettes booléennes.
                     %% -------------------------------- code -----------------------------------
supprimer_v1(String, dic('*', false, Dico), dic('*', false, Dico_)):-
    string_chars(String, List),
    predicat_supprimer1(List, Dico, Dico_), !.

predicat_supprimer1([X], [dic(X,true,Dico)|RestD], [dic(X,false,Dico)|RestD]).

predicat_supprimer1([X], [dic(Y,true,Dico)|RestD], [dic(Y,true,Dico)|RestD_]):-
    X \= Y,
    predicat_supprimer1([X], RestD, RestD_), !.

predicat_supprimer1([X|RestL], [dic(X,Bool,Dico)|RestD], [dic(X,Bool,Dico_)|RestD]):-
    predicat_supprimer1(RestL, Dico, Dico_), !.

predicat_supprimer1([X|RestL], [dic(Y,Bool,Dico)|RestD], [dic(Y,Bool,Dico)|RestD_]):-
    X \= Y,
    predicat_supprimer1([X|RestL], RestD, RestD_), !.




%% Exemple :
%%  ?- un_dico(Dico), inserer("baie", Dico, Dico_), supprimer_v1("bar", Dico_, Dico__).
%% Dico = dic(*,false,[dic(a,true,[dic(n,true,[])]),dic(b,false,[dic(a,false,[dic(c,true,[]),dic(r,true,[])])])]),
%% Dico_ = dic(*,false,[dic(a,true,[dic(n,true,[])]),dic(b,false,[dic(a,false,[dic(c,true,[]),dic(r,true,[]),dic(i,false,[dic(e,true,[])])])])]),
%% Dico__ = dic(*,false,[dic(a,true,[dic(n,true,[])]),dic(b,false,[dic(a,false,[dic(c,true,[]),dic(r,false,[]),dic(i,false,[dic(e,true,[])])])])]) ;
%% ;
%% false.

%% 5. Définir le prédicat suppimer_v2/3 qui est tel que supprimer_v2(String, Dico, Dico_) est vrai si le dictionnaire Dico_ est le résultat de la suppresion de la chaîne de caractère String dans le dictionnaire Dico en éliminant les noeuds qui ne permettent plus de former des mots.
    %% --------------------------------------------- code -------------------------------------------- 
supprimer_v2(String, dic('*', false, Dico), dic('*', false, Dico_)):-
    string_chars(String, List),
    predicat_supprimer2(List, Dico, Dico_), !.

predicat_supprimer2([X], [dic(X,true,Dico)|RestD], RestD_):-
    append(Dico, RestD, RestD_).

predicat_supprimer2([X], [dic(Y,true,Dico)|RestD], [dic(Y,true,Dico)|RestD_]):-
    X \= Y,
    predicat_supprimer2([X], RestD, RestD_), !.

predicat_supprimer2([X|RestL], [dic(X,Bool,Dico)|RestD], [dic(X,Bool,Dico_)|RestD]):-
    predicat_supprimer2(RestL, Dico, Dico_), !.

predicat_supprimer2([X|RestL], [dic(Y,Bool,Dico)|RestD], [dic(Y,Bool,Dico)|RestD_]):-
    X \= Y,
    predicat_supprimer2([X|RestL], RestD, RestD_), !.



%% ?- un_dico(Dico), inserer("baie", Dico, Dico_), supprimer_v2("bar", Dico_, Dico__).
%% Dico = dic(*,false,[dic(a,true,[dic(n,true,[])]),dic(b,false,[dic(a,false,[dic(c,true,[]),dic(r,true,[])])])]),
%% Dico_ = dic(*,false,[dic(a,true,[dic(n,true,[])]),dic(b,false,[dic(a,false,[dic(c,true,[]),dic(r,true,[]),dic(i,false,[dic(e,true,[])])])])]),
%% Dico__ = dic(*,false,[dic(a,true,[dic(n,true,[])]),dic(b,false,[dic(a,false,[dic(c,true,[]),dic(i,false,[dic(e,true,[])])])])]) ;
%% ;
%% false.

%% 6. Définir le prédicat coq_a_l_ane/4 qui est tel que coq_a_l_ane(String1, String2, Dico, Sequence) permet de passer de la chaîne de départ String1 à une chaîne de caractère String2 (qui appartiennent tous deux au dictionnaire) en changeant une lettre à la fois, de telle sorte que tous les mots intermédiaires formant Sequence appartiennent aussi au dictionnaire.
% Prédicat member/2
member(Element, [Element|_]).
member(Element, [_|Reste]) :-
    member(Element, Reste).

% Prédicat mot_identique/2
mot_identique(Word, Word).

% Prédicat suppresion/3
suppresion([Element|Reste], Element, Reste).
suppresion([Tete|Queue], Element, [Tete|Resultat]) :-
    suppresion(Queue, Element, Resultat).

            %% -----------------------code --------------------------------
coq_a_l_ane(Word1 , Word2 , Dico,Sequence):-
    tous_les_mots(Dico,Liste),
    ecrire(Liste),
    member(Word1,Liste),
    member(Word2,Liste),
    coq_a_l_ane(Word1,Word2,Liste,Sequence).

coq_a_l_ane(Word1,Word2,Liste,[Word1,Word2]):-
    member(Word1,Liste),
    member(Wodr2 , Liste),
    mot_identique(Word1 , Word2).

coq_a_l_ane(Word1 ,Word2 , Liste , [Word1 | Rest]):-
    member(Word3 , Liste),
    mot_identique(Word1,Word3),
    suppresion(Liste,Word1,Liste1),
    coq_a_l_ane(Word3,Word2,Liste1,Rest).

%% ?- un_dico(Dico), inserer("baie", Dico, Dico_), inserer("brie", Dico_, Dico__), inserer("rive", Dico__, Dico___), coq_a_l_ane("baie", "rive", Dico___, Sequence).
%% Dico = dic(*,false,[dic(a,true,[dic(n,true,[])]),dic(b,false,[dic(a,false,[dic(c,true,[]),dic(r,true,[])])])]),
%% Dico_ = dic(*,false,[dic(a,true,[dic(n,true,[])]),dic(b,false,[dic(a,false,[dic(c,true,[]),dic(r,true,[]),dic(i,false,[dic(e,true,[])])])])]),
%% Dico__ = dic(*,false,[dic(a,true,[dic(n,true,[])]),dic(b,false,[dic(a,false,[dic(c,true,[]),dic(r,true,[]),dic(i,false,[dic(e,true,[])])]),dic(r,false,[dic(i,false,[dic(e,true,[])])])])]),
%% Dico___ = dic(*,false,[dic(a,true,[dic(n,true,[])]),dic(b,false,[dic(a,false,[dic(c,true,[]),dic(r,true,[]),dic(i,false,[dic(e,true,[])])]),dic(r,false,[dic(i,false,[dic(e,true,[])])])]),dic(r,false,[dic(i,false,[dic(v,false,[dic(e,true,[])])])])]),
%% Sequence = ["baie","brie","rive"] ;
%% ;
%% false.


%% Une directive pour modifier la sortie standard
:- set_prolog_flag(answer_write_options, [quoted(true), portray(true), max_depth(100), attributes(portray)]). 
