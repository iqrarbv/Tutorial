public class SalesByContactController {
	public Ledger__c objectLedger {get;set;}
	public List<Ledger__c> listLedger {get;set;}
	public List<AggregateResult> listCustomers {get;set;}
	public string currencySymbol{get;set;}		
	
	public Date StartDate {get;set;}
	public Date EndDate {get;set;}
	
	public List<string> CustomerNames;
	public List<decimal> salesCalculated;
	public List<string> MonthNames;
		
	public Date stDate;
	public integer mName;
	public integer yName;
	public decimal sales ;
	public string customer;
	
	public SalesByContactWrapper objectWrapper;
	public List<SalesByContactWrapper> listWrapper;
		
	public SalesByContactController ()
	{
		objectLedger = new Ledger__c();
		currencySymbol = Functions.getOrganisationCurrency('CurrencySymbol');				
	}	
	public List<SalesByContactWrapper> getCalculatedFields()
	{		
		return listWrapper;
	}
	public List<string> getMonthNames()
	{
		return MonthNames;
	}	
	public pagereference customerRptPg()
	{				
		try
		{	
			string AccttId = apexpages.currentpage().getParameters().get('paramCstmr');			
			Account Acctt = [select id, AccountNumber , Type, Name from Account where AccountNumber =: AccttId];
			if(Acctt.Type == 'Customer')		
				return new pageReference('/apex/CstmrRpt?Cstmr='+Acctt.Name);
			else
				throw new CustomException('The type of this Account is not Customer');
		}
		catch(exception e)
		{
			Apexpages.addMessages(e);
			return null;
		}
	}		
	public void CalculateforExcel()
	{
		try
		{			
			objectLedger.Trans_Date__c = Date.parse(apexpages.currentPage().getParameters().get('StartDate'));
			objectLedger.Bank_Reconcile_Date__c = Date.parse(apexpages.currentPage().getParameters().get('EndDate'));		
			Calculate();
		}
		catch(exception e) 
		{
			apexpages.addmessages(e);
		}				
	}
	public void Calculate()
	{		
		try
		{	
			validationRules();	
			listWrapper = new List<SalesByContactWrapper>();					
			listLedger = [Select Type__c, Sub_Account__c , Net__c , Trans_Date__c  From Ledger__c  where Trans_Date__c >=: objectLedger.Trans_Date__c and Trans_Date__c <=: objectLedger.Bank_Reconcile_Date__c and type__c = 'SI' and Is_Deleted__c = false and Show_On_Transaction__c = 1];
			listCustomers = [Select Sub_Account__c From Ledger__c where Type__c = 'SI' and Is_Deleted__c = false group by Sub_Account__c];														
			CustomerNames = new List<string>();			
			MonthNames = new List<string>();
			salesCalculated = new List<decimal>();																		
			for(integer i = 0 ; i < listCustomers.size()-1 ; i++) 
			{
				customer = (string)listCustomers[i].get('Sub_Account__c');
				stDate = objectLedger.Trans_Date__c;
				MonthNames.clear();
				if(customer != null && customer != '' && stDate <= objectLedger.Bank_Reconcile_Date__c )
				{								
					CustomerNames.add(customer);					
					salesCalculated = new List<decimal>();
					do
					{							
						mName = stDate.Month();
						yName = stDate.Year();	
						MonthNames.add(Functions.getMonth(stDate));									
						sales = 0.0;																														
						for(Ledger__c ld : listLedger)
						{		
							if((ld.Trans_Date__c.Month() == mName) && (ld.Trans_Date__c.Year() == yName) && (ld.Sub_Account__c == customer))
							{																																											
								sales = sales + ld.Net__c;																
							} 																																																
						}											
						salesCalculated.add(sales);												
						stDate = stDate.addMonths(1);			 																	
					}
					while(stDate <= objectLedger.Bank_Reconcile_Date__c);
					objectWrapper = new SalesByContactWrapper(customer,salesCalculated);					
					listWrapper.add(objectWrapper);					
				}				
			}
		}
		catch(exception e) 
		{
			apexpages.addmessages(e);
		}
	}
	public void validationRules()
	{
		if(objectLedger.Trans_Date__c == null)		
			throw new CustomException('Enter From Date first');
		if(objectLedger.Bank_Reconcile_Date__c == null)		
			throw new CustomException('Enter To Date first');
		if(objectLedger.Bank_Reconcile_Date__c < objectLedger.Trans_Date__c )		
			throw new CustomException('From date must be less than To date'); 			
	}
	private static testMethod void SalesByContactController_Test()
	{
		Ledger__c ldg = new Ledger__c(Trans_Date__c = Date.newInstance(2011,1,1) , Bank_Reconcile_Date__c = Date.today());
		insert ldg;
		SalesByContactController scRpt = new SalesByContactController();
		try
		{
			scRpt.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'Enter From Date first');
		}
		scRpt.objectLedger.Trans_Date__c = ldg.Trans_Date__c;
		try
		{
			scRpt.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'Enter To Date first');
		}
		scRpt.objectLedger.Bank_Reconcile_Date__c = ldg.Bank_Reconcile_Date__c;				
		scRpt.Calculate();		
		List<SalesByContactWrapper> scw = scRpt.getCalculatedFields();
		List<string> mNames = scRpt.getMonthNames();
		scRpt.CalculateforExcel();
		Account act = new Account (AccountNumber = 'AC-25695' , Type = 'Customer', Name = 'testAccount');
		insert act; 
		apexpages.currentpage().getParameters().put('paramCstmr', act.AccountNumber);
		scRpt.customerRptPg();	
	}
}