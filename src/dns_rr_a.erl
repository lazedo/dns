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

-module(dns_rr_a).

-export([decode/3]).
-export([encode/4]).

decode(_, <<IP1:8, IP2:8, IP3:8, IP4:8>>, _) ->
    {IP1, IP2, IP3, IP4}.


encode({IP1, IP2, IP3, IP4}, _, Packet, Offsets) ->
    {<<Packet/bytes, IP1:8, IP2:8, IP3:8, IP4:8>>, Offsets}.
