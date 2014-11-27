/*
Basado y adpatado por loriacarlols@gmail.com de
http://www.pathwayslms.com/swipltuts/html/
Uso: para efectos académicos.
Ver:
Http-Programming
http://www.swi-prolog.org/pldoc/doc_for?object=section(%27packages/http.html%27)
JSON Support
http://www.swi-prolog.org/pldoc/man?section=jsonsupport
RECORDS Support
http://www.swi-prolog.org/pldoc/man?section=record

*/
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_error)).
:- use_module(library(http/html_write)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_files)).
:- use_module(library(http/http_log)).
:- use_module(library(http/json)).         % provides support for the core JSON object serialization.
:- use_module(library(http/json_convert)). % converts between the primary representation of JSON terms in Prolog 
                                           % and more application oriented Prolog terms. 
										   % E.g. point(X,Y) vs. object([x=X,y=Y]).
:- use_module(library(http/http_json)). 
:- use_module(library(http/http_client)). 
 :- [grafos].
:- multifile http:location/3.
:- dynamic   http:location/3.

% Response JSON object
:- json_object response(ok:boolean).


http:location(files, '/f', []).

/* 
   Predicate server(+Port) starts the server. It simply creates a
   number of Prolog threads and then returns to the toplevel, so you can (re-)load code, debug, etc.
*/
server(Port) :-
        http_server(http_dispatch, [port(Port)]).
stop_server(Port) :- http_stop_server(Port,[]).

%  Paths (routes)
:- http_handler('/hi', say_hi, []).
:- http_handler('/error', say_error, []).
:- http_handler('/json', say_json, []).
% this serves files from the directory assets
% under the working directory
:- http_handler(files(.), serve_files, [prefix]).

serve_files(Request) :-
	 http_reply_from_files('assets', [], Request).
serve_files(Request) :-
	  http_404([], Request).

% Controllers	  
say_hi(Request) :-
	catch(http_parameters(Request, [id(I, [])]), _, I='param is missing'),
	reply_html_page(
	   [title('Swi Prolog'), \html_receive(css),  \html_receive(js)],
	   [h1('A Simple Web Page'),
	    \css('/f/specialstyle.css'),
		 \js('/f/script.js'),
	    p('With some text'), p(I),
		button([id('btn')], 'click me')
		]).

say_error(_Request) :-
	reply_html_page(
	   [title('Invalid')],
	   [h1('Invalid id in request')]).
	
say_json(Request) :-
      http_read_json(Request, JSONIn),
      json_to_prolog(JSONIn, PrologIn),
	    assert(xx(PrologIn)),
      retractall(xx(_)),
      assert(xx(PrologIn)),
      respondJson(PrologIn, PrologOut),		
      prolog_to_json(PrologOut, JSONOut),
      reply_json(JSONOut).

 %respondJson(_, response(true)).

:- json_object respuesta(arc:list).
respondJson(_, respuesta(L)) :- generate_graph, circuit(L).	  
 
css(URL) -->
        html_post(css,
                  link([ type('text/css'),
                         rel('stylesheet'),
                         href(URL)
                       ])).
js(URL) -->
        html_post(js,
                  script([ src(URL),
                           type('text/javascript')
                               ], [])).