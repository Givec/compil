#include "../include/table_symb.h"

static symb* getTableOfFunctionByIndex(int cur_fun_index, int** table_size){
	if(cur_fun_index == -1){
		*table_size = &table_symb_size;
		return table_symb;
	}	
	
	*table_size = &(table_fun[cur_fun_index].nb_alloc);
	return table_fun[cur_fun_index].variables;
	
}

int getIdAddrOnStack(char* id, int cur_fun_index){
	
	char err_msg[80];
	
	int *size;
	symb* tmp_symb = getTableOfFunctionByIndex(cur_fun_index, &size);
	
	if(NULL != tmp_symb)
		return tmp_symb->addr;
	
	strcpy(err_msg, "Uninitialized variable ");
	strcat(err_msg, id);	
	
	yyerror(err_msg);
	return -1;
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

symb* searchInTable(const char* id, int cur_fun_index){
	int i;
	int *size;
	symb* tmp_symb = getTableOfFunctionByIndex(cur_fun_index, &size);
	if(NULL == tmp_symb)
		/* erreur de function introuvable */
		return NULL;
	
	for(i=0; i<(*size); i++){
		if(strcmp(tmp_symb[i].id, id) == 0)
			return &tmp_symb[i];
	}
	
	if(cur_fun_index == -1) /* on a chercher dans la table principale, pas trouvé -> n'existe pas */
		return NULL;	
		
	/* sinon, on cherche dans la table des symboles principale. */
	for(i=0; i<table_symb_size; i++){
		if(strcmp(table_symb[i].id, id) == 0)
			return &table_symb[i];
	}
	return NULL; /* le symbole n'existe pas ! */
}

/* Check if the symb id is const */
int verifyConst(const char* id, int cur_fun_index){
	
	symb* tmp_symb = searchInTable(id, cur_fun_index);
	if(NULL == tmp_symb )
		return -1;
	return tmp_symb->is_const;
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

void add_fun(const char* id, int nb_param, int addr, type_var type){
	static int index = 0;
	
	if(index >= table_fun_size){
		table_fun_size++;
		table_fun = (fun_ident*) realloc(table_fun, sizeof(fun_ident) * table_fun_size);
		if(table_symb == NULL)
			fprintf(stderr, "Initialisation failure\n");
	}

	memcpy(table_fun[index].id, id, strlen(id));
	table_fun[index].nb_param = nb_param;
	table_fun[index].addr = addr;
	table_fun[index].type = type;
	
	index++;
	
}	

void add_symb(const char* id, int is_const, int addr, int cur_fun_index, type_var type){
	static int index = 0;
	
	symb* tmp = NULL;
	int* tmp_size = NULL;
	
	/* on verifie que la variable n'est pas déjà dans la table des symboles générale */
	if(NULL != searchInTable(id, cur_fun_index)){
		yyerror("Variable already defined");
		exit(EXIT_FAILURE);
	}
	
	tmp = getTableOfFunctionByIndex(cur_fun_index, &tmp_size);		
	
	if(index >= *tmp_size){
		*tmp_size = *tmp_size + 1;
		tmp = (symb*) realloc(tmp, sizeof(symb) * (*tmp_size));
		if(tmp == NULL)
			fprintf(stderr, "Initialisation failure\n");
	}
	
	memcpy(tmp[index].id, id, strlen(id));
	tmp[index].is_const = is_const;
	tmp[index].addr = addr;
	tmp[index].type = type;
	
	index++;
}

void startFun(int stack_cur, char* id){
	
	int i;
	for(i=0; i<table_fun_size; i++){
		if(0 == strcmp(id, table_fun[i].id)){
			instarg("CALL", table_fun[i].addr);
			return;
		}
	}
	
	
}
