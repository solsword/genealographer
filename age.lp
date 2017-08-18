%#minimize { 1@100, error(R, X) : error(R, X) }.
:- error(R, X).

% limit things that stand out
error(too_many_standouts, T) :-
  allowed_standouts(T, X),
  X < { standout(T, N) : standout(T, N) }.

% Assign everyone an age:
age(0..140).

1 = { age(N, G) : age(G); error(no_age, N) } :- node(N).

either_parent(C, P) :- parent(C, P).
either_parent(C, P) :- partner(_, P, C).

sibling(C, S) :-
  parent(C, P),
  parent(S, P),
  partner(P, Pr, C),
  partner(P, Pr, S).

step_sibling(C, Ss) :-
  parent(C, P),
  parent(Ss, P),
  not sibling(C, Ss).

step_sibling(C, Ss) :-
  partner(_, P, C),
  partner(_, P, Ss),
  not sibling(C, Ss).

any_sibling(C, S) :- sibling(C, S).
any_sibling(C, S) :- step_sibling(C, S).

% parent age restrictions
error(parent_too_young, P) :-
  age(C, Cg),
  age(P, Pg),
  either_parent(C, P),
  Pg - Cg < 15.

young_parent(C, P) :-
  age(C, Cg),
  age(P, Pg),
  either_parent(C, P),
  Pg - Cg < 18.

standout(young_parent, P) :- young_parent(C, P).

highlight(C, "red") :- young_parent(C, P).
highlight(P, "red") :- young_parent(C, P).
gvn("young_parent", "color=red") :- highlight(X, "red").

% restrict number of old parents
error(parent_too_old, P) :-
  age(C, Cg),
  age(P, Pg),
  either_parent(C, P),
  Pg - Cg > 50.

old_parent(C, P) :-
  age(C, Cg),
  age(P, Pg),
  either_parent(C, P),
  Pg - Cg > 38.

standout(old_parent, P) :- old_parent(C, P).
highlight(C, "yellow") :- old_parent(C, P).
highlight(P, "yellow") :- old_parent(C, P).
gvn("old_parent", "color=yellow") :- highlight(X, "yellow").

partner_gap(X, P) :-
  partner(X, P, C),
  age(X, Xg),
  age(P, Pg),
  age(C, Cg),
  Xg > Pg,
  (Xg - Cg) - (Pg - Cg) > (Pg - Cg) / 3.

partner_gap(X, P) :-
  partner(X, P, C),
  age(X, Xg),
  age(P, Pg),
  age(C, Cg),
  Pg > Xg,
  (Pg - Cg) - (Xg - Cg) > (Xg - Cg) / 3.

standout(partner_gap, X) :- partner_gap(X, P).
highlight(X, "brown") :- partner_gap(X, P).
highlight(P, "brown") :- partner_gap(X, P).
gvn("partner_gap", "color=brown") :- highlight(X, "brown").

sibling_gap(C, S) :-
  sibling(C, S),
  age(C, Cg),
  age(S, Sg),
  Cg - Sg > 8.

sibling_gap(C, S) :-
  any_sibling(C, S),
  age(C, Cg),
  age(S, Sg),
  Cg - Sg > 15.

standout(sibling_gap, C) :- sibling_gap(C, S).
highlight(C, "cyan") :- sibling_gap(C, S).
highlight(S, "cyan") :- sibling_gap(C, S).
gvn("sibling_gap", "color=cyan") :- highlight(X, "cyan").

tuplets(C, S) :-
  parent(C, P),
  parent(S, P),
  age(C, Cg),
  age(S, Sg),
  Cg = Sg,
  C != S.

% You can't have tuplets with different partners
error(tuplets_with_multiple_partners, P) :-
  tuplets(C, S),
  partner(P, R1, C),
  partner(P, R2, S),
  R1 != R2.

has_tuplets(P) :-
  parent(C, P),
  tuplets(C, _).

standout(has_tuplets, P) :- has_tuplets(P).
highlight(P, "pink") :- has_tuplets(P).
gvn("has_tuplets", "color=pink") :- highlight(X, "pink").

gvn(N, "") :- node(n(N)).
gvnp(N, label, G) :- node(n(N)), age(n(N), G).
gvnp(N, color, C) :- node(n(N)), highlight(n(N), C).
gve(P, N, "") :- parent(n(N), n(P)).
gve(P, C, "style=dotted") :- partner(n(X), n(P), n(C)).
%gve(X, P, "style=dotted") :- partner(n(X), n(P), n(C)).
gvep(P, C, label, GaB) :-
  parent(n(C), n(P)),
  age(n(C), Cg),
  age(n(P), Pg),
  GaB = Pg - Cg.
gvep(P, C, label, GaB) :-
  partner(_, n(P), n(C)),
  age(n(C), Cg),
  age(n(P), Pg),
  GaB = Pg - Cg.
