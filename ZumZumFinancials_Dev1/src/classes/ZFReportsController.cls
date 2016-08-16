public class ZFReportsController {
	public Report rpt;
	public ZFReportsController()
	{}
	public pagereference LedgerReport()
	{		
		rpt = [select id , DeveloperName , Name from Report where DeveloperName = 'Ledger1'];
		return new pageReference('/'+rpt.id);
	}
	public pagereference ActualsReport()
	{		
		rpt = [select id , DeveloperName , Name from Report where DeveloperName = 'Nominal_Monthly_Actuals1'];
		return new pageReference('/'+rpt.id);
	}
	public pagereference NominalBalancesReport()
	{		
		rpt = [select id , DeveloperName , Name from Report where DeveloperName = 'Nominal_Account_Balances'];
		return new pageReference('/'+rpt.id);
	}	
	public pagereference PurchaseTaxReport()
	{		
		rpt = [select id , DeveloperName , Name from Report where DeveloperName = 'Purchase_Tax1'];
		return new pageReference('/'+rpt.id);
	}
	public pagereference SalesTaxReport()
	{		
		rpt = [select id , DeveloperName , Name from Report where DeveloperName = 'Sales_Tax'];
		return new pageReference('/'+rpt.id);
	}
	private static testMethod void ZFReportsController_Test()
	{
		ZFReportsController rpts = new ZFReportsController();
		rpts.ActualsReport();
		rpts.LedgerReport();
		rpts.NominalBalancesReport();
		rpts.PurchaseTaxReport();
		rpts.SalesTaxReport();
	}
}