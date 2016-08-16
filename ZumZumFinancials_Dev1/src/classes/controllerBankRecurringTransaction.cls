public class controllerBankRecurringTransaction {
	public Recurring_Transaction__c objectRecurringTransaction {get;set;}
	public List<Bank_Account__c> listBankAccount{get;set;}
	public List<Tax_Rate__c> listTaxRate{get;set;}
	public string idNom{get;set;}
	public string retURL{get;set;}
	public Map<string,Nominal_Account__c> mp {get;set;}
	public controllerBankRecurringTransaction()
	{
		retURL = 'https://'+apexPages.currentPage().getHeaders().get('Host')+'/apex/BankMenu';
		objectRecurringTransaction = new Recurring_Transaction__c(); 
		mp = new Map<string,Nominal_Account__c>([select id,Name from Nominal_Account__c limit 1000]); 		
	}
	public List<SelectOption> getBankAccount()
	{
		List<SelectOption> options = new List<SelectOption>();
		for(Bank_Account__c bnk : [select id, Name, Nominal_Account__r.Nominal_Code__c, Nominal_Account__c from Bank_Account__c limit 1000])
		{
			options.add(new SelectOption(bnk.id,bnk.Nominal_Account__r.Nominal_Code__c+'-'+bnk.Name));
		} 
		return options;
	}
	public List<SelectOption> getTaxRate()
	{
		List<SelectOption> options = new List<SelectOption>();
		for(Tax_Rate__c tx : [select id, Name, Tax_Rate__c from Tax_Rate__c limit 1000])
		{
			options.add(new SelectOption(tx.id,tx.Name));
		} 
		return options;
	}
	public PageReference Cancel()
	{
		return new PageReference(retURL);
	}
	public PageReference Save()
	{
		try
		{			
			if(mp.KeySet().contains(idNom))
			objectRecurringTransaction.Nominal_Account__c = mp.get(idNom).id;
			settingRules(); 					
			return null;
		}
		catch(exception e)
		{
			ApexPages.AddMessages(e);
			return null;
		}
	}
	public void settingRules()
	{
		if((objectRecurringTransaction.Transaction_Type__c == 'Bank/Cash/Credit Card Transfer') ||(objectRecurringTransaction.Transaction_Type__c == 'Customer payment on Account'))
		{		
			objectRecurringTransaction.VAT__c = null;
			objectRecurringTransaction.Vat_Amount__c = 0.0;			
		}		
	}
	private static testMethod void controllerBankRecurringTransaction_Test()
	{
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
    	Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, Expense__c = true, Name = 'Plumbering', Account_Code__c = 1222);
		insert nm ;
		Nominal_Account__c nm1 = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, Expense__c = true, Name = 'Plumbering', Account_Code__c = 1299);
		insert nm1 ;
		Nominal_Account__c na = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, Expense__c = true, Name = 'Gardening', Account_Code__c = 100);
		insert na ;
		controllerBankRecurringTransaction recurTrans = new controllerBankRecurringTransaction();
		List<SelectOption> bnkAct = recurTrans.getBankAccount();
		List<SelectOption> txRat = recurTrans.getTaxRate();
		recurTrans.Cancel();
		recurTrans.Save();
	}	
}