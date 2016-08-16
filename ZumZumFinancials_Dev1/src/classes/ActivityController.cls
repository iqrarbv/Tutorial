public class ActivityController {	
	public string AccttId{get;set;}	
	public Report rpt {get;set;}
	public Account Acctt{get;set;}	
	public ActivityController (ApexPages.StandardController std)
	{
		AccttId = ApexPages.currentPage().getParameters().get('Id');			
		Acctt = [select id, AccountNumber , Type, Name from Account where id =: AccttId];		
	}
	public pagereference activity()
	{		
		rpt = [select id , DeveloperName , Name from Report where DeveloperName = 'Account_Activity_1'];
		return new pageReference('/'+rpt.id+'?pv0='+Acctt.AccountNumber);
	}
	public pagereference customer()
	{				
		try
		{
		if(Acctt.Type == 'Customer')		
			return new pageReference('/apex/CstmrRpt?Cstmr='+Acctt.Name);
		else
			throw new CustomException('The type of this Account is not Customer');
		}
		catch(exception e)
		{
			Apexpages.addMessages(e);
			return null;
		}
	}		
	private static testMethod void ActivityController_Test()
	{
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
    	Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, Expense__c = true, Name = 'Plumbering', Account_Code__c = 1222);
		insert nm ;
		Account act = new Account(Name = 'ABC Company' , AccountNumber = 'ABC-16');
		insert act;
		
		ApexPages.currentPage().getParameters().put('Id',act.id);
		ActivityController aActvty = new ActivityController(new ApexPages.StandardController(act));
		aActvty.activity();
		act.Type = 'Supplier';
		aActvty.customer();
		act.Type = 'Customer';
		aActvty.customer();
	} 
}