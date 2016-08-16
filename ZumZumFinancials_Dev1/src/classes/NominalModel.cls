public class NominalModel {
	public List<Nominal_Account__c> listNominalAccount;
	public List<Nominal_Account__c> newlistNominalAccount;
	public string CreditId;
	public string DebitId;	
	public decimal amount;
	public decimal creditAmount;
	public decimal debitAmount;
	
	public NominalModel()
	{		
		listNominalAccount = [select id, Name, Debit_Balance__c, Credit_Balance__c from Nominal_Account__c limit 1000];
		newlistNominalAccount = new List<Nominal_Account__c>(); 
	}
	
	/*
	public NominalModel(string c, string d,decimal a)	
	{
		if(c== null || c =='')
			creditID = null;
		else	
			creditID = c;
		if( d== null || d =='')
			debitID = null;
		else
			debitID = d;		
		amount = a;		
		listNominalAccount = [select id, Name, Debit_Balance__c, Credit_Balance__c from Nominal_Account__c where id In (:CreditId, :DebitId)];		
	}
	*/	
	/*
	public void Save()
	{
		Savepoint sp =  DataBase.setSavepoint();
		try
		{		
			addtoList();	
			update listNominalAccount;
	    } 						
		catch(exception e)
		{
			Database.rollback(sp);
			throw new CustomException('Unable to Save '+e.getMessage());
		}
	}
	*/
	/*
	public void AddtoList()
	{		
		if(listNominalAccount.size() > 0)
		{
			for(Nominal_Account__c itr: listNominalAccount)
			{		 						
				if(CreditId != null && CreditId != '')				
				{
					system.debug('credit : '+ CreditId);
					if(string.valueof(itr.Id) == CreditId)
					{							
						if(itr.Credit_Balance__c == null)
							itr.Credit_Balance__c = amount;	 		
				 		else
				 			itr.Credit_Balance__c += amount;			 					 				 					 			
					}
				}
				if(DebitId != null && DebitId != '')
				{
					system.debug('credit : '+ DebitId);
					if(string.valueof(itr.id) == DebitId)
					{					
						if(itr.Debit_Balance__c == null)
							itr.Debit_Balance__c = amount;	
						else 
				 			itr.Debit_Balance__c += amount;			 					 	
					}			    			   
				}
			}
		}		
		else
			throw new CustomException('Nominal Account doesnot exist');		
	}
	
	*/
	public void AddCredit(string c, decimal a)
	{
		boolean matchedCredit = false;
		CreditId = c;
		amount = a;		
		if(newlistNominalAccount.size() > 0)
		{
			system.debug('size of list increases in credit: '+newlistNominalAccount);
			for(Nominal_Account__c itrt: newlistNominalAccount)
			{
				if(itrt.id == CreditId)
				{
					if(itrt.Credit_Balance__c == null)
						itrt.Credit_Balance__c = amount;					
					else
						itrt.Credit_Balance__c += amount;
					matchedCredit = true;
					system.debug('matchedCredit : '+itrt.Credit_Balance__c);
				}
			}
		}
		if(!matchedCredit)
		{
			listNominalAccount = [select id, Name, Credit_Balance__c from Nominal_Account__c where id =: CreditId];			
			for(Nominal_Account__c itr: listNominalAccount)
			{		 	
				system.debug('credit object Nom : '+itr.Name);										
				if(itr.Id == CreditId)
				{						
					system.debug('credit Nom : '+itr.Credit_Balance__c);	
					if(itr.Credit_Balance__c == null)
						itr.Credit_Balance__c = amount;	 		
			 		else
			 			itr.Credit_Balance__c += amount;			 	
			 		system.debug('new credit Nom is : '+itr.Credit_Balance__c);
			 		newlistNominalAccount.add(itr);			 				 					 			
				}			
			}
		}		
	}
	public void AddDebit(string d, decimal a)
	{
		boolean matchedDebit = false;
		DebitId = d;
		amount = a;		
		if(newlistNominalAccount.size() > 0)
		{
			system.debug('size of list increases in debit: '+newlistNominalAccount);
			for(Nominal_Account__c itrt: newlistNominalAccount)
			{
				if(itrt.id == DebitId)
				{
					if(itrt.Debit_Balance__c == null)
						itrt.Debit_Balance__c = amount;
					else
						itrt.Debit_Balance__c += amount;
					matchedDebit = true;
					system.debug('matchedDebit : '+itrt.Debit_Balance__c);
				}
			}
		}
		if(!matchedDebit)
		{		
			system.debug('does not matchedDebit : '+matchedDebit);
			listNominalAccount = [select id, Name, Debit_Balance__c from Nominal_Account__c where id =: DebitId];
			for(Nominal_Account__c itr: listNominalAccount)
			{		 	
				system.debug('debit object Nom : '+itr.Name);
											
				if(itr.Id == DebitId)
				{						
					system.debug('debit Nom : '+itr.debit_Balance__c);	
					if(itr.Debit_Balance__c == null)
						itr.Debit_Balance__c = amount;	 		
			 		else
			 			itr.Debit_Balance__c += amount;
			 		system.debug('new debit Nom is : '+itr.Debit_Balance__c);			 	
			 		newlistNominalAccount.add(itr);
				}	
		 	}
		}					
	}
	public void newSave()
	{
		Savepoint spl =  DataBase.setSavepoint();
		try
		{					
			update newlistNominalAccount;
	    } 						
		catch(exception e)
		{
			Database.rollback(spl);
			throw new CustomException('Unable to Save \n Nominal Model Exception \n'+e.getMessage());
		}
	}		
}