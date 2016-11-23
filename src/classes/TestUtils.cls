public class TestUtils {

    public static void createRandomExpenses(){
        createRandomExpenses(40);
        createRandomExpensesWithAmountGreaterThan5000(40);
    }
        
    /**
    * 
    */
    private static void createRandomExpenses(integer cant) {
        List<Expense__c> expenses = new List<Expense__c>();
		for(integer i=0; i<cant; i++){
			Expense__c expense = new Expense__c();
			expense.Name = 'expense'+1;
			
			Contact employee = new Contact();
			employee.LastName = 'Test'+i;
			insert employee; 
			
			expense.Employee__c = employee.Id;
			
			//just for generating expenses with different business trips and clients meetings types
			if(math.mod(i, 2) == 0){
				expense.Type__c = 'Business trips';
				expense.Travel_country__c = 'India';
				expense.Travel_region__c = 'Asia';
			}else{
				expense.Type__c = 'Client meetings';
				
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
    
    /**
    * 
    */
    private static void createRandomExpensesWithAmountGreaterThan5000(integer cant){
        List<Expense__c> expenses = new List<Expense__c>();
		for(integer i=0; i<cant; i++){
		    Expense__c expense = new Expense__c();
			expense.Name = 'expense'+1;
			
			Contact employee = new Contact();
			employee.LastName = 'Test'+i;
			insert employee; 
			
			expense.Employee__c = employee.Id;
			expense.Type__c = 'Client meetings';
			expense.Submitted__c = false;
			expense.Expense_Status__c = 'NOT SUBMITTED';
			expense.Amount__c = 6000;
			expense.Category__c = 'Transportation';
			expense.Client_Company__c = 'Company'+1;
			
			expenses.add(expense);
		}
		insert expenses;
    }
    
    public static Boolean getRandomBoolean(){
         return math.mod(getRandomNumber(10),2) == 0;
    }
    
    public static Integer getRandomNumber(Integer size){
          Double d = math.random() * size;
          return d.intValue();
     }
     
    /**
	 * Returns the first contact in the database 
	 */
	public static Contact getAContact(){
		List<Contact> employees = [select Id from Contact limit 1];
    	System.assert(employees != null);
    	System.assert(!employees.isempty());
    	return  employees.get(0);
	}
}