# Make INTerceptor #

**Mint** is a tool that generates a JSON compilation database.

The [JSON compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html) contains full information on how to parse a translation unit. So that the tools based on the C/C++ Abstract Syntax Tree can parse a translation unit independently.

## Why ##

It's not easy to generate compilation database under the pure `make` system.
Athough there are already some tools[^1] for this job, making them work well is different.

## How it works ##

**Mint** intercepts the implicit variables `CC` and `CXX` in order to receive the compilation commands from `make` and `shell`.
And then **Mint** parses the compilation commands and generates a JSON compilation database.

## Usage ##

make-wrapper.sh [make options] [-- [-a] [-d] [-h] [-o db_file]]
 -a		use 'arguments' instead of 'command' field in compilation database
 -d		print debug message
 -h		display this help and exit
 -o 	db_file	write output to the db_file

[^1]: [Bear](https://github.com/rizsotto/Bear), [compiledb-generator](https://github.com/nickdiego/compiledb-generator)
