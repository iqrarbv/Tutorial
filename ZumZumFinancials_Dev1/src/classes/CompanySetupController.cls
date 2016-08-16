public class CompanySetupController {
	public Company_Setup__c cn {get;set;}
	public string cnId  {get;set;}
	public CompanySetupController(ApexPages.standardcontroller std)
	{
		cnId  = [select id from Company_Setup__c limit 1].id;
	}
	public PageReference init()
	{
		cn = [select id,Name, Account_Lock_Date__c, Company_Registration_Number__c,Entity_Type__c, VatMethod__c, VAT_Number__c from Company_Setup__c where id=: cnId ];
		return new PageReference('/'+cn.id);
	}	
	private static testMethod void CompanySetupController_Test()
	{
		CompanySetupController cs = new CompanySetupController(new ApexPages.standardController(new Company_Setup__c()));
		cs.init();
	} 
}