public class SalesReportController {
	public Ledger__c objectLedger {get;set;}		
	public List<SalesReportWrapper> listwrapper;
	public string currencySymbol{get;set;}	
	public SalesReportController ()
	{
		objectLedger = new Ledger__c();	
		currencySymbol = Functions.getOrganisationCurrency('CurrencySymbol');
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
			SalesReportWrapper objectwrapper;
			integer mName , yName;
			decimal sale , crdtNote;	
			Date stDate;								 				
			listwrapper = new List<SalesReportWrapper>();
			stDate = objectLedger.Trans_Date__c;											
			do
			{			
				mName = stDate.Month();
				yName = stDate.Year();	
				sale = 0.0;
				crdtNote = 0.0;
				for(Ledger__c ld : [Select Type__c, Net__c , Trans_Date__c  From Ledger__c  where (Type__c = 'SI' or Type__c = 'SC') and Trans_Date__c >=: objectLedger.Trans_Date__c and Trans_Date__c <=: objectLedger.Bank_Reconcile_Date__c and Is_Deleted__c = false and Show_On_Transaction__c = 1])
				{					
					if((ld.Trans_Date__c.Month() == mName) && (ld.Trans_Date__c.Year() == yName))
					{
						if((ld.Type__c == 'SI'))
						{	
							sale = sale + ld.Net__c; 												
						}
						else if((ld.Type__c == 'SC'))
						{	
							crdtNote = crdtNote + ld.Net__c ;
						}
					}
				}
				objectwrapper = new SalesReportWrapper(stDate , mName , yName , sale , crdtNote);				
				listwrapper.add(objectwrapper);
				stDate = stDate.addMonths(1);					
			}
			while(stDate <= objectLedger.Bank_Reconcile_Date__c);													
		}
		catch(exception e)
		{
			apexpages.addmessages(e);
		}
	}	
	public List<SalesReportWrapper> getSalesTaxReport()
	{		
		return listwrapper;	
	}
	public void validationRules()
	{
		if(objectLedger.Trans_Date__c == null)		
			throw new CustomException('Enter From Date first');
		if(objectLedger.Bank_Reconcile_Date__c == null)		
			throw new CustomException('Enter To Date first');
	}
	private static testMethod void SalesReportController_Test()
	{
		Ledger__c ldg = new Ledger__c(Trans_Date__c = Date.newInstance(2011,1,1) , Bank_Reconcile_Date__c = Date.today());
		insert ldg;
		SalesReportController sRpt = new SalesReportController();
		try
		{
			sRpt.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'Enter From Date first');
		}
		sRpt.objectLedger.Trans_Date__c = ldg.Trans_Date__c;
		try
		{
			sRpt.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'Enter To Date first');
		}
		sRpt.objectLedger.Bank_Reconcile_Date__c = ldg.Bank_Reconcile_Date__c;					
		sRpt.Calculate();
		List<SalesReportWrapper>  srw = sRpt.getSalesTaxReport();
		sRpt.CalculateforExcel();	
	}
}