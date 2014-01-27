%%
%% Reference, single threaded list processing.
%%

-module(reference).

-behaviour(listproc).

-export([process/1]).

process(List) ->
    [ listproc:do_work(Val) || Val <- List ]. 
