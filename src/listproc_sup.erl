
-module(listproc_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    C = {listproc, {listproc, start_link, []}, transient, 5000, worker, [listproc]},
    {ok, { {one_for_one, 5, 10}, [C]} }.

