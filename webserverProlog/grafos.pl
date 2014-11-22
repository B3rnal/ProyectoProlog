% 		Universidad Nacional
% 		Paradigmas de programación.
%		Prof: Carlos Loria
%		Autores:
% 		- Bernal Araya Estrada
% 		- Esteban Gamboa Arrieta
% 		- Diego Alonso Méndez
% 		Grupo 5pm

:- dynamic arco/4, node/2, degree/3, stack/1, visited/1, tree/3, tree/2,ruta/2, edge/2.
:- use_module(library(record)). 
:- use_module(library(http/json)).
:- use_module(library(http/json_convert)).
:- use_module(library(http/http_json)).

% arco(grafo, arco, izq, der).
% node(grafo, nom).
% degree(grafo, nodo, d).
% stack(nodo).
% visited(nodo).
% tree(raiz, izq, der).
% ruta(from, to).

% OBTIENE DATOS DEL JSON
get_name(N)							:-	xx(json([grafo=json([name=N|_])|_])).
get_nodes(NL)						:-	xx(json([grafo=json([_,nodes=NL|_])|_])).
get_moves(M) 						:-	xx(json([grafo=json([_,_,moves=M])|_])).

generate_nodes						:-	retractall(node(_,_)),
										get_name(X),
										get_nodes(NL),
 										forall(member(N, NL), assert(node(X,N))), !.
generate_arcos						:-	retractall(arco(_,_,_,_)),
										get_name(X),
										forall(get_moves(M), 
											   forall(member([B,F,T], M),  assert(arco(X,B,F,T)))), !.
find_rutas(N, R)					:-	findall(T, arco(_,_,N,T),R).
generate_rutas						:-	retractall(ruta(_,_)),
										get_nodes(NL),
										forall(member(N, NL),
											   (find_rutas(N, R), assert(ruta(N, R)))).
generate_edges 						:-	retractall(edge(_,_)),
									  	forall(ruta(N, L),
											   forall(member(M, L), 
													  assert(edge(N, M)))).
generate_graph						:-	generate_nodes,
										generate_arcos,
										generate_rutas,
										generate_edges.
:- generate_graph.


adjacent(G, N, M, E)				:-	arco(G, E, N, M);arco(G, E, M, N).
find_proper_arco(G, N, E, M) 		:- 	adjacent(G, N, M, E), 
										M\=N.
find_loop_arco(G, N, E)				:-	arco(G, E, N, N).
find_proper_degree_node(G, N, D) 	:- 	node(G, N), 
										findall(1, find_proper_arco(G, N, _, _), L), 
										length(L, D).
find_loop_degree_node(G, N, D) 		:- 	node(G, N), 
										findall(1, find_loop_arco(G, N, _), L), 
										length(L, K), K is not(0), D is K+K.
% find_not_connect(G, N, D)			:-	node(G, N),

find_degree_node(G, N, D) 			:-	find_proper_degree_node(G, N, DP), find_loop_degree_node(G, N, DL), D is DP + DL.
generate_degree(G)					:-	retractall(degree(_,_,_)),
										forall(find_degree_node(G,N,D), assert(degree(G,N,D))).
has_euler(G)						:-	generate_degree(G),
										forall(degree(G, _, D), 0 is mod(D, 2)).
dfs(G, N)							:-	retractall(stack(_)),retractall(visited(_)),retractall(tree(_,_,_)),
										assert(stack(N)),
										dfs(G).
dfs(G)								:-	retract(stack(N)),
										not(visited(N)), assert(visited(N)),
										forall((adjacent(G, N, M, R), not(visited(M))),
											   (asserta(stack(M)), assert(tree(R, N, M)))),
										dfs(G).
dfs(_).
is_connected(G)						:-	node(G, N), !, dfs(G, N),
										forall(node(G, M), visited(M)).

adjacent(N, M) 						:- 	edge(N, M); edge(M, N).

writeln(T) 							:- 	write(T), nl.

path(A, B) 							:- 	adjacent(A, B), 
										assert(tree(A, B)).

path(A, B) 							:- 	adjacent(A, C),
										not(visited(C)), 
										assert(visited(C)), 
										path(C, B),
										assert(tree(A, C)).

find_path(A, B) 					:- 	retractall(visited(_)), 
					                   	retractall(tree(_,_)),
					                   	assert(visited(A)), 
					                   		   path(A, B).

root(R) 							:- 	tree(R, _), \+tree(_, R).

% Flag para que se vean  listas grandes o profundas
:- 	set_prolog_flag(toplevel_print_options, [quoted(true), portray(true), max_depth(50), spacing(next_argument)]).

:- 	json_object fromTo(from:atom, to:atom).
:- 	json_object graph(edges:list).

walk(P) 							:- 	root(R), 
										walk(R, [], P).
walk(R, L, P) 						:- 	tree(R, N), !, 
										walk(N, [fromTo(R, N)|L], P).
walk(_, L, R) 						:- 	reverse(L, R).

walk_to_json 						:- 	walk(P), prolog_to_json(graph(P), J), json_write(current_output, J).