ERL_INCLUDE_PATH=$(shell erl -eval 'io:format("~s~n", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)

all: priv/nifs.so

priv/nifs.so: src/nifs.c src/perlin.c src/chunk.c
	cc -Wall -Wextra -Wpedantic -O3 -fPIC -shared -std=c99 -I$(ERL_INCLUDE_PATH) -o priv/nifs.so src/nifs.c src/perlin.c src/chunk.c
