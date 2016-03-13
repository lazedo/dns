%% Copyright (c) 2012-2016 Peter Morgan <peter.james.morgan@gmail.com>
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%% http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(dns_node).

-export([add/5]).
-export([find/3]).
-export([remove/3]).
-export([remove/5]).

-on_load(on_load/0).

on_load() ->
    crown_table:new(?MODULE, bag).


-record(?MODULE, {
           name,
           class,
           type,
           nct,
           ttl = 0,
           data
          }).

add(Name, Class, Type, TTL, Data) ->
    ets:insert(?MODULE, [r(Name, Class, Type, TTL, Data)]).

r(Name, Class, Type, TTL, Data) ->
    #?MODULE{name = Name, class = Class, type = Type, ttl = TTL, data = Data}.

find(Name, Class, Type) ->
    case ets:match_object(?MODULE, r(Name, Class, Type, '_', '_')) of
        [] ->
            not_found;

        Matches ->
            [as_map(Match) || #?MODULE{} = Match <- Matches]
    end.

remove(Name, Class, Type) ->
    ets:match_delete(?MODULE, r(Name, Class, Type, '_', '_')).

remove(Name, Class, Type, TTL, Data) ->
    ets:delete_object(?MODULE, r(Name, Class, Type, TTL, Data)).

as_map(#?MODULE{name = Name,
                class = Class,
                type = Type,
                ttl = TTL,
                data = Data}) ->
    #{labels => Name, class => Class, type => Type, ttl => TTL, data => Data}.
