public class controllerCustomerRefund {
public CustomerLookup__c objectLookup{get;set;}
public Control_Account__c defaultBank{get;set;}
public string NominalId{get;set;}
public string cheque{get;set;}
public string pay{get;set;}
public list<Bank_Account__c> listBankAccount {get;set;}
public string retURL{get;set;}
public string currencySymbol{get;set;}
	public controllerCustomerRefund()
	{
		pay = '0.0';
		currencySymbol = Functions.getOrganisationCurrency('CurrencySymbol');			
		retURL = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/apex/TransactionsMenu';			
		objectLookup = new CustomerLookup__c();
		objectLookup.Date__c = Date.today(); 									 																							
		listBankAccount = [select id,Name, Nominal_Account__r.Nominal_Code__c, Nominal_Account__r.Name from Bank_Account__c where Status__c =: 'Active' order by Nominal_Account__r.Nominal_Code__c];																					
	}	
	public list<SelectOption> getBankAccount()//options from list of Bank Accounts with Nominal Codes
	{
		try
		{
			List<SelectOption> options = new list<SelectOption>();	
			defaultBank = [Select c.Default_Bank__r.Nominal_Code__c, c.Default_Bank__r.Name, c.Default_Bank__r.Id, c.Default_Bank__c From Control_Account__c c where c.Name= 'Control Accounts'];
			Bank_Account__c opt = [select Name, Nominal_Account__r.Id,Nominal_Account__r.Nominal_Code__c, Nominal_Account__r.Name from Bank_Account__c where Nominal_Account__r.Name =: defaultBank.Default_Bank__r.Name];		
	 		options.add(new SelectOption(opt.Nominal_Account__r.Id,opt.Nominal_Account__r.Nominal_Code__c+' - '+opt.Name));
			for(Bank_Account__c bnk : listBankAccount) 		
			{			
				if(bnk.Nominal_Account__r.id != opt.Nominal_Account__r.Id)
					options.add(new SelectOption(bnk.Nominal_Account__r.Id,bnk.Nominal_Account__r.Nominal_Code__c+' - '+bnk.Name));
			}
			return options;
		}
		catch(exception e)
		{
			apexpages.addMessages(e);
			return null;
		}	
	}
	public PageReference Save()
	{		
		try
		{						
			validationRules();									
 			CustomerRefund_BudgetModel bModel = new CustomerRefund_BudgetModel();
 			bModel.AddDebit(Functions.getNominalAccountId('Debtors Control Account'),decimal.valueOf(pay), string.valueOf(objectLookup.Date__c));
 			bModel.AddCredit(NominalId , decimal.valueOf(pay) , string.valueOf(objectLookup.Date__c));
 			bModel.newSave(); 	 			 			 											
			Ledger financial = new Ledger();
			financial.AddCustomerRefund(decimal.valueOf(pay),Functions.getAccountNumberById(objectLookup.CustomerAccount__c),Functions.getNominalAccountCode('Debtors Control Account'),Functions.getAccountCodeById(NominalId),cheque,objectLookup.Date__c);
			financial.Save();									
			return new PageReference(retURL);
		}
		catch(exception e)
		{
			ApexPages.addMessages(e);
			return null; 
		}
	}
	public PageReference Cancel()
	{
		return new PageReference(retURL);
	}	
	public void validationRules()
	{					
		if(objectLookup.CustomerAccount__c == null)
			throw new CustomException('Select an account first');
		if(objectLookup.Date__c == null)			
			throw new CustomException('You must enter date to save the record');
		if(pay == null || pay == '')
			throw new CustomException('Enter an amount first');		
		if(!Pattern.matches('^[0-9]+(.[0-9]{1,2})?$', pay)) 
			throw new CustomException('Enter valid currency value');
		if(decimal.valueOf(pay) <= 0.0)
			throw new CustomException('Enter an amount first');
				
	}
	private static testMethod void controllerCustomerRefundTest()
	{
		Account act = new Account(Name='ABC Company',Type='Customer');
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		//Tax_Rate__c tx = [select Id , Tax_Rate__c from Tax_Rate__c limit 1];
		Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, Expense__c = true, Name = 'Plumbering', Account_Code__c = 1222);
		insert nm ;
		Bank_Account__c	ba = new Bank_Account__c (Name = 'testBank',Account_Number__c = 'tst123',Nominal_Account__c = nm.id, Status__c = 'Active');	
		insert ba;		
		/*try  
		{ 
			ba = new Bank_Account__c (Name = 'testBank2',Account_Number__c = 'Secondtst',Nominal_Account__c = nm.id, Status__c = 'Active');
			insert ba;
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'This Nominal Account already selected into another Bank Account');			
		}	*/	
		controllerCustomerRefund cstmr = new controllerCustomerRefund();
		cstmr.objectLookup.CustomerAccount__c = null;
		cstmr.objectLookup.Date__c = date.today();
		cstmr.pay = string.valueOf(2);				
		try
		{
			cstmr.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Select an account first');
		}		
		list<selectoption> getbnkAcctts = cstmr.getBankAccount();
		cstmr.NominalId = nm.id;
		cstmr.objectLookup.CustomerAccount__c = act.id;
		cstmr.objectLookup.Date__c = null;
		cstmr.pay = string.valueOf(2);		
		try
		{
			cstmr.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'You must enter date to save the record');
		}		
		cstmr.objectLookup.CustomerAccount__c = act.id;
		cstmr.objectLookup.Date__c = Date.today();
		cstmr.pay = 'a';		
		try
		{
			cstmr.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Enter valid currency value');
		}
		
		cstmr.objectLookup.CustomerAccount__c = act.id;
		cstmr.objectLookup.Date__c = Date.today();
		cstmr.pay = string.valueOf(0);		
		try
		{
			cstmr.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Enter an amount first');
		}
		cstmr.objectLookup.CustomerAccount__c = act.id;
		cstmr.objectLookup.Date__c = Date.today();
		cstmr.pay = null;		
		try
		{
			cstmr.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Enter an amount first');
		}
		cstmr.objectLookup.CustomerAccount__c = act.id;
		cstmr.objectLookup.Date__c = Date.today();
		cstmr.pay = string.valueOf(2);
		cstmr.cheque = 'abc';		
		cstmr.Save();
		cstmr.Cancel();	
	}
}