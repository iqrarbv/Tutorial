public abstract class ReportControllerBase
{
	protected AggregateResult[] QuerySubCatTotals(string mainCategoryName, integer startMonth, integer startYear, integer endMonth, integer endYear)
	{
		//apexpages.addmessage(new apexpages.message(apexpages.severity.info,'mainCategoryName: '+mainCategoryName+' - startMonth: '+startMonth+'  - startYear: '+startYear+' - endMonth: '+endMonth+' - endYear: '+endYear));
		return [Select n.Nominal_Account__r.Sub_Category__c subCategoryId, n.Nominal_Account__r.Sub_Category__r.Name subCategoryName, Sum(n.Actuals_Debit__c) totalDebit, Sum(n.Actuals_Credit__c) totalCredit 
			    From Nominal_Budget__c n
			    Where n.Nominal_Account__r.Sub_Category__r.Nominal_Categories__r.Name=:mainCategoryName
			    and ((Month__c>=:startMonth and Year__c>=:startYear) or (Month__c<=:endMonth and Year__c<=:endYear))
			    Group by n.Nominal_Account__r.Sub_Category__c, n.Nominal_Account__r.Sub_Category__r.Name
			    Order by n.Nominal_Account__r.Sub_Category__r.Name];
	}
}