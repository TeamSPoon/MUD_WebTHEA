/* -*- Mode: Prolog -*- */

:- use_module(owl2_visitor).

:- begin_tests(owl2_visitor,[setup(init_axioms),cleanup(retract_all_axioms)]).

init_axioms :-
        load_axioms('testfiles/caro.owl').

test(tr_axiom, [true(Axiom = subClassOf(b,someValuesFrom(p2,a)))]) :-
        rewrite_axiom(subClassOf(a,someValuesFrom(p,b)),
                      tr(axiom,
                         subClassOf(A,someValuesFrom(p,B)),
                         subClassOf(B,someValuesFrom(p2,A)),
                         true,
                         []),
                      Axiom).
test(tr_axiom_dupe, [true(Axioms = [_,_])]) :-
        findall(Axiom,
                rewrite_axiom(subClassOf(a,someValuesFrom(p,b)),
                              tr(axiom,
                                 subClassOf(A,someValuesFrom(p,B)),
                                 (   subClassOf(B,someValuesFrom(p2,A)),
                                     subClassOf(B,someValuesFrom(p3,A))
                                 ),
                                 true,
                                 []),
                              Axiom),
                Axioms).


test(tr_expr, [true(Axiom = subClassOf(a,allValuesFrom(p,b)))]) :-
        rewrite_axiom(subClassOf(a,someValuesFrom(p,b)),
                      tr(expression,
                         someValuesFrom(p,B),
                         allValuesFrom(p,B),
                         true,
                         []),
                      Axiom),
        writeln(Axiom).

test(tr_expr_deep, [true(Axiom = subClassOf(a,intersectionOf([z,someValuesFrom(q,allValuesFrom(p,b))])))]) :-
        rewrite_axiom(subClassOf(a,intersectionOf([z,someValuesFrom(q,someValuesFrom(p,b))])),
                      tr(expression,
                         someValuesFrom(p,B),
                         allValuesFrom(p,B),
                         true,
                         []),
                      Axiom),
        writeln(Axiom).

test(tr_expr_dupe, [true((member(subClassOf(a,allValuesFrom(p,b)),Axioms),
                          member(subClassOf(a,allValuesFrom(p2,b)),Axioms),
                          Axioms=[_,_]))]) :-
        findall(Axiom,
                rewrite_axiom(subClassOf(a,someValuesFrom(p,b)),
                              tr(expression,
                                 someValuesFrom(p,B),
                                 (   allValuesFrom(p,B),
                                     allValuesFrom(p2,B)
                                 ),
                                 true,
                                 []),
                              Axiom),
                Axioms),
        writeln(Axioms).

test(tr_expr_ec, [true(Axiom = equivalentClasses([z,someValuesFrom(p,intersectionOf([a,b]))]))]) :-
        rewrite_axiom(equivalentClasses([z,intersectionOf([a,someValuesFrom(p,b)])]),
                      tr(expression,
                         intersectionOf([A,someValuesFrom(P,B)]),
                         someValuesFrom(P,intersectionOf([A,B])),
                         true,
                         []),
                      Axiom),
        writeln(a1=Axiom).
test(tr_expr_ec2, [true(Axiom = equivalentClasses([z,someValuesFrom(p,intersectionOf([a,b]))]))]) :-
        rewrite_axiom(equivalentClasses([z,intersectionOf([a,someValuesFrom(p,b)])]),
                      tr(expression,
                         intersectionOf([A,someValuesFrom(P,B)]),
                         someValuesFrom(P,intersectionOf([A,B])),
                         atomic(A),
                         []),
                      Axiom),
        writeln(a2=Axiom).

test(tr_expr_open, [true(Axiom = equivalentClasses([z,someValuesFrom(p,intersectionOf([a,b]))]))]) :-
        rewrite_axiom(equivalentClasses([z,intersectionOf([a,someValuesFrom(p,b)])]),
                      tr(_,
                         intersectionOf([A,someValuesFrom(P,B), tail(_)]),
                         someValuesFrom(P,intersectionOf([A,B])),
                         true,
                         []),
                      Axiom),
        writeln(a3=Axiom).
