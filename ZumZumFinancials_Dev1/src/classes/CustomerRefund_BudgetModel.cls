public class CustomerRefund_BudgetModel {
	public Nominal_Budget__c objectNomBudget;	
	public List<Nominal_Budget__c> listNominalBudget;
	public List<Nominal_Budget__c> curListNomBudget;
	public List<Nominal_Budget__c> newListNomBudget;
	
	public List<Nominal_Budget__c> mpBudget;
	public decimal amount;
	public string creditID;
	public string debitID;
	public boolean modifiedCredit;
	public boolean modifiedDebit;	
	public NominalModel nModel;
	
	public CustomerRefund_BudgetModel()	
	{			
		nModel= new NominalModel();
		listNominalBudget = [select id, Nominal_Account__c ,Month__c, Year__c, Actuals_Credit__c, Actuals_Debit__c from Nominal_Budget__c limit 1000000];
		curListNomBudget = new List<Nominal_Budget__c>();
		newListNomBudget = new List<Nominal_Budget__c>();
	}
	/*
	public CustomerRefund_BudgetModel (string c, string d, decimal a)
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
		listNominalBudget = [select id, Nominal_Account__c ,Month__c, Actuals_Credit__c, Actuals_Debit__c from Nominal_Budget__c];
		curListNomBudget = new List<Nominal_Budget__c>();
	}
	public void Save()
	{
		Savepoint sp = Database.setSavepoint();
		try
		{
			updateCredit();
			updateDebit() ;	
		}
		catch(exception e)
		{
			Database.rollback(sp);
			throw new CustomException('Unable to Save Budget '+e.getMessage());
		}
	}
	*/
	/*
	public void AddtoList()
	{
		if(listNominalBudget.size()>0)
		{		 		
			for(Nominal_Budget__c itrtor : listNominalBudget)
		 	{		
			 	if((itrtor.Nominal_Account__c == creditID) &&(itrtor.Month__c == Date.today().month()) && (itrtor.year__c == Date.today().year()))
			 	{
			 		if(itrtor.Actuals_Credit__c  == null)
	 					itrtor.Actuals_Credit__c = 0.0;
			 		itrtor.Actuals_Credit__c += amount;			 		
			 		modifiedCredit = true;
			 	}	
			 	if((string.valueof(itrtor.Nominal_Account__c) == debitID) &&(itrtor.Month__c == Date.today().month()) && (itrtor.year__c == Date.today().year()))
			 	{			 		
			 		if (itrtor.Actuals_Debit__c  == null)
	 					itrtor.Actuals_Debit__c = 0.0;
			 		itrtor.Actuals_Debit__c += amount;
			 		modifiedDebit = true;		 		
			 	}	
		 	}
		 	//update listNominalBudget;	
	 	}
	 	if(!modifiedCredit)
 		{ 				
 			if(creditID != '' || creditID != null)
 			{
	 			objectNomBudget = new Nominal_Budget__c();	 			
	 			objectNomBudget.Nominal_Account__c = creditID;		
	 			objectNomBudget.Month__c = Date.today().month();
	 			objectNomBudget.Year__c =  Date.today().Year();
	 			if (objectNomBudget.Actuals_Credit__c  == null)
	 				objectNomBudget.Actuals_Credit__c = 0.0;
	 			objectNomBudget.Actuals_Credit__c += amount;
	 			//insert objectNomBudget;
	 			//curListNomBudget.add(objectNomBudget);
	 			curListNomBudget.add(objectNomBudget);
 			}
 		}
 		if(!modifiedDebit)
 		{ 				
 			if(DebitId != '' || DebitId != null)
 			{
	 			objectNomBudget = new Nominal_Budget__c();	 			
	 			objectNomBudget.Nominal_Account__c = DebitId;		
	 			objectNomBudget.Month__c = Date.today().month();
	 			objectNomBudget.Year__c =  Date.today().Year();
	 			if (objectNomBudget.Actuals_Debit__c  == null)
	 				objectNomBudget.Actuals_Debit__c = 0.0;
	 			objectNomBudget.Actuals_Debit__c += amount; 	
	 			//insert objectNomBudget;
	 			curListNomBudget.add(objectNomBudget); 			
	 			//listNominalBudget.add(objectNomBudget);	
 			}				
 		}	 	
	}
	// starting of KS code 1-6-2011
	*/
	public void updateCredit()
	{
		if(creditID != null )
		{
			List<Nominal_Budget__c> nmBudget = [select id,Actuals_Credit__c,Actuals_Debit__c,Month__c,Nominal_Account__c,Year__c from Nominal_Budget__c  where Nominal_Account__c = :creditId and Month__c = : date.today().month() and year__c = : date.today().year() limit 1];
			if (nmBudget.size() > 0)
			{	
				if (nmBudget[0].Actuals_Credit__c == null )
					nmBudget[0].Actuals_Credit__c = amount ;
				else	
					nmBudget[0].Actuals_Credit__c += amount ;
				update nmBudget[0] ;		
			}
			else
			{
				Nominal_Budget__c newActualEntry = new 	Nominal_Budget__c(Actuals_Credit__c =  amount , month__c = date.today().month() , year__c =  date.today().year()  , Nominal_Account__c = creditID );
				upsert newActualEntry ;
			}
		}
	}
	public void updateDebit()
	{
		if(debitID != null )
		{
			List<Nominal_Budget__c> nmBudget = [select id,Actuals_Credit__c,Actuals_Debit__c,Month__c,Nominal_Account__c,Year__c from Nominal_Budget__c  where Nominal_Account__c = :debitID and Month__c = : date.today().month() and year__c = : date.today().year() limit 1];
			if (nmBudget.size() > 0)
			{	
				if (nmBudget[0].Actuals_Debit__c == null )
					nmBudget[0].Actuals_Debit__c = amount;
				else
					nmBudget[0].Actuals_Debit__c += amount;
				update nmBudget[0] ;		
			}
			else
			{
				Nominal_Budget__c newActualEntry = new 	Nominal_Budget__c(Actuals_Debit__c =  amount , month__c = date.today().month() , year__c =  date.today().year()  , Nominal_Account__c = debitID );
				upsert newActualEntry ;
			}
		}
	}
	// end of code
		
	public void AddDebit(string d, decimal a, string dt)
	{
		nModel.AddDebit(d, a);
		boolean matchedDebit = false;
		modifiedDebit = false;
		debitID = d;
		amount = a;
		Date dat;
		if(dt != null && dt != '')
			dat = Date.ValueOf(dt);
		else
			dat = Date.today();
		
		if(curListNomBudget.size() > 0)
		{
			system.debug('size of list increases in debit: '+curListNomBudget);
			for(Nominal_Budget__c itrt: curListNomBudget)
			{
				if((itrt.Nominal_Account__c == DebitId) && (itrt.Month__c == dat.month()) && (itrt.year__c == dat.year()))
				{
					if(itrt.Actuals_Debit__c == null)
						itrt.Actuals_Debit__c = amount;
					else
						itrt.Actuals_Debit__c += amount;
					matchedDebit = true;
					system.debug('matchedDebit : '+itrt.Actuals_Debit__c);
				}
			}
			
		}
		if(!matchedDebit)
		{		
			for(Nominal_Budget__c itrtor : listNominalBudget)
			{						
				if((itrtor.Nominal_Account__c == debitID)&& (itrtor.Month__c == dat.month()) && (itrtor.year__c == dat.year()))
				{
					if (itrtor.Actuals_Debit__c  == null)
		 				itrtor.Actuals_Debit__c = amount;
		 			else
						itrtor.Actuals_Debit__c += amount;
					curListNomBudget.add(itrtor);
					modifiedDebit = true;
				}								
			}		
			if(!modifiedDebit)
			{
				matchedDebit = false;
				if(newListNomBudget.size() > 0)
				{
					system.debug('size of list increases in debit in inserted list: '+newListNomBudget);
					for(Nominal_Budget__c itrt: newListNomBudget)
					{
						if((itrt.Nominal_Account__c == DebitId) && (itrt.Month__c == dat.month()) && (itrt.year__c == dat.year()))
						{
							if(itrt.Actuals_Debit__c == null)
								itrt.Actuals_Debit__c = amount;
							else
								itrt.Actuals_Debit__c += amount;
							matchedDebit = true;
							system.debug('matchedDebit : '+itrt.Actuals_Debit__c);
						}
					}					
				}
				if(!matchedDebit)
				{				
					objectNomBudget = new Nominal_Budget__c();	 			
		 			objectNomBudget.Nominal_Account__c = DebitId;		
		 			objectNomBudget.Month__c = dat.month();
		 			objectNomBudget.Year__c =  dat.Year(); 			
		 			objectNomBudget.Actuals_Debit__c = amount; 			
		 			newListNomBudget.add(objectNomBudget);
				}
			}
		}
	}
	public void AddCredit(string c, decimal a, string dt)
	{
		nModel.AddCredit(c, a);
		modifiedCredit = false;
		boolean matchedCredit = false;
		creditID = c;
		amount = a;
		Date dat;
		if(dt != null && dt != '')
			dat = Date.ValueOf(dt);
		else
			dat = Date.today();		
		
		if(curListNomBudget.size() > 0)
		{
			system.debug('size of list increases in debit: '+curListNomBudget);
			for(Nominal_Budget__c itrt: curListNomBudget)
			{
				if((itrt.Nominal_Account__c == creditID) && (itrt.Month__c == dat.month()) && (itrt.year__c == dat.year()))
				{
					if(itrt.Actuals_Credit__c == null)
						itrt.Actuals_Credit__c = amount;
					else
						itrt.Actuals_Credit__c += amount;
					matchedCredit  = true;
					system.debug('matchedDebit : '+itrt.Actuals_Credit__c);
				}
			}			
		}
		if(!matchedCredit)
		{
			for(Nominal_Budget__c itrtor : listNominalBudget)
			{						
				if((string.valueof(itrtor.Nominal_Account__c) == creditID) &&(itrtor.Month__c == dat.month()) && (itrtor.year__c == dat.year()))
				{
					if (itrtor.Actuals_Credit__c  == null)
		 				itrtor.Actuals_Credit__c = amount;
		 			else
						itrtor.Actuals_Credit__c += amount;
					curListNomBudget.add(itrtor);
					modifiedCredit = true;
				}			
			}
			if(!modifiedCredit)
			{
				if(newListNomBudget.size() > 0)
				{
					system.debug('size of list increases in debit in inserted list: '+newListNomBudget);
					for(Nominal_Budget__c itrt: newListNomBudget)
					{
						if((itrt.Nominal_Account__c == creditID) && (itrt.Month__c == dat.month()) && (itrt.year__c == dat.year()))
						{
							if(itrt.Actuals_Credit__c == null)
								itrt.Actuals_Credit__c = amount;
							else
								itrt.Actuals_Credit__c += amount;
							matchedCredit = true;
							system.debug('matchedCredit : '+itrt.Actuals_Credit__c);
						}
					}					
				}
				if(!matchedCredit)
				{				
					objectNomBudget = new Nominal_Budget__c();	 			
		 			objectNomBudget.Nominal_Account__c = creditID;		
		 			objectNomBudget.Month__c = dat.month();
		 			objectNomBudget.Year__c =  dat.Year(); 			
		 			objectNomBudget.Actuals_Credit__c = amount; 			
		 			newListNomBudget.add(objectNomBudget);
				}
			}			
		}
	}
	public void newSave()
	{
		Savepoint spl = Database.setSavepoint();
		try
		{
			nModel.newSave();
			system.debug('update list : '+ curListNomBudget);
			update curListNomBudget;
			if(newListNomBudget.size() > 0)
			{
				system.debug('insert list : '+ newListNomBudget);
				insert newListNomBudget;
			}
		}
		catch(exception e)
		{
			Database.rollback(spl);
			throw new CustomException('Unable to Save Budget '+e.getMessage());
		}
	}
}