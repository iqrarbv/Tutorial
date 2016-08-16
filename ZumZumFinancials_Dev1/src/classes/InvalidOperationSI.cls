public class InvalidOperationSI 
{
	public Sales_Invoice__c sI {get; set;}
	public InvalidOperationSI( apexpages.Standardcontroller invalidOperation )
	{
	
	}
	public pagereference init()
	{
		try
		{
			Id editId = apexpages.currentPage().getParameters().get('id');
			sI = [select id , Name ,Status__c  from Sales_Invoice__c where Id IN(Select Sales_Invoice__c from Sales_Invoice_Line_Item__c where Id = :editId ) limit 1 ];
			return new pagereference('/apex/EditSalesInvoice?id='+sI.Id+'&retURL='+apexpages.currentPage().getParameters().get('retURL'));
		}
		catch(Exception e)
		{
			apexpages.addMessages(e);	
			return null ;
		}
	}
	
	//Starting of test functions
	
	private static testmethod void TESTSOPDF()
	{
		//preparing data for unit testing
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Account act = new Account(Name='ABC Company',Type='Customer' , Tax_Rate__c = tx.Id );
		insert act;
		
		Opportunity op = new Opportunity(AccountId = act.id , Name = 'Opportunity abc' , StageName = 'IIT' , Activity_Start__c = date.today(), Activity_End__c = date.today().addDays(5) , CloseDate = date.today().addDays(5));
		insert op;
		
		Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		//Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		//insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Tax_Rate__c = tx.Id, P_O__c = true, Name = 'Plumbering', Account_Code__c = 150);
		insert nm ;
		
		Product2 product = new Product2 (ProductCode = 'TST', Name = 'Test Product', IsActive = true , Description = 'I am writing Test Classes');
		insert product ;
		
		Pricebook2 proBook = [Select p.SystemModstamp, p.Name, p.LastModifiedDate, p.LastModifiedById, p.IsStandard, p.IsDeleted, p.IsActive, p.Id, p.Description, p.CreatedDate, p.CreatedById From Pricebook2 p where p.IsStandard = true limit 1] ;
		
		/*
		Pricebook2 proBook = new Pricebook2(Name = 'Testing', IsActive = true , Description = 'Testing Description' );
		insert proBook ;
		proBook = new Pricebook2(Name = 'Testing 2', IsActive = true , Description = 'Testing Description'  );
		insert proBook ;
		*/
		Invoice_Template__c invTemplate = new Invoice_Template__c( Font_Face__c = 'Arial' , Font_Size__c = '12' , 
																	   Footer_Text__c = 'ZumZum Financials Footer' , 
																	   Heading_Text__c = 'ZumZum Financials Heading' ,
																	   Margins_left_right_Inches__c = .5 ,
																	   Margins_top_bottom__c = .5 ,
																	   Name = 'ZumZum Sample Template');

		insert invTemplate ;																	   
		
		PricebookEntry priceBook  = new PricebookEntry( UnitPrice = 20 , Product2Id = product.Id , IsActive = true , Pricebook2Id = proBook.id  ) ;
		insert priceBook ;
		
		OpportunityLineItem opLineItem = new OpportunityLineItem(UnitPrice = 10 , Quantity = 1 , PricebookEntryId = priceBook.id , OpportunityId = op.id , Description = 'I am Testing SOP');
		insert opLineItem ;
		
		Sales_Invoice__c sO = new Sales_Invoice__c ();
		sO.Account__c = act.id;
		sO.Name = '00526';
		sO.Invoice_Date__c = Date.today();
		sO.Invoice_Due_Date__c = date.today().adddays(+7);
		sO.Invoice_Template__c = invTemplate.id ; 
		sO.Paid_Amount__c = 150 ; 
		sO.SOP_Number__c = '00526';
		sO.Status__c = 'Approved';
		sO.Type__c = 'Approved';
		
		insert sO ;
		
		Sales_Invoice_Line_Item__c LineItem = new Sales_Invoice_Line_Item__c();
		LineItem.Narrative__c = 'I am Testing';
		LineItem.Opportunity__c = op.id ; 
		LineItem.Quantity__c = 1 ; 
		LineItem.Tax_Rate__c = tx.id ;
		LineItem.Amount__c = 10 ; 
		LineItem.Total_Gross__c = 10 ;
		LineItem.VAT_Amount__c = 2 ; 
		LineItem.Total_Net__c = 12 ;
		LineItem.Product__c = product.id ;
		LineItem.Sales_Invoice__c = sO.Id ;
		
		insert LineItem ;
		
		
		ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(new Sales_Invoice__c());
		Apexpages.currentPage().getParameters().put('id' ,sO.id );
		InvalidOperationSI obj = new InvalidOperationSI(std);
		obj.init();
	}
	//Ending of test functions
}