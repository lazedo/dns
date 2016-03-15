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

-module(dns_res).
-export([lookup/3]).


lookup(Name, Class, soa) ->
    dns_node:find(Name, Class, soa);

lookup(Name, Class, Type) ->
    case dns_node:find(Name, Class, Type) of

        not_found ->
            case has_soa(Name, Class) of
                true ->
                    not_found;
                false ->
                    recursive(Name, Class, Type)
            end;

        Resources ->
            Resources
    end.

has_soa([_ | Domain] = Name, Class) ->
    case dns_node:find(Name, Class, soa) of
        not_found ->
            has_soa(Domain, Class);

        _ ->
            true
    end;
has_soa([], _) ->
    false.




recursive(Name, Class, Type) ->
    case resolve(dns_name:stringify(Name), Class, Type) of

        {error, {nxdomain, _}} ->
            not_found;

        {error, formerr} ->
            not_found;

        {error, timeout} ->
            error_logger:error_report([{module, ?MODULE},
                                       {line, ?LINE},
                                       {name, Name},
                                       {class, Class},
                                       {type, Type}]),
            not_found;

        {ok, Response} ->
            [translate(Answer) || Answer <- inet_dns:msg(Response, anlist)]
    end.


resolve(Name, Class, Type) ->
    case dns_config:nameservers() of
        [] ->
            inet_res:resolve(Name, Class, Type);

        Nameservers ->
            inet_res:resolve(
              Name,
              Class,
              Type,
              [{nameservers, Nameservers}])
    end.


translate(Resource) ->
    resource(maps:from_list(inet_dns:rr(Resource))).


resource(#{type := ptr, data := Data} = Resource) ->
    label(maps:without([data], Resource#{name => dns_name:labels(Data)}));

resource(#{type := cname, data := Data} = Resource) ->
    label(Resource#{data := dns_name:labels(Data)});

resource(#{type := aaaa} = Resource) ->
    label(Resource);

resource(#{type := a} = Resource) ->
    label(Resource).

label(#{domain := Domain} = Resource) ->
    maps:without([domain], Resource#{labels => dns_name:labels(Domain)}).
