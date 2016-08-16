public class ReportBalanceSheetController extends ReportControllerBase
{
	private Control_Account__c controlAccounts;
	public string fiscalStartPeriod {get;set;}
	public string fiscalEndPeriod {get;set;}
	
	private integer fiscalStartMonth;
	private integer fiscalStartYear;
	
	private Map<string, NominalCategoryTotals> FixedAssetsDetailMap;
	private Map<string, NominalCategoryTotals> CurrentAssetsDetailMap;
	private Map<string, NominalCategoryTotals> CurrentLiabilitiesDetailMap;
	private Map<string, NominalCategoryTotals> LongTermLiabilitiesDetailMap;
	private Map<string, NominalCategoryTotals> CapitalAndReservesDetailMap;
	
	public List<NominalCategoryTotals> FixedAssetsDetail {get{return FixedAssetsDetailMap.values();}}
	public List<NominalCategoryTotals> CurrentAssetsDetail {get{return CurrentAssetsDetailMap.values();}}
	public List<NominalCategoryTotals> CurrentLiabilitiesDetail {get{return CurrentLiabilitiesDetailMap.values();}}
	public List<NominalCategoryTotals> LongTermLiabilitiesDetail {get{return LongTermLiabilitiesDetailMap.values();}}
	public List<NominalCategoryTotals> CapitalAndReservesDetail {get{return CapitalAndReservesDetailMap.values();}}
	
	
	//Periodic calculation fields
	public decimal FixedAssetsPeriodTotal {get; private set;}
	public decimal CurrentAssetsPeriodTotal {get;private set;}
	public decimal CurrentLiabilitiesPeriodTotal {get; private set;}
	public decimal LongTermLiabilitiesPeriodTotal {get; private set;}
	public decimal CapitalAndReservesPeriodTotal {get; private set;}
	public decimal CurrentAssetsLessCurrentLiabilitiesPeriodTotal
	{
		get
		{
			return CurrentAssetsPeriodTotal - CurrentLiabilitiesPeriodTotal;
		}
	}
	public decimal TotalAssetsLessCurrentLiabilitiesPeriodTotal
	{
		get
		{
			return FixedAssetsPeriodTotal + CurrentAssetsPeriodTotal - CurrentLiabilitiesPeriodTotal;
		}
	}
	public decimal TotalAssetsLessTotalLiabilitiesPeriodTotal
	{
		get
		{
			return FixedAssetsPeriodTotal + CurrentAssetsPeriodTotal - CurrentLiabilitiesPeriodTotal - LongTermLiabilitiesPeriodTotal;
		}
	}
	
	//To-date calculation fields
	public decimal FixedAssetsToDateTotal {get; private set;}
	public decimal CurrentAssetsToDateTotal {get;private set;}
	public decimal CurrentLiabilitiesToDateTotal {get; private set;}
	public decimal LongTermLiabilitiesToDateTotal {get; private set;}
	public decimal CapitalAndReservesToDateTotal {get; private set;}
	public decimal CurrentAssetsLessCurrentLiabilitiesToDateTotal
	{
		get
		{
			return CurrentAssetsToDateTotal - CurrentLiabilitiesToDateTotal;
		}
	}
	public decimal TotalAssetsLessCurrentLiabilitiesTotDateTotal
	{
		get
		{
			return FixedAssetsToDateTotal + CurrentAssetsToDateTotal - CurrentLiabilitiesToDateTotal;
		}
	}
	public decimal TotalAssetsLessTotalLiabilitiesTotDateTotal
	{
		get
		{
			return FixedAssetsToDateTotal + CurrentAssetsToDateTotal - CurrentLiabilitiesToDateTotal - LongTermLiabilitiesToDateTotal;
		}
	}
	
	//Periodic calculation fields
	public CurrencyField__c FixedAssetsPeriodTotalCurrency {get{return new CurrencyField__c(Amount__c=FixedAssetsPeriodTotal);}}
	public CurrencyField__c CurrentAssetsPeriodTotalCurrency {get{return new CurrencyField__c(Amount__c=CurrentAssetsPeriodTotal);}}
	public CurrencyField__c CurrentLiabilitiesPeriodTotalCurrency {get{return new CurrencyField__c(Amount__c=CurrentLiabilitiesPeriodTotal);}}
	public CurrencyField__c LongTermLiabilitiesPeriodTotalCurrency {get{return new CurrencyField__c(Amount__c=LongTermLiabilitiesPeriodTotal);}}
	public CurrencyField__c CapitalAndReservesPeriodTotalCurrency {get{return new CurrencyField__c(Amount__c=CapitalAndReservesPeriodTotal);}}
	public CurrencyField__c CurrentAssetsLessCurrentLiabilitiesPeriodTotalCurrency {get{return new CurrencyField__c(Amount__c=CurrentAssetsLessCurrentLiabilitiesPeriodTotal);}}
	public CurrencyField__c TotalAssetsLessCurrentLiabilitiesPeriodTotalCurrency {get{return new CurrencyField__c(Amount__c=TotalAssetsLessCurrentLiabilitiesPeriodTotal);}}
	public CurrencyField__c TotalAssetsLessTotalLiabilitiesPeriodTotalCurrency {get{return new CurrencyField__c(Amount__c=TotalAssetsLessTotalLiabilitiesPeriodTotal);}}
	
	//To-date calculation fields
	public CurrencyField__c FixedAssetsToDateTotalCurrency {get{return new CurrencyField__c(Amount__c=FixedAssetsToDateTotal);}}
	public CurrencyField__c CurrentAssetsToDateTotalCurrency {get{return new CurrencyField__c(Amount__c=CurrentAssetsToDateTotal);}}
	public CurrencyField__c CurrentLiabilitiesToDateTotalCurrency {get{return new CurrencyField__c(Amount__c=CurrentLiabilitiesToDateTotal);}}
	public CurrencyField__c LongTermLiabilitiesToDateTotalCurrency {get{return new CurrencyField__c(Amount__c=LongTermLiabilitiesToDateTotal);}}
	public CurrencyField__c CapitalAndReservesToDateTotalCurrency {get{return new CurrencyField__c(Amount__c=CapitalAndReservesToDateTotal);}}
	public CurrencyField__c CurrentAssetsLessCurrentLiabilitiesToDateTotalCurrency {get{return new CurrencyField__c(Amount__c=CurrentAssetsLessCurrentLiabilitiesToDateTotal);}}
	public CurrencyField__c TotalAssetsLessCurrentLiabilitiesToDateTotalCurrency {get{return new CurrencyField__c(Amount__c=TotalAssetsLessCurrentLiabilitiesTotDateTotal);}}
	public CurrencyField__c TotalAssetsLessTotalLiabilitiesToDateTotalCurrency {get{return new CurrencyField__c(Amount__c=TotalAssetsLessTotalLiabilitiesTotDateTotal);}}
	
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
	
	//Periodic Profit and loss calculation fields
	public CurrencyField__c SalesPeriodTotalCurrency {get{return new CurrencyField__c(Amount__c=SalesPeriodTotal);}}
	public CurrencyField__c PurchasesPeriodTotalCurrency {get{return new CurrencyField__c(Amount__c=PurchasesPeriodTotal);}}
	public CurrencyField__c DirectExpensesPeriodTotalCurrency {get{return new CurrencyField__c(Amount__c=DirectExpensesPeriodTotal);}}
	public CurrencyField__c OverheadsPeriodTotalCurrency {get{return new CurrencyField__c(Amount__c=OverheadsPeriodTotal);}}
	public CurrencyField__c GrossPeriodProfitCurrency {get{return new CurrencyField__c(Amount__c=GrossPeriodProfit);}}
	public CurrencyField__c NetPeriodProfitCurrency {get{return new CurrencyField__c(Amount__c=NetPeriodProfit);}}
	
	//To-date Profit and loss calculation fields
	public CurrencyField__c SalesToDateTotalCurrency {get{return new CurrencyField__c(Amount__c=SalesToDateTotal);}}
	public CurrencyField__c PurchasesToDateTotalCurrency {get{return new CurrencyField__c(Amount__c=PurchasesToDateTotal);}}
	public CurrencyField__c DirectExpensesToDateTotalCurrency {get{return new CurrencyField__c(Amount__c=DirectExpensesToDateTotal);}}
	public CurrencyField__c OverheadsToDateTotalCurrency {get{return new CurrencyField__c(Amount__c=OverheadsToDateTotal);}}
	public CurrencyField__c GrossToDateProfitCurrency {get{return new CurrencyField__c(Amount__c=GrossToDateProfit);}}
	public CurrencyField__c NetToDateProfitCurrency {get{return new CurrencyField__c(Amount__c=NetToDateProfit);}}  
	
	public ReportBalanceSheetController()
	{
		init();		
	}
	
	private void init()
	{
		controlAccounts = Utility.GetControlAccount();
		
		FixedAssetsPeriodTotal = 0;
		CurrentAssetsPeriodTotal = 0;
		CurrentLiabilitiesPeriodTotal = 0;
		LongTermLiabilitiesPeriodTotal = 0;
		CapitalAndReservesPeriodTotal = 0;
		
		FixedAssetsToDateTotal = 0;
		CurrentAssetsToDateTotal = 0;
		CurrentLiabilitiesToDateTotal = 0;
		LongTermLiabilitiesToDateTotal = 0;
		CapitalAndReservesToDateTotal = 0;
		
		SalesPeriodTotal = 0;
		PurchasesPeriodTotal = 0;
		DirectExpensesPeriodTotal = 0;
		OverheadsPeriodTotal = 0;
		
		SalesToDateTotal = 0;
		PurchasesToDateTotal = 0;
		DirectExpensesToDateTotal = 0;
		OverheadsToDateTotal = 0;
		
		FixedAssetsDetailMap = new Map<string, NominalCategoryTotals>();
		CurrentAssetsDetailMap = new  Map<string, NominalCategoryTotals>();
		CurrentLiabilitiesDetailMap = new  Map<string, NominalCategoryTotals>();
		LongTermLiabilitiesDetailMap = new  Map<string, NominalCategoryTotals>();
		CapitalAndReservesDetailMap = new  Map<string, NominalCategoryTotals>();
		
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
		system.debug('this is start date: ' + fiscalStartPeriod ) ;
		system.debug('this is end date: ' + fiscalEndPeriod ) ;
		RunReport();
	}
	public decimal thisMonth {get;set;}
	public decimal secMonth {get;set;}
	public decimal thrdMonth {get;set;}
	public void RunReportForDashBoard()
	{
		for(integer i = 0 ; i <= 2 ; i++)
		{
			fiscalStartPeriod = string.valueof(date.today().month()-i) + ':' +string.valueof(date.today().year()) ;
			fiscalEndPeriod = string.valueof(date.today().month()-i) + ':' +string.valueof(date.today().year()) ;
			RunReport();
			if(i==0)
				thisMonth = CapitalAndReservesPeriodTotalCurrency.Amount__c ;
			if(i==1)
				secMonth = CapitalAndReservesPeriodTotalCurrency.Amount__c ;
			if(i==2)
				thrdMonth = CapitalAndReservesPeriodTotalCurrency.Amount__c ;	
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
			CalculateProfitAndLoss(startMonth, startYear, endMonth, endYear);
			FixedAssetsDetailMap = GetSubcategoryTotals(utility.FixedAssetsMainCategory, startMonth, startYear, endMonth, endYear);
			CurrentAssetsDetailMap = GetSubcategoryTotals(utility.CurrentAssetsMainCategory, startMonth, startYear, endMonth, endYear);
			CurrentLiabilitiesDetailMap = GetSubcategoryTotals(utility.CurrentLiabilitiesMainCategory, startMonth, startYear, endMonth, endYear, true);
			LongTermLiabilitiesDetailMap = GetSubcategoryTotals(utility.LongTermLiabilitiesMainCategory, startMonth, startYear, endMonth, endYear, true);
			CapitalAndReservesDetailMap = GetSubcategoryTotals(utility.CapitalAndReservesMainCategory, startMonth, startYear, endMonth, endYear);
			
			system.debug('Before header settlement FixedAssetsDetailMap: '+FixedAssetsDetailMap);
			system.debug('Before header settlement CurrentAssetsDetailMap: '+CurrentAssetsDetailMap);
			system.debug('Before header settlement CurrentLiabilitiesDetailMap: '+CurrentLiabilitiesDetailMap);
			system.debug('Before header settlement LongTermLiabilitiesDetailMap: '+LongTermLiabilitiesDetailMap);
			system.debug('Before header settlement CapitalAndReservesDetailMap: '+CapitalAndReservesDetailMap);
			
			SettleBankBalanceHeader(startMonth, startYear, endMonth, endYear);
			SettleSalesTaxHeader(startMonth, startYear, endMonth, endYear);
			SettlePurchaseTaxHeader(startMonth, startYear, endMonth, endYear);
			
			system.debug('After header settlement: '+FixedAssetsDetailMap);
			system.debug('After header settlement: '+CurrentAssetsDetailMap);
			system.debug('After header settlement: '+CurrentLiabilitiesDetailMap);
			system.debug('After header settlement: '+LongTermLiabilitiesDetailMap);
			system.debug('After header settlement: '+CapitalAndReservesDetailMap);
			
			/*
			integer index=0;
			for(NominalCategoryTotals nct : CurrentAssetsDetail)
			{
				if(nct.PeriodTotal<0 && nct.Name=='Deposits And Cash')
				{
					CalculatePeriodTotals(utility.CurrentAssetsMainCategory,-nct.PeriodTotal);
					CalculatePeriodTotals(utility.CurrentLiabilitiesMainCategory,nct.PeriodTotal);
					
					CalculateToDateTotals(utility.CurrentAssetsMainCategory,-nct.ToDateTotal);
					CalculateToDateTotals(utility.CurrentLiabilitiesMainCategory,nct.ToDateTotal);
					
					CurrentLiabilitiesDetail.Add(nct);
					CurrentAssetsDetail.Remove(index);					
				}	
				index++;
			}*/						
		}
		catch(Exception ex)
		{
			Apexpages.AddMessages(ex);
		}
	}
	
	private void CalculatePeriodTotals(string mainCategoryName,decimal total)
	{
		if(mainCategoryName==Utility.FixedAssetsMainCategory)
		{
			FixedAssetsPeriodTotal += total;
		}
		else if(mainCategoryName==Utility.CurrentAssetsMainCategory)
		{
			CurrentAssetsPeriodTotal += total;
		}
		else if(mainCategoryName==Utility.CurrentLiabilitiesMainCategory)
		{
			CurrentLiabilitiesPeriodTotal += total;
		}
		else if(mainCategoryName==Utility.LongTermLiabilitiesMainCategory)
		{
			LongTermLiabilitiesPeriodTotal += total;
		}
		else if(mainCategoryName==Utility.CapitalAndReservesMainCategory)
		{
			CapitalAndReservesPeriodTotal += total;
		}
	}
	
	private void CalculateToDateTotals(string mainCategoryName,decimal total)
	{
		if(mainCategoryName==Utility.FixedAssetsMainCategory)
		{
			FixedAssetsToDateTotal += total;
		}
		else if(mainCategoryName==Utility.CurrentAssetsMainCategory)
		{
			CurrentAssetsToDateTotal += total;
		}
		else if(mainCategoryName==Utility.CurrentLiabilitiesMainCategory)
		{
			CurrentLiabilitiesToDateTotal += total;
		}
		else if(mainCategoryName==Utility.LongTermLiabilitiesMainCategory)
		{
			LongTermLiabilitiesToDateTotal += total;
		}
		else if(mainCategoryName==Utility.CapitalAndReservesMainCategory)
		{
			CapitalAndReservesToDateTotal += total;
		}
	}
	
	private Map<string, NominalCategoryTotals> GetSubcategoryTotals(string mainCategoryName, integer startMonth, integer startYear, integer endMonth, integer endYear)
	{
		return GetSubcategoryTotals(mainCategoryName, startMonth, startYear, endMonth, endYear, false);
	}
	
	private Map<string, NominalCategoryTotals> GetSubcategoryTotals(string mainCategoryName, integer startMonth, integer startYear, integer endMonth, integer endYear, boolean isLiabilityAccount)
	{
		Map<string, NominalCategoryTotals> totals = new Map<string, NominalCategoryTotals>();
		for(AggregateResult ar : QuerySubCatTotals(mainCategoryName, fiscalstartMonth, fiscalstartYear, endMonth, endYear))
		{
			NominalCategoryTotals obj = new NominalCategoryTotals();
			string name = (string) ar.get('subCategoryName');
			obj.Name = name;
			decimal totalDebit = (decimal) ar.get('totalDebit');
			totalDebit = totalDebit==null?0:totalDebit;
			decimal totalCredit = (decimal) ar.get('totalCredit');
			totalCredit = totalCredit==null?0:totalCredit;
			obj.ToDateTotal = isLiabilityAccount == true ? totalCredit - totalDebit : totalDebit - totalCredit;
			totals.put(obj.Name,obj);
			CalculateToDateTotals(mainCategoryName,obj.ToDateTotal);			
		}
		
		for(AggregateResult ar : QuerySubCatTotals(mainCategoryName, startMonth, startYear, endMonth, endYear))
		{
			NominalCategoryTotals obj = totals.get((string) ar.get('subCategoryName'));
			decimal totalDebit = (decimal) ar.get('totalDebit');
			totalDebit = totalDebit==null?0:totalDebit;
			decimal totalCredit = (decimal) ar.get('totalCredit');
			totalCredit = totalCredit==null?0:totalCredit;
			obj.PeriodTotal = isLiabilityAccount == true ? totalCredit - totalDebit : totalDebit - totalCredit;
			CalculatePeriodTotals(mainCategoryName,obj.PeriodTotal);
		}
		if(mainCategoryName == Utility.CapitalAndReservesMainCategory)
		{
			NominalCategoryTotals obj = new NominalCategoryTotals();
			obj.Name = 'Profit And Loss Account';
			obj.PeriodTotal = NetPeriodProfit;
			obj.ToDateTotal = NetToDateProfit;
			totals.put('Profit And Loss Account', obj);
			CalculatePeriodTotals(mainCategoryName,obj.PeriodTotal);
			CalculateToDateTotals(mainCategoryName,obj.ToDateTotal);
		}		
		return totals;
	}
	
	private static AggregateResult[] QueryProfitTotals(string mainCategoryName, integer startMonth, integer startYear, integer endMonth, integer endYear)
	{
		return [Select Sum(n.Actuals_Debit__c) totalDebit, Sum(n.Actuals_Credit__c) totalCredit 
			    From Nominal_Budget__c n
			    Where n.Nominal_Account__r.Sub_Category__r.Nominal_Categories__r.Name=:mainCategoryName
			    and ((Month__c>=:startMonth and Year__c>=:startYear) or (Month__c<=:endMonth and Year__c<=:endYear))
			    ];			    
	}
	
	private void CalculateProfitPeriodTotals(string mainCategoryName,decimal total)
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
	
	private void CalculateProfitToDateTotals(string mainCategoryName,decimal total)
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
	
	private void CalculateProfitAndLoss(integer startMonth, integer startYear, integer endMonth, integer endYear)
	{
		GetProfitAndLossTotals(Utility.SalesMainCategory, startMonth, startYear, endMonth, endYear);
		GetProfitAndLossTotals(Utility.PurchasesMainCategory, startMonth, startYear, endMonth, endYear);
		GetProfitAndLossTotals(Utility.DirectExpensesMainCategory, startMonth, startYear, endMonth, endYear);
		GetProfitAndLossTotals(Utility.OverheadsMainCategory, startMonth, startYear, endMonth, endYear);
	}
	
	private void GetProfitAndLossTotals(string mainCategoryName, integer startMonth, integer startYear, integer endMonth, integer endYear)
	{
		Map<string, NominalCategoryTotals> totals = new Map<string, NominalCategoryTotals>();
		AggregateResult[] arlist = QueryProfitTotals(mainCategoryName, startMonth, startYear, endMonth, endYear);
		if(arlist.size()>0)
		{
			AggregateResult ar = arlist[0];
			decimal totalDebit = (decimal) ar.get('totalDebit');
			totalDebit = totalDebit==null?0:totalDebit;
			decimal totalCredit = (decimal) ar.get('totalCredit');
			totalCredit = totalCredit==null?0:totalCredit;			
			decimal PeriodTotal = mainCategoryName==Utility.SalesMainCategory ? totalCredit - totalDebit : totalDebit - totalCredit ;
			CalculateProfitPeriodTotals(mainCategoryName,PeriodTotal);
		}
		//endMonth = date.today().Month();
		//endYear = date.today().Year();
		arlist = QueryProfitTotals(mainCategoryName, fiscalstartMonth, fiscalstartYear, endMonth, endYear);
		if(arlist.size()>0)
		{
			AggregateResult ar = arlist[0];
			decimal totalDebit = (decimal) ar.get('totalDebit');
			totalDebit = totalDebit==null?0:totalDebit;
			decimal totalCredit = (decimal) ar.get('totalCredit');
			totalCredit = totalCredit==null?0:totalCredit;
			decimal ToDateTotal = mainCategoryName==Utility.SalesMainCategory ? totalCredit - totalDebit : totalDebit - totalCredit ;
			CalculateProfitToDateTotals(mainCategoryName,ToDateTotal);			
		}
	}
	
	private static decimal GetNominalBalance(Id nominalId, integer startMonth, integer startYear, integer endMonth, integer endYear)
	{
		AggregateResult[] arlist = [Select Sum(n.Actuals_Debit__c) totalDebit, Sum(n.Actuals_Credit__c) totalCredit 
			    From Nominal_Budget__c n
			    Where n.Nominal_Account__c=:nominalId
			    and ((Month__c>=:startMonth and Year__c>=:startYear) or (Month__c<=:endMonth and Year__c<=:endYear))
				];
		if(arlist.size()==0)
			return 0;
		decimal credit = arlist[0].get('totalCredit')==null?0:(decimal) arlist[0].get('totalCredit');
		decimal debit = arlist[0].get('totalDebit')==null?0:(decimal) arlist[0].get('totalDebit');
		return debit - credit;
	}
	
	private decimal GetDefaultBankNominalAccountBalance(integer startMonth, integer startYear, integer endMonth, integer endYear)
	{
		return GetNominalBalance(controlAccounts.Default_Bank__c, startMonth, startYear, endMonth, endYear);			
	}
	
	private decimal GetSalesTaxNominalAccountBalance(integer startMonth, integer startYear, integer endMonth, integer endYear)
	{
		return GetNominalBalance(controlAccounts.VAT_on_Sales__c, startMonth, startYear, endMonth, endYear) * -1;			
	}
	
	private decimal GetPurchaseTaxNominalAccountBalance(integer startMonth, integer startYear, integer endMonth, integer endYear)
	{
		return GetNominalBalance(controlAccounts.VAT_on_Purchases__c, startMonth, startYear, endMonth, endYear) * -1;			
	}	
	
	private void SettleBankBalanceHeader(integer startMonth, integer startYear, integer endMonth, integer endYear)
	{
		decimal bankPeriodBalance = GetDefaultBankNominalAccountBalance(startMonth, startYear, endMonth, endYear);
		decimal bankToDateBalance = GetDefaultBankNominalAccountBalance(fiscalstartMonth, fiscalstartYear, endMonth, endYear);
		if(bankPeriodBalance<0)
		{
			bankPeriodBalance = bankPeriodBalance * -1;
			
			//settle Asset totals
			CurrentAssetsPeriodTotal += bankPeriodBalance;//neutralize negative impact of periodTotal
			CurrentAssetsDetailMap.get(controlAccounts.Default_Bank__r.Sub_Category__r.Name).PeriodTotal += bankPeriodBalance;
			
			//settle Liabilities totals
			CurrentLiabilitiesPeriodTotal += bankPeriodBalance;//add to liabilities total
			
			NominalCategoryTotals obj = new NominalCategoryTotals();
			obj.Name = controlAccounts.Default_Bank__r.Name;
			obj.PeriodTotal = bankPeriodBalance;						 
			obj.ToDateTotal = 0;
			CurrentLiabilitiesDetailMap.put(controlAccounts.Default_Bank__r.Name, obj);
			
			if(bankToDateBalance<0)
			{
				bankToDateBalance = bankToDateBalance * -1;
				
				//settle asset totals
				CurrentAssetsToDateTotal += bankToDateBalance;//neutralize negative impact of periodTotal
				CurrentAssetsDetailMap.get(controlAccounts.Default_Bank__r.Sub_Category__r.Name).ToDateTotal += bankToDateBalance;
				
				//settle Liabilities totals
				CurrentLiabilitiesToDateTotal += bankToDateBalance;//add to liabilities total
				obj.ToDateTotal = bankToDateBalance;
			}
			else
			{
				NominalCategoryTotals obj1 = new NominalCategoryTotals();
				obj1.Name = controlAccounts.Default_Bank__r.Name;
				obj1.PeriodTotal = 0;						 
				obj1.ToDateTotal = bankToDateBalance;
				CurrentAssetsDetailMap.put(controlAccounts.Default_Bank__r.Name, obj1);
			}
		}
	}
	
	private void SettleSalesTaxHeader(integer startMonth, integer startYear, integer endMonth, integer endYear)
	{
		decimal salesTaxPeriodBalance = GetSalesTaxNominalAccountBalance(startMonth, startYear, endMonth, endYear);
		decimal salesTaxToDateBalance = GetSalesTaxNominalAccountBalance(fiscalstartMonth, fiscalstartYear, endMonth, endYear);
		if(salesTaxPeriodBalance<0)
		{
			salesTaxPeriodBalance = salesTaxPeriodBalance * -1;
			
			//settle Liabilities totals
			CurrentLiabilitiesPeriodTotal += salesTaxPeriodBalance;//neutralize negative impact of periodTotal
			CurrentLiabilitiesDetailMap.get(controlAccounts.Vat_On_Sales__r.Sub_Category__r.Name).PeriodTotal += salesTaxPeriodBalance;
			
			//settle Assets totals
			CurrentAssetsPeriodTotal += salesTaxPeriodBalance;//add to liabilities total
			
			NominalCategoryTotals obj = new NominalCategoryTotals();
			obj.Name = controlAccounts.Vat_On_Sales__r.Name;
			obj.PeriodTotal = salesTaxPeriodBalance;						 
			obj.ToDateTotal = 0;
			CurrentAssetsDetailMap.put(controlAccounts.Vat_On_Sales__r.Name, obj);
			
			if(salesTaxToDateBalance<0)
			{
				salesTaxToDateBalance = salesTaxToDateBalance * -1;
				
				//settle asset totals
				CurrentLiabilitiesToDateTotal += salesTaxToDateBalance;//neutralize negative impact of periodTotal
				CurrentLiabilitiesDetailMap.get(controlAccounts.Vat_On_Sales__r.Sub_Category__r.Name).ToDateTotal += salesTaxToDateBalance;
				
				//settle Assetes totals
				CurrentAssetsToDateTotal += salesTaxToDateBalance;//add to liabilities total
				obj.ToDateTotal = salesTaxToDateBalance;
			}
			else
			{
				NominalCategoryTotals obj1 = new NominalCategoryTotals();
				obj1.Name = controlAccounts.Vat_On_Sales__r.Name;
				obj1.PeriodTotal = 0;						 
				obj1.ToDateTotal = salesTaxToDateBalance;
				CurrentLiabilitiesDetailMap.put(controlAccounts.Vat_On_Sales__r.Name, obj1);
			}
		}			
	}
	
	private void SettlePurchaseTaxHeader(integer startMonth, integer startYear, integer endMonth, integer endYear)
	{
		decimal purchaseTaxPeriodBalance = GetPurchaseTaxNominalAccountBalance(startMonth, startYear, endMonth, endYear);
		decimal purchaseTaxToDateBalance = GetPurchaseTaxNominalAccountBalance(fiscalstartMonth, fiscalstartYear, endMonth, endYear);
		if(purchaseTaxPeriodBalance<0)
		{
			purchaseTaxPeriodBalance = purchaseTaxPeriodBalance * -1;
			
			//settle Liabilities totals
			CurrentLiabilitiesPeriodTotal += purchaseTaxPeriodBalance;//neutralize negative impact of periodTotal
			CurrentLiabilitiesDetailMap.get(controlAccounts.Vat_On_purchases__r.Sub_Category__r.Name).PeriodTotal += purchaseTaxPeriodBalance;
			
			//settle Assets totals
			CurrentAssetsPeriodTotal += purchaseTaxPeriodBalance;//add to liabilities total
			
			NominalCategoryTotals obj = new NominalCategoryTotals();
			obj.Name = controlAccounts.Vat_On_purchases__r.Name;
			obj.PeriodTotal = purchaseTaxPeriodBalance;						 
			obj.ToDateTotal = 0;
			CurrentAssetsDetailMap.put(controlAccounts.Vat_On_purchases__r.Name, obj);
			
			if(purchaseTaxToDateBalance<0)
			{
				purchaseTaxToDateBalance = purchaseTaxToDateBalance * -1;
				
				//settle asset totals
				CurrentLiabilitiesToDateTotal += purchaseTaxToDateBalance;//neutralize negative impact of periodTotal
				CurrentLiabilitiesDetailMap.get(controlAccounts.Vat_On_purchases__r.Sub_Category__r.Name).ToDateTotal += purchaseTaxToDateBalance;
				
				//settle Liabilities totals
				CurrentAssetsToDateTotal += purchaseTaxToDateBalance;//add to liabilities total
				obj.ToDateTotal = purchaseTaxToDateBalance;
			}
			else
			{
				NominalCategoryTotals obj1 = new NominalCategoryTotals();
				obj1.Name = controlAccounts.Vat_On_purchases__r.Name;
				obj1.PeriodTotal = 0;						 
				obj1.ToDateTotal = purchaseTaxToDateBalance;
				CurrentLiabilitiesDetailMap.put(controlAccounts.Vat_On_purchases__r.Name, obj1);
			}
		}
	}
	// starting of test functions
	private static testMethod void ReportBalanceSheetController_Test()
	{
		ReportBalanceSheetController obj = new ReportBalanceSheetController();
		obj.init();
		List<SelectOption> fisLst = obj.FiscalMonthsList;
		apexpages.currentPage().getParameters().put('fiscalStartPeriod' , '4:2011');
		apexpages.currentPage().getParameters().put('fiscalEndPeriod' , '4:2011');
		obj.RunReportFromURLParams();
		obj.RunReportForDashBoard();
		obj.fiscalStartPeriod = '10:2011';
		obj.fiscalStartPeriod = '4:2011';
		obj.RunReport();		
	} 
	// end of test functions		
}