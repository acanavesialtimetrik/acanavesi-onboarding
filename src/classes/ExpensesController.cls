public class ExpensesController {

    public List<SelectOption> typeOptions { get; set; }
    public List<SelectOption> statusOptions { get; set; }
    public List<Expense__c> expenses {get; set;}
    public String selectedType {get; set;}
    public String selectedStatus {get; set;}
    public Contact employee {get; set;}
    private Id employeeId;

    public ExpensesController() {
        typeOptions = new List<SelectOption>();
        typeOptions.add(new SelectOption('All Expenses', 'All Expenses'));
        typeOptions.add(new SelectOption('Business trips', 'Business trips'));
        typeOptions.add(new SelectOption('Client meetings', 'Client meetings'));
        selectedType = typeOptions.get(0).getValue();
        
        statusOptions = new List<SelectOption>();
        statusOptions.add(new SelectOption('All statuses', 'All statuses'));
        statusOptions.add(new SelectOption('Submitted', 'Submitted'));
        statusOptions.add(new SelectOption('Not submitted', 'Not submitted'));
        selectedStatus = statusOptions.get(0).getValue();

        employeeId = apexpages.currentpage().getparameters().get('employeeId');
        if(employeeId != null){
           employee = [select Name from Contact where Id = :employeeId];
        }

        refreshData();
    }

    public PageReference refreshData(){
        PageReference pageReference = null;
        String condition = '';
        System.debug('Selected type: '+selectedType);
        if(!selectedType.equals('All Expenses')){
             condition += ' AND Type__c = :selectedType ';
        }
        System.debug('Selected employee: '+employee.Name+' ('+employeeId+')');
        if(employeeId != null){
          condition += ' AND Employee__r.Id = :employeeId ';
        }
     
        System.debug('Selected status: '+selectedStatus);
        if(selectedStatus.equals('Submitted')){
            condition += ' AND Submitted__c = true ';
        }else if(selectedStatus.equals('Not submitted')){
            condition += ' AND Submitted__c = false ';
        }
        
        if(condition.length() > 0 ){
          condition = condition.replaceFirst('AND', ' WHERE ');
        }
        String query = String.escapeSingleQuotes(' SELECT  Employee__c, Category__c, Type__c, Amount__c, Tax__c, Client_Company__c, Submitted__c' +
        ' FROM Expense__c ' +
        condition+
        ' LIMIT 100'); //TODO do pagination
        
        System.debug(query);

        expenses = Database.query(query); 
        
        return pageReference;
    }

}