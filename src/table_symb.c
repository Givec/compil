#include "../include/table_symb.h"


int getIdAddrOnStack(char* id, int stack_max){
	int i;
	char err_msg[80];
	
	for(i=0; i<stack_max; i++){
		if(strcmp(table_symb[i].id, id) == 0)
			return i;
	}
	strcpy(err_msg, "Uninitialized variable ");
	strcat(err_msg, id);	
	
	yyerror(err_msg);
	exit(EXIT_FAILURE);
}

void putOnStack(int addr, int val){
	/* On sauve reg1 et reg2 DANS L'ORDRE */
	inst("PUSH"); /* On sauve reg1 */
	instarg("SET", addr); /* On sauve l'addresse dans le reg1 */
	inst("SWAP"); /* On swap pour avoir addr dans reg2 */
	inst("PUSH"); /* on sauve reg2 */
	instarg("SET", val); /* on met la valeur a sauvegarder dans reg1 */
	inst("SAVE");
	inst("POP"); /* on rétablie reg2 */
	inst("SWAP");
	inst("POP"); /* On retablie reg1 */

}

/* Check if the symb id is const */
int verifyConst(const char* id){
	int i;
	
	for(i=0; i<table_symb_size; i++){
		if(strcmp(table_symb[i].id, id) == 0)
			return table_symb[i].is_const;
	}
	return -1;	
}

void initTableSymb(){
	
	table_symb = (symb*)malloc(sizeof(symb));
	table_symb_size = 1;
	if(table_symb == NULL)
		fprintf(stderr, "Initialisation failure\n");
	
}

void initTableFun(){
	
	table_fun = (fun_ident*)malloc(sizeof(fun_ident));
	table_fun_size = 1;
	if(table_fun == NULL)
		fprintf(stderr, "Initialisation failure\n");
	
}

void add_fun(const char* id, int nb_param, int addr){
	static index = 0;
	
	if(index >= table_fun_size){
		table_fun_size++;
		table_fun = (fun_ident*) realloc(table_fun, sizeof(fun_ident) * table_fun_size);
		if(table_symb == NULL)
			fprintf(stderr, "Initialisation failure\n");
	}

	memcpy(table_fun[index].id, id, strlen(id));
	table_fun[index].nb_param = nb_param;
	table_fun[index].addr_fun = addr;
	
	index++;
	
}	

void add_symb(const char* id, int is_const, int addr, int cur_fun_index){
	static int index = 0;
	
	symb* tmp = NULL;
	int* tmp_size = NULL;
	
	if(cur_fun_index == -1){
		tmp = table_symb;
		tmp_size = &table_symb_size;
	} else {
		tmp = table_fun[cur_fun_index].variables;
		tmp_size = table_fun[cur_fun_index].nb_alloc;
	}		
	
	if(index >= *tmp_size){
		*tmp_size++;
		tmp = (symb*) realloc(tmp, sizeof(symb) * (*tmp_size));
		if(tmp == NULL)
			fprintf(stderrn, "Initialisation failure\n");
	}
	
	memcpy(tmp[index].id, id, strlen(id));
	tmp[index].is_const = is_const;
	tmp[index].addr_stack = addr;
	
	index++;
}

void putArgsAndStartFun(int stack_cur, char* id){
	
	
	
}
