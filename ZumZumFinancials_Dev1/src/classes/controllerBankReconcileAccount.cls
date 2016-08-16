public class controllerBankReconcileAccount {
	public BankReconcile__c objectBankReconcile{get;set;}	
	public BankReconcile__c curObjectBankReconcile{get;set;}			
	public Control_Account__c defaultBank{get;set;}
	public List<Ledger__c> financial{get;set;}	
	public string retURL {get;set;}
	public string idNom1{get;set;}
	public string idNom2{get;set;}
	public string BankId{get;set;}
	public decimal nomBalance{get;set;}
	public decimal Balance{get;set;}	
	public Bank_Account__c opt;
	
	public controllerBankReconcileAccount(ApexPages.standardController std) 
	{									
		objectBankReconcile = new BankReconcile__c();
		objectBankReconcile.Ending_Balance__c = 0.0;
		objectBankReconcile.Statement_Date__c = Date.today();
		retURL = 'https://'+apexPages.currentPage().getHeaders().get('Host')+'/apex/BankMenu';				
		defaultBank = [Select c.Default_Bank__r.Nominal_Code__c, c.Default_Bank__r.Name, c.Default_Bank__r.Id, c.Default_Bank__c From Control_Account__c c where c.Name= 'Control Accounts'];
		opt = [select Name, Nominal_Account__r.Id,Nominal_Account__r.Nominal_Code__c, Nominal_Account__r.Name from Bank_Account__c where Nominal_Account__r.id =: defaultBank.Default_Bank__r.id];		
		nomBalance = [Select Balance__c From Nominal_Account__c where id =: opt.Nominal_Account__r.Id].Balance__c;
		findBalance();
			
	}	
	public list<SelectOption> getBankAccount()//options from list of Bank Accounts with Nominal Codes
	{
		List<SelectOption> options = new list<SelectOption>();						
 		options.add(new SelectOption(opt.Nominal_Account__r.Id,opt.Nominal_Account__r.Nominal_Code__c+' - '+opt.Name));
		for(Bank_Account__c bnk : [select id, Name, Nominal_Account__r.Nominal_Code__c, Nominal_Account__c from Bank_Account__c where Status__c =: 'Active'])
		{			
			if(bnk.Nominal_Account__r.id != opt.Nominal_Account__r.Id)
				options.add(new SelectOption(bnk.Nominal_Account__r.Id ,bnk.Nominal_Account__r.Nominal_Code__c+' - '+bnk.Name));
		}
		return options;	
	}
	public void NominalBalance()
	{
		try
		{					
			nomBalance = [Select Balance__c From Nominal_Account__c where id =: BankId].Balance__c;
			findBalance();
		}
		catch(exception e)
		{
			apexpages.addmessages(e);
		}
	}		
	public void findBalance()
	{
		if(objectBankReconcile.Ending_Balance__c == null)
			objectBankReconcile.Ending_Balance__c = 0.0;
		if(objectBankReconcile.Interest_Amount__c == null)
			objectBankReconcile.Interest_Amount__c = 0.0;		
		if(objectBankReconcile.Charges_Amount__c == null)
			objectBankReconcile.Charges_Amount__c = 0.0;		
		decimal endBalance = nomBalance - objectBankReconcile.Ending_Balance__c;
		decimal intrst = endBalance + objectBankReconcile.Interest_Amount__c;
		balance =  intrst - objectBankReconcile.Charges_Amount__c;
				
	}
	public void SaveValidation()
	{
		if(objectBankReconcile.Ending_Balance__c == 0.0 || objectBankReconcile.Ending_Balance__c == null) 
			throw new CustomException('Enter Ending Balance first.');
		if(objectBankReconcile.Statement_Date__c == null)
			throw new CustomException('Enter Statement Date first.');
		if(objectBankReconcile.Interest_Amount__c != 0)
		{			
			if(objectBankReconcile.Interest_Date__c == null)
				throw new CustomException('Enter Interest Date first.');
			if(IdNom1 == null || IdNom1 == '')
				throw new CustomException('Select Nominal Account first under the head of Interest earned.');			
		}
		if(objectBankReconcile.Charges_Amount__c != 0)
		{			
			if(objectBankReconcile.Charges_Date__c == null)
				throw new CustomException('Enter Charges Date first.');
			if(IdNom2 == null || IdNom2 == '')
				throw new CustomException('Select Nominal Account first under the head of Amount Charges.');			
		}		
		if(((objectBankReconcile.Interest_Date__c != null) || (objectBankReconcile.Interest_Nominal_Account__c != null )) && ((objectBankReconcile.Interest_Amount__c <= 0) || (objectBankReconcile.Interest_Amount__c == null)))
			throw new CustomException('Enter Intrest Amount first.');
		if(((objectBankReconcile.Charges_Date__c != null) || (objectBankReconcile.Charges_Nominal_Account__c != null )) && ((objectBankReconcile.Charges_Amount__c <= 0) || (objectBankReconcile.Charges_Amount__c == null)))
			throw new CustomException('Enter Charges Amount first.');
		if(Balance != 0)
			throw new CustomException('Account is not balanced');
		if((IdNom1 != null && IdNom1 != '') || (IdNom2 != null && IdNom2 != ''))
			if((IdNom1 == idNom2) || (IdNom1 == BankId) || (BankId == idNom2))
				throw new CustomException('All three Nominals must be different');
		
	}
	public PageReference Save()
	{						
		try
		{							
			SaveValidation();
			if(idNom1 != null && idNom1 != '')				
				objectBankReconcile.Interest_Nominal_Account__c = idNom1;
			if(idNom2 != null && idNom2 != '')				
				objectBankReconcile.Charges_Nominal_Account__c = idNom2;
				
			Bank_Account__c bnkAcctt = [select id , Name from Bank_Account__c where Nominal_Account__r.Id =: BankId];									
			BankReconcileModel bnk = new BankReconcileModel(new BankReconcile__c(Bank_Account__c = bnkAcctt.id ,Reference__c = objectBankReconcile.Reference__c,Ending_Balance__c = objectBankReconcile.Ending_Balance__c,Statement_Date__c= objectBankReconcile.Statement_Date__c,Interest_Amount__c=objectBankReconcile.Interest_Amount__c,Interest_Date__c = objectBankReconcile.Interest_Date__c, Interest_Nominal_Account__c = objectBankReconcile.Interest_Nominal_Account__c ,Charges_Amount__c=objectBankReconcile.Charges_Amount__c, Charges_Date__c = objectBankReconcile.Charges_Date__c,Charges_Nominal_Account__c = objectBankReconcile.Charges_Nominal_Account__c)); 
			bnk.Save();	
			
			Ledger financials = new Ledger();				
			CustomerRefund_BudgetModel bModel = new CustomerRefund_BudgetModel();				
			if(objectBankReconcile.Interest_Nominal_Account__c != null )
			{			
				financials.AddBankReconcileTransaction(objectBankReconcile.Interest_Amount__c, objectBankReconcile.Ending_Balance__c, idNom1, BankId, objectBankReconcile.Reference__c, objectBankReconcile.Interest_Date__c, objectBankReconcile.Statement_Date__c);					
				bModel.AddDebit(idNom1,objectBankReconcile.Interest_Amount__c, string.valueOf(objectBankReconcile.Interest_Date__c));
	 			bModel.AddCredit(BankId, objectBankReconcile.Ending_Balance__c  , string.valueOf(objectBankReconcile.Statement_Date__c));
			}
			if(objectBankReconcile.Charges_Nominal_Account__c  != null )
			{		
				financials.AddBankReconcileTransaction(objectBankReconcile.Ending_Balance__c, objectBankReconcile.Charges_Amount__c, BankId, idNom2, objectBankReconcile.Reference__c, objectBankReconcile.Statement_Date__c, objectBankReconcile.Charges_Date__c);					
	 			bModel.AddDebit(BankId, objectBankReconcile.Ending_Balance__c , string.valueOf(objectBankReconcile.Statement_Date__c));
	 			bModel.AddCredit(idNom2,objectBankReconcile.Charges_Amount__c, string.valueOf(objectBankReconcile.Charges_Date__c)); 
			}									
			financials.save();				
			bModel.newSave();				
			financial = [select Trans_Date__c , Bank_Reconcile__c, Bank_Reconcile_Date__c from Ledger__c where Trans_Date__c <=: objectBankReconcile.Statement_Date__c];
			for (Ledger__c l : financial )
			{
				if(l.Bank_Reconcile__c == 'N')
				{
					l.Bank_Reconcile__c = 'Y';
					l.Bank_Reconcile_Date__c = Date.today();
				}
			}
			update financial;				
			return new PageReference('/'+bnk.curObjectBankReconcile.id);			
		}
		catch(exception e)
		{			 
			ApexPages.AddMessages(e);
			return null;
		}
	}		
	private static testMethod void controllerBankReconcileAccountTest()
	{
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
    	Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, Expense__c = true, Name = 'Plumbering', Account_Code__c = 1222);
		insert nm ;
		Nominal_Account__c nm1 = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, Expense__c = true, Name = 'Plumbering', Account_Code__c = 1142);
		insert nm1 ;
		Nominal_Account__c nm2 = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, Expense__c = true, Name = 'Plumbering', Account_Code__c = 1500);
		insert nm2 ;
		Bank_Account__c ba = new Bank_Account__c (Nominal_Account__c = nm.id, Status__c = 'Active' , Name = 'Bank Receipt Account' , Account_Number__c = 'B745');
		insert ba;
		controllerBankReconcileAccount bnkReconcyl = new controllerBankReconcileAccount(new ApexPages.standardController(new BankReconcile__c()));
		bnkReconcyl.nomBalance = 10;		
		BankReconcile__c br = new BankReconcile__c(Bank_Account__c = ba.id ,Reference__c = 'testRefer',Ending_Balance__c = bnkReconcyl.nomBalance + 10 ,Statement_Date__c= Date.today() , Interest_Amount__c =  bnkReconcyl.nomBalance + 10 ,Interest_Date__c = Date.today() , Interest_Nominal_Account__c = nm1.id ,Charges_Amount__c= bnkReconcyl.nomBalance , Charges_Date__c = Date.today(),Charges_Nominal_Account__c = nm2.id);
		insert br;		
		List<SelectOption> bnkAcctt = bnkReconcyl.getBankAccount(); 
		bnkReconcyl.BankId = nm.id;
		bnkReconcyl.objectBankReconcile.Ending_Balance__c = null;
		bnkReconcyl.findBalance();
		try
		{
			bnkReconcyl.SaveValidation();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Enter Ending Balance first.');
		}
		bnkReconcyl.objectBankReconcile.Ending_Balance__c = 0;
		bnkReconcyl.findBalance();
		try
		{
			bnkReconcyl.SaveValidation();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Enter Ending Balance first.');
		}				
		bnkReconcyl.objectBankReconcile.Ending_Balance__c = bnkReconcyl.nomBalance - 1;
		bnkReconcyl.findBalance();
		try
		{
			bnkReconcyl.SaveValidation();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Account is not balanced');
		}
		bnkReconcyl.objectBankReconcile.Ending_Balance__c = bnkReconcyl.nomBalance + 10;
		bnkReconcyl.findBalance();
		bnkReconcyl.objectBankReconcile.Statement_Date__c = null;
		try
		{
			bnkReconcyl.SaveValidation();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Enter Statement Date first.');
		}	
		bnkReconcyl.objectBankReconcile.Statement_Date__c = Date.today();		
		bnkReconcyl.objectBankReconcile.Reference__c = 'test1';	
		bnkReconcyl.objectBankReconcile.Interest_Amount__c = bnkReconcyl.nomBalance + 10;	
		bnkReconcyl.objectBankReconcile.Interest_Date__c = null;
		bnkReconcyl.findBalance();
		bnkReconcyl.objectBankReconcile.Charges_Amount__c = bnkReconcyl.Balance;
		bnkReconcyl.findBalance();
		try
		{
			bnkReconcyl.SaveValidation();
		} 
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Enter Interest Date first.');
		}
		bnkReconcyl.objectBankReconcile.Interest_Date__c = Date.today();
		bnkReconcyl.findBalance();
		bnkReconcyl.idNom1 = null;
		try
		{
			bnkReconcyl.SaveValidation();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Select Nominal Account first under the head of Interest earned.');
		}		
		bnkReconcyl.objectBankReconcile.Interest_Nominal_Account__c = nm1.Id ;
		bnkReconcyl.idNom1 = nm1.Id; 
		bnkReconcyl.objectBankReconcile.Charges_Date__c = null;
		try
		{
			bnkReconcyl.SaveValidation();
		}
		catch(exception e)
		{ 
			system.assertEquals(e.getMessage(), 'Enter Charges Date first.');
		}
		bnkReconcyl.objectBankReconcile.Charges_Date__c = Date.today();
		bnkReconcyl.idNom2 = null;
		try
		{
			bnkReconcyl.SaveValidation();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Select Nominal Account first under the head of Amount Charges.');
		}	
		bnkReconcyl.objectBankReconcile.Interest_Nominal_Account__c = nm.Id ;
		bnkReconcyl.idNom2 = nm.id;
		try
		{
			bnkReconcyl.SaveValidation();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'All three Nominals must be different');			
		}		
		bnkReconcyl.objectBankReconcile.Interest_Nominal_Account__c = nm2.Id ;
		bnkReconcyl.idNom2 = nm2.Id ;
		bnkReconcyl.save();
	}	  
}