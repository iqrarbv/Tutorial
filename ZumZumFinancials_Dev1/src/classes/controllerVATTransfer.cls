public class controllerVATTransfer {	
	public VAT_Return__c objectVATReturn{get;set;}
	public Nominal_Account__c objectNominal{get;set;}
	private List<General_Setup__c> Gsetup {get; set;}	
	public integer serialVAT;
	public string retURL;
	public string Sales{get;set;}
	public string Purchases{get;set;}		
	public string currencySymbol{get;set;}
	 
	public controllerVATTransfer()
	{	
		try
		{	
			currencySymbol = Functions.getOrganisationCurrency('CurrencySymbol');
			retURL = 'https://'+apexPages.currentPage().getHeaders().get('Host')+'/apex/TransactionsMenu';						
			objectNominal = [select id, Nominal_Code__c , Name from Nominal_Account__c where Name =: 'VAT Liability'];			
			serialVAT = getOrderNumber();
			if(serialVAT == -1)
				throw new CustomException('No VAT Return Transaction has been made yet. First make it from VAT Return');			   		
			objectVATReturn = [select id , Is_posted__c,Date_To__c,Box_6__c,Box_7__c from VAT_Return__c where Trans_No__c =: serialVAT];
			if(objectVATReturn != null)							
			{
				if(objectVATReturn.Is_posted__c == true) 
				{
					Sales = '0.00';
					Purchases = '0.00';
				} 
				else
				{
					Sales = string.valueOf(objectVATReturn.Box_6__c);
					Purchases = string.valueOf(objectVATReturn.Box_7__c);
				}
			}
			else
				throw new CustomException('No VAT Return Transaction has been made yet. First make it from VAT Return');							
		}
		catch(exception e)
		{
			apexpages.addmessages(e);	
			Sales = '0.00';
			Purchases = '0.00';
		}
	}
	public void validationRules()
	{
		if( objectVATReturn.Date_To__c == null)
			throw new CustomException('Enter date first');
		if(Sales == null || Sales == '')
			Sales = '0.0';
		if(Purchases == null || Purchases == '')
			Purchases = '0.0';			
		if((!Pattern.matches('^[0-9]+(.[0-9]{1,2})?$', Sales)) || (!Pattern.matches('^[0-9]+(.[0-9]{1,2})?$', Purchases))) 		
			throw new CustomException('Enter valid currency value');    	    							 	
	}
	public PageReference Save()
	{
		savepoint sp= Database.setSavepoint();
		try
		{
			validationRules();
			objectVATReturn.Box_6__c = decimal.valueOf(Sales);
			objectVATReturn.Box_7__c = decimal.valueOf(Purchases);
			Ledger financial = new Ledger();																
			financial.AddJournalDebitEntry(objectVATReturn.Box_6__c , Functions.getNominalAccountCode('Sales Tax Control Account'),'Transfer VAT Liability' , '', 'T1' , objectVATReturn.Date_To__c);
			financial.AddJournalCreditEntry(objectVATReturn.Box_6__c ,objectNominal.Nominal_Code__c, 'Transfer VAT Liability' , '', 'T1' , objectVATReturn.Date_To__c);			
			financial.AddJournalCreditEntry(objectVATReturn.Box_7__c ,objectNominal.Nominal_Code__c, 'Transfer VAT Liability' , '', 'T1' , objectVATReturn.Date_To__c);
			financial.AddJournalDebitEntry(objectVATReturn.Box_7__c ,Functions.getNominalAccountCode('Purchase Tax Control Account'), 'Transfer VAT Liability' , '', 'T1' , objectVATReturn.Date_To__c);			
			financial.Save();										
			CustomerRefund_BudgetModel Actuals = new CustomerRefund_BudgetModel();					
			Actuals.AddDebit(string.valueOf(objectNominal.id), objectVATReturn.Box_6__c, '');
			Actuals.AddCredit(Functions.getNominalAccountId('Sales Tax Control Account'), objectVATReturn.Box_6__c, '');						
			Actuals.AddDebit(Functions.getNominalAccountId('Purchase Tax Control Account'), objectVATReturn.Box_7__c, '');
			Actuals.AddCredit(string.valueOf(objectNominal.id), objectVATReturn.Box_7__c, '');			
			Actuals.newSave();							
			return new PageReference(retURL);
		}
		catch(exception e)
		{
			apexpages.addMessages(e);
			return null;
		}
	}
	public PageReference Discard()
	{
		return new PageReference(retURL); 		
	}	
	public integer getOrderNumber()
	{
		integer ordernumber ; 
		Gsetup = new List<General_Setup__c>() ;
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'VAT Transaction' limit 1] ; 
		if (Gsetup.size()>0)
		{
			if (Gsetup[0].Current_Document_Number__c == null)
				throw new CustomException ('Please enter starting VAT Reconcile #. & current document number in GENERAL SETUP');
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
		system.debug(orderNo);
		if (orderNo.length() < 6)
		{
			integer ln = 6 - orderNo.length();
			for (integer i=0 ; i<ln ; i++)
			{
				orderNo  = '0'+ orderNo;
			}
		}
		system.debug(orderNo);
		return orderNo ;
	}
	public void updateOrderNo(integer currentOrderNo)
	{		
		Gsetup = new List<General_Setup__c>() ;
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'VAT Transaction' limit 1] ; 
		Gsetup[0].Current_Document_Number__c = currentOrderNo ;
		update Gsetup ;
	}
	private static testMethod void controllerVATTransferTest()
	{		
		controllerVATTransfer VATTransfr;
		try
		{
			VATTransfr = new controllerVATTransfer();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'No VAT Return Transaction has been made yet. Define it first from VAT Return Module');
		}		
		VAT_Return__c retrn1 = new VAT_Return__c(Box_1__c = 52.5, Box_2__c = 52.5, Box_3__c = 52.5, Box_4__c = 52.5, Box_5__c = 52.5, Box_8__c = 52.5, Box_9__c = 52.5, Box_6__c = 52.5, Box_7__c = 67.2, Is_posted__c = false, Date_To__c = Date.newInstance(2011,1,1), Date_From__c = Date.newInstance(2011,2,1), Date_Calculated__c = DateTime.now(), Trans_No__c = 2);
		insert retrn1;
		General_setup__c Gsetup = [select id, Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'VAT Transaction' limit 1] ;
		Gsetup.Current_Document_Number__c = retrn1.Trans_No__c;
		Gsetup.Starting_Document_No__c = '0';
		update Gsetup; 		
		try
		{
			VATTransfr = new controllerVATTransfer();
			VATTransfr.objectVATReturn = retrn1; 			
		}
		catch(exception e)
		{
			system.debug('object : '+ e.getMessage());
		}
		VATTransfr.objectVATReturn.Date_To__c = null;
		try
		{
			VATTransfr.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Enter date first');
		}			
		VATTransfr.objectVATReturn.Date_To__c = Date.today();
		VATTransfr.Sales = null;
		VATTransfr.Purchases = 'asdf';
		try
		{
			VATTransfr.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Enter valid currency value');			
		}		
		VATTransfr.Sales = 'asdf';
		VATTransfr.Purchases = null;
		try
		{
			VATTransfr.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(), 'Enter valid currency value');
		}		
		VATTransfr.Sales = '6';
		VATTransfr.Purchases = '7';
		VATTransfr.objectVATReturn.Date_To__c = Date.today();
		VATTransfr.Save();
		Gsetup = [select id, Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'VAT Transaction' limit 1] ;
		Gsetup.Current_Document_Number__c = -1;
		Gsetup.Starting_Document_No__c = '0';
		update Gsetup;	
		VATTransfr.serialVAT = VATTransfr.getOrderNumber();
		
		VAT_Return__c retrn2 = new VAT_Return__c (Box_1__c = 52.5, Box_2__c = 52.5, Box_3__c = 52.5, Box_4__c = 52.5, Box_5__c = 52.5, Box_8__c = 52.5, Box_9__c = 52.5, Box_6__c = 52.5, Box_7__c = 67.2, Is_posted__c = true, Date_To__c = Date.newInstance(2011,1,1),Date_From__c = Date.newInstance(2011,2,1), Date_Calculated__c = DateTime.now(), Trans_No__c = VATTransfr.serialVAT );
		insert retrn2;
		Gsetup = [select id, Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'VAT Transaction' limit 1] ;
		Gsetup.Current_Document_Number__c = retrn2.Trans_No__c;
		Gsetup.Starting_Document_No__c = '0';
		update Gsetup;
		try
		{
			VATTransfr = new controllerVATTransfer();
			VATTransfr.objectVATReturn = retrn2; 			
		}
		catch(exception e)
		{
			system.debug('object : '+ e.getMessage());
		}
		VATTransfr.Discard();
				
	} 
}