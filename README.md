# A Builder of Compilation Database #

**ABCD** is a `bash` tool that generates a JSON compilation database.

The [JSON compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html) contains full information on how to parse a translation unit.   
So that the tools based on the C/C++ Abstract Syntax Tree can parse a translation unit independently.

## Why ##

It's not easy to generate compilation database under the pure `make` system.  
Athough there are already some tools<sup>[1](#footnote1)</sup> for this job, making them work well is difficult.  

## How it works ##
**ABCD** intercepts the implicit variables `CC` and `CXX` in order to receive the compilation commands from `make` and `shell`.<sup>[2](#footnote2)</sup>  
And then **ABCD** parses the compilation commands and generates a JSON compilation database.  

## Usage ##

    abcd.sh [make options and target(s)] [-- [-a] [-d] [-h] [-m mk_name] [-o db_file]]
     -a           use 'arguments' instead of 'command' field in compilation database
     -d           print debug message
     -h           display this help and exit
     -m mk_name   specify path or name of 'make' such as 'gmake'
     -o db_file   write output to the db_file('./compile_commands.json' by default)

Enter the directory you run `make` generally, invoke `abcd.sh` instead. For example,  

    /path/to/abcd.sh -Bkj <target> -- -o compile_commands.json

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
<a name="footnote2">2</a>: **ABCD** also supports 'Scons'-built projects whose 'Sconstruct' exposes CC/CXX:

    /path/to/abcd.sh -j 8 <target> -- -m "scons" -o compile_commands.json    
