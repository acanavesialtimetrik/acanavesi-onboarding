/**
 *
 */
@isTest
public class ExpensesSubmitterBatchTest {

    /**
    * Creates a couple of expenses with amount greater than 5000 and submitted = false.
    */
	@testSetup static void setup(){
	    TestUtils.createRandomExpenses();
	}
	
	/**
	 * Checks all expenses created in the setup method was submitted
	 */
    @isTest static void executeBatchTest() {
        Test.startTest();
        ExpensesSubmitterBatch batch = new ExpensesSubmitterBatch();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();

        // after the testing stops, assert records were updated properly
        System.assertEquals(0, [select count() from Expense__c where Submitted__c = false and Amount__c > 5000], 'At least one expense with amount greater than 5000 was not submitted');
    }
}