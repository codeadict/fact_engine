%% Everything between `Definitions.` and `Rules.` is a macro and value.
%%
%% Defintion Format:
%% Macro         = Value
Definitions.

Command = (INPUT|QUERY)
Predicate  = [a-z_?]+[\s]+?\(
Space = [\s\r\n\t]+
Number = [0-9]+
Args     = [A-Za-z_][0-9a-zA-Z_/-]*


%% Everything betweeen `Rules.` and `Erlang code.` represent regular
%% expressions transformed into erlang code. They use the
%% defintions from above. The order of rules matter here.
%%
%% Rule Format:
%% Regular Expression    : erlang code
Rules.

{Command}                : {token, {cmd, to_lower_atom(TokenChars)}}.
{Number}                 : {token, {number, list_to_integer(TokenChars)}}.
{Number}[.]{Number}+     : {token, {number, list_to_float(TokenChars)}}.
{Predicate}              : {token, {fact, cleanup_predicate(TokenChars)}}.
{Args}                   : {token, parse_param(TokenChars)}.
[(),]                    : skip_token.
{Space}                  : skip_token.

% Any erlang can be added here to assist processing in `Rules.`
Erlang code.

parse_param([Hd|_] = TokenChars) when Hd >= $A, Hd =< $Z ->
	{var, list_to_atom(TokenChars)};
parse_param([Hd|_] = TokenChars) when Hd >= $a, Hd =< $z ->
	{atom, list_to_atom(TokenChars)}.

to_lower_atom(Str) ->
	list_to_atom(string:to_lower(Str)).

cleanup_predicate(Str) ->
	TrimmedStr = string:trim(lists:droplast(Str)),
	iolist_to_binary(TrimmedStr).
