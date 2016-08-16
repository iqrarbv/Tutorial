public class controllerRecurringTransaction { 
	public RecurringTransaction__c objectRecurringTransaction {get;set;}
	public RecurringTransaction__c editRecurringTransaction {get;set;}	
	public List<Bank_Account__c> listBankAccount{get;set;}
	public List<Tax_Rate__c> listTaxRate{get;set;}
	public string idNom{get;set;}
	public string retURL{get;set;}	
	public string frequency{get;set;}
	public string netAmount{get;set;}
	public string dt  {get;set;}
	public id editID {get;set;}		
	public controllerRecurringTransaction(ApexPages.Standardcontroller std)
	{
		retURL='https://'+apexPages.currentPage().getHeaders().get('Host')+'/apex/BankMenu';
		editId = ApexPages.currentPage().getParameters().get('id');
		if(editId != null)
		{
			objectRecurringTransaction = [select Bank_Account__c,Details__c,Finish_Date__c,No_of__c,Name_of__c,Last_Posted__c,Net_Amount__c,Nominal_Account__c,Reference__c,Required_Posting__c,Start_Date__c,Suspend_Posting__c,Tax_Rate__c,TransactionType__c,VAT__c from RecurringTransaction__c where id=: editId];
			frequency = string.valueOf(objectRecurringTransaction.No_of__c);
			netAmount = string.valueOf(objectRecurringTransaction.Net_Amount__c);
		} 
		else 
			objectRecurringTransaction = new RecurringTransaction__c();
		frequency = '1';
		netAmount = '0.0';
		objectRecurringTransaction.Required_Posting__c = 1;
		objectRecurringTransaction.VAT__c = 0.0;
		objectRecurringTransaction.Start_Date__c = Date.today();
		objectRecurringTransaction.Finish_Date__c = Date.today(); 
		listBankAccount = [select id, Name, Nominal_Account__r.Nominal_Code__c, Nominal_Account__c from Bank_Account__c where Status__c =: 'Active'];
		listTaxRate = [select id, Name, Tax_Rate__c from Tax_Rate__c limit 1000];			
	}
	public controllerRecurringTransaction(RecurringTransaction__c trans)
	{
		objectRecurringTransaction = trans;
	}
	public List<SelectOption> getBankAccount()
	{
		List<SelectOption> options = new list<SelectOption>();				
		Control_Account__c defaultBank = [Select c.Default_Bank__r.Nominal_Code__c, c.Default_Bank__r.Name, c.Default_Bank__r.Id, c.Default_Bank__c From Control_Account__c c where c.Name= 'Control Accounts'];
		Bank_Account__c opt = [select id, Name, Nominal_Account__r.Id,Nominal_Account__r.Nominal_Code__c, Nominal_Account__r.Name from Bank_Account__c where Nominal_Account__r.Name =: defaultBank.Default_Bank__r.Name];
 		options.add(new SelectOption(opt.Id,opt.Nominal_Account__r.Nominal_Code__c+' - '+opt.Name));
		for(Bank_Account__c bnk : listBankAccount) 		
		{			
			if(bnk.Nominal_Account__r.id != opt.Nominal_Account__r.Id)
				options.add(new SelectOption(bnk.Id,bnk.Nominal_Account__r.Nominal_Code__c+' - '+bnk.Name));
		}
		return options;	
	}
	public List<SelectOption> getTaxRate()
	{
		List<SelectOption> options = new List<SelectOption>();
		Tax_Rate__c opt = [select Id, Name, Tax_Rate__c from Tax_Rate__c where is_default__c =: true];
    	options.add(new SelectOption(opt.id,opt.Name));
		for(Tax_Rate__c tx : listTaxRate)
		{
			if(tx.id != opt.id)
				options.add(new SelectOption(tx.id,tx.Name));
		} 
		return options;
	}
	public PageReference Cancel()
	{
		if(editId != null)
		 return new PageReference('/'+editID);
		else
			return new PageReference(retURL);
	}
	public PageReference Save()
	{
		try
		{									
			if(idNom != null && idNom != '')
				objectRecurringTransaction.Nominal_Account__c = idNom;
			SetTaxValues(); 
			if(!Pattern.matches('^[0-9]+$', frequency))
				throw new CustomException('Enter Numeric value');	
			if(!Pattern.matches('^[0-9]+(.[0-9]{1,2})?$', netAmount))
				throw new CustomException('Enter currency value');
			objectRecurringTransaction.No_of__c = decimal.valueOf(frequency);			
			objectRecurringTransaction.Net_Amount__c = decimal.valueOf(netAmount);
			SetNextRunDate(objectRecurringTransaction);			
			BankRecurringModel bnk = new BankRecurringModel(objectRecurringTransaction);
			bnk.Save();	
			return new PageReference('/'+bnk.objRecurringTransaction.id);
		}
		catch(exception e)
		{			
			ApexPages.AddMessages(e);						
			return null;
		} 
	}
	public void SetTaxValues()
	{
		if((objectRecurringTransaction.TransactionType__c == 'Bank/Cash/Credit Card Transfer') ||(objectRecurringTransaction.TransactionType__c == 'Customer payment on Account'))
		{		
			objectRecurringTransaction.Tax_Rate__c = null;
			objectRecurringTransaction.VAT__c = 0.0;			
		}			
	}
	public static void SetNextRunDate(RecurringTransaction__c objectRecurringTransaction)
	{
		string frequency = string.valueof(objectRecurringTransaction.No_of__c);
				
		if(objectRecurringTransaction.Last_Posted__c == null)		
			objectRecurringTransaction.Next_Transaction_Date__c = Date.today();		
		else
			objectRecurringTransaction.Next_Transaction_Date__c = objectRecurringTransaction.Last_Posted__c;		
		if(objectRecurringTransaction.Name_of__c == 'Day(s)')		
			objectRecurringTransaction.Next_Transaction_Date__c = objectRecurringTransaction.Next_Transaction_Date__c.addDays(integer.valueof(frequency));			
		if(objectRecurringTransaction.Name_of__c == 'Week(s)')		
			objectRecurringTransaction.Next_Transaction_Date__c = objectRecurringTransaction.Next_Transaction_Date__c.addDays(integer.valueof(frequency)*7);			
		if(objectRecurringTransaction.Name_of__c == 'Month(s)')		
			objectRecurringTransaction.Next_Transaction_Date__c = objectRecurringTransaction.Next_Transaction_Date__c.addMonths(integer.valueof(frequency));								
	}
}