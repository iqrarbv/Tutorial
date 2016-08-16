public class BankRecurringModel {
	public RecurringTransaction__c objRecurringTransaction {get;set;}
	public decimal a {get;set;}	
	public BankRecurringModel(RecurringTransaction__c  rt)
	{
		objRecurringTransaction  = rt;		
	}
	public void Save()
	{
		savePoint sp = Database.setSavepoint();
		try
		{
			ValidationRules();
			//if(editId != null)
				upsert objRecurringTransaction ;
			//else
//				insert objRecurringTransaction ;
		}
		catch(exception e)
		{
			Database.rollback(sp); 
			throw new CustomException('Unable to Save \n'+e.getMessage());			
		}
	}
	public void ValidationRules()
	{
		if(objRecurringTransaction.TransactionType__c == null)		
			throw new CustomException('Select Transaction type first');
		if(objRecurringTransaction.Nominal_Account__c == null)		
			throw new CustomException('Select Nominal Account first');
		if(objRecurringTransaction.Net_Amount__c == 0.00)		
			throw new CustomException('Enter Amount first');
		if(objRecurringTransaction.Name_of__c == null)		
			throw new CustomException('Select Time Period first');
		if(objRecurringTransaction.No_of__c == 0)		
			throw new CustomException('Enter Time Period first');
		if(objRecurringTransaction.Start_Date__c == null)		
			throw new CustomException('Enter Start Date first');
		if(objRecurringTransaction.Finish_Date__c == null)		
			throw new CustomException('Enter Finish Date first');
		/*if(REGEX( objRecurringTransaction.No_of__c,"[0-9]+""))
			throw new CustomException('Enter Frequency as a number');*/		
				 
			
	}
}