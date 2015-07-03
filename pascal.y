%{
#include "global.h"
#include "util.h"
%}

%union {
	TreeNode *syntaxTree;
}

%type <syntaxTree> program program_head routine
%type <syntaxTree> expression expr factor term  // 常数名 类型 函数名 变量名

%token NAME

// OP
%token DOT EQUAL LB RB LP RP ASSIGN GE GT LE LT UNEQUAL 
%token PLUS MINUS MUL MOD DIV OR AND NOT

// 保留字
%token PROGRAM TYPE OF RECORD CONST BEGIN END FUNCTION PROCEDURE ARRAY
%token IF THEN ELSE REPEAT UNTIL FOR DO TO DOWNTO CASE GOTO WHILE LABEL VAR 

%token COLON COMMA SEMI DOTDOT	

%token SYS_PROC SYS_TYPE READ // see doc

%%
program: program_head  routine  DOT {
	$$ = createTreeNodeStmt(PROGRAM);
	syntaxTreeRoot = $$;
	$$->child = $1;
	$1->sibling = $2;
}
;
program_head: PROGRAM  NAME  SEMI
;
routine: routine_head  routine_body {
	$$ = createTreeNodeStmt(ROUTINE);
	$$->child = $1;
	$1->sibling = $2;
}
;
sub_routine: routine_head  routine_body {
	$$ = createTreeNodeStmt(SUB_ROUTINE);
	$$->child = $1;
	$1->sibling = $2;
}
;

routine_head: label_part  const_part  type_part  var_part  routine_part {
	$$ = createTreeNodeStmt(ROUTINE_HEAD);
	$$->child = $1;
	$1->sibling = $2; $2->sibling = $3; $3->sibling = $4; $4->sibling = $5;
}
;
label_part: 
;
const_part: CONST const_expr_list {
	$$ = createTreeNodeStmt(CONST_PART);
	$$->child = $2;
}
|;
const_expr_list: const_expr_list  NAME  EQUAL  const_value  SEMI {
			$4->attr.symbolName = (char*)malloc(sizeof($2));
			strcpy(p->attr.symbolName, $2);
			$$ = createTreeNodeStmt(CONST_EXPR_LIST);
			$$->child = $1;
			$1->sibling = $4;
		}
		|  NAME  EQUAL  const_value  SEMI {
			$3->attr.symbolName = (char*)malloc(sizeof($1));
			strcpy(p->attr.symbolName, $1);
			$$ = createTreeNodeStmt(CONST_EXPR_LIST);
			$$->child = $3;
		}
;
const_value: INTEGER {
				$$ = createTreeNodeConstant();
				$$->type = INTEGER;
				$$->attr.value.integer = atoi($1);
			}
			|  REAL {
				$$ = createTreeNodeConstant();
				$$->type = REAL;
				$$->attr.value.real = atof($1);
			}
			|  CHAR {
				$$ = createTreeNodeConstant();
				$$->type = CHARACTER;
				$$->attr.value.character = $1[0];
			}  
			|  STRING {
				$$ = createTreeNodeConstant();
				$$->type = STRING;
				$$->attr.value.string = (char*)malloc(sizeof($1));
				strcpy($$->attr.value.string, $1);
			}
			|  SYS_CON {
				$$ = createTreeNodeConstant();
				if (strcmp($1,"false")==0) {
					$$->type = BOOLEAN;
					$$-attr.value.boolean = 0;
				} else if (strcmp($1,"true")==0) {
					$$->type = BOOLEAN;
					$$-attr.value.boolean = 1;
				} else if (strcmp($1,"maxint")==0) {
					$$->type = INTEGER;
					$$-attr.value.integer = INT_MAX;
				} else {
					$$->type = INTEGER;
					$$-attr.value.integer = 0;
				}
			};

type_part: TYPE type_decl_list {
				$$ = createTreeNodeStmt(TYPE_PART);
				$$->child = $2;
			}
|;
type_decl_list: type_decl_list  type_definition {
					$$ = createTreeNodeStmt(TYPE_DECL_LIST);
					$$->child = $1;
					$1->sibling = $2;
				}
				| type_definition {
					$$ = createTreeNodeStmt(TYPE_DECL_LIST);
					$$->child = $1;
				}
;
type_definition: NAME  EQUAL  type_decl  SEMI
;
type_decl: simple_type_decl  |  array_type_decl  |  record_type_decl
;
simple_type_decl: SYS_TYPE  |  NAME  |  LP  name_list  RP  
		|  const_value  DOTDOT  const_value  
		|  MINUS  const_value  DOTDOT  const_value
		|  MINUS  const_value  DOTDOT  MINUS  const_value
		|  NAME  DOTDOT  NAME
;
array_type_decl: ARRAY  LB  simple_type_decl  RB  OF  type_decl
;
record_type_decl: RECORD  field_decl_list  END
;

field_decl_list: field_decl_list  field_decl  |  field_decl
;
field_decl: name_list  COLON  type_decl  SEMI
;
name_list: name_list  COMMA  NAME  
		|  NAME
;
var_part: VAR  var_decl_list {
	$$ = createTreeNodeStmt(VAR_PART);
	$$->child = $2;
}
|;
var_decl_list : var_decl_list  var_decl {
					$$ = createTreeNodeStmt(VAR_DECL_LIST);
					$$->child = $1;
					$1->sibling = $2;
			 	}
			 	|  var_decl {
			 		$$ = createTreeNodeStmt(VAR_DECL_LIST);
			 		$$->child = $1;
			 	}
