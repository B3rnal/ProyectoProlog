:- dynamic arco/4, node/2, degree/3, stack/1, visited/1, tree/3, ruta/2.
% arco(grafo, arco, izq, der).
% node(grafo, nom).
% degree(grafo, nodo, d).
% stack(nodo).
% visited(nodo).
% ruta(nodo, nodo).

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
generate_graph						:-	generate_nodes,
										generate_arcos,
										generate_rutas.
adjacent(G, N, M, E)				:-	arco(G, E, N, M);arco(G, E, M, N).
find_proper_arco(G, N, E, M) 		:- 	adjacent(G, N, M, E), 
										M\=N.
find_loop_arco(G, N, E)				:-	arco(G, E, N, N).
find_proper_degree_node(G, N, D) 	:- 	node(G, N), 
										findall(1, find_proper_arco(G, N, _, _), L), 
										length(L, D).
find_loop_degree_node(G, N, D) 		:- 	node(G, N), 
										findall(1, find_loop_arco(G, N, _), L), 
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
dfs(_).
is_connected(G)						:-	node(G, N), !, dfs(G, N),
										forall(node(G, M), visited(M)).