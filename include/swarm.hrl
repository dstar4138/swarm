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

-ifndef(swarm_hrl).
-define(swarm_hrl, 1).

-record(swarm_dn, {c     = [], 
                   st    = [], 
                   l     = [], 
                   o     = [], 
                   ou    = [], 
                   cn    = [], 
                   email = []}).
                     
-record(swarm_info, {peer_addr :: string(),
                     peer_port :: integer(),
                     peer_dn = #swarm_dn{}}).

-ifdef(debug).
-define(DEBUG(Msg),error_logger:info_report( Msg )).
-define(DEBUG(Msg,Fmt),error_logger:info_report( io_lib:format(Msg, Fmt) )).
-else.
-define(DEBUG(Msg),ok).
-define(DEBUG(Msg,Fmt),ok).
-endif.

%% Explicit Error Message formatting. 
-define(ERROR(Msg),exit({Msg,erlang:get_stacktrace()})).
-define(ERROR(Msg,Fmt),exit({io_lib:format(Msg,Fmt),erlang:get_stacktrace()})).

-endif.
