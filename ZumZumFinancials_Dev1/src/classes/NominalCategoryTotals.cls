public class NominalCategoryTotals
{
	public NominalCategoryTotals()
	{
		
	}
	
	public string Name {get; set;}
	public decimal PeriodTotal {get; set;}
	public decimal ToDateTotal {get; set;}
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
			return new CurrencyField__c(Amount__c=ToDateTotal);
		}
	}
}