%%
%% First shot at parallel processing. Quite pathetic
%%

-module(worker1).

-behaviour(listproc).

-export([process/1]).


process(List) ->
    Self = self(),
    Schedulers = 4,
    %%Schedulers = erlang:system_info(schedulers),
    [ spawn(fun() -> 
		    worker_start(Self, List, WorkerID, Schedulers)
	    end) || WorkerID <- lists:seq(1,Schedulers)],

    collect_results(Schedulers, []).

collect_results(0, Result) ->
    %% FIXME: Merge lists correctly
    Result;

%% Sequentially grab all the results
collect_results(N, Result) ->
    receive 
	{ result, WorkerID, NewList } -> 
	    collect_results(N - 1, [{WorkerID, NewList} | Result]);
	XX -> io:format("Wut(~p)~n", [ XX])
    end.

worker_start(From, List, WorkerID, WorkerCount) ->
    %% Strip off aproriate number of elements from beginning of 
    %% list to get a staggered start.
    StaggeredStart = lists:nthtail(WorkerID - 1, List),    
    worker(From, StaggeredStart, WorkerID, WorkerCount, []).
    

%%FIXME: Monitoring
worker(From, [], WorkerID, _WorkerCount, St) ->
    From ! { result, WorkerID, St },
    exit(normal);

worker(From, [ V | Tail], WorkerID, WorkerCount, St) ->

    StaggeredTail = 
	%% Strip worker count elements of the front of the list,
	%% making the head our next element to process.
	try lists:nthtail(WorkerCount - 1, Tail) of
	    Res -> Res
	catch
	    %% Func clauset thrown if length(RemTmp) < WorkerCoxunt
	    error:_ -> [] 
	end,
    
    worker(From, StaggeredTail,WorkerID,  WorkerCount, [ listproc:do_work(V) | St ]).

