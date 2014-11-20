:- dynamic edge/4, node/2, degree/3, stack/1, visited/1, tree/3.
% edge(grafo, arco, izq, der).
% node(grafo, nom).
% degree(grafo, nodo, d).
% stack(nodo).
% visited(nodo).

 %node(g1, n0).
 %node(g1, n1).
 %node(g1, n2).
 %node(g1, n3).
 %node(g1, n4).
 %node(g1, n5).
 %node(g1, n6).





%edge(g1, m, n0, n0).
%edge(g1, l, n0, n0).
%edge(g1, b, n0, n1).
%edge(g1, e, n0, n2).
%edge(g1, d, n0, n4).
%edge(g1, a, n0, n5).
%edge(g1, f, n1, n2).
%edge(g1, g, n1, n3).
%edge(g1, c, n1, n4).
%edge(g1, h, n2, n3).
%edge(g1, i, n2, n4).
%edge(g1, j, n3, n4).
%edge(g1, k, n3, n5).

generate_graph						:-	retract_all,
										generate_nodes,
										generate_edges.
retract_all							:-	retractall(stack(_)),
										retractall(visited(_)),
										retractall(tree(_,_,_),
										retractall(edge(_,_,_,_)),
										retractall(node(_,_)).
get_name(N)							:-	xx(json([grafo=json([name=N|_])|_])).
get_nodes(NL)						:-	xx(json([grafo=json([_,nodes=NL|_])|_])).
generate_nodes						:-	retractall(node(_,_)),
										get_name(X),
										get_nodes(NL),
 										forall(member(N, NL), assert(node(X,N))), !.
get_moves(M) 						:-	xx(json([grafo=json([_,_,moves=M])|_])).
generate_edges						:-	retractall(edge(_,_,_,_)),
										get_name(X),
										forall(get_moves(M), 
											   forall(member([B,F,T], M),  assert(edge(X,B,F,T)))), !.

adjacent(G, N, M, E)				:-	edge(G, E, N, M);edge(G, E, M, N).
find_proper_edge(G, N, E, M) 		:- 	adjacent(G, N, M, E), 
										M\=N.
find_loop_edge(G, N, E)				:-	edge(G, E, N, N).
find_proper_degree_node(G, N, D) 	:- 	node(G, N), 
										findall(1, find_proper_edge(G, N, _, _), L), 
										length(L, D).
find_loop_degree_node(G, N, D) 		:- 	node(G, N), 
										findall(1, find_loop_edge(G, N, _), L), 
										length(L, K), D is K+K.
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
% dfs(_).
is_connected(G)						:-	node(G, N), !, dfs(G, N),
										forall(node(G, M), visited(M))
										.


% retract ni assert no sirve para backtracking pues cuando viene de vuelta no vuelve a hacerlo, mientras q el backtrkng si trata todas las veces
% 

% JS rx la pagina

% diseñar el json para transportar el grafo del cliente al server

% recorrer los 2 algoritmos (euler y is connected) con el grafo q viene del cliente

% cuando ya tengamos las respuestas mandamos el grafo de vuelta por medio del json