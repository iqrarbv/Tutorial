public class InvalidOperationES 
{
	public Expense_Sheet__c eS {get; set;}
	public InvalidOperationES( apexpages.Standardcontroller invalidOperation )
	{
	
	}
	public pagereference init()
	{
		try
		{
			Id editId = apexpages.currentPage().getParameters().get('id');
			eS = [select id , Name ,Status__c  from Expense_Sheet__c where Id IN(Select Expense_Sheet__c from Expense_Sheet_Detail__c where Id = :editId ) limit 1 ];
			return new pagereference('/apex/Edit_Expense_Sheet?id='+eS.Id+'&retURL='+apexpages.currentPage().getParameters().get('retURL'));
		}
		catch(Exception e)
		{
			apexpages.addMessages(e);	
			return null ;
		}
	}
	
	private static testmethod void InvalidES()
	{
		Account act = new Account(Name='ABC Company',Type='Supplier');
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		//Tax_Rate__c tx = [select Id , Tax_Rate__c from Tax_Rate__c limit 1];
		Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, Expense__c = true, Name = 'Plumbering', Account_Code__c = 150);
		insert nm ;
		//Nominal_Account__c nm = [Select Id , Sub_Category__c, Tax_Rate__c from Nominal_Account__c where  Expense__c = true limit 1 ];	
		Opportunity op = new Opportunity(Name = 'Opportunity abc' , StageName = 'IIT' , Activity_Start__c = date.today(), Activity_End__c = date.today().addDays(5) , CloseDate = date.today().addDays(5));
		insert op;
		Opportunity subOp = new Opportunity(Name = 'Opportunity abc' , StageName = 'IIT' , Activity_Start__c = date.today(), Activity_End__c = date.today().addDays(5) , Sub_Project__c =op.Id , CloseDate = date.today().addDays(5));
		insert subOp;
		Expense_Sheet__c esinfo = new Expense_Sheet__c();
		esinfo.Month_Number__c = date.today().month();
		esinfo.Year__c = date.today().year();
		insert esinfo;
		apexpages.currentPage().getParameters().put('id' , esinfo.Id);
		ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(esinfo);
		InvalidOperationES obj = new  InvalidOperationES(std); 
		obj.init();
	}
}