public class expenseSheetDetailWrapper 
{
	public Expense_Sheet_Detail__c expenseSheetDetail {get; set;}
	public integer Index {get; set;}
	public decimal taxRate  {get; set;}
	public expenseSheetDetailWrapper(Expense_Sheet_Detail__c expenseSheet)
	{
		expenseSheetDetail = expenseSheet ;
	}
	/*
	public string projectName 
	{
		get
		{
			string code  = '' ;
			Opportunity op  = AllProjects.get(expenseSheetDetail.Project__c);
			if (op != null)
			{
				if (op.Code__c != null)
					code = op.Code__c + ' - ' + op.Name;
				else
					code = op.Name;
				return code ;	
			}
			else if (!AllProjects.keyset().contains(expenseSheetDetail.Project__c) && expenseSheetDetail.Project__c !=null)
			{
				op = [select Id , Name , Code__c from Opportunity where id  =:expenseSheetDetail.Project__c ];	
				if (op.Code__c != null)
					code = op.Code__c + ' - ' + op.Name;
				else
					code = op.Name;
				return code ;	
			}
			else
				return code ;
		}
		set;
	}
	*/
	public string nominalAccount 
	{
		get
		{
			string code  = '' ;
			Nominal_Account__c nm = ALLNominalAccounts.get(expenseSheetDetail.Nominal_Account__c);
			if (nm !=null)
			{
				return nm.Name ;	
			}
			else if (expenseSheetDetail.Nominal_Account__c !=null )
			{
				nm = [select Id, Name from Nominal_Account__c  where id =:expenseSheetDetail.Nominal_Account__c ] ;
					return	nm.Name;
			}
			else
				return code ;
		}
		set;
	}
	public string totalTax
	{
		get
		{
			if (expenseSheetDetail.Total_VAT__c ==null || expenseSheetDetail.Total_VAT__c == 0)
			{
				return '0.00';
			}
			else
			{
				return string.valueof(expenseSheetDetail.Total_VAT__c.setScale(2));
			}
		}
	}
	public string totalAmount
	{
		get
		{
			if (expenseSheetDetail.Total_Gross__c ==null || expenseSheetDetail.Total_Gross__c == 0)
			{
				return '0.00';
			}
			else
			{
				return string.valueof(expenseSheetDetail.Total_Gross__c.setScale(2));
			}
		}
	}
	public string totalNetAmount
	{
		get
		{
			if (expenseSheetDetail.Total_Net__c ==null || expenseSheetDetail.Total_Net__c == 0)
			{
				return '0.00';
			}
			else
			{
				return string.valueof(expenseSheetDetail.Total_Net__c.setScale(2));
			}
		}
	}
	public static map<Id , Opportunity> AllProjects = new Map<Id, Opportunity>([select Id,name , (select Id,name from Opportunities__r where StageName  != 'Closed Won' and  StageName != 'Closed Lost' ) from Opportunity where StageName  != 'Closed Won' and  StageName != 'Closed Lost' ]);
	public static map<Id , Nominal_Account__c> ALLNominalAccounts = new Map<Id, Nominal_Account__c>([select Id, Name  from Nominal_Account__c where Expense__c = true]);
	public string strTaxRate
	{
		get
		{
			if (expenseSheetDetail.Tax_Rate__c != null )
			{
				if (AllTaxRateMap.keyset().contains(expenseSheetDetail.Tax_Rate__c))
					return  AllTaxRateMap.get(expenseSheetDetail.Tax_Rate__c).Name + ' - ' + string.valueof(AllTaxRateMap.get(expenseSheetDetail.Tax_Rate__c).Tax_Rate__c) + ' %'  ; // + ALLOpportunities.get(purchaseInvoiceLineItems.Opportunity__c).Name ;
				else if(!AllTaxRateMap.keyset().contains(expenseSheetDetail.Tax_Rate__c))
				{
					Tax_Rate__c nm = [Select Tax_Rate__c , Name From Tax_Rate__c where id =: expenseSheetDetail.Tax_Rate__c];
					return nm.Tax_Rate__c + ' - % ' ;// + nm.Name ;
				}
				else 
					return null ;		
			}
			else
				return null;	
		}
		set;
	}
	public static map<Id , Tax_Rate__c> AllTaxRateMap = new map<Id , Tax_Rate__c>([Select Tax_Rate__c , Name From Tax_Rate__c limit 10000]);
}