public class GeneralJournalController {	 
    public CustomerLookup__c objectLookup{get;set;}
    public string Reference{get;set;}
    public string Narrative{get;set;}    
    public Tax_Rate__c objectTaxRate{get;set;}    
    public GeneralJournalWrapper objectWrapper{get;set;}
    public List<GeneralJournalWrapper> listGeneralJournal{get;set;}    
    public List<Tax_Rate__c> listTaxRate{get;set;}         
    public string nameGeneralJournal{get;set;}         
    public string codeGeneralJournal{get;set;}
    public string code{get;set;}
    public string name{get;set;}
    public string nameTaxRate;
    public string ncId{get;set;}
    public string Debit {get;set;}
    public string Credit{get;set;} 
    public integer index{get;set;}
    public integer deletedIndex;        
    public integer editedIndex;	
    public Decimal totalDebit{get;set;}
    public Decimal totalCredit{get;set;}
    public Decimal Balance{get;set;}    
    public boolean edited;    
    public string currencySymbol{get;set;}
    public string retURL{get;set;}                     
    public Ledger financial;    
    public CustomerRefund_BudgetModel bm;
    
    public GeneralJournalController()
    {    	    	
    	retURL ='https://'+ApexPages.currentPage().getHeaders().get('Host')+'/apex/TransactionsMenu';
    	totalDebit = 0.0;    	
    	totalCredit = 0.0;
    	Debit= '0.00';
    	Credit= '0.00';
    	Balance = 0.00;
		index = 0;		
		currencySymbol = Functions.getOrganisationCurrency('CurrencySymbol');								        
    	objectLookup = new CustomerLookup__c(); 
    	objectLookup.Date__c = Date.today();
        listGeneralJournal = new List<GeneralJournalWrapper>();
    	listTaxRate = [select Id, Name, Tax_Rate__c from Tax_Rate__c order by is_default__c , Tax_Rate__c limit 1000];                           
    }    
    public List<SelectOption> getTaxRate() 
	{
		try
		{
	    	List<SelectOption> options = new List<SelectOption>();	    	
	    	for(Tax_Rate__c t : listTaxRate)
	    	{	    		
	    		options.add(new SelectOption(t.Id,t.Name));    		
	    	}    
        	return options;
	    		    	
		}
		catch(exception e)
		{
			apexpages.addMessages(e);
			return null;
		}
    }    
    public void validationRules()
    {    	
    	if(ncId == null || ncId == '')
    		throw new CustomException('Enter Nominal Account first');
    	if(objectLookup.Tax_Rate__c==null)
    		throw new CustomException('Select VAT first');
    	if(Narrative != null)
    		if(Narrative.length() > 255)
    			throw new CustomException('Detail exceeded limit of 255 characters');
    	if(Debit == null || Debit == '')
	    	Debit = '0.00';
    	if(Credit == null || Credit == '')
    		Credit = '0.00';	 
    	if((!Pattern.matches('^[0-9]+(.[0-9]{1,2})?$', Debit)) || (!Pattern.matches('^[0-9]+(.[0-9]{1,2})?$', Credit)))
			throw new CustomException('Enter valid currency value');    	    	
    	if((Decimal.valueOf(Debit) > 0) && (Decimal.valueOf(Credit)> 0))    	    		
    		throw new CustomException('You can not perform Debit and Credit at once');    	    	
    	else if((Decimal.valueOf(Debit) <= 0) && (Decimal.valueOf(Credit) <= 0))    	
    		throw new CustomException('You must perform either Debit or Credit');    		    		    	    		        	    	    		    		    	    	    	   
    }
    public void Add()
    {    	      	
    	try
    	{     		
	    	for(Tax_Rate__c t : listTaxRate)
	    	{
	    		if(t.id == objectLookup.Tax_Rate__c) 
	    			nameTaxRate = t.Name;
	    	}    	    	
    		validationRules();	 	    				    			    					    		    	  									
			objectWrapper = new GeneralJournalWrapper(ncId,string.valueOf(objectLookup.Tax_Rate__c),Narrative,Debit,Credit,nameTaxRate,index);
    		listGeneralJournal.add(objectWrapper);    		
    		Total();
    		index++;	    		
    		clearCurrentValues();    			    	        	 	
    		edited = false;
    	}
    	catch(exception e)
    	{    		
    		apexPages.addMessages(e);    		
    		if(ncID != null && ncID != '' )
    		{    				    		
	    		codeGeneralJournal = Functions.getAccountCodeById(ncId);
	    		nameGeneralJournal = Functions.getNominalAccountNameByID(ncId);	    		
    		}    		    		
    	}   	
    }
    public void Total()
    {
    	totalDebit = 0.0;
    	totalCredit = 0.0;
    	for(GeneralJournalWrapper iterator : listGeneralJournal)    	
    	{
    		totalDebit += iterator.Debit;
    		totalCredit += iterator.Credit; 
    	}
    	Balance = (totalDebit - totalCredit); 
    }    
    public void clearCurrentValues()
    {
    	ncId = null;
    	Narrative = null;
    	objectLookup.Tax_Rate__c = null;
    	Debit = '0.00';
    	Credit = '0.00'; 
    	codeGeneralJournal = null;
    	nameGeneralJournal = null;
    }              
    public PageReference Discard()
    {
    	return new PageReference(retURL);    	
    }
    public void SaveValidationRules()
    {    
    	if(Balance != 0.0)
			throw new CustomException('The Journal;s Entry is not balanced');
		if(listGeneralJournal.size()==0)
			throw new CustomException('You must make entries to save the record');
		if(objectLookup.Date__c == null)
			throw new CustomException('You must enter date to save the record');
    }
    public PageReference Save()
    {    	
    	try
    	{
    		SaveValidationRules();	    		    	   		    		    			    						    			    		
			financial =  new Ledger();
			bm = new CustomerRefund_BudgetModel();										
		    for(GeneralJournalWrapper itr : listGeneralJournal)		    
		    {			    	
		    	if(itr.Credit > 0)			    			    				   
		    	{			    		
					financial.AddJournalCreditEntry(itr.Credit ,  itr.Code , itr.Narrative, Reference, itr.Tax , objectLookup.Date__c);
					bm.AddCredit(itr.idNominal , itr.Credit , string.valueOf(objectLookup.Date__c));						
		    	}						
				else
				{																								
					financial.AddJournalDebitEntry(itr.Debit ,  itr.Code , itr.Narrative , Reference, itr.Tax , objectLookup.Date__c);							
					bm.AddDebit(itr.idNominal, itr.Debit , string.valueOf(objectLookup.Date__c));
				}														    		
		    }				    	    
		    financial.Save();			    
		    bm.newSave();			   		    		   		        		    		    		       		    		 
		    return new PageReference(retURL);		  
    	}
    	catch(exception e)
    	{
    		apexPages.addMessages(e);    		    	
    		return null;	
    	}
    }
    public void deleteItem()
    {       	 
    	if((ApexPages.currentPage().getParameters().get('paramDelete') != null) || (ApexPages.currentPage().getParameters().get('paramDelete') != ''))
    	{
			deletedIndex = integer.valueOf(ApexPages.currentPage().getParameters().get('paramDelete'));				
			delete_update(deletedIndex);	
			Total();
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
    		Total();
    	}	       	 	    
    }  
    public void edition(integer param)    
	{
		edited = true;
		for(GeneralJournalWrapper iterator:listGeneralJournal)
		{   
			if(iterator.ind == editedIndex)
			{ 		
	    		ncId = iterator.idNominal;
	    		Narrative = iterator.Narrative;
		    	objectLookup.Tax_Rate__c = iterator.idTax;
		    	Debit = string.valueOf(iterator.Debit);
		    	Credit = string.valueOf(iterator.Credit);
		    	codeGeneralJournal = iterator.Code;
		    	nameGeneralJournal =  iterator.Name;		    			    
		    	break;	    				    	
			}  
		}
		delete_update(editedIndex);
	}   
    public void delete_update(integer param)
    {
    	if(listGeneralJournal.size()==1)
		{
			listGeneralJournal.remove(param);
			index--;    			    			
		}
		else
		{    			    			
    		listGeneralJournal.remove(param);
    		index--;	    			    			    	
    		updateIndexes(param);
		}  
    }          
    public void updateIndexes(integer deletedIndex)
    {
    	for(GeneralJournalWrapper iterator : listGeneralJournal)    	
    	{    
    		if(iterator.ind > deletedIndex )
    		{	    	
    			iterator.ind = deletedIndex;
    			listGeneralJournal.set(deletedIndex,iterator);
    			deletedIndex++;
    		}    									
    	}	    	
    }      
    public List<GeneralJournalWrapper> getListGeneralJournal()
    {
    	return listGeneralJournal; 
    }
    
    private static TestMethod void GeneralJournalControllerTest()
    {    	
    	Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
    	Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, Expense__c = true, Name = 'Plumbering', Account_Code__c = 150);
		insert nm ;
		
		GeneralJournalController gCntrlr = new GeneralJournalController();
    	gCntrlr.Reference = 'abc';
    	gCntrlr.objectLookup.Date__c = date.today() ;//date.newinstance(2011,01,01);
    	
		gCntrlr.ncId = nm.id;
		gCntrlr.codeGeneralJournal = string.valueOf(nm.Account_Code__c);
		gCntrlr.nameGeneralJournal = nm.Name;		
		gCntrlr.Narrative = '123Hello';		
		gCntrlr.objectLookup.Tax_Rate__c = tx.id;
		try
		{		
			gCntrlr.SaveValidationRules();
		}
		catch (exception e)
		{			
			system.assertEquals(e.getMessage(), 'You must make entries to save the record');	
		}
		gCntrlr.Debit = string.valueof(2);
		gCntrlr.Credit = string.valueof(3);		
		try		
		{
			gCntrlr.validationRules();
		}
		catch (exception e)
		{			
			system.assertEquals(e.getMessage(), 'You can not perform Debit and Credit at once');	
		}					
		gCntrlr.Credit = 'a';
		gCntrlr.Debit = string.valueof(0);
		try		
		{
			gCntrlr.validationRules();
		}
		catch (exception e)
		{			
				system.assertEquals(e.getMessage(), 'Enter valid currency value');	
		}		
		gCntrlr.Credit = '5';
		gCntrlr.Debit = null;
		gCntrlr.Add();
		try
		{		
			gCntrlr.SaveValidationRules();
		}
		catch (exception e)
		{			
			system.assertEquals(e.getMessage(), 'The Journal;s Entry is not balanced');	
		}					
		gCntrlr.Credit = string.valueof(0);
		gCntrlr.Debit  = string.valueOf(5);																			
		try
		{
			gCntrlr.validationRules();
		}
		catch (exception e)
		{			
			system.assertEquals(e.getMessage(), 'Enter Nominal Account first');				
		}
		gCntrlr.ncId = nm.id;
		gCntrlr.codeGeneralJournal = string.valueOf(nm.Account_Code__c);
		gCntrlr.nameGeneralJournal = nm.Name;		
		gCntrlr.Narrative = '123Hello';		
		gCntrlr.objectLookup.Tax_Rate__c = tx.id;
		try
		{			
			gCntrlr.Add();
		}
		catch (exception e)
		{			
			system.debug('error on 4th add :' +e.getMessage());			
		}
		gCntrlr.objectLookup.Date__c = null;
		try
		{		
			gCntrlr.SaveValidationRules();
		}
		catch (exception e)
		{			
			system.assertEquals(e.getMessage(), 'You must enter date to save the record');	
		}			
		gCntrlr.objectLookup.Date__c = date.newinstance(2011,01,01);		
		gCntrlr.save();		
		
		ApexPages.currentPage().getParameters().put('paramDelete' , '0');		
		gCntrlr.deleteItem();			
		nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, Expense__c = true, Name = 'testingNominal', Account_Code__c = 1150 );
		insert nm ;		
		ApexPages.currentPage().getParameters().put('paramEdit' , '0');
		gCntrlr.editItem();
		gCntrlr.ncId = nm.id;
		gCntrlr.codeGeneralJournal = string.valueOf(nm.Account_Code__c);
		gCntrlr.nameGeneralJournal = nm.Name;		
		gCntrlr.Narrative = 'tst123';		
		gCntrlr.objectLookup.Tax_Rate__c = tx.id;		
		gCntrlr.Credit = string.valueof(1); 
		gCntrlr.Debit = string.valueof(0);		
		try
		{			
			gCntrlr.Add();			
		}
		catch(exception e)
		{
			system.debug('exception in 5th add : '+e); 
		}
		system.debug('gCntrlr 2 : '+ gCntrlr);		
		gCntrlr.ncId = nm.id;
		gCntrlr.codeGeneralJournal = string.valueOf(nm.Account_Code__c);
		gCntrlr.nameGeneralJournal = nm.Name;					
		gCntrlr.objectLookup.Tax_Rate__c = null;		
		gCntrlr.Credit = string.valueof(0); // normally binded with decimal
		gCntrlr.Debit = string.valueof(1);	// normally binded with decimal				
		try
		{			
			gCntrlr.Add();
		}
		catch(exception e)
		{			
			system.assertEquals(e.getMessage(), 'Select VAT first');							
		}		
		gCntrlr.objectLookup.Tax_Rate__c = tx.id;
		gCntrlr.Add();		
		gCntrlr.Save();			
		gCntrlr.ncId = nm.id;
		gCntrlr.codeGeneralJournal = string.valueOf(nm.Account_Code__c);
		gCntrlr.nameGeneralJournal = nm.Name;					
		gCntrlr.objectLookup.Tax_Rate__c = tx.id;		
		gCntrlr.Credit = string.valueof(5);
		gCntrlr.Debit = string.valueof(0);								
		gCntrlr.Add();		
		gCntrlr.ncId = nm.id;
		gCntrlr.codeGeneralJournal = string.valueOf(nm.Account_Code__c);
		gCntrlr.nameGeneralJournal = nm.Name;					
		gCntrlr.objectLookup.Tax_Rate__c = tx.id;				
		gCntrlr.Debit = string.valueof(5);	
		gCntrlr.Credit = null; 									
		gCntrlr.Add();		
		gCntrlr.ncId = nm.id;
		gCntrlr.codeGeneralJournal = string.valueOf(nm.Account_Code__c);
		gCntrlr.nameGeneralJournal = nm.Name;					
		gCntrlr.objectLookup.Tax_Rate__c = tx.id;		
		gCntrlr.Credit = string.valueof(10);
		gCntrlr.Debit = null;									
		gCntrlr.Add();		
		gCntrlr.ncId = nm.id;
		gCntrlr.codeGeneralJournal = string.valueOf(nm.Account_Code__c);
		gCntrlr.nameGeneralJournal = nm.Name;					
		gCntrlr.objectLookup.Tax_Rate__c = tx.id;		
		gCntrlr.Credit = string.valueof(0);
		gCntrlr.Debit = string.valueof(10);								
		gCntrlr.Add();		
		ApexPages.currentPage().getParameters().put('paramDelete' , '0');		
		gCntrlr.deleteItem();
		gCntrlr.Discard();										
    } 
}