public class NewAccountController
{
	public integer paymentDueDays {get;set;}
	public integer settlementDueDays {get;set;}
	public integer settlementDiscount {get;set;}
	public string acctname {get;set;}
	public NewAccountController(Apexpages.standardcontroller con)
	{
		paymentDueDays = 30;
		settlementDueDays = 30;
		settlementDiscount = 2;
		acctname = '0001';
	}
}