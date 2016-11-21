trigger ExpenseUpdateDeleteRules on Expense__c (before update, before delete) {
	
    // Prevent delete or update submitted expenses
    if (Trigger.isDelete) {
         for (Expense__c expense : Trigger.Old) {
            if(expense.Submitted__c){ 
                Trigger.oldMap.get(expense.Id).addError('Cannot delete submitted expenses');
            }
         }   
    } else if(Trigger.isUpdate){
        for (Expense__c expense : Trigger.Old) {
            if(expense.Submitted__c){
                //Trigger.oldMap.get(expense.Id).addError('Cannot update submitted expenses');
            } 
        }
    }
}