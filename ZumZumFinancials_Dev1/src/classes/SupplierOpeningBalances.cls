public class SupplierOpeningBalances {	
	public CustomerLookup__c objectAccount{get;set;}
	public Ledger__c objectLedger{get;set;}
	public string BType {get; set;}
	public string retURL{get; set;}
	public string currencySymbol{get;set;}
	public string Amount{get;set;}
	public SupplierOpeningBalances()
	{
		retURL = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/apex/Setup';
		currencySymbol = Functions.getOrganisationCurrency('CurrencySymbol');
		objectAccount = new CustomerLookup__c();
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
			string AccountNo = [select AccountNumber from Account where id=: objectAccount.SupplierAccount__c].AccountNumber;		
			string DebitorsCode = Functions.getNominalAccountCode('Suspense Account');
			string CreditorsCode = Functions.getNominalAccountCode('Creditors Control Account');				
			Ledger financial = new Ledger();			
			CustomerRefund_BudgetModel bModel = new CustomerRefund_BudgetModel();
			if(BType == 'Debit')
			{		
				financial.AddDebitOpeningBalances('PI', objectLedger.Amount__c , objectLedger.Details__c,  AccountNo , DebitorsCode ,CreditorsCode, objectLedger.Trans_Date__c);				
				bModel.AddDebit(Functions.getNominalAccountId('Suspense Account') , objectLedger.Amount__c  , string.valueOf(objectLedger.Trans_Date__c));
				bModel.AddCredit(Functions.getNominalAccountId('Creditors Control Account'),objectLedger.Amount__c , string.valueOf(objectLedger.Trans_Date__c)); 			  
			}		
			else
			{		
				financial.AddCreditOpeningBalances('PI', objectLedger.Amount__c , objectLedger.Details__c,  AccountNo ,  DebitorsCode ,CreditorsCode, objectLedger.Trans_Date__c);								
 				bModel.AddDebit(Functions.getNominalAccountId('Creditors Control Account'), objectLedger.Amount__c  , string.valueOf(objectLedger.Trans_Date__c));
 				bModel.AddCredit(Functions.getNominalAccountId('Suspense Account'),objectLedger.Amount__c , string.valueOf(objectLedger.Trans_Date__c));
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
		if(objectAccount.SupplierAccount__c == null)
			throw new CustomException('You must select an Account');			
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
		objectAccount.SupplierAccount__c = null;
		objectLedger.Details__c = null;
		objectLedger.Amount__c = null;		
	}
	private static testMethod void SupplierOpeningBalances_Test()
	{		
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
    	Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, Expense__c = true, Name = 'Plumbering', Account_Code__c = 1222);
		insert nm ;
		Account act = new Account(Name='ABC Company',Type='Supplier', Nominal_Account__c = nm.id);
		insert act;
			
		SupplierOpeningBalances SoB = new SupplierOpeningBalances();
		try
		{
			SoB.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'You must select an Account');
		}
		SoB.objectAccount.SupplierAccount__c = act.id;
		try
		{
			SoB.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'Enter amount first');
		}
		SoB.Amount = 'gafadf';
		try
		{
			SoB.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'Enter valid currency value');
		}
		SoB.Amount = '11';
		SoB.objectLedger.Trans_Date__c = null;
		try
		{
			SoB.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'You must select a date');
		}
		SoB.objectLedger.Trans_Date__c = Date.today();
		SoB.BType = 'Debit';		
		SoB.Save();		
		SoB.BType = 'Credit';
		SoB.SaveAndNew();
		SoB.Cancel();		
	}
}