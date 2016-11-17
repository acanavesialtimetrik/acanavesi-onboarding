/**
 *
 */
@isTest
private class ExpensesControllerTest {
	
	
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
			expense.Expense_Status__c = 'NOT SUBMITTED';
			
			expenses.add(expense);
		}
		insert expenses;
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

	/**
	 * Tests that the controller filters by the two types
	 */
    @isTest static void filterByTypeTest() {
		ExpensesController expensesController = new ExpensesController();
		expensesController.selectedType = 'Business trips';
		expensesController.refreshData();
		
		List<Expense__c> expenses = expensesController.expenses;
		for(Expense__c expense : expenses){
			System.assertEquals('Business trips', expense.Type__c, 'At least one expense is not Bussines trips');
		}
		
		expensesController.selectedType = 'Client meetings';
		expensesController.refreshData();
		expenses = expensesController.expenses;
		for(Expense__c expense : expenses){
			System.assertEquals('Client meetings', expense.Type__c, 'At least one expense is not Client meetings');
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
		List<Expense__c> expenses = expensesController.expenses;
		System.assert(expenses != null);
		System.assert(!expenses.isempty());
		for(Expense__c expense : expenses){
			System.assertEquals(employee.Id, expense.Employee__c, 'At least one expense does not belong to the employee given by the url parameter');
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
		List<Expense__c> expenses = expensesController.expenses;
		System.assert(expenses != null);
		System.assert(!expenses.isempty());
		for(Expense__c expense : expenses){
			System.assertEquals('Business trips', expense.Type__c, 'At least one expense is not Bussines trips');
			System.assertEquals(employee.Id, expense.Employee__c, 'At least one expense does not belong to the employee given by the url parameter');
		}
		
		expensesController.selectedType = 'Client meetings';
		expensesController.refreshData();
		expenses = expensesController.expenses;
		for(Expense__c expense : expenses){
			System.assertEquals('Client meetings', expense.Type__c, 'At least one expense is not Client meetings');
			System.assertEquals(employee.Id, expense.Employee__c, 'At least one expense does not belong to the employee given by the url parameter');
		}
		
    }
}