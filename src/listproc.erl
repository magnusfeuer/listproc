%%
%% Parallel list processing
%%

-module(listproc).


-export([process_list/2,
	 process_file/2,
	 do_work/1]).

-callback process(list()) -> list().


process_list(Module, List) ->
    io:format("Processing list~n"),
    { USec, Val } = timer:tc(Module, process, [List]),
    io:format("Processing time: ~p msec~n", [ round(USec/ 1000)]),
    Val.

process_file(Module, FileName) ->
    io:format("Loading ~p~n", [ FileName]),
    { ok, [List]} = file:consult(FileName),
    process_list(Module, List).

do_work(Value) ->
    microsleep(Value),
    Value * 2.

%% Stolen and stripped from the web
microsleep(MicroSec) ->
    Target = add_microsec(MicroSec, now()),
    busywait_until(Target),
    ok.


add_microsec(Micro, {Mega0, Sec0, Micro0}) ->
    Micro1 = Micro0 + Micro,
    Sec1 = Sec0 + (Micro1 div 1000000),
    Mega1 = Mega0 + (Sec1 div 1000000),
    {Mega1, (Sec1 rem 1000000), (Micro1 rem 1000000)}.

busywait_until(Target) ->
    case now() of
	Now when Now >= Target ->
	    ok;
	_ ->
	    erlang:yield(),
	    busywait_until(Target)
    end.




















