ERL_INCLUDE_PATH=$(shell erl -eval 'io:format("~s~n", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)

all: priv/world.so

priv/world.so: src/world.c
	cc -Wall -Wextra -Wpedantic -O3 -fPIC -shared -std=c99 -I$(ERL_INCLUDE_PATH) -o priv/world.so src/world.c
