% Generation constraints

1 = { generation(N, X) : X = 1..max_gen } :- root(N).
generation(N, X+1) :- generation(P, X), parent(N, P), X < max_gen+2.
generation(N, X+1) :- generation(P, X), partner(_, P, N), X < max_gen+2.

% Each node must be assigned a single, unique, generation.
:- generation(N, X), generation(N, Y), X != Y.
:- node(N), 0 = { generation(N, X) }.
:- generation(N, X), X > max_gen.

%gvnp(N, label, G) :- node(n(N)), generation(n(N), G).