;
var_decl :  name_list  COLON  type_decl  SEMI {
				$$ = createTreeNodeStmt(VAR_DECL);
				$$->child = $1;
				$1->sibling = $3;
			}
;
routine_part: routine_part  function_decl {
				$$ = createTreeNodeStmt(ROUTINE_PART);
				$$->child = $1;
				$1->sibling = $2;
			}
		|  routine_part  procedure_decl {
			$$ = createTreeNodeStmt(ROUTINE_PART);
			$$->child = $1;
			$1->sibling = $2;
		}
		|  function_decl {
			$$ = createTreeNodeStmt(ROUTINE_PART);
			$$->child = $1;
		}
		|  procedure_decl {
			$$ = createTreeNodeStmt(ROUTINE_PART);
			$$->child = $1;
		}
		| ;
function_decl : function_head  SEMI  sub_routine  SEMI {
					$$ = createTreeNodeStmt(FUNCTION_DECL);
					$$->child = $1;
					$1->sibling = $3;
				};
function_head :  FUNCTION  NAME  parameters  COLON  simple_type_decl {
					$$ = createTreeNodeStmt(FUNCTION_HEAD);
					$$->attr.symbolName = (char*)malloc(sizeof($2));
					strcpy($$->attr.symbolName, $2);
					// function_head saved the name of function
					$$->child = $3;
					$3->sibling = $5;
				};
procedure_decl :  procedure_head  SEMI  sub_routine  SEMI
					$$ = createTreeNodeStmt(PROCEDURE_DECL);
					$$->child = $1;
					$1->sibling = $3;
				};
procedure_head :  PROCEDURE NAME parameters 
					$$ = createTreeNodeStmt(PROCEDURE_HEAD); 
					$$->attr.symbolName = (char*)malloc(sizeof($2));
					strcpy($$->attr.symbolName, $2);
					// procedure_head saved the name of function
					$$->child = $3;
				};
parameters: LP  para_decl_list  RP {
			$$ = createTreeNodeStmt(PARAMETERS);
			$$->child = $2;
}
|;
para_decl_list: para_decl_list  SEMI  para_type_list {
					$$ = createTreeNodeStmt(PARA_DECL_LIST);
					$$->child = $1;
					$1->sibling = $3;
				}
				| para_type_list {
					$$ = createTreeNodeStmt(PARA_DECL_LIST);
					$$->child = $1;
				};
para_type_list: var_para_list COLON  simple_type_decl {
					$$ = createTreeNodeStmt(PARA_TYPE_LIST);
					$$->child = $1;
					$1->sibling = $3;
				}  
;
var_para_list: VAR name_list {
					
				};
val_para_list: name_list
;
routine_body: compound_stmt
;
compound_stmt: BEGIN  stmt_list  END
;
stmt_list: stmt_list  stmt  SEMI  |  
;
stmt: INTEGER  COLON non_label_stmt  
	|  non_label_stmt
;
non_label_stmt: assign_stmt | proc_stmt | compound_stmt | if_stmt | repeat_stmt | while_stmt 
| for_stmt | case_stmt | goto_stmt
;
assign_stmt: NAME  ASSIGN  expression
           | NAME LB expression RB ASSIGN expression
           | NAME  DOT  NAME  ASSIGN  expression
;
proc_stmt: NAME
          |  NAME  LP  args_list  RP
          |  SYS_PROC
          |  SYS_PROC  LP  expression_list  RP
          |  READ  LP  factor  RP
;
if_stmt: IF  expression  THEN  stmt  else_clause
;
else_clause: ELSE stmt | 
;
repeat_stmt: REPEAT  stmt_list  UNTIL  expression
;
while_stmt: WHILE  expression  DO stmt
;
for_stmt: FOR  NAME  ASSIGN  expression  direction  expression  DO stmt
;
direction: TO | DOWNTO
;
case_stmt: CASE expression OF case_expr_list  END
;
case_expr_list: case_expr_list  case_expr  |  case_expr
;
case_expr: const_value  COLON  stmt  SEMI
          |  NAME  COLON  stmt  SEMI
;
goto_stmt: GOTO  INTEGER
;
expression_list: expression_list  COMMA  expression  |  expression
;
expression: expression  GE  expr  
		|  expression  GT  expr 
		|  expression  LE  expr
		|  expression  LT  expr  
		|  expression  EQUAL  expr  
		|  expression  UNEQUAL  expr  
		|  expr
;
expr: expr  PLUS  term  |  expr  MINUS  term  |  expr  OR  term  |  term
;
term: term  MUL  factor  
	|  term  DIV  factor  
	|  term  MOD  factor 
	|  term  AND  factor  
	|  factor
 ;
factor: NAME  
	|  NAME  LP  args_list  RP  
	|  SYS_FUNCT
	|  SYS_FUNCT  LP  args_list  RP  
	|  const_value  
	|  LP  expression  RP 
	|  NOT  factor  
	|  MINUS  factor  
	|  NAME  LB  expression  RB
	|  NAME  DOT  NAME
;
args_list: args_list  COMMA  expression  {

	}
	|  expression {
		
	}
}
;

%%

int main()
{
	return yyparse();
}