/*
test(tr_expr_open2, [true(Axiom = equivalentClasses([z,someValuesFrom(p,intersectionOf([a,b]))]))]) :-
        rewrite_axiom(equivalentClasses([z,intersectionOf([a,someValuesFrom(p,b),someValuesFrom(q,c)])]),
                      tr(expression,
                         intersectionOf([A,someValuesFrom(P,B) | _]),
                         someValuesFrom(P,intersectionOf([A,B])),
                         true,
                         []),
                      Axiom),
        writeln(a4=Axiom).
test(tr_expr_open3, [true(Axiom = equivalentClasses([z,someValuesFrom(p,intersectionOf([a,b,someValuesFrom(q,c)]))]))]) :-
        rewrite_axiom(equivalentClasses([z,intersectionOf([a,someValuesFrom(p,b),someValuesFrom(q,c)])]),
                      tr(expression,
                         intersectionOf([A,someValuesFrom(P,B) | Rest]),
                         someValuesFrom(P,intersectionOf([A,B | Rest])),
                         P==p,
                         []),
                      Axiom),
        writeln(a5=Axiom).
*/



test(structurally_equivalent1, [true(structurally_equivalent(a,a))]) :- true.
test(structurally_equivalent2, [true(structurally_equivalent(someValuesFrom(a,b),someValuesFrom(a,b)))]) :- true.
test(structurally_equivalent3, [true(\+structurally_equivalent(someValuesFrom(a,b),someValuesFrom(b,a)))]) :- true.
test(structurally_equivalent4, [true(structurally_equivalent(intersectionOf([a,b,c]),
                           intersectionOf([b,a,c])))]) :- true.
test(structurally_equivalent5, [true(\+structurally_equivalent(intersectionOf([a,b,c,d]),
                             intersectionOf([b,a,c])))]) :- true.
test(structurally_equivalent6, [true(structurally_equivalent(intersectionOf([a,b,c]),
                           intersectionOf([b,a,tail(_)])))]) :- true.
test(structurally_equivalent7, [true(\+structurally_equivalent(intersectionOf([a,b,c]),
                             intersectionOf([d,tail(_)])))]) :- true.

test(structurally_equivalent8, [true(A/P/B=a/p/b)]) :-
        structurally_equivalent(intersectionOf([a,someValuesFrom(p,b)]),
               intersectionOf([someValuesFrom(P,B),A])),
        writeln(sm(A/P/B)).
test(structurally_equivalent9, [true(A/P/B=a/p/b)]) :-
        structurally_equivalent(intersectionOf([a,someValuesFrom(p,b)]),
               intersectionOf([A,someValuesFrom(P,B),tail(_)])),
        writeln(sm(A/P/B)).
test(structurally_equivalent10, [true(A/P/B=a/p/b)]) :-
        structurally_equivalent(intersectionOf([a,someValuesFrom(p,b),b,c]),
               intersectionOf([A,someValuesFrom(P,B),tail(_)])),
        writeln(sm(A/P/B)).
test(structurally_equivalent11, [true(P/B/Rest=p/b/[c,someValuesFrom(q,d)])]) :-
        structurally_equivalent(intersectionOf([a,someValuesFrom(p,b),c,someValuesFrom(q,d)]),
               intersectionOf([a,someValuesFrom(P,B),tail(Rest)])),
        writeln(sm(P/B/Rest)).
test(structurally_equivalent12, [true(Q/E/Rest=p/unionOf([e,someValuesFrom(po,e)])/[someValuesFrom(qualifier,abn)])]) :-
        structurally_equivalent(intersectionOf([someValuesFrom(inheres_in,unionOf([e,someValuesFrom(po,e)])),
                               p,
                               someValuesFrom(qualifier,abn)]),
               intersectionOf([Q,
                               someValuesFrom(inheres_in,E),
                               tail(Rest)])),
        writeln(sm12(Q/E/Rest)).

test(structurally_equivalent13, [true(true)]) :-
        owl2_visitor:structurally_equivalent_args_unordered([q, someValuesFrom('http://purl.obolibrary.org/obo/test_inheres_in_part_of', e), someValuesFrom('http://purl.obolibrary.org/obo/test_qualifier', ab)],
                                           [someValuesFrom('http://purl.obolibrary.org/obo/test_inheres_in_part_of', E), tail(Tail)]).



        

:- end_tests(owl2_visitor).

/** <module> tests for OWL2 visitor

---+ Synopsis

Command line:
  
==
swipl
?- [owl2_visitor].
?- load_test_files([]).
?- run_tests.
==

---+ Details

This is a test module for the module owl2_visitor

*/
