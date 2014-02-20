
all: compile


deps:
	rebar get-deps


debug:
	rebar -Ddebug compile


compile:
	rebar compile


clean:
	rebar clean


distclean: clean
	rm -rf deps log


.PHONY: deps

