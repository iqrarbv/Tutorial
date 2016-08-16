public class OpeningBalances {
	public Account objectNominal{get;set;}
	public Ledger__c objectLedger{get;set;}
	public string BType {get; set;}
	public string retURL{get; set;}
	public string currencySymbol{get;set;}
	public string Amount{get;set;}
	public OpeningBalances()
	{
		retURL = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/apex/Setup';
		currencySymbol = Functions.getOrganisationCurrency('CurrencySymbol');
		objectNominal = new Account();		
		objectLedger = new Ledger__c();
		objectLedger.Trans_Date__c = Date.today();
		Amount = '0.0';			
	}
	public PageReference Save()
	{
		try
		{
			ValidationRules(); 
			objectLedger.Amount__c = decimal.valueOf(Amount);
			string nominalCode = [select Nominal_Code__c from Nominal_Account__c where id =: objectNominal.Nominal_Account__c].Nominal_Code__c;
			string suspenseCode = Functions.getNominalAccountCode('Suspense Account');		
			CustomerRefund_BudgetModel bModel = new CustomerRefund_BudgetModel();
			Ledger financial = new Ledger();
			if(BType == 'Debit')
			{
				financial.AddJournalDebitEntry(objectLedger.Amount__c, Functions.getAccountCodeById(string.valueOf(objectNominal.Nominal_Account__c)) , objectLedger.Details__c , '', 'T9' , objectLedger.Trans_Date__c);
				financial.AddJournalCreditEntry(objectLedger.Amount__c, suspenseCode , objectLedger.Details__c , '', 'T9' , objectLedger.Trans_Date__c);			
				bModel.AddDebit(string.valueOf(objectNominal.Nominal_Account__c),objectLedger.Amount__c , string.valueOf(objectLedger.Trans_Date__c));
	 			bModel.AddCredit(Functions.getNominalAccountId('Suspense Account') , objectLedger.Amount__c  , string.valueOf(objectLedger.Trans_Date__c));				
			}
			else
			{
				financial.AddJournalCreditEntry(objectLedger.Amount__c,  Functions.getAccountCodeById(string.valueOf(objectNominal.Nominal_Account__c))  , objectLedger.Details__c , '', 'T9' , objectLedger.Trans_Date__c);
				financial.AddJournalDebitEntry(objectLedger.Amount__c,  suspenseCode , objectLedger.Details__c , '', 'T9' , objectLedger.Trans_Date__c);			
				bModel.AddDebit(Functions.getNominalAccountId('Suspense Account'),objectLedger.Amount__c , string.valueOf(objectLedger.Trans_Date__c));
	 			bModel.AddCredit(string.valueOf(objectNominal.Nominal_Account__c), objectLedger.Amount__c  , string.valueOf(objectLedger.Trans_Date__c));		
			}
			financial.save();			
			bModel.newSave();
			return new PageReference(retURL);
		}
		catch(exception ex)
		{
			apexpages.addMessages(ex);
			return null;
		}
	}
	public void ValidationRules()
	{
		if(objectLedger.Trans_Date__c == null)
			throw new CustomException('You must select a date');
		if(objectNominal.Nominal_Account__c == null)
			throw new CustomException('You must select Nominal Account');			
		if(Amount == null || Amount == '')    	    	
			throw new CustomException('Enter amount first');
		if(!Pattern.matches('^[0-9]+(.[0-9]{1,2})?$', Amount)) 
			throw new CustomException('Enter valid currency value');
		if(decimal.valueOf(Amount) <= 0)    	    	
			throw new CustomException('Enter amount first');					
	}
	public PageReference SaveAndNew()
	{
		this.save();
		clearAll();		
		return null;
	}
	public PageReference Cancel()
	{		
		return new PageReference(retURL);
	}
	public void clearAll()
	{
		objectLedger.Trans_Date__c = null;
		objectNominal.Nominal_Account__c = null;
		objectLedger.Details__c = null;
		objectLedger.Amount__c = null;		
	}
	private static testMethod void OpeningBalances_Test()
	{		
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
    	Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, Expense__c = true, Name = 'Plumbering', Account_Code__c = 1222);
		insert nm ;
		Account act = new Account(Name='ABC Company',Type='Customer', Nominal_Account__c = nm.id);
		insert act;
			
		OpeningBalances ob = new OpeningBalances();
		try
		{
			ob.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'You must select Nominal Account');
		}
		ob.objectNominal.Nominal_Account__c = nm.id;
		try
		{
			ob.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'Enter amount first');
		}
		ob.Amount = 'gafadf';
		try
		{
			ob.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'Enter valid currency value');
		}
		ob.Amount = '11';
		ob.objectLedger.Trans_Date__c = null;
		try
		{
			ob.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'You must select a date');
		}
		ob.objectLedger.Trans_Date__c = Date.today();
		ob.BType = 'Debit';		
		ob.Save();		
		ob.BType = 'Credit';
		ob.SaveAndNew();
		ob.Cancel();		
	}	
}