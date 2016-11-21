/**
 *
 */
@isTest
public class ExpensesSubmitterSchedulerTest {

	// Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    /**
    * Creates a couple of expenses with amount greater than 5000 and submitted = false.
    */
	@testSetup static void setup(){
	    TestUtils.createRandomExpenses();
	}
	
	/**
	 * 
	 */
    @isTest static void executeScheduler() {
    	Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('myJob', CRON_EXP, new ExpensesSubmitterScheduler());         
     
        // Stopping the test will run the job synchronously
        Test.stopTest();
        
        // Now that the scheduled job has executed,
        // check that the expenses were updated to submitted
        //TODO alwas fails and It is pretty obvious: we are asking for results and maybe the Apex batch didn't finish
        System.assertEquals(0, [select count() from Expense__c where Submitted__c = false], 'At least one expense with amount greater than 5000 was not submitted');
    }
}