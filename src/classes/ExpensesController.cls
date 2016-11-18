public class ExpensesController {

    public List<SelectOption> typeOptions { get; set; }
    public List<SelectOption> statusOptions { get; set; }
    public List<ExpenseWrapper> expenses {get; set;}
    public String selectedType {get; set;}
    public String selectedStatus {get; set;}
    public Contact employee {get; set;}
    private Id employeeId;
    //for massive selection ni the UI
    public Boolean allChecked { get; set; }
    //the list of url parameters for the page that exports expenses to pdf. These parameters could be employeeId, expenseType or status
    public String expensesAsPdfParams {get; set;}

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

        setUpUrlParameters();
        
        allChecked = false;
        
        refreshData();
    }
    
    private void setUpUrlParameters(){
         
        //get the url parameter (It's optional)
        employeeId = apexpages.currentpage().getparameters().get('employeeId');
        if(employeeId != null){
           employee = [select Name from Contact where Id = :employeeId];
        }
        
        String status = apexpages.currentpage().getparameters().get('status');
        if(status != null){
            selectedStatus = status;
        }
        
        String expenseType = apexpages.currentpage().getparameters().get('type');
        if(expenseType != null){
            selectedType = expenseType;
        }
        
    }
    
    /**
     * Builds the url for redirecting to the page that exports the records to pdf
     */
    private void buildUrlParameters(){
        expensesAsPdfParams = '?status='+selectedStatus+'&type='+selectedType;
        if(employeeId != null){
            expensesAsPdfParams+='&employeeId='+employeeId;
        }
    }

    /**
     * 
     */
    public PageReference refreshData(){
        buildUrlParameters();
        String condition = '';
        System.debug('Selected type: '+selectedType);
        if(!selectedType.equals('All Expenses')){
             condition += ' AND Type__c = :selectedType ';
        }
        System.debug('Selected employee id: '+employeeId);
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

        List<Expense__c> expensesC = Database.query(query); 
        
        //convert to ExpenseWrapper domain
        expenses = new List<ExpenseWrapper>();
        for(Expense__c expenseC :expensesC){
            ExpenseWrapper expenseW = new ExpenseWrapper();
            expenseW.selected = false;
            expenseW.expenseC = expenseC;
            expenses.add(expenseW);
        }
        
        return null;
    }
    
    /**
     * 
     */
    public PageReference checkUncheck(){
        for(ExpenseWrapper expenseW : expenses){
            expenseW.selected = allChecked;
        }
        return null;
    }  
    
    /**
     *  
     */
    public PageReference markSelectedAsSubmitted(){
        List<Expense__c> expensesToSubmit = new List<Expense__c>();
         for(ExpenseWrapper expenseW : expenses){
               if( expenseW.selected){
                   expenseW.expenseC.Submitted__c = true;
                   expensesToSubmit.add(expenseW.expenseC);
               }
         }
         update expensesToSubmit;
         refreshData();
        return null;
    }
    
    /**
     * Wrapper to give extra functionality to the UI in particular for massive selection
     */
    public class ExpenseWrapper{
        public Expense__c expenseC { get; set; }
        public Boolean selected { get; set; }
    }

}