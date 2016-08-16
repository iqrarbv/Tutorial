public class InvalidOperationSO 
{
	public Sales_Order__c sO {get; set;}
	public InvalidOperationSO( apexpages.Standardcontroller invalidOperation )
	{
	
	}
	public pagereference init()
	{
		try
		{
			Id editId = apexpages.currentPage().getParameters().get('id');
			sO = [select id , Name ,Status__c  from Sales_Order__c where Id IN(Select Sales_Order__c from Sales_Order_Line_Items__c where Id = :editId ) limit 1 ];
			return new pagereference('/apex/EditSalesOrder?id='+sO.Id+'&retURL='+apexpages.currentPage().getParameters().get('retURL'));
		}
		catch(Exception e)
		{
			apexpages.addMessages(e);	
			return null ;
		}
	}
	public static TestMethod void testDeleteSalesOrder()
	{
		//preparing data for unit testing
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Account act = new Account(Name='ABC Company',Type='Customer' , Tax_Rate__c = tx.Id );
		insert act;
		
		Opportunity op = new Opportunity(AccountId = act.id , Name = 'Opportunity abc' , StageName = 'IIT' , Activity_Start__c = date.today(), Activity_End__c = date.today().addDays(5) , CloseDate = date.today().addDays(5));
		insert op;
		
		Sales_Order__c sO = new Sales_Order__c ();
		sO.Account__c = act.id;
		sO.Name = '000';
		sO.Order_By__c = userinfo.getUserId();
		sO.Order_Date__c = date.today();
		sO.Status__c = 'Approved';
		
		insert sO ;
		
		apexpages.currentPage().getParameters().put('id' , sO.Id);
		ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(sO);
		InvalidOperationSO obj = new  InvalidOperationSO(std); 
		obj.init();
	}
	
}