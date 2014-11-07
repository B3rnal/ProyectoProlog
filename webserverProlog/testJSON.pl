% http://www.swi-prolog.org/pldoc/man?section=jsonsupport
:- use_module(library(http/json)).
:- use_module(library(http/json_convert)).
:- use_module(library(http/http_json)).
:- json_object point(x:integer, y:integer).
:- json_object response(ok:boolean).

test:-
  prolog_to_json(response(true), JSON_Object),
  format(user_output, '~w', JSON_Object).