# Make INTerceptor #

**Mint** is a `bash` tool that generates a JSON compilation database.

The [JSON compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html) contains full information on how to parse a translation unit.   
So that the tools based on the C/C++ Abstract Syntax Tree can parse a translation unit independently.

## Why ##

It's not easy to generate compilation database under the pure `make` system.  
Athough there are already some tools<sup>[1](#footnote1)</sup> for this job, making them work well is difficult.  

## How it works ##
**Mint** intercepts the implicit variables `CC` and `CXX` in order to receive the compilation commands from `make` and `shell`.  
And then **Mint** parses the compilation commands and generates a JSON compilation database.  

## Usage ##

    mint.sh [make options] [-- [-a] [-d] [-h] [-o db_file]]
     -a           use 'arguments' instead of 'command' field in compilation database
     -d           print debug message
     -h           display this help and exit
     -m           tspecify path or name of 'make'
     -o db_file   write output to the db_file

Enter the directory you run `make` generally, invoke `mint.sh` instead. For example,  

    /path/to/mint.sh -Bkj all -- -o compile_commands.json

## Testing ##
Already tested under Macosx Sierra 10.12.6 and Ubuntu 16.04.

## Issues ##
If you find a bug, please report it to the issue tracker. Please give the detailed description such as OS, projects and so on.

## Contribution ##
Any suggestion and pull request is welcomed :)

## License ##
MIT.
&nbsp;

&nbsp;

<a name="footnote1">1</a>: [Bear](https://github.com/rizsotto/Bear), [compiledb-generator](https://github.com/nickdiego/compiledb-generator) etc.
