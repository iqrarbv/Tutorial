public class CustomAccountsController {
	public Control_Account__c cn {get;set;} 
	public CustomAccountsController(ApexPages.standardController std)
	{				
	}
	public PageReference init()
	{
		cn = [select id, Name from Control_Account__c where Name =: 'Control Accounts'];
		return new PageReference('/'+cn.id);
	}
	private static testMethod void CustomAccountsController_Test()
	{
		CustomAccountsController ca = new CustomAccountsController(new ApexPages.standardController(new Control_Account__c()));
		ca.init();
	}
}