public class controllerVATReturn {
	public VAT_Return__c objectVATReturn{get;set;}
	public VAT_Return__c newobjectVATReturn{get;set;}
	public Company_Setup__c objectCompany{get;set;}
	public Date startDate {get;set;}
	public Date endDate {get;set;}
	public List<Ledger__c> listLedger{get;set;}	
	private List<General_Setup__c> Gsetup {get; set;}
	public string retURL{get;set;}
	public decimal box1;
	public decimal box2;
	public decimal box3;
	public decimal box4;
	public decimal box5;
	public decimal box6;
	public decimal box7;
	public decimal box8;
	public decimal box9;	
	public integer serialVAT;
	public string currencySymbol{get;set;}	
	public controllerVATReturn(ApexPages.standardcontroller std)
	{		
		box1 = 0.0;
		box2 = 0.0;
		box3 = 0.0;
		box4 = 0.0;
		box5 = 0.0;
		box6 = 0.0;
		box7 = 0.0;
		box8 = 0.0;
		box9 = 0.0;
		objectVATReturn = new VAT_Return__c(); 
		currencySymbol = Functions.getOrganisationCurrency('CurrencySymbol');
		retURL ='https://'+ApexPages.currentPage().getHeaders().get('Host')+'/apex/TransactionsMenu';		
		listLedger = new List<Ledger__c>();	
		objectCompany = [select VatMethod__c from Company_Setup__c limit 1];				
	}
	public void calculate()	
	{				
		try
		{			
			validationRules();			
			box1 = 0.0;
			box2 = 0.0;
			box3 = 0.0;
			box4 = 0.0;
			box5 = 0.0;
			box6 = 0.0;
			box7 = 0.0;
			box8 = 0.0;
			box9 = 0.0;						
			listLedger = [Select VAT__c, Paid__c, Type__c,Tax__c,Net__c,Trans_Date__c From Ledger__c  where Trans_Date__c >=: objectVATReturn.Date_From__c and Trans_Date__c <=: objectVATReturn.Date_To__c];			
			Ledger__c itr = new Ledger__c();
			if(objectCompany.VatMethod__c == 'Accrual')
			{
				for(integer i=0; i< listLedger.size(); i++)
				{
					itr = (Ledger__c)listLedger[i];
					if(itr.VAT__c == 'N')
					{
						if(itr.Tax__c == null )
							itr.Tax__c = 0.0;											
						if(itr.Type__c == 'SI')
							box1 = box1 + itr.Tax__c;
						if(itr.Type__c == 'BR')
							box1 = box1 + itr.Tax__c;
						if(itr.Type__c == 'SC')
							box1 = box1 - itr.Tax__c;								
						if(itr.Type__c == 'PI')
							box4 = box4 + itr.Tax__c;
						if(itr.Type__c == 'BP')
							box4 = box4 + itr.Tax__c;
						if(itr.Type__c == 'PC')
							box4 = box4 - itr.Tax__c;															
						if(itr.Type__c == 'SI')
							box6 = box6 + itr.Net__c;
						if(itr.Type__c == 'BR')
							box6 = box6 + itr.Net__c;
						if(itr.Type__c == 'SC')
							box6 = box6 - itr.Net__c;								
						if(itr.Type__c == 'PI')
							box7 = box7 + itr.Net__c;
						if(itr.Type__c == 'BP')
							box7 = box7 + itr.Net__c;
						if(itr.Type__c == 'PC')
							box7 = box7 - itr.Net__c;	
					}									
				} 
			}	
			else
			{
				for(integer i=0; i< listLedger.size(); i++)
				{						
					itr = (Ledger__c)listLedger[i];
					if((itr.VAT__c == 'N') && (itr.Paid__c == 'Y'))
					{							
						if(itr.Type__c == 'SI')
							box1 = box1 + itr.Tax__c;
						if(itr.Type__c == 'BR')
							box1 = box1 + itr.Tax__c;
						if(itr.Type__c == 'SC')
							box1 = box1 - itr.Tax__c;
							
						if(itr.Type__c == 'PI')
							box4 = box4 + itr.Tax__c;
						if(itr.Type__c == 'BP')
							box4 = box4 + itr.Tax__c;
						if(itr.Type__c == 'PC')
							box4 = box4 - itr.Tax__c;
									
						if(itr.Type__c == 'SI')
							box6 = box6 + itr.Net__c;
						if(itr.Type__c == 'BR')
							box6 = box6 + itr.Net__c;
						if(itr.Type__c == 'SC')
							box6 = box6 - itr.Net__c;
							
						if(itr.Type__c == 'PI')
							box7 = box7 + itr.Net__c;
						if(itr.Type__c == 'BP')
							box7 = box7 + itr.Net__c;
						if(itr.Type__c == 'PC')
							box7 = box7 - itr.Net__c;								
					}								
				} 					
			}
			BOX3 = BOX1 + BOX2;
			BOX5 = BOX1 - BOX4;				
			objectVATReturn.Box_1__c = box1;		
			objectVATReturn.Box_2__c = box2;
			objectVATReturn.Box_3__c = box3;
			objectVATReturn.Box_4__c = box4;
			objectVATReturn.Box_5__c = box5;
			objectVATReturn.Box_6__c = box6;
			objectVATReturn.Box_7__c = box7;
			objectVATReturn.Box_8__c = box8;
			objectVATReturn.Box_9__c = box9;							
		}
		catch(exception e) 
		{
			apexPages.addMessages(e);			
		}
	}
	public PageReference Discard()
	{
		return new PageReference(retURL);
	} 
	public PageReference Save()
	{
		savepoint sp = database.setSavepoint();
		try
		{						
			serialVAT = getOrderNumber();
			serialVAT = serialVAT+1;			
			newobjectVATReturn = new VAT_Return__c(Trans_No__c = serialVAT,Box_1__c = objectVATReturn.Box_1__c,Box_2__c = objectVATReturn.Box_2__c,Box_3__c = objectVATReturn.Box_3__c,Box_4__c = objectVATReturn.Box_4__c,Box_5__c = objectVATReturn.Box_5__c,Box_6__c = objectVATReturn.Box_6__c,Box_7__c = objectVATReturn.Box_7__c,Box_8__c = objectVATReturn.Box_8__c,Box_9__c = objectVATReturn.Box_9__c, Date_From__c = objectVATReturn.Date_From__c,Date_To__c = objectVATReturn.Date_To__c, Is_posted__c = objectVATReturn.Is_posted__c,Date_Calculated__c = DateTime.now());
			insert newobjectVATReturn;
			updateOrderNo(serialVAT);				
			return new PageReference('https://'+apexpages.currentPage().getHeaders().get('Host')+'/apex/TransactionsMenu');
		}
		catch(exception e) 
		{
			apexPages.addMessages(e);
			Database.rollback(sp);			
			return null;
		}
	}
	public void validationRules()
	{
		if(objectVATReturn.Date_From__c == null)		
			throw new CustomException('Enter From Date first');					
		if(objectVATReturn.Date_To__c == null)		
			throw new CustomException('Enter To Date first');			
				
	}
	public integer getOrderNumber()
	{
		integer ordernumber ; 
		Gsetup = new List<General_Setup__c>() ;
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'VAT Transaction' limit 1] ; 
		if (Gsetup.size()>0)
		{
			if (Gsetup[0].Current_Document_Number__c == -1)
			{
				ordernumber  = 	integer.valueof(Gsetup[0].Starting_Document_No__c) ; 
			}
			else 
			{
				string dc_curentno = string.valueof(Gsetup[0].Current_Document_Number__c);
                ordernumber  = 	integer.valueof(dc_curentno);                
			}
		}
		else
		{
			throw new customException('Please enter starting VAT Transaction #. in GENERAL SETUP.');
		}
		return ordernumber ;
	}
	public static string getOrderNo(string orderNo)
	{		
		if (orderNo.length() < 6)
		{
			integer ln = 6 - orderNo.length();
			for (integer i=0 ; i<ln ; i++)
			{
				orderNo  = '0'+ orderNo;
			}
		}		
		return orderNo ;
	}
	public void updateOrderNo(integer currentOrderNo)
	{
		Gsetup = new List<General_Setup__c>() ;
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'VAT Transaction' limit 1] ; 
		Gsetup[0].Current_Document_Number__c = currentOrderNo ;
		update Gsetup ;
	}
	private static testMethod void controllerVATReturnTest()
	{
		Company_Setup__c cs = [select id, VatMethod__c from Company_Setup__c];
		cs.VatMethod__c = 'Accrual';
		update cs;
				
		controllerVATReturn VATRtrn = new controllerVATReturn(new ApexPages.StandardController(new VAT_Return__c()));
		VATRtrn.serialVAT = VATRtrn.getOrderNumber()+1; 
		Ledger__c l1 = new Ledger__c(Show_On_Transaction__c = 1 , Trans_No__c = VATRtrn.serialVAT, VAT__c = 'N', Paid__c = 'Y', Type__c = 'SI' , Tax__c = 29750 , Credit__c = 17000, Debit__c = 50000 , Trans_Date__c = Date.newInstance(2011,1,1));		
		insert l1;
		VATRtrn.serialVAT ++;
		Ledger__c l2 = new Ledger__c(Show_On_Transaction__c = 1 , Trans_No__c = VATRtrn.serialVAT, VAT__c = 'N', Paid__c = 'Y', Type__c = 'PI' , Tax__c = 100 , Credit__c = 10, Debit__c = 0 , Trans_Date__c = Date.newInstance(2011,2,1));
		insert l2;
		VATRtrn.serialVAT ++;
		Ledger__c l3 = new Ledger__c(Show_On_Transaction__c = 1 , Trans_No__c = VATRtrn.serialVAT, VAT__c = 'N', Paid__c = 'Y', Type__c = 'SC' , Tax__c = 29750 , Credit__c = 0, Debit__c = 50000 , Trans_Date__c = Date.newInstance(2011,3,1));
		insert l3;
		VATRtrn.serialVAT ++;
		Ledger__c l4 = new Ledger__c(Show_On_Transaction__c = 1 , Trans_No__c = VATRtrn.serialVAT, VAT__c = 'N', Paid__c = 'Y', Type__c = 'PC' , Tax__c = 0 , Credit__c = 0, Debit__c = 50000 , Trans_Date__c = Date.newInstance(2011,4,1));
		insert l4;
		VATRtrn.serialVAT ++;
		Ledger__c l5 = new Ledger__c(Show_On_Transaction__c = 1 , Trans_No__c = VATRtrn.serialVAT, VAT__c = 'N', Paid__c = 'Y', Type__c = 'BP' , Tax__c = .88 , Credit__c = 5, Debit__c = 0 , Trans_Date__c = Date.newInstance(2011,5,1));
		insert l5;
		VATRtrn.serialVAT ++;
		Ledger__c l6 = new Ledger__c(Show_On_Transaction__c = 1 , Trans_No__c = VATRtrn.serialVAT, VAT__c = 'N', Paid__c = 'Y', Type__c = 'BR' , Tax__c = 75 , Credit__c = 255, Debit__c = 0 , Trans_Date__c = Date.newInstance(2011,6,1));
		insert l6;
		VATRtrn.serialVAT ++;
		Ledger__c l7 = new Ledger__c(Show_On_Transaction__c = 1 , Trans_No__c = VATRtrn.serialVAT, VAT__c = 'N', Paid__c = 'Y', Type__c = 'BP' , Tax__c = 150 , Credit__c = 0, Debit__c = 3200 , Trans_Date__c = Date.newInstance(2011,7,6));
		insert l7;
		VATRtrn.serialVAT ++;
		VATRtrn.updateOrderNo(VATRtrn.serialVAT);		
		VATRtrn.objectVATReturn.Date_From__c = null;		
		VATRtrn.objectVATReturn.Date_To__c  = null;
		try
		{			
			VATRtrn.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Enter From Date first');
		}
		VATRtrn.objectVATReturn.Date_From__c  = Date.newInstance(2011,1,1);
		VATRtrn.objectVATReturn.Date_To__c  = null;
		try
		{			
			VATRtrn.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Enter To Date first');
		}
		VATRtrn.objectVATReturn.Date_From__c  = Date.newInstance(2011,1,1);
		VATRtrn.objectVATReturn.Date_To__c  = Date.today();		
		VATRtrn.calculate();		
		VATRtrn.Save();		
		VATRtrn.Discard();
		cs = [select id, VatMethod__c from Company_Setup__c];
		cs.VatMethod__c = 'Cash Accounting';
		update cs;
		VATRtrn = new controllerVATReturn(new ApexPages.StandardController(new VAT_Return__c()));
		VATRtrn.objectVATReturn.Date_From__c  = Date.newInstance(2011,1,1);
		VATRtrn.objectVATReturn.Date_To__c  = Date.today();		
		VATRtrn.calculate();				
		VATRtrn.Save();
	} 
}