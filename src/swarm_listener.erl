%%
%% Copyright (C) 2012 Jeremey Barrett <jlb@rot26.com>
%%
%% Permission is hereby granted, free of charge, to any person obtaining
%% a copy of this software and associated documentation files (the
%% "Software"), to deal in the Software without restriction, including
%% without limitation the rights to use, copy, modify, merge, publish,
%% distribute, sublicense, and/or sell copies of the Software, and to
%% permit persons to whom the Software is furnished to do so, subject to
%% the following conditions:
%%
%% The above copyright notice and this permission notice shall be
%% included in all copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
%% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
%% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
%% NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
%% LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
%% OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
%% WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
%%

-module(swarm_listener).

-export([start_link/5]).
-export([run/5,acceptor/5]).

-include("../include/swarm.hrl").

start_link(Name, AcceptorCount, Transport, TransOpts, {M, F, A}) ->
    Pid = spawn_link(?MODULE, run,
                     [Name, AcceptorCount, Transport, TransOpts, {M, F, A}]),
    {ok, Pid}.


run(Name, AcceptorCount, Transport, TransOpts, {M, F, A}) ->
    process_flag(trap_exit, true),
    {ok, LSock} = Transport:listen(TransOpts),
    SpawnArgs = [self(), Name, LSock, Transport, {M, F, A}],
    [spawn_link(?MODULE,acceptor,SpawnArgs) || _ <- lists:seq(1, AcceptorCount)],
    State = {Name,SpawnArgs,AcceptorCount},
    loop(State, 0, 0, 0).


loop({_Name, SpawnArgs, _Acceptors} = State, Count, RunningCount, ErrorCount) ->
    ?DEBUG("~s configured acceptors: ~p, actual: ~p, running: ~p, errored: ~p", 
           [_Name, _Acceptors, Count, RunningCount, ErrorCount]),
    receive
        listening -> 
            loop(State, Count+1, RunningCount, ErrorCount);

        accepted ->
            spawn_link(?MODULE, acceptor, SpawnArgs),
            loop(State, Count-1, RunningCount+1, ErrorCount);

        {'EXIT', _FromPid, normal} -> 
            loop(State, Count, RunningCount-1, ErrorCount);

        {'EXIT', _FromPid, _Reason} ->
            ?DEBUG("~s child pid ~p died with reason ~p",
                                                    [_Name,_FromPid,_Reason]),
            loop(State, Count, RunningCount-1, ErrorCount+1);

        _ -> loop(State, Count, RunningCount, ErrorCount)
    end.


acceptor(LPid, Name, LSock, Transport, {M, F, A}) ->
    LPid ! listening,
    Accept = Transport:accept(LSock),
    LPid ! accepted,
    case Accept of
        {ok, S} ->
            erlang:apply(M, F, [S, Name, Transport, get_info(Transport, S)]++A);
        {error, closed} ->
            ?DEBUG("~s Transport:accept received {error, closed}", [Name]);
        Error -> ?ERROR("~s Transport:accept error ~p", [Name, Error])
    end.


get_info(Transport, Socket) ->
    {ok, {Addr, Port}} = Transport:peername(Socket),
    DN = Transport:dn(Socket),
    #swarm_info{peer_addr = Addr, peer_port = Port, peer_dn = DN}.


