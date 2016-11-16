public class ExpensesController {
    
    public List<SelectOption> typeOptions { get; set; }
    //public  SelectOption theType {get; set;}
    public List<Expense__c> expenses {get; set;}
    public String selectedType {get; set;}
    
    public ExpensesController() {
        typeOptions = new List<SelectOption>();        
        typeOptions.add(new SelectOption('All Expenses', 'All Expenses'));
        typeOptions.add(new SelectOption('Business trips', 'Business trips'));
        typeOptions.add(new SelectOption('Client meetings', 'Client meetings'));
        selectedType = typeOptions.get(0).getValue(); 
        refreshData();
    }
    
    public String getDateString(){
        return Datetime.now()+' '+selectedType;
    }
    
    public integer getExpensesSize(){
        return expenses.size();
    }
       
    public PageReference refreshData(){
        String condition = '';
        if(selectedType != 'All expenses'){
            condition = ' WHERE Type__c = \''+selectedType+'\'';
        }
        expenses = Database.query(
            ' SELECT Id, Name, Type__c, Employee__c' +
            ' FROM Expense__c ' +
            condition+
            ' LIMIT 100'
        );
        return null;
    }
    
}