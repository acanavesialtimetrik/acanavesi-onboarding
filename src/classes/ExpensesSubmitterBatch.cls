/**
* Batch for submitting all the expenses with the amount greater that 5000
*/
global class ExpensesSubmitterBatch implements Database.Batchable<sObject> {

    global Iterable<sObject> start(Database.BatchableContext bc) {
        //get the batch records to be processed in the execute method
        return [select Id from Expense__c where Submitted__c = false and Amount__c > 5000];
    }

    global void execute(Database.BatchableContext bc, List<Expense__c> records){
        //set the submitted flag of the expense to true and update the records in the database
        for(Expense__c expense :records){
            expense.Submitted__c = true;
        }
        update records;
    }    

    global void finish(Database.BatchableContext bc){
        // TODO send an email
    }    

}