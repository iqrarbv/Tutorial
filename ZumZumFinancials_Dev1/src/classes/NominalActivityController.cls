public class NominalActivityController {		
	public string NomId{get;set;}
	public Report rpt {get;set;}	
	public Nominal_Account__c Nominal{get;set;}	
	public NominalActivityController(ApexPages.StandardController std)
	{				
		NomId = ApexPages.currentPage().getParameters().get('Id');
		system.debug('id is : '+NomId);		
		if(NomId != null && NomId != '')
			Nominal = [select id, Name, Nominal_Code__c from Nominal_Account__c where id =: NomId];
		system.debug('object is : '+Nominal);							
	}
	public pagereference NominalAction()
	{		
		rpt = [select id , DeveloperName , Name from Report where DeveloperName = 'Nominal_Activity2'];
		system.debug('report is : '+rpt);
		return new pageReference('/'+rpt.id+'?pv0='+Nominal.Nominal_Code__c);
	}
	private static testMethod void NominalActivityController_Test()
	{
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
    	Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, Expense__c = true, Name = 'Plumbering', Account_Code__c = 1222);
		insert nm ;
		ApexPages.currentPage().getParameters().put('Id',nm.id);
		NominalActivityController nActvty = new NominalActivityController(new ApexPages.StandardController(new Nominal_Account__c()));
		nActvty.NominalAction();		
	} 
}