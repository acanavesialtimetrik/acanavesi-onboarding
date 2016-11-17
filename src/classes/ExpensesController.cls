public class ExpensesController {

    public List<SelectOption> typeOptions { get; set; }
    public List<Expense__c> expenses {get; set;}
    public String selectedType {get; set;}
    public Contact employee {get; set;}
    private Id employeeId;

    public ExpensesController() {
        typeOptions = new List<SelectOption>();
        typeOptions.add(new SelectOption('All Expenses', 'All Expenses'));
        typeOptions.add(new SelectOption('Business trips', 'Business trips'));
        typeOptions.add(new SelectOption('Client meetings', 'Client meetings'));
        selectedType = typeOptions.get(0).getValue();

        employeeId = apexpages.currentpage().getparameters().get('employeeId');
        if(employeeId != null){
           employee = [select Name from Contact where Id = :employeeId];
        }

        refreshData();
    }

    public PageReference refreshData(){

        String condition = '';
        if(selectedType != 'All expenses'){
             condition = ' AND Type__c = :selectedType ';
        }
        if(employee != null){
          condition += ' AND Employee__r.Id = :employeeId ';
        }
        if(condition.length() > 0 ){
          condition = condition.replaceFirst('AND', ' WHERE ');
        }
        String query = String.escapeSingleQuotes(' SELECT  Employee__c, Category__c, Type__c, Amount__c, Tax__c, Client_Company__c, Submitted__c' +
        ' FROM Expense__c ' +
        condition+
        ' LIMIT 100');

        expenses = Database.query(query); 
        
        return null;
    }

}