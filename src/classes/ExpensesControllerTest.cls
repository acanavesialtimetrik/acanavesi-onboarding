/**
 *
 */
@isTest
private class ExpensesControllerTest {
	
	
	/////////////////////////////////////// Util methods ////////////////////////////////////
	/**
	 * This method is executed for each test method.
	 */
	@testSetup static void createRandomExpenses(){
	
		List<Expense__c> expenses = new List<Expense__c>();
		for(integer i=0; i<10; i++){
			Expense__c expense = new Expense__c();
			expense.Name = 'expense'+1;
			
			Contact employee = new Contact();
			employee.LastName = 'Test'+i;
			insert employee; 
			
			expense.Employee__c = employee.Id;
			
			//just for generating expenses with business trips and clients meetings	types
			if(math.mod(i, 2) == 0){
				expense.Type__c = 'Business trips';
				expense.Travel_country__c = 'India';
				expense.Travel_region__c = 'Asia';
			}else{
				expense.Type__c = 'Client meetings';
				expense.Employee__c = employee.Id;
				
			}
			expense.Amount__c = 1000*1; 
			expense.Category__c = 'Transportation';
			expense.Client_Company__c = 'Company'+1;
			
			if(getRandomBoolean()){
				expense.Submitted__c = false;
				expense.Expense_Status__c = 'NOT SUBMITTED';
			}else{
				expense.Submitted__c = true;
				expense.Expense_Status__c = 'SUBMITTED';
			}
			
			expenses.add(expense);
		}
		insert expenses;
	}
	
	private static Boolean getRandomBoolean(){
         return math.mod(getRandomNumber(10),2) == 0;
    }
    
    private static Integer getRandomNumber(Integer size){
          Double d = math.random() * size;
          return d.intValue();
     }
	
	/**
	 * Returns the first contact in the database 
	 */
	static Contact getAContact(){
		List<Contact> employees = [select Id from Contact limit 1];
    	System.assert(employees != null);
    	System.assert(!employees.isempty());
    	return  employees.get(0);
	}
	
	/////////////////////////////////////// End util methods ////////////////////////////////////////

	/**
	 * Tests that the controller filters by the two types
	 */
    @isTest static void filterByTypeTest() {
    
    	//set the page URL for the employeeId
		PageReference pf = Page.expenses;
		Test.setCurrentPage(pf);
		apexpages.currentPage().getParameters().put('type', 'Business trips');
		
		ExpensesController expensesController = new ExpensesController();
		expensesController.refreshData();
		
		List<ExpenseWrapper> expenses = expensesController.expenses;
		for(ExpenseWrapper expense : expenses){
			System.assertEquals('Business trips', expense.expenseC.Type__c, 'At least one expense is not Bussines trips');
		}
		
		expensesController.selectedType = 'Client meetings';
		expensesController.refreshData();
		expenses = expensesController.expenses;
		for(ExpenseWrapper expense : expenses){
			System.assertEquals('Client meetings', expense.expenseC.Type__c, 'At least one expense is not Client meetings');
		}
        
    }
    
    /**
	 * Tests that the controller filters by the employee id given in the URL
	 */
    @isTest static void filterByEmployeeTest() {
    	Contact employee = getAContact();
		
		//set the page URL for the employeeId
		PageReference pf = Page.expenses;
		Test.setCurrentPage(pf);
		apexpages.currentPage().getParameters().put('employeeId', employee.Id);
		
		ExpensesController expensesController = new ExpensesController();
		System.assert(expensesController.employee != null);
		System.assertEquals(employee.Id, expensesController.employee.Id);
		expensesController.refreshData();
		List<ExpenseWrapper> expenses = expensesController.expenses;
		System.assert(expenses != null);
		System.assert(!expenses.isempty());
		for(ExpenseWrapper expense : expenses){
			System.assertEquals(employee.Id, expense.expenseC.Employee__c, 'At least one expense does not belong to the employee given by the url parameter');
		}
		
    }
    
    /**
	 * Tests that the controller filters by the two critereas: employee id and type
	 */
    @isTest static void filterByTypeAndEmployeeTest() {
    	Contact employee = getAContact();
    	
    	PageReference pf = Page.expenses;
		Test.setCurrentPage(pf);
		apexpages.currentPage().getParameters().put('employeeId', employee.Id);
		
		ExpensesController expensesController = new ExpensesController();
		System.assert(expensesController.employee != null);
		System.assertEquals(employee.Id, expensesController.employee.Id);
		expensesController.selectedType = 'Business trips';
		expensesController.refreshData();
		List<ExpenseWrapper> expenses = expensesController.expenses;
		System.assert(expenses != null);
		System.assert(!expenses.isempty());
		for(ExpenseWrapper expense : expenses){
			System.assertEquals('Business trips', expense.expenseC.Type__c, 'At least one expense is not Bussines trips');
			System.assertEquals(employee.Id, expense.expenseC.Employee__c, 'At least one expense does not belong to the employee given by the url parameter');
		}
		
		expensesController.selectedType = 'Client meetings';
		expensesController.refreshData();
		expenses = expensesController.expenses;
		for(ExpenseWrapper expense : expenses){
			System.assertEquals('Client meetings', expense.expenseC.Type__c, 'At least one expense is not Client meetings');
			System.assertEquals(employee.Id, expense.expenseC.Employee__c, 'At least one expense does not belong to the employee given by the url parameter');
		}
    }
    
    @isTest static void filterByStatusSubmitted() {
    	filterByStatus('Submitted');
    }
    
     @isTest static void filterByStatusNotSubmitted() {
    	filterByStatus('Not submitted');
     }
     
    static void filterByStatus(String status){
     	Contact employee = getAContact();
		
		//set the page URL for the employeeId
		PageReference pf = Page.expenses;
		Test.setCurrentPage(pf);
		apexpages.currentPage().getParameters().put('status', status);
		
		ExpensesController expensesController = new ExpensesController();
		System.assert(expensesController.selectedStatus != null);
		System.assertEquals(expensesController.selectedStatus, status);
		expensesController.refreshData();
		List<ExpenseWrapper> expenses = expensesController.expenses;
		System.assert(expenses != null);
		System.assert(!expenses.isEmpty());
		for(ExpenseWrapper expense : expenses){
			if(status.equals('Submitted')){
				System.assert(expense.expenseC.Submitted__c);
			}else{
				System.assert(!expense.expenseC.Submitted__c);
			}
		}
     }
     
     /**
     * We cannot update or delete submitted expenses. This test checks that
     */
     @isTest static void updateDeleteSubmittedExpenseTest() {
    	Expense__c expense = [select Id from Expense__c where Submitted__c = true limit 1];
    	
    	//test update
    	expense.Client_Company__c = 'Random'+getRandomNumber(10);
    	Database.SaveResult saveResult = Database.update(expense, false);
		System.assert(!saveResult.isSuccess());
    	System.assert(saveResult.getErrors().size() > 0);
    	
    	//test deletion
		Database.DeleteResult deleteResult = Database.delete(expense, false);
		System.assert(!deleteResult.isSuccess());
    	System.assert(deleteResult.getErrors().size() > 0);
     }
     
     /**
     * We can update or delete expenses while they are not submitted. This test checks that
     */
     @isTest static void updateDeleteNotSubmittedExpenseTest() {
    	List<Expense__c> expenses = [select Id from Expense__c where Submitted__c = false];
    	
    	//I use a random string for all expenses in order to check later
    	String randomString = 'random'+getRandomNumber(10);
    	for(Expense__c expense : expenses){
    		expense.Client_Company__c = randomString;
    	}
    	
    	//test update
    	update expenses;
    	List<Expense__c> updatedExpenses = [select Id from Expense__c where Submitted__c = false];
    	for(Expense__c expense : updatedExpenses){
    		 System.assertEquals(randomString, expense.Client_Company__c, 'At least one expense was not updated');
    	}
    	
    	//test delete
    	delete expenses;
    	List<Expense__c> deletedExpenses = [select Id from Expense__c where Submitted__c = false];
    	System.assert(deletedExpenses.isEmpty(), 'At leaste one expense was not deleted');
     }
     
    @isTest static void markSelectedAsSubmittedTest() {
    	ExpensesController expensesController = new ExpensesController();
    	
    	//build a list with all not submitted expenses to mark them all as submitted later
    	List<Expense__c> expensesC = new List<Expense__c>();
    	for(ExpenseWrapper expense :expensesController.expenses){
    		if(!expense.expenseC.Submitted__c){
    			expense.selected = true;
    			expensesC.add(expense.expenseC);
    		}
    	}
    	System.assert(expensesC.size()>0, 'Unable to test. There is not at least one not-submitted expense');
    	
    	expensesController.markSelectedAsSubmitted();
    	for(Expense__c expense :expensesC){
    		System.assert(expense.Submitted__c, 'At least one expense was not marked as submitted');
    	}
     }
     
     @isTest static void checkUncheckTest() {
    	ExpensesController expensesController = new ExpensesController();
    	
    	//test selection
    	expensesController.allChecked = true;
    	expensesController.checkUncheck();
    	for(ExpenseWrapper expense :expensesController.expenses){
			System.assert(expense.selected);    		
    	}
    	
    	//test unselection
    	expensesController.allChecked = false;
    	expensesController.checkUncheck();
    	for(ExpenseWrapper expense :expensesController.expenses){
			System.assert(!expense.selected);    		
    	}
    	
     }
     
     
}