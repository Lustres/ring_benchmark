%%%-------------------------------------------------------------------
%% @doc Ring benchmark for Erlang
%% @end
%%%-------------------------------------------------------------------

-module(ring_benchmark).
-export([start/2]).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Start the benchmark
%% @spec start(ProcessCount, Times) -> ok
%% @end
%%--------------------------------------------------------------------

start(ProcessCount, Times) ->
    RootPid = spawn(fun()-> rootLoop(true, 1, Times) end),
    statistics(wall_clock),

    %% create processes
    RootPid ! {set, lists:foldl(
                        fun(_, Pid)->
                            spawn(fun()-> loop(Pid) end)
                        end,
                        RootPid,
                        lists:seq(1, ProcessCount))},

    {_ ,Time} = statistics(wall_clock),
    io:format("spawn process use: ~p msec.~n", [Time]),

    %% start round
    _ = [RootPid ! test || _ <- lists:seq(1, Times)],
    ok.

%%%===================================================================
%%% Internal functions
%%%===================================================================

rootLoop(State, Round, Times) ->
    receive
        stop ->
            if
                is_pid(State) ->
                    State ! stop,
                    void;

                true -> void
            end;

        %% dom send
        {set, Pid} when is_pid(Pid)  ->
            % io:format("Has Set Pid~n"),
            rootLoop(Pid, Round, Times);

        % %% loop send msg
        {send, _Msg} when Round < Times ->
            % io:format("Back~n"),
            rootLoop(State, Round + 1, Times);

         {send, _Msg} when Round =:= Times ->
            {_ ,Time} = statistics(wall_clock),
            io:format("Loop message use: ~p msec.~n", [Time]),
            io:format("Finished~n"),
            State ! stop,
            void;

        Msg when is_pid(State)  ->
            State ! {send, Msg},
            rootLoop(State, Round, Times);

        _any ->
            rootLoop(State, Round, Times)
    end.

%%--------------------------------------------------------------------

loop(Next) ->
    receive
        stop ->
            Next ! stop,
            % io:format("Stoped~n"),
            void;

        {send, Msg} ->
            % io:format("Get Msg~n"),
            Next ! {send, Msg},
            loop(Next);

        _Any -> loop(Next)

    end.
