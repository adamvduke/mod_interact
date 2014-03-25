%%%----------------------------------------------------------------------

%%% File    : mod_unavailable_post.erl
%%% Author  : Adam Duke <adam.v.duke@gmail.com>
%%% Purpose : Forward offline presence notifications to a url
%%% Created : 12 Feb 2012 by Adam Duke <adam.v.duke@gmail.com>
%%%
%%%
%%% Copyright (C) 2012   Adam Duke
%%%
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License as
%%% published by the Free Software Foundation; either version 2 of the
%%% License, or (at your option) any later version.
%%%
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%%% General Public License for more details.
%%%
%%% You should have received a copy of the GNU General Public License
%%% along with this program; if not, write to the Free Software
%%% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
%%% 02111-1307 USA
%%%
%%%----------------------------------------------------------------------

-module(mod_unavailable_post).
-author('adam.v.duke@gmail.com').

-behavior(gen_mod).

-export([start/2,
	 init/2,
	 stop/1,
	 send_unavailable_notice/4]).

-define(PROCNAME, ?MODULE).

-include("ejabberd.hrl").
-include("jlib.hrl").
-include("logger.hrl").

start(Host, Opts) ->
    ?INFO_MSG("Starting mod_unavailable_post", [] ),
    register(gen_mod:get_module_proc(Host, ?PROCNAME),
	     proc_lib:spawn(?MODULE, init, Opts)),
%%    register(?PROCNAME,spawn(?MODULE, init, [Host, Opts])),  
    ok.

%%% unset_presence_hook(User, Server, Resource, Status) -> void()
init(Host, _Opts) ->
    inets:start(),
    ssl:start(),
    ejabberd_hooks:add(unset_presence_hook, Host, ?MODULE, send_unavailable_notice, 10),
    ok.

stop(Host) ->
    ?INFO_MSG("Stopping mod_unavailable_post", [] ),
    ejabberd_hooks:delete(unset_presence_hook, Host,
			  ?MODULE, send_unavailable_notice, 10),
    ok.

send_unavailable_notice(User, Server, _Resource, _Status) ->
    Token = gen_mod:get_module_opt(Server, ?MODULE, auth_token, fun(S) -> iolist_to_binary(S) end, list_to_binary("")),
    PostUrl = gen_mod:get_module_opt(Server, ?MODULE, post_url, fun(S) -> iolist_to_binary(S) end, list_to_binary("")),
    if (Token /= "") ->
	      Sep = "&",
	      Post = [
	        "jabber_id=", User, Sep,
	        "access_token=", Token ],
	      ?INFO_MSG("Sending post request ~p~n",[Post] ),
	      httpc:request(post, {binary_to_list(PostUrl), [], "application/x-www-form-urlencoded", list_to_binary(Post)},[],[]),
	      ok;
	    true ->
	      ok
    end.

