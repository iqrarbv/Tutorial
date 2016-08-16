public class CustomerSalesInvoiceController {
	public Ledger__c objectLedger{get;set;}
	public string currencySymbol{get;set;}
	public string AccttId{get;set;}
	public List<Ledger__c> listLedger{get;set;}
	public Account Acctt{get;set;}
	public CustomerLookup__c objectLookup {get;set;}
	public Ledger__c FirstInvoice{get;set;}
	public Ledger__c LastInvoice{get;set;}	
	public Ledger__c LastReceipt{get;set;}
	public Ledger__c LastPayment{get;set;}
	public decimal MTD {get;set;}
	public decimal YTD {get;set;}
	public decimal PriorYTD {get;set;}
	
	public CustomerSalesInvoiceWrapper objectWrapper;
	public List<CustomerSalesInvoiceWrapper> listWrapper;
	
	public CustomerSalesInvoiceController()
	{
		MTD = 0.0;
		YTD = 0.0;
		PriorYTD = 0.0;
		objectLookup = new CustomerLookup__c();
		objectLedger = new Ledger__c();
		currencySymbol = Functions.getOrganisationCurrency('CurrencySymbol');
		FirstInvoice = new Ledger__c(); 
		LastInvoice = new Ledger__c();
		LastReceipt = new Ledger__c();
		LastPayment = new Ledger__c();		
	}
	public void CalculateforExcel()
	{
		try
		{										
			objectLookup.CustomerAccount__c = [select id , Name from Account where Name =: apexpages.currentPage().getParameters().get('Cstmr') limit 1].id;
			system.debug('Cstmr : '+objectLookup.CustomerAccount__c );	
			Calculate();
		}
		catch(exception e) 
		{
			apexpages.addmessages(e);
		}				
	}
	public void ValidationRules()
	{
		AccttId = objectLookup.CustomerAccount__c;
		Acctt = [select id, AccountNumber from Account where id =: AccttId];
		List<Ledger__c> lst = [select Sub_Account__c from Ledger__c where Sub_Account__c =: Acctt.AccountNumber and (Type__c = 'SI' or Type__c = 'SC' or Type__c = 'SR' or Type__c = 'SP') limit 1];
		if(lst.size() <= 0)
			throw new CustomException('No any entry has been made by this Customer');			
	}
	public void Calculate()
	{				
		try
		{	 
			ValidationRules();
			List<Ledger__c> lst = [select Trans_Date__c from Ledger__c where Sub_Account__c =: Acctt.AccountNumber and Type__c = 'SI' order by Trans_Date__c ];
			if(lst.size() >= 1)
			{											
				FirstInvoice = lst[0];
				LastInvoice = lst[lst.size()-1];
			}				
			lst = [select Trans_Date__c from Ledger__c where Sub_Account__c =: Acctt.AccountNumber and Type__c = 'SR' order by Trans_Date__c ];
			if(lst.size() >= 1)
				LastReceipt = lst[lst.size()-1];				
			lst = [select Trans_Date__c from Ledger__c where Sub_Account__c =: Acctt.AccountNumber and Type__c = 'SP' order by Trans_Date__c ];
			if(lst.size() >= 1)
				LastPayment = lst[lst.size()-1];								
			listWrapper = new List<CustomerSalesInvoiceWrapper>();
			Date StartDt = Date.newInstance(2011 , Functions.getOrgFiscalYearStartMonth() , 1);
			Date EndDt = StartDt.addMonths(11);				
			listLedger = [Select Type__c, Net__c , Trans_Date__c , Sub_Account__c From Ledger__c  where (Type__c = 'SI' or Type__c = 'SC' or Type__c = 'SR' or Type__c = 'SP') and Trans_Date__c >=: StartDt and Trans_Date__c <: EndDt and Is_Deleted__c = false and Show_On_Transaction__c = 1 and Sub_Account__c =: Acctt.AccountNumber];					
			integer i = 0;				
			integer month = Functions.getOrgFiscalYearStartMonth();			
			integer year = 2011;
			MTD = 0.0;
			YTD = 0.0;
			PriorYTD = 0.0;
			do
			{
				decimal sales = 0.0;
				decimal credits = 0.0;
				decimal receipts = 0.0;
				decimal payments = 0.0;						
				for(Ledger__c ld : listLedger)
				{
					if(i== 0 && (ld.Trans_Date__c.Year() == Date.today().year()) && (ld.Type__c == 'SI'))
					{
						YTD = YTD + ld.Net__c;
					}	
					if(ld.Trans_Date__c.Year() < Date.today().year())
					{
						PriorYTD = PriorYTD + ld.Net__c;
					}
										
					if(ld.Type__c == 'SI' && ld.Trans_Date__c.month() == month && ld.Trans_Date__c.Year() == Year)
					{
						sales = sales + ld.Net__c;
						if(ld.Trans_Date__c.month() == Date.today().month())
						{
							MTD = MTD + ld.Net__c;
						}
					}
					if(ld.Type__c == 'SC' && ld.Trans_Date__c.month() == month && ld.Trans_Date__c.Year() == Year )
					{
						credits = credits + ld.Net__c;
					}				
					if(ld.Type__c == 'SR'&& ld.Trans_Date__c.month() == month && ld.Trans_Date__c.Year() == Year )
					{
						receipts = receipts + ld.Net__c;
					}						
					if(ld.Type__c == 'SP' && ld.Trans_Date__c.month() == month && ld.Trans_Date__c.Year() == Year )
					{
						payments = payments + ld.Net__c;
					}						
				}
				objectWrapper = new CustomerSalesInvoiceWrapper(StartDt,sales , credits, receipts ,payments);
				listWrapper.add(objectWrapper);
				system.debug('listWrapper : '+listWrapper[i]);
				i++;				
				StartDt = StartDt.addMonths(1);
				month = StartDt.month();
				Year = StartDt.Year();
			}
			while(i < 12);					
		}
		catch(exception e)		
		{
			apexpages.addMessages(e);
		}		
	}		
	public List<CustomerSalesInvoiceWrapper> getSalesInvoices()
	{
		return listWrapper;
	}
	private static testMethod void CustomerSalesInvoiceController_Test()
	{		
		Account act = new Account(Name='ABC Company',Type='Customer', AccountNumber = 'ABC-85');
		insert act;
		CustomerSalesInvoiceController csiRpt = new CustomerSalesInvoiceController();
		csiRpt.objectLookup.CustomerAccount__c = act.id;
		try
		{
			csiRpt.validationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'No any entry has been made by this Customer'); 
		}			
		Ledger__c ldg = new Ledger__c(Trans_Date__c = Date.newInstance(2011,1,1) , Sub_Account__c = 'ABC-85' , Type__c = 'SI', Credit__c = 10, Debit__c = 5 , Is_Deleted__c = false , Show_On_Transaction__c = 1 );
		insert ldg;
		ldg = new Ledger__c(Trans_Date__c = Date.newInstance(2011,2,1) , Sub_Account__c = 'ABC-85' , Type__c = 'SP' , Credit__c = 10, Debit__c = 5 , Is_Deleted__c = false , Show_On_Transaction__c = 1 );
		insert ldg;
		ldg = new Ledger__c(Trans_Date__c = Date.newInstance(2011,3,1) , Sub_Account__c = 'ABC-85' , Type__c = 'SC' , Credit__c = 10, Debit__c = 5 , Is_Deleted__c = false , Show_On_Transaction__c = 1 );
		insert ldg;
		ldg = new Ledger__c(Trans_Date__c = Date.newInstance(2011,4,1) , Sub_Account__c = 'ABC-85' , Type__c = 'SR' , Credit__c = 10, Debit__c = 5 , Is_Deleted__c = false , Show_On_Transaction__c = 1 );		
		insert ldg;
		ldg = new Ledger__c(Trans_Date__c = Date.newInstance(2011,7,1) , Sub_Account__c = 'ABC-85' , Type__c = 'SI' , Credit__c = 10, Debit__c = 5 , Is_Deleted__c = false , Show_On_Transaction__c = 1 );
		insert ldg;
		ldg = new Ledger__c(Trans_Date__c = Date.newInstance(2011,7,1) , Sub_Account__c = 'ABC-85' , Type__c = 'SP' , Credit__c = 10, Debit__c = 5 , Is_Deleted__c = false , Show_On_Transaction__c = 1 );
		insert ldg;
		
		csiRpt.Calculate();
		List<CustomerSalesInvoiceWrapper> csiw = csiRpt.getSalesInvoices();				
	}	
}