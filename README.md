# Pascal Compiler for ZJU course project

## team member:
- 王力宁 3120000405
- 朱稼乐 3120000346
- 龚源   3120000381

## How to compile
You need to compile this project in Linux. The following instructions are for Ubuntu.

### dependencies
- gcc
- yacc
- flex
- clang
- python (a python script is used to debug)

### instructions

Build the project
```
$> make
```

Build test programs for lex
```
$> make test
```

Clear built files
```
$> make clean
```

Show lex results for a pas file. See utils/README.md for an example.
```
$> utils/token.bash < path/to/pascal_file.pas
```

Setting YYDEBUG environment variable to 1 will enable debug info.
```
$> export YYDEBUG=1
```

Compile a pas file to llvm assembly. (Not yet finished, only has the most limited functionality.)
```
./run.bash
```

Run llvm assembly directly
```
lli path/to/llvm_assembly_file.ll
```
