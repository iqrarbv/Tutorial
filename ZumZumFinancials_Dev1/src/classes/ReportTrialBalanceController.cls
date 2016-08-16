public class ReportTrialBalanceController
{
	public List<Nominal_Budget__c> Records {get;set;}
	public string fiscalMonth {get;set;}
	
	public ReportTrialBalanceController()
	{
		fiscalMonth = Utility.GetCurrentMonthYearForSelectList();
	}
	
	public void InitPDF()
	{
		fiscalMonth = apexPages.currentPage().getParameters().get('fiscalMonth');
		GetRecords();
	}
	
	public List<SelectOption> MonthsList
	{
		get
		{
			if(MonthsList==null)
			{
				MonthsList = Utility.GetFiscalMonthsList();
			}
			return MonthsList;
		}
		set;
	}
	
	public void GetRecordsFromURLParams()
	{
		fiscalMonth = Apexpages.currentPage().getParameters().get('fiscalMonth');
		GetRecords();
	}
	
	public void GetRecords()
	{
		if(fiscalMonth==null)
		{
			Apexpages.addMessage(new apexpages.Message(apexpages.severity.info,'Please select a month to view trial balance report.'));
			return;
		}			
		
		string[] monthYear = fiscalMonth.split(':');
		integer month = Integer.valueof(monthYear[0]);
		integer year = Integer.valueof(monthYear[1]);
			
		Records = [Select n.Year__c, n.Nominal_Account__r.Nominal_Code__c, n.Nominal_Account__r.Name, n.Nominal_Account__c, n.Month__c, n.Id, n.Actuals_Debit__c, n.Actuals_Credit__c 
				   From Nominal_Budget__c n
				   Where Month__c=:month and Year__c=:year
				   Order by Nominal_Account__r.Nominal_Code__c];
				   
		AggregateResult[] totals = [Select Sum(Actuals_Debit__c) totalDebit, Sum(Actuals_Credit__c) totalCredit
					From Nominal_Budget__c n
				   Where Month__c=:month and Year__c=:year];
				   	
		if(totals.size()>0)
		{
			double TotalDebit = (Double) totals[0].get('TotalDebit');
			totalDebit = totalDebit==null?0:totalDebit;
			double TotalCredit = (Double) totals[0].get('TotalCredit');
			totalCredit = totalCredit==null?0:totalCredit;
			Records.add(new Nominal_Budget__c(Nominal_Account__r = new Nominal_Account__c(Name='Total'), Actuals_Debit__c=TotalDebit, Actuals_Credit__c=TotalCredit));
		}		   			   
		if(Records.size()==0)
			Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.Info,'No records found'));
	}
	
	private static testmethod void Test_ReportTrialBalanceController()
	{
		integer month = datetime.now().date().month();
		integer year = datetime.now().date().year(); 
		List<Nominal_Budget__c> nominalRecords = new List<Nominal_Budget__c>();
		for(integer i=0; i<20; i++)
		{
			Nominal_Account__c nominalAccount = new Nominal_Account__c(Name='test '+i,Account_Code__c=(1000+i));
			insert nominalAccount;
			for(integer j=1; j<=12; j++)
			{			
				nominalRecords.add(new Nominal_Budget__c(Nominal_Account__c=nominalAccount.id,Month__c=j,Year__c=year,Budget_Credit__c=0,Budget_Debit__c=1000,Actuals_Credit__c=10,Actuals_Debit__c=0));
			}
		}
		
		insert nominalRecords;
		
		ReportTrialBalanceController obj = new ReportTrialBalanceController();
		obj.fiscalMonth = month+':'+year;
		obj.GetRecords();
		List<Nominal_Budget__c> records = obj.Records;				
	}
	
	
	// Start of test functions
	private static testmethod void TestTrailBalance()
	{
		ReportTrialBalanceController obj = new 	ReportTrialBalanceController();
		obj.fiscalMonth = null ;
		try
		{
			obj.GetRecords();
		}
		catch (Exception e)
		{
			system.assertEquals(e.getMessage(), 'Please select a month to view trial balance report.');
		}
		List<Selectoption> objList = obj.MonthsList ;
		obj.fiscalMonth = '4:2011';
		obj.GetRecords(); 
		apexpages.currentPage().getParameters().put('fiscalMonth' , '4:2011');
		obj.GetRecordsFromURLParams();
		obj.InitPDF();
	}
	// end of test functions
}