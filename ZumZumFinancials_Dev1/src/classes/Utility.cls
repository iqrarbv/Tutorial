public class Utility
{
	public static string SalesMainCategory
	{
		get
		{
			return 'Sales';
		}
	}
	
	public static string PurchasesMainCategory
	{
		get
		{
			return 'Purchases';
		}
	}
	
	public static string DirectExpensesMainCategory
	{
		get
		{
			return 'Direct Expenses';
		}
	}
	
	public static string OverheadsMainCategory
	{
		get
		{
			return 'Overheads';
		}
	}
	
	public static string CurrentAssetsMainCategory
	{
		get
		{
			return 'Current Assets';
		}
	}
	
	public static string FixedAssetsMainCategory
	{
		get
		{
			return 'Fixed Assets';
		}
	}
	
	public static string CurrentLiabilitiesMainCategory
	{
		get
		{
			return 'Current Liabilities';
		}
	}
	
	public static string LongTermLiabilitiesMainCategory
	{
		get
		{
			return 'Long Term Liabilities';
		}
	}
	
	public static string CapitalAndReservesMainCategory
	{
		get
		{
			return 'Capital & Reserves';
		}
	}
	
	public static string OrganisationCurrencySymbol
	{
		get
		{
			if(Organisation_Currency__c.getInstance('Default_Currency')==null)
				return null;
			return Organisation_Currency__c.getInstance('Default_Currency').Currency_Symbol__c;	
		}
	}
		
	public static List<SelectOption> GetFiscalMonthsList()
	{
		integer startMonth = [Select o.FiscalYearStartMonth From Organization o].FiscalYearStartMonth ;
				
		integer month = DateTime.Now().Month();
		integer year = DateTime.Now().Year();
		
		integer startYear = month > startMonth ? year : year - 1;
		DateTime endDate = datetime.newInstance(startYear,startMonth,1).AddMonths(11);
		
		integer endMonth = endDate.Month();
		integer endYear = endDate.Year(); 
		
		List<SelectOption> MonthsList = new List<SelectOption>();
		
		integer sMonth = startMonth;
		integer sYear = startYear;
		for(integer j=1;j<=12;j++)
		{
			MonthsList.add(new SelectOption(sMonth+':'+sYear,GetMonthName(sMonth)+', '+sYear));
			if(sMonth+1>12)
			{
				sMonth = 1;
				sYear++;						
			}		
			else
			{
				sMonth++;
			}
		}
		return MonthsList;
	}
	
	public static string GetCurrentMonthYearForSelectList()
	{
		integer month = DateTime.Now().Month();
		integer year = DateTime.Now().Year();
		return month+':'+year;
	}
	
	public static string GetMonthName(integer month)
	{
		DateTime dt = DateTime.newInstance(1900, month, 1);		
		return dt.Format('MMMM');
 	}	
 	
 	public static Id GetDefaultBankId()
 	{
 		Id BankId;
 		List<Control_Account__c> ca = [Select c.Default_Bank__r.Account_Code__c, c.Default_Bank__r.Name, c.Default_Bank__r.Id, c.Default_Bank__c From Control_Account__c c limit 1];
		if(ca.size()>0)
		{
			List<Bank_Account__c> banklist = [select Id from Bank_Account__c where Nominal_Account__c =: ca[0].Default_Bank__c limit 1];
			if(bankList.size()>0)
			{
				BankId = bankList[0].Id;
			}	
		}
		return BankId;
 	}
 	
 	public static Control_Account__c GetControlAccount()
 	{
 		List<Control_Account__c> ca = [Select c.VAT_on_Sales__r.Nominal_Code__c, c.VAT_on_Sales__r.Sub_Category__c, c.VAT_on_Sales__r.Sub_Category__r.Name, c.VAT_on_Sales__r.Name, c.VAT_on_Sales__r.Id, c.VAT_on_Sales__c, c.VAT_on_Purchases__r.Nominal_Code__c, c.VAT_on_Purchases__r.Sub_Category__c, c.VAT_on_Purchases__r.Sub_Category__r.Name, c.VAT_on_Purchases__r.Name, c.VAT_on_Purchases__r.Id, c.VAT_on_Purchases__c, c.Default_Bank__r.Balance__c, c.Default_Bank__r.Nominal_Code__c, c.Default_Bank__r.Sub_Category__c, c.Default_Bank__r.Sub_Category__r.Name, c.Default_Bank__r.Name, c.Default_Bank__r.Id, c.Default_Bank__c From Control_Account__c c limit 1];
		if(ca.size()==0)
		{
			throw new customException('No control account record cound.');		
		}
		return ca[0];
 	}
 	
 	public static date[] GetFiscalStartEndDates()
 	{
 		integer cMonth = date.today().month();
 		integer cYear = date.today().year();
 		integer fiscalMonth = [Select o.FiscalYearStartMonth From Organization o].FiscalYearStartMonth ;
		integer sYear =  fiscalMonth<=cMonth?cYear:(cYear-1); //=IF(E13<=B13,B14,B14-1) //E14
        integer eMonth = (fiscalMonth+11)<=12?(fiscalMonth+11):((fiscalMonth+11)-12); //IF((E13+11)<=12,(E13+11),(E13+11)-12) // H13
        integer eYear = (eMonth-fiscalMonth)>0?sYear:(sYear+1); //IF((H13-E13)>0,E14,E14+1) // H14
        
        date[] dates = new date[2];
        dates[0] = date.newInstance(sYear, fiscalMonth, 1);
        dates[1] = date.newInstance(eYear, eMonth, 1);
        return dates;
 	}
}