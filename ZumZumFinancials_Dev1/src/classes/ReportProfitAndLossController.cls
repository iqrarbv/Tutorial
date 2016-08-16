public class ReportProfitAndLossController
{
	public string fiscalStartPeriod {get;set;}
	public string fiscalEndPeriod {get;set;}
	
	private integer fiscalStartMonth;
	private integer fiscalStartYear;
	
	public List<NominalCategoryTotals> SalesDetail {get; private set;}
	public List<NominalCategoryTotals> PurchasesDetail {get; private set;}
	public List<NominalCategoryTotals> DirectExpensesDetail {get; private set;}
	public List<NominalCategoryTotals> OverheadsDetail {get; private set;}
	
	
	//Periodic calculation fields
	public decimal SalesPeriodTotal {get; private set;}
	public decimal PurchasesPeriodTotal {get;private set;}
	public decimal DirectExpensesPeriodTotal {get; private set;}
	public decimal OverheadsPeriodTotal {get; private set;}
	public decimal GrossPeriodProfit
	{
		get
		{
			return SalesPeriodTotal - PurchasesPeriodTotal - DirectExpensesPeriodTotal;
		}
	}
	public decimal NetPeriodProfit
	{
		get
		{
			return GrossPeriodProfit - OverheadsPeriodTotal;
		}
	}
	
	//To-date calculation fields
	public decimal SalesToDateTotal {get; private set;}
	public decimal PurchasesToDateTotal {get;private set;}
	public decimal DirectExpensesToDateTotal {get; private set;}
	public decimal OverheadsToDateTotal {get; private set;}
	public decimal GrossToDateProfit
	{
		get
		{
			return SalesToDateTotal - PurchasesToDateTotal - DirectExpensesToDateTotal;
		}
	}
	public decimal NetToDateProfit
	{
		get
		{
			return GrossToDateProfit - OverheadsToDateTotal;
		}
	}
	
	//Periodic calculation fields
	public CurrencyField__c SalesPeriodTotalCurrency {get{return new CurrencyField__c(Amount__c=SalesPeriodTotal);}}
	public CurrencyField__c PurchasesPeriodTotalCurrency {get{return new CurrencyField__c(Amount__c=PurchasesPeriodTotal);}}
	public CurrencyField__c DirectExpensesPeriodTotalCurrency {get{return new CurrencyField__c(Amount__c=DirectExpensesPeriodTotal);}}
	public CurrencyField__c OverheadsPeriodTotalCurrency {get{return new CurrencyField__c(Amount__c=OverheadsPeriodTotal);}}
	public CurrencyField__c GrossPeriodProfitCurrency {get{return new CurrencyField__c(Amount__c=GrossPeriodProfit);}}
	public CurrencyField__c NetPeriodProfitCurrency {get{return new CurrencyField__c(Amount__c=NetPeriodProfit);}}
	
	//To-date calculation fields
	public CurrencyField__c SalesToDateTotalCurrency {get{return new CurrencyField__c(Amount__c=SalesToDateTotal);}}
	public CurrencyField__c PurchasesToDateTotalCurrency {get{return new CurrencyField__c(Amount__c=PurchasesToDateTotal);}}
	public CurrencyField__c DirectExpensesToDateTotalCurrency {get{return new CurrencyField__c(Amount__c=DirectExpensesToDateTotal);}}
	public CurrencyField__c OverheadsToDateTotalCurrency {get{return new CurrencyField__c(Amount__c=OverheadsToDateTotal);}}
	public CurrencyField__c GrossToDateProfitCurrency {get{return new CurrencyField__c(Amount__c=GrossToDateProfit);}}
	public CurrencyField__c NetToDateProfitCurrency {get{return new CurrencyField__c(Amount__c=NetToDateProfit);}}  
	
	public ReportProfitAndLossController()
	{
		init();		
	}
	
	private void init()
	{
		SalesPeriodTotal = 0;
		PurchasesPeriodTotal = 0;
		DirectExpensesPeriodTotal = 0;
		OverheadsPeriodTotal = 0;
		
		SalesToDateTotal = 0;
		PurchasesToDateTotal = 0;
		DirectExpensesToDateTotal = 0;
		OverheadsToDateTotal = 0;
		
		salesDetail = new List<NominalCategoryTotals>();
		purchasesDetail = new List<NominalCategoryTotals>();
		directExpensesDetail = new List<NominalCategoryTotals>();
		overheadsDetail = new List<NominalCategoryTotals>();
		
		fiscalStartPeriod = fiscalEndPeriod = Utility.GetCurrentMonthYearForSelectList();		
	}
	public List<SelectOption> FiscalMonthsList
	{
		get
		{
			if(FiscalMonthsList==null)
			{
				FiscalMonthsList = Utility.GetFiscalMonthsList();
			}
			return FiscalMonthsList;
		}
		set;
	}
	
	public void RunReportFromURLParams()
	{
		fiscalStartPeriod = apexpages.currentPage().getParameters().get('fiscalStartPeriod');
		fiscalEndPeriod = apexpages.currentPage().getParameters().get('fiscalEndPeriod');
		RunReport();
	}
	
	public decimal thisMonth {get;set;}
	public decimal secMonth {get;set;}
	public decimal thrdMonth {get;set;}
	public void RunDashBoardReport()
	{
		for(integer i = 0 ; i <= 2 ; i++)
		{
			fiscalStartPeriod = string.valueof(date.today().month()-i) + ':' +string.valueof(date.today().year()) ;
			fiscalEndPeriod = string.valueof(date.today().month()-i) + ':' +string.valueof(date.today().year()) ;
			RunReport();
			if(i==0)
				thisMonth = NetPeriodProfitCurrency.Amount__c ;
			if(i==1)
				secMonth = NetPeriodProfitCurrency.Amount__c ;
			if(i==2)
				thrdMonth = NetPeriodProfitCurrency.Amount__c ;	
		}	
	}
	
	public void RunReport()
	{
		try
		{
			init();
			string[] fiscalStart = FiscalMonthsList[0].getValue().split(':');
			fiscalStartMonth = Integer.valueof(fiscalStart[0]);
			fiscalStartYear = Integer.valueof(fiscalStart[1]);			
			
			string[] startMonthYear = fiscalStartPeriod.split(':');
			integer startMonth = Integer.valueof(startMonthYear[0]);
			integer startYear = Integer.valueof(startMonthYear[1]);
			date startDate = date.newInstance(startYear,startMonth,1);
			
			string[] endMonthYear = fiscalEndPeriod.split(':');
			integer endMonth = Integer.valueof(endMonthYear[0]);
			integer endYear = Integer.valueof(endMonthYear[1]);
			date endDate = date.newInstance(endYear,endMonth,1);
			
			if(startDate>endDate)
			{
				throw new CustomException('Invalid period selected.');
			}
			SalesDetail = GetSubcategoryTotals(utility.SalesMainCategory, startMonth, startYear, endMonth, endYear);
			PurchasesDetail = GetSubcategoryTotals(utility.PurchasesMainCategory, startMonth, startYear, endMonth, endYear);
			DirectExpensesDetail = GetSubcategoryTotals(utility.DirectExpensesMainCategory, startMonth, startYear, endMonth, endYear);
			OverheadsDetail = GetSubcategoryTotals(utility.OverheadsMainCategory, startMonth, startYear, endMonth, endYear);
						
		}
		catch(Exception ex)
		{
			Apexpages.AddMessages(ex);
		}
	}
	
	private static AggregateResult[] QuerySubCatTotals(string mainCategoryName, integer startMonth, integer startYear, integer endMonth, integer endYear)
	{
		//apexpages.addmessage(new apexpages.message(apexpages.severity.info,'mainCategoryName: '+mainCategoryName+' startMonth: '+startMonth+' startYear: '+startYear+' endMonth: '+endMonth+' endYear: '+endYear));
		return [Select n.Nominal_Account__r.Sub_Category__c subCategoryId, n.Nominal_Account__r.Sub_Category__r.Name subCategoryName, Sum(n.Actuals_Debit__c) totalDebit, Sum(n.Actuals_Credit__c) totalCredit 
			    From Nominal_Budget__c n
			    Where n.Nominal_Account__r.Sub_Category__r.Nominal_Categories__r.Name=:mainCategoryName
			    and ((Month__c>=:startMonth and Year__c>=:startYear) or (Month__c<=:endMonth and Year__c<=:endYear))
			    Group by n.Nominal_Account__r.Sub_Category__c, n.Nominal_Account__r.Sub_Category__r.Name
			    Order by n.Nominal_Account__r.Sub_Category__r.Name];
			    
	}
	
	private void CalculatePeriodTotals(string mainCategoryName,decimal total)
	{
		if(mainCategoryName==Utility.SalesMainCategory)
		{
			SalesPeriodTotal += total;
		}
		else if(mainCategoryName==Utility.PurchasesMainCategory)
		{
			PurchasesPeriodTotal += total;
		}
		else if(mainCategoryName==Utility.DirectExpensesMainCategory)
		{
			DirectExpensesPeriodTotal += total;
		}
		else if(mainCategoryName==Utility.OverheadsMainCategory)
		{
			OverheadsPeriodTotal += total;
		}
	}
	
	private void CalculateToDateTotals(string mainCategoryName,decimal total)
	{
		if(mainCategoryName==Utility.SalesMainCategory)
		{
			SalesToDateTotal += total;
		}
		else if(mainCategoryName==Utility.PurchasesMainCategory)
		{
			PurchasesToDateTotal += total;
		}
		else if(mainCategoryName==Utility.DirectExpensesMainCategory)
		{
			DirectExpensesToDateTotal += total;
		}
		else if(mainCategoryName==Utility.OverheadsMainCategory)
		{
			OverheadsToDateTotal += total;
		}
	}
	
	private List<NominalCategoryTotals> GetSubcategoryTotals(string mainCategoryName, integer startMonth, integer startYear, integer endMonth, integer endYear)
	{
		Map<string, NominalCategoryTotals> totals = new Map<string, NominalCategoryTotals>();
		for(AggregateResult ar : QuerySubCatTotals(mainCategoryName, startMonth, startYear, endMonth, endYear))
		{
			NominalCategoryTotals obj = new NominalCategoryTotals();
			obj.Name = (string) ar.get('subCategoryName');
			decimal totalDebit = (decimal) ar.get('totalDebit');
			totalDebit = totalDebit==null?0:totalDebit;
			decimal totalCredit = (decimal) ar.get('totalCredit');
			totalCredit = totalCredit==null?0:totalCredit;
			obj.PeriodTotal = mainCategoryName==Utility.SalesMainCategory ? totalCredit - totalDebit : totalDebit - totalCredit ;
			totals.put(obj.Name,obj);
			CalculatePeriodTotals(mainCategoryName,obj.PeriodTotal);
		}
		
		startMonth = fiscalStartMonth;
		startYear = fiscalStartYear;
		for(AggregateResult ar : QuerySubCatTotals(mainCategoryName, startMonth, startYear, endMonth, endYear))
		{
			NominalCategoryTotals obj = totals.get((string) ar.get('subCategoryName'));
			if(obj==null)
			{
				obj = new NominalCategoryTotals();
				obj.Name = (string) ar.get('subCategoryName');
				totals.put(obj.Name,obj);
			}
			decimal totalDebit = (decimal) ar.get('totalDebit');
			totalDebit = totalDebit==null?0:totalDebit;
			decimal totalCredit = (decimal) ar.get('totalCredit');
			totalCredit = totalCredit==null?0:totalCredit;
			obj.ToDateTotal = mainCategoryName==Utility.SalesMainCategory ? totalCredit - totalDebit : totalDebit - totalCredit ;
			CalculateToDateTotals(mainCategoryName,obj.ToDateTotal);			
		}		
		return totals.values();
	}
	
	public class NominalCategoryTotals
	{
		public string Name {get; private set;}
		public decimal PeriodTotal {get; private set;}
		public decimal ToDateTotal {get; private set;}
		public CurrencyField__c PeriodTotalCurrency
		{
			get
			{
				return new CurrencyField__c(Amount__c=PeriodTotal);
			}
		}
		public CurrencyField__c ToDateTotalCurrency
		{
			get
			{
				return new CurrencyField__c(Amount__c=PeriodTotal);
			}
		}
	}
	
	
	// starting of test functions
	private static testMethod void ReportProfitandLossController_Test()
	{
		ReportProfitAndLossController obj = new ReportProfitAndLossController();
		obj.init();
		List<SelectOption> fisLst = obj.FiscalMonthsList;
		apexpages.currentPage().getParameters().put('fiscalStartPeriod' , '4:2011');
		apexpages.currentPage().getParameters().put('fiscalEndPeriod' , '4:2011');
		obj.RunReportFromURLParams();
		obj.RunDashBoardReport();
		obj.fiscalStartPeriod = '10:2011';
		obj.fiscalStartPeriod = '4:2011';
		obj.RunReport();
		
	} 
	// end of test functions		
}