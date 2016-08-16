public class controllerBankTransfer {		
	public list<Bank_Account__c> listBankAccount{get;set;}
	public Control_Account__c defaultBank{get;set;}			
	public BankTransfer__c objectBankTransfer{get;set;}
	public BankTransfer__c curObjectBankTransfer{get;set;}	
	public string retURL;
	public string amount{get;set;}
	public string fromId{get;set;}
	public string toId{get;set;}	
	public Ledger financial;	
		
	public controllerBankTransfer()
	{
		retURL = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/apex/BankMenu';		
		objectBankTransfer = new BankTransfer__c();
		objectBankTransfer.Date__c = Date.today();
		amount = '0.00';		
		listBankAccount = [select id,Name, Nominal_Account__r.Nominal_Code__c, Nominal_Account__c from Bank_Account__c where Status__c =: 'Active' order by Nominal_Account__r.Nominal_Code__c];			
	}
	public list<SelectOption> getFromBankAccount()
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
	public list<SelectOption> getToBankAccount()
	{
		List<SelectOption> options = new list<SelectOption>();				
 		options.add(new SelectOption('','-- Select --'));		
		for(Bank_Account__c bnk : listBankAccount)
			options.add(new SelectOption(bnk.Nominal_Account__r.Id,bnk.Nominal_Account__r.Nominal_Code__c+' - '+bnk.Name));		
		return options;	
	}
	
	public PageReference Discard()
	{
		return new PageReference(retURL);
	}
	public PageReference Save()
	{
		try
		{					
			ValidationRules();	
			
			objectBankTransfer.Payment_Value__c = decimal.valueOf(amount);
			BankTransfer__c bnkTransfer = new BankTransfer__c(Reference__c = objectBankTransfer.Reference__c, Description__c = objectBankTransfer.Description__c, Date__c = objectBankTransfer.Date__c, Payment_Value__c = objectBankTransfer.Payment_Value__c);
			insert bnkTransfer;
												
			CustomerRefund_BudgetModel bModel = new CustomerRefund_BudgetModel();
			bModel.AddDebit(toId, objectBankTransfer.Payment_Value__c , string.valueOf(objectBankTransfer.Date__c));
			bModel.AddCredit(fromId, objectBankTransfer.Payment_Value__c , string.valueOf(objectBankTransfer.Date__c));
 			bModel.newSave();  			
 			
 			financial =  new Ledger(); 			
 			financial.AddBankTransferTransaction( objectBankTransfer.Payment_Value__c , toId, fromId, objectBankTransfer.Description__c , objectBankTransfer.Reference__c, objectBankTransfer.Date__c ); 											
			financial.Save(); 
					
			return new PageReference(retURL);		
		}	
		catch(exception e)
		{
			ApexPages.AddMessages(e);
			return null;
		}
	}
	public void ValidationRules()	
	{
		if(fromId == null || toId == null)
			throw new CustomException('Select Bank Account first');
		if(fromId == toId)
			throw new CustomException('You must select different Bank Accounts');
		if(objectBankTransfer.Date__c == null)			
			throw new CustomException('You must enter date to save the record');
		if(Amount == null || Amount == '')
			Amount = '0.0'; 		
		if(!Pattern.matches('^[0-9]+(.[0-9]{1,2})?$', Amount))
			throw new CustomException('Enter an Amount first');
		if(decimal.valueOf(Amount) <= 0)
				throw new CustomException('Enter an Amount first');
	}	
	private static testMethod void controllerBankTransfer_Test()
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
		Bank_Account__c ba = new Bank_Account__c (Nominal_Account__c = nm.id, Status__c = 'Active' , Name = 'Bank From Account' , Account_Number__c = 'B745');
		insert ba;
		Bank_Account__c ba1 = new Bank_Account__c (Nominal_Account__c = nm1.id, Status__c = 'Active' , Name = 'Bank To Account' , Account_Number__c = 'B4165');
		insert ba1;
		
		controllerBankTransfer bnkTransfr = new controllerBankTransfer();
		List<SelectOption> FrmbnkAcctt = bnkTransfr.getFromBankAccount();								
		List<SelectOption> TobnkAcctt = bnkTransfr.getToBankAccount();
		try
		{
			bnkTransfr.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Select Bank Account first');
		}
		bnkTransfr.fromId = nm.Id;
		try
		{
			bnkTransfr.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Select Bank Account first');
		}
		bnkTransfr.toId = nm.Id;
		try
		{
			bnkTransfr.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'You must select different Bank Accounts');
		}
		bnkTransfr.toId = nm1.Id;
		bnkTransfr.objectBankTransfer.Date__c = null;
		try
		{
			bnkTransfr.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'You must enter date to save the record');
		}
		bnkTransfr.objectBankTransfer.Date__c = Date.today();
		bnkTransfr.amount = null;
		try
		{
			bnkTransfr.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Enter an Amount first');
		}
		bnkTransfr.amount = 'asdg';
		try
		{
			bnkTransfr.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Enter an Amount first');
		}
		bnkTransfr.amount = '4';
		bnkTransfr.Save();
		bnkTransfr.Discard();
		
	}  
}