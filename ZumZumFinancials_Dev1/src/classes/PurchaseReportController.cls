public class PurchaseReportController {
	public Ledger__c objectLedger {get;set;}
	public List<Ledger__c> listLedger {get;set;}	
	public PurchaseReportWrapper objectwrapper;
	public List<PurchaseReportWrapper> listwrapper;
	public integer mName;
	public integer yName;
	public decimal purchase;
	public decimal crdtNote;	
	public Date stDate;
	public string currencySymbol{get;set;}		
	public PurchaseReportController ()
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
			listLedger = [Select Type__c, Net__c , Trans_Date__c  From Ledger__c  where Trans_Date__c >=: objectLedger.Trans_Date__c and Trans_Date__c <=: objectLedger.Bank_Reconcile_Date__c and Is_Deleted__c = false];									
			listwrapper = new List<PurchaseReportWrapper>();
			stDate = objectLedger.Trans_Date__c;											
			do
			{			
				mName = stDate.Month();
				yName = stDate.Year();	
				purchase = 0.0;
				crdtNote = 0.0;
				for(Ledger__c ld : listLedger)
				{					
					if((ld.Trans_Date__c.Month() == mName) && (ld.Trans_Date__c.Year() == yName))
					{
						if((ld.Type__c == 'PI'))
						{	
							purchase = purchase + ld.Net__c; 												
						}
						else if((ld.Type__c == 'PC'))
						{	
							crdtNote = crdtNote + ld.Net__c ;
						}
					}
				}
				objectwrapper = new PurchaseReportWrapper(stDate , purchase , crdtNote);								
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
	public List<PurchaseReportWrapper> getPurchaseReport()
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
	private static testMethod void PurchaseReportController_Test()
	{
		Ledger__c ldg = new Ledger__c(Trans_Date__c = Date.newInstance(2011,1,1) , Bank_Reconcile_Date__c = Date.today());
		insert ldg;
		PurchaseReportController pRpt = new PurchaseReportController();
		try
		{
			pRpt.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'Enter From Date first');
		}
		pRpt.objectLedger.Trans_Date__c = ldg.Trans_Date__c;
		try
		{
			pRpt.ValidationRules();
		}
		catch(exception e)
		{
			system.assertEquals(e.getMessage(),'Enter To Date first');
		}
		pRpt.objectLedger.Bank_Reconcile_Date__c = ldg.Bank_Reconcile_Date__c;				
		pRpt.Calculate();
		List<PurchaseReportWrapper> prw = pRpt.getPurchaseReport();
		pRpt.CalculateforExcel();	
	}
}