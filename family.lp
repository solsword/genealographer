#const population = 17.
%#const population = 6.
#const max_gen = 6.
#const max_children = 16.
#const min_roots = 2.
#const max_roots = 8.

%#minimize { 1@100, error(R, X) : error(R, X) }.
:- error(R, X).

node(n(1..population)).

% limit things that stand out
error(too_many_standouts, T) :-
  allowed_standouts(T, X),
  X < { standout(T, N) : standout(T, N) }.

error(too_many_children, P) :- node(P), max_children < { parent(C, P) }.
error(too_many_children, P) :- node(P), max_children < { partner(_, P, C) }.

many_children(P) :-
  node(P),
  4 < { parent(C, P) }.

many_children(P) :-
  node(P),
  4 < { partner(_, P, C) }.

standout(many_children, P) :- many_children(P).
highlight(X, "green") :- many_children(X).
gvn("many_children", "color=green") :- highlight(X, "green").

{ root(X) : node(X) }.

error(too_few_roots, "") :- min_roots > { root(X) }.
error(too_many_roots, "") :- max_roots < { root(X) }.

1 = {
  parent(X, P) : node(P), X != P;
  error(missing_parent, X)
} :- node(X), not root(X).

ancestor(X, P) :- parent(X, P).

ancestor(X, A) :- parent(X, P), ancestor(P, A).

ancestor(X, P) :- partner(_, P, X).

ancestor(X, A) :- parent(X, P), ancestor(P, A).
ancestor(X, A) :- partner(_, P, X), ancestor(P, A).

1 = {
  partner(X, P, C) : node(P), X != P, C != P;
  error(missing_partner, p(X, C))
} :- parent(C, X).

% strict sex separation
% Note: AFAIK this is impossible even given modern medicine circa 2017.
% Although being both a father and a mother is certainly possible, being both
% biologically is not.
mixed_sex_partners(P) :- parent(_, P), partner(_, P, _).
standout(mixed_sex_partners, P) :- mixed_sex_partners(P).
highlight(X, "purple") :- mixed_sex_partners(X).
gvn("mixed_sex_partners", "color=purple") :- highlight(X, "purple").

multiple_partners(X) :-
  node(X),
  N = { node(P) : partner(X, P, C) },
  N > 1.

multiple_partners(X) :-
  node(X),
  N = { node(P) : partner(P, X, C) },
  N > 1.

standout(multiple_partners, X) :- multiple_partners(X).
highlight(X, "blue") :- multiple_partners(X).
gvn("multiple_partners", "color=blue") :- highlight(X, "blue").

related(X, Y) :- ancestor(X, Y).
related(X, Y) :- partner(X, Y, C).
related(Y, X) :- related(X, Y).
related(X, Z) :- related(X, Y), related(Y, Z).

error(self_ancestor, X) :- ancestor(X, X).

step_parent(X, Y) :-
  partner(P, Y, C),
  parent(X, P).

step_ancestor(X, Y) :-
  step_parent(X, P),
  ancestor(P, Y).

step_ancestor(X, Y) :-
  ancestor(X, A),
  step_parent(A, Y).

step_ancestor(X, Y) :-
  step_ancestor(X, A),
  ancestor(A, Y).

step_ancestor(X, Y) :-
  ancestor(X, A),
  step_ancestor(A, Y).

unrelated(X, Y) :-
  node(X),
  node(Y),
  not related(X, Y).

incest(X, P, C) :- partner(X, P, C), ancestor(X, P).
incest(X, P, C) :- partner(X, P, C), ancestor(P, X).

incest(X, P, C) :- partner(X, P, C), ancestor(X, A), ancestor(P, A).

incest(X, P, C) :- partner(X, P, C), step_ancestor(X, P).
incest(X, P, C) :- partner(X, P, C), step_ancestor(P, X).

incest(X, P, C) :- partner(X, P, C), step_ancestor(X, A), step_ancestor(P, A).

standout(incest, X) :- incest(X, P, C).
highlight(X, "magenta") :- incest(X, P, C).
highlight(P, "magenta") :- incest(X, P, C).
highlight(C, "magenta") :- incest(X, P, C).
gvn("incest", "color=magenta") :- highlight(X, "magenta").

error(not_fully_related, p(X, Y)) :- unrelated(X, Y).

gvn(N, "") :- node(n(N)).
gvnp(N, color, C) :- node(n(N)), highlight(n(N), C).
gve(P, N, "") :- parent(n(N), n(P)).
gve(P, C, "") :- partner(n(X), n(P), n(C)).
%gve(X, P, "style=dotted") :- partner(n(X), n(P), n(C)).
