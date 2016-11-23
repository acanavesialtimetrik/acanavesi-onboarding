/**
* Scheduler for calling the batch class to submit all expenses with the amount greater than 5000
*/
global class ExpensesSubmitterScheduler implements Schedulable{
	
    global void execute(SchedulableContext ctx) {
        //call a batch object to do the large operation
        ExpensesSubmitterBatch batch = new ExpensesSubmitterBatch();
        Id batchId = Database.executeBatch(batch);
        System.debug('Started ExpensesSubmitterBatch with batcj id: '+batchId);

    }

}