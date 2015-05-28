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

void add_symb(const char* id, int is_const, int addr){
	/* le programme est limité à 20 constantes pour l'instant */
	static int index = 0;
	
	memcpy(table_symb[index].id, id, strlen(id));
	table_symb[index].is_const = is_const;
	table_symb[index].addr_stack = addr;
	
	index++;
}
