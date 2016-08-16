public class StatementController {	
	public Schedule_Statements__c objectStatement{get;set;}
	public string retURL{get;set;}	
	public StatementController(apexPages.standardController std)
	{
		retURL ='https://'+ApexPages.currentPage().getHeaders().get('Host')+'/apex/Setup'; 
		objectStatement = new Schedule_Statements__c(); 
	}
	public PageReference Discard()
    {
    	return new PageReference(retURL);    	
    }
    public void ValidationRules()
    {
    	if(objectStatement.Day__c == null)
    		throw new CustomException('You must define date of execution');
   		if(objectStatement.Frequency__c != null)
    		if(objectStatement.Frequency__c == 'Yearly' && objectStatement.Month__c == null)
    			throw new CustomException('You must define month of execution');    		
    	if(objectStatement.Frequency__c == null)
    		throw new CustomException('You must define frequency of schedule statements');    	
    }
    public PageReference Save()
    {
    	Savepoint sp =  DataBase.setSavepoint();
    	try
    	{
    		ValidationRules();
	    	objectStatement = new Schedule_Statements__c(Day__c=objectStatement.Day__c,Frequency__c = objectStatement.Frequency__c,Month__c = objectStatement.Month__c,send_statements_if_balance_is_zero__c = objectStatement.send_statements_if_balance_is_zero__c);	    	
	    	insert objectStatement;    	 
	    	return new PageReference(retURL);
    	}  
    	catch(exception e)
		{
			Database.rollback(sp);			
			apexPages.addMessages(e);
			return null;
		}
    }
    private static testMethod void RemindersController_Test()
	{
		Schedule_Statements__c ss = new Schedule_Statements__c(Day__c = '2', Month__c = '5' , Frequency__c = 'Monthly', send_statements_if_balance_is_zero__c = true);
		insert ss;
		Schedule_Statements__c ss1 = new Schedule_Statements__c(Day__c = '2', Month__c = '5' , Frequency__c = 'Yearly', send_statements_if_balance_is_zero__c = true);
		insert ss1;
		StatementController sc = new StatementController(new ApexPages.standardController(new Schedule_Statements__c()));
		try
		{
			sc.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'You must define date of execution');
		}
		sc.objectStatement.Day__c = ss.Day__c;
		try
		{
			sc.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'You must define frequency of schedule statements');
		}
		sc.objectStatement.Frequency__c = ss1.Frequency__c;
		try
		{
			sc.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'You must define month of execution');
		}
		sc.objectStatement.Month__c = ss.Month__c;
		sc.Discard();
		sc.Save();
	}
}