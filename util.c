#include "global.h"
#include "util.h"

void yyerror(char *s)
{
	fprintf(stderr, "%s\n", s);
}

TreeNode *createTreeNodeStmt(StmtType stmtType)
{
	TreeNode *p = (TreeNode*)malloc(sizeof(TreeNode));
	if (p==NULL) {
		yyerror("Malloc TreeNode Failed!\n");
		return NULL;
	}
	p->nodeKind = STMT;
	p->kind.stmtType = stmtType;
	p->child = p->sibling = NULL;
	return p;
}

TreeNode *createTreeNodeConstant()
{
	TreeNode *p = (TreeNode*)malloc(sizeof(TreeNode));
	if (p==NULL) {
		yyerror("Malloc TreeNode Failed!\n");
		return NULL;
	}
	p->nodeKind = EXP;
	p->kind.expKind = CONSTKIND;
	p->child = p->sibling = NULL;
	return p;
}

