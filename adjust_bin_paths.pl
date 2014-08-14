/** <module> adjust_bin_paths
 *
 *  change all scripts in thea/bin having #!/usr/bin/swipl to actual swipl executable
 *  --------
 *  @author carlo
 */

:- module(adjust_bin_paths, [adjust_bin_paths/0]).

:- use_module(library(readutil)).
:- use_module(library(process)).
:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(debug)).

%%  adjust_bin_paths is det.
%
%   Describe this default entry point.
%
adjust_bin_paths :-
	get_swipl_path(Swipl),
	expand_file_name('bin/*', L),
	maplist(adjust_bin_path(Swipl), L).

adjust_bin_path(Swipl, Script) :-
	file_name_extension(Script, '', Script),
	read_file_to_codes(Script, Cs, []),
	atom_codes("#!/usr/bin/swipl", PCs),
	append(PCs, R, Cs),
	debug(adjust_bin_paths, 'ok ~s', Script),
	open(Script, write, S),
	format(S, '~s~s', [Swipl, R]),
	close(S),
	process_create(path(chmod), ['+x', file(Script)], []),
	print_message(informational, path_adjusted(Script, Swipl)).

adjust_bin_path(_Swipl, P) :-
	debug(adjust_bin_paths, 'no ~s', P).

get_swipl_path(Swipl) :-
	process_create(path(which), [swipl], [stdout(pipe(S))]),
	read_line_to_codes(S, Swipl).

:- multifile
        prolog:message//1.

prolog:message(path_adjusted(Script, Swipl)) -->
        [ 'script ~s, path adjusted to ~s'-[Script, Swipl] ].
