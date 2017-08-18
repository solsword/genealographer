% First-stage decisions
#const min_common_standouts = 4.
#const max_common_standouts = 5.
#const min_rare_standouts = 0.
#const max_rare_standouts = 1.
#const max_standouts_per_type = 2.

%#minimize { 1@100, error(R, X) : error(R, X) }.
:- error(R, X).

common_standout_type(
  many_children;
  multiple_partners;
  young_parent;
  old_parent;
  partner_gap;
  sibling_gap;
  has_tuplets
).

rare_standout_type(
  mixed_sex_partners;
  incest
).

standout_count(0..max_standouts_per_type).

%allowed_standouts(T, 0) :- common_standout_type(T).
%allowed_standouts(T, 0) :- rare_standout_type(T).

1 = { allowed_standouts(T, N) : standout_count(N) } :- common_standout_type(T). 
1 = { allowed_standouts(T, N) : standout_count(N) } :- rare_standout_type(T). 

total_common_standouts(S) :- S = #sum {
  N,allowed_standouts(T, N) : allowed_standouts(T, N), common_standout_type(T)
}.
total_rare_standouts(S) :- S = #sum {
  N,allowed_standouts(T, N) : allowed_standouts(T, N), rare_standout_type(T)
}.

error(wrong_number_of_common_standouts, "") :-
  total_common_standouts(N),
  min_common_standouts > N.

error(wrong_number_of_common_standouts, "") :-
  total_common_standouts(N),
  max_common_standouts < N.

error(wrong_number_of_rare_standouts, "") :-
  total_rare_standouts(N),
  min_rare_standouts > N.

error(wrong_number_of_rare_standouts, "") :-
  total_rare_standouts(N),
  max_rare_standouts < N.
