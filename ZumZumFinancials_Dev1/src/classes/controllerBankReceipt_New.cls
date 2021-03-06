public class controllerBankReceipt_New {		
	public wrapperBankReceipt objectWrapper {get;set;}
	public List<wrapperBankReceipt> lstWrapper;	
	public Map<string, Tax_Rate__c> mapTaxRate{get;set;}	
	public string BankId {get;set;}
	public string NominalId {get;set;}
	public string TaxId {get;set;}
	public string Reference {get;set;}
	public string nameTaxRate;
	public string Details{get;set;}
	public string NomCode{get;set;}
	public string NomName{get;set;} 	
	public string retURL{get;set;}
	public string Amount {get;set;}
	public decimal Rate{get;set;}
	public decimal Tax{get;set;}
	public decimal Net{get;set;}
	public string currencySymbol{get;set;}
	public boolean edited;
	public integer index{get;set;}
	public integer deletedIndex;        
	public integer editedIndex;	
		
	public controllerBankReceipt_New()
	{			
		Amount = '0.0';
		index = 0;
		Tax = 0.0;
		Net = 0.0;
		currencySymbol = Functions.getOrganisationCurrency('CurrencySymbol');
		retURL = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/apex/BankMenu';								
		lstWrapper = new List<wrapperBankReceipt>(); 				
		mapTaxRate = new Map<string, Tax_Rate__c>([select Id, Tax_Rate__c, Name from Tax_Rate__c order by Name asc limit 50]);			
	}
	public List<SelectOption> getTaxRate()
	{
		try
		{	
			List<SelectOption> options = new List<SelectOption>();
			Tax_Rate__c opt = [select Id, Name, Tax_Rate__c from Tax_Rate__c where is_default__c =: true];
	    	options.add(new SelectOption(opt.id,opt.Name));
	    	Rate = opt.Tax_Rate__c;
			for(Tax_Rate__c txt : [select Id, Tax_Rate__c, Name from Tax_Rate__c order by Name asc])
			{ 
				if(txt.id != opt.id)
					options.add(new SelectOption(txt.Id, txt.Name));					
			}		
			return options;
		}
		catch(exception e)
		{
			apexpages.addmessages(e);
			return null;
		}
	}
	public list<SelectOption> getBankAccount()//options from list of Bank Accounts with Nominal Codes
	{
		List<SelectOption> options = new list<SelectOption>();	
		Control_Account__c defaultBank = [Select c.Default_Bank__r.Nominal_Code__c, c.Default_Bank__r.Name, c.Default_Bank__r.Id, c.Default_Bank__c From Control_Account__c c where c.Name= 'Control Accounts'];
		Bank_Account__c opt = [select Name, Nominal_Account__r.Id,Nominal_Account__r.Nominal_Code__c, Nominal_Account__r.Name from Bank_Account__c where Nominal_Account__r.Name =: defaultBank.Default_Bank__r.Name];		
 		options.add(new SelectOption(opt.Nominal_Account__r.Id,opt.Nominal_Account__r.Nominal_Code__c+' - '+opt.Name));
		for(Bank_Account__c bnk : [select id,Name, Nominal_Account__r.Nominal_Code__c, Nominal_Account__c from Bank_Account__c where Status__c =: 'Active']) 		
		{			
			if(bnk.Nominal_Account__r.id != opt.Nominal_Account__r.Id)
				options.add(new SelectOption(bnk.Nominal_Account__r.Id,bnk.Nominal_Account__r.Nominal_Code__c+' - '+bnk.Name));
		}
		return options;	
	}
	public void settingRate()
	{	
		try
		{	
			if(mapTaxRate.KeySet().contains(TaxId))
			{
				if(!Pattern.matches('^[0-9]+(.[0-9]{1,2})?$', Amount))
				throw new CustomException('Enter currency first');
				Rate = Rate.setScale(2);						
				Rate =mapTaxRate.get(TaxId).Tax_Rate__c;		
				if(decimal.valueof(Amount) > 0)
				{						
					Tax = decimal.valueOf(Amount) * (Rate/100);
					Net = decimal.valueOf(Amount) + Tax;
					Tax = Tax.setScale(2);
					Net = Net.setScale(2);
				}	
				else
					throw new CustomException('Enter Amount first');
			}		
		}
		catch(exception e)
		{
			ApexPages.addMessages(e);			
		}
	}
	public decimal getRate()
	{
		return Rate;
	}
	public decimal getTax()
	{
		return Tax;
	}
	public decimal getNet()
	{
		return Net;
	}
	public void validationRules()
	{	
		if(BankId == null)		
			throw new CustomException('Select Bank Account first');					
		if(NominalId == null || NominalId == '')		
			throw new CustomException('Select Nominal Account first');							
		if(Details != null && Details != '')
			if(Details.length() > 255)
			{
	    		throw new CustomException('Detail exceeded limit of 255 characters');
	    		Nominal();
			}
		if(!Pattern.matches('^[0-9]+(.[0-9]{1,2})?$', Amount))
		{
			throw new CustomException('Enter an amount first');
			Nominal();
		}
		if(decimal.valueof(Amount) <= 0)
		{
			throw new CustomException('Enter an amount first');
			Nominal();
		}				
		if(TaxId == null)		
			throw new CustomException('Select Tax Rate first');											
	}
	public void Add()
	{			
		try
		{
			validationRules();			
			settingRate();				
			if(mapTaxRate.KeySet().contains(TaxId))
				nameTaxRate = mapTaxRate.get(TaxId).Name;								 			
			objectWrapper = new wrapperBankReceipt(NominalId,TaxId, nameTaxRate,BankId,Functions.getAccountCodeById(BankId),Reference,Details,decimal.valueOf(Amount),Rate,Tax,Net,index);
			lstWrapper.add(objectWrapper);
			clearValues();
			edited = false;	
			index++;
			
		}
		catch(exception e)
		{
			Nominal();
			ApexPages.addMessages(e);			
		}	
	}	
	public void Nominal()
	{					
		try	
		{
		if(NominalId != null && NominalId != '')
		{
			NomCode = Functions.getAccountCodeById(NominalId);
			NomName = Functions.getNominalAccountNameByID(NominalId);
		}
		}
		catch(exception e)
		{
			ApexPages.addMessages(e);	
		}	
	}	
	public void clearValues()
	{
		NominalId =  null;
		BankId =  null;
		TaxId =  null;
		Reference =  null;
		Details =  null;	
		Amount = '0.0';
		Rate =  0.0;
		Tax =  0.0;
		Net =  0.0;	
		NomCode = '';
		NomName = '';
	}
	public void deleteItem()
	{    	        	 		
		if((ApexPages.currentPage().getParameters().get('paramDelete') != null) || (ApexPages.currentPage().getParameters().get('paramDelete') != ''))
    	{
			deletedIndex = integer.valueOf(ApexPages.currentPage().getParameters().get('paramDelete'));
			delete_update(deletedIndex);
    	}					     
	}
	public void editItem()
	{		
		editedIndex = integer.valueOf(ApexPages.currentPage().getParameters().get('paramEdit'));
		if(edited == true)
		{
			Add();
			edition(editedIndex);
		}
		else
		{
			edition(editedIndex);    		
		}	       	 	    
	}
	public void edition(integer param)    
	{	
		edited = true;
		for(wrapperBankReceipt iterator:lstWrapper)
		{    
			if(iterator.index == editedIndex)
			{ 	  
				BankId = iterator.BankId;
				Reference = iterator.Reference;			
	    		NominalId = iterator.NominalId;
	    		NomCode = iterator.codeNom;
	    		NomName = iterator.NomAcctt;    		
		    	Details = iterator.Details;
		    	TaxId = iterator.TaxId;
		    	Amount = string.valueOf(iterator.Amount);
		    	Rate = iterator.Rate; 
		    	Tax = iterator.Tax;
		    	Net = iterator.Tax;	    			    			   
		    	break;	    				    	
			}  
		}
		delete_update(editedIndex);
	}    
	public void delete_update(integer param)
	{
		if(lstWrapper.size()==1)
		{
			lstWrapper.remove(param);
			index--;    			    			
		}
		else
		{    			    			
			lstWrapper.remove(param);
			index--;	    			    			    	
			updateIndexes(param);
		}  
	}          
	public void updateIndexes(integer deletedIndex)
	{
		for(wrapperBankReceipt iterator:lstWrapper)    	
		{    
			if(iterator.index > deletedIndex )
			{	    	
				iterator.index = deletedIndex;
				lstWrapper.set(deletedIndex,iterator);
				deletedIndex++;
			}    									
		}	    	
	}  
	public List<wrapperBankReceipt> getlstWrapper()
	{
		return lstWrapper; 
	}
	public PageReference Discard()
	{
		return new PageReference(retURL);	
	}
	public PageReference Save()
	{
		try
		{					
			if(lstWrapper.size() > 0)
			{	
				Ledger financial =  new Ledger();	
				CustomerRefund_BudgetModel bm = new CustomerRefund_BudgetModel();
				for(wrapperBankReceipt itr: lstWrapper)
				{										
					financial.AddBankReceiptTransaction(itr.Net,itr.bnkAcctt,itr.codeNom,itr.Details,itr.Reference,itr.taxName,itr.Tax);																					
					bm.AddDebit(itr.BankId, itr.Net, '');				
					bm.AddCredit(itr.NominalId, itr.Amount , '');								
	 				if(itr.Tax > 0) 				 				
	 					bm.AddCredit(Functions.getNominalAccountId('Sales Tax Control Account') , itr.Tax , ''); 					 				 				 			 			
				}					
				financial.Save();			
				bm.newSave();
				return new PageReference(retURL);
			}
			else
				throw new CustomException('You must make entries to save the record');
		}
		catch(exception e)
		{
			apexpages.addMessages(e);
			return null;			
		}	
	}
	private static testMethod void controllerBankPayment_Test()
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
		Bank_Account__c ba = new Bank_Account__c (Nominal_Account__c = nm.id, Status__c = 'Active' , Name = 'Bank Receipt Account' , Account_Number__c = 'B745');
		insert ba; 
		
		controllerBankReceipt_New bnkrcpt = new controllerBankReceipt_New();
		List<SelectOption> txrate = bnkrcpt.getTaxRate();
		List<SelectOption> bnkAcctt = bnkrcpt.getBankAccount();		
		bnkrcpt.Reference = 'test1';				
		try
		{
			bnkrcpt.Save();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'You must make entries to save the record');
		}
		try
		{
			bnkrcpt.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'Select Bank Account first');
		}
		bnkrcpt.BankId =  nm.id;
		try
		{
			bnkrcpt.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'Select Nominal Account first');
		}
		bnkrcpt.NominalId = na.Id;
		try
		{
			bnkrcpt.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'Enter an amount first');
		}
		bnkrcpt.Amount = '0';
		try
		{
			bnkrcpt.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'Enter an amount first');
		}
		bnkrcpt.Amount = 'abcd';
		try
		{
			bnkrcpt.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'Enter an amount first');
		}		
		bnkrcpt.Details = '1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 1234567890 ';
		try
		{
			bnkrcpt.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'Detail exceeded limit of 255 characters');
		}
		bnkrcpt.Amount = '5';
		bnkrcpt.Details = 'testDetail';
		bnkrcpt.TaxId = null;
		try
		{
			bnkrcpt.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'Select Tax Rate first');
		}
		bnkrcpt.TaxId = tx.Id;
		bnkrcpt.Add();
		apexpages.currentPage().getParameters().put('paramDelete','0');
		bnkrcpt.deleteItem();
		
		bnkrcpt.BankId =  nm.id;
		bnkrcpt.NominalId = na.Id;
		bnkrcpt.Amount = '5';
		bnkrcpt.Details = 'testDetail';
		bnkrcpt.TaxId = tx.Id;
		bnkrcpt.Add();
		apexpages.currentPage().getParameters().put('paramEdit','0');
		bnkrcpt.editItem();
		
		bnkrcpt.BankId =  nm1.id;
		bnkrcpt.NominalId = na.Id;
		bnkrcpt.Amount = '15';		
		bnkrcpt.TaxId = tx.Id;
		bnkrcpt.Add();
		List<wrapperBankReceipt> lst = bnkrcpt.getlstWrapper();
		bnkrcpt.Save();							
	} 	  		  	
}