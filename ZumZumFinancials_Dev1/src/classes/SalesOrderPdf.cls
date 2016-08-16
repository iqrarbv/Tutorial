public class SalesOrderPdf 
{
	public Sales_Order__c salesOrderInfo {get; set;}
	public List<Sales_Order_Line_Items__c> orderLineItems {get; set;} 
	public string UserName {get; set;}
	public string orderDate {get; set;}
	public decimal PoAmount {get;  set ; }
	public decimal totalTax {get; set;}
	public decimal wtAmount {get; set;}
	public boolean allowedit {get; set;}
	public boolean showPdf {get; set;}
	public List<SOLineItemWrapper> soLineItems {get; set;}
	public Invoice_Template__c invoiceTmpl {get; set;}
	public string imageUrl {get; set;}
	public SalesOrderPdf( apexpages.Standardcontroller salesOrderPdf )
	{
		init() ;	
	}
	public SalesOrderPdf( )
	{
		
	}
	public void init()
	{
		try
		{
			showPdf =false;
			Id purchaseOrderId = apexpages.currentPage().getParameters().get('id');
			salesOrderInfo  = [Select s.Total_Net__c  , s.CreatedBy.Name ,s.Account__r.Entity_Email__c , s.Account__r.Fax, s.Account__r.Phone , s.Total_VAT__c, s.Total_Gross__c, s.SystemModstamp, s.Supplier_Reference__c, s.Status__c, s.Placed_By__c, s.OwnerId, s.Order_Date__c, s.Order_By__c, s.Net_Amount__c, s.Name, s.Id, s.Customer_Order_No__c, s.CreatedDate, s.CreatedById, s.Approved_By__c, s.Account__r.Description, s.Account__r.BillingPostalCode, s.Account__r.BillingState, s.Account__r.BillingCity, s.Account__r.BillingStreet, s.Account__r.Name, s.Account__c From Sales_Order__c s where s.Id = :purchaseOrderId limit 1];
			if (salesOrderInfo.Status__c == 'Pending' || salesOrderInfo.Status__c == 'Submitted_For_Approval' || salesOrderInfo.Status__c == 'Rejected')
			{
				showPdf =false;
				throw new CustomException(salesOrderInfo.Name +' is not Approved, You Cannot View Sales Order Pdf ');
			}
			List<Invoice_Template__c> invTmpl = [Select i.Footer_Text__c  , i.Name, i.Margins_top_bottom__c, i.Margins_left_right_Inches__c, i.Heading_Text__c, i.Font_Size__c, i.Font_Face__c From Invoice_Template__c i where Is_Default__c = true];
			if(invTmpl.size() == 0)
				throw new CustomException('No Default Template Found , Please select Template as default');
			else
				invoiceTmpl = invTmpl[0] ;
			List<Attachment> att = [Select a.ParentId, a.Name, a.Id, a.Description, a.ContentType, a.BodyLength, a.Body From Attachment a where a.ParentId = : invoiceTmpl.id  limit 1];
			if(att.size() > 0 )
				imageUrl = 'https://'+apexpages.currentPage().getHeaders().get('host').substring(0 ,apexpages.currentPage().getHeaders().get('host').indexOf('.',2))+'.content.force.com/servlet/servlet.FileDownload?file='+string.valueof(att[0].id) ;
			else
				throw new CustomException('No Invoice Logo Found for Default Template, Please Upload Logo for Default Template');
			showPdf = true ;
			orderDate = salesOrderInfo.Order_Date__c.format();
			soLineItems = new List<SOLineItemWrapper>();			
			for (Sales_Order_Line_Items__c soI : [Select Nominal_Account__r.Name , Product__c  , UID__c  ,Tax_Rate__r.Tax_Rate__c , Total_Amount__c, VAT_Amount__c, Quantity__c, Sales_Order__c, Project__c, Project__r.Name , Nominal_Account__c, Narrative__c, Name, Id, Delete__c, Amount__c , Tax_Rate__c , Tax_Rate__r.Name , Serial_No__c From Sales_Order_Line_Items__c where Sales_Order__c = :salesOrderInfo.Id])
			{
				SOLineItemWrapper soW = new SOLineItemWrapper(soI);
				soW.taxselected = true ; 
				soW.taxrate = soI.Tax_Rate__r.Tax_Rate__c ;
				soLineItems.add(soW) ;	
			}
		}
		catch (exception e)
		{
			apexpages.addMessages(e);
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
		
		 
		Sales_Order__c sO = new Sales_Order__c ();
		sO.Account__c = act.id;
		sO.Name = '000';
		sO.Order_By__c = userinfo.getUserId();
		sO.Order_Date__c = date.today();
		sO.Status__c = 'Approved';
		
		insert sO ;
		
		Sales_Order_Line_Items__c LineItem = new Sales_Order_Line_Items__c();
		LineItem.Product__c = product.id ; 
		LineItem.Narrative__c = 'I am Testing';
		LineItem.Project__c = op.id ; 
		LineItem.Nominal_Account__c = nm.id ;
		LineItem.Quantity__c = 1 ; 
		LineItem.Serial_No__c = 1 ;
		LineItem.Tax_Rate__c = tx.id ;
		LineItem.Amount__c = 10 ; 
		LineItem.Total_Amount__c = 10 ;
		LineItem.VAT_Amount__c = 2 ; 
		LineItem.Total_Net__c = 12 ;
		LineItem.Product__c = product.id ; 
		LineItem.Sales_Order__c = sO.id ;
		
		insert LineItem ;
		
		ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(new Sales_Order__c());
		Apexpages.currentPage().getParameters().put('id' ,sO.id );
		SalesOrderPdf obj = new SalesOrderPdf(std);
		
		sO = new Sales_Order__c ();
		sO.Account__c = act.id;
		sO.Name = '000';
		sO.Order_By__c = userinfo.getUserId();
		sO.Order_Date__c = date.today();
		sO.Status__c = 'Pending';
		
		insert sO ;
		
		Apexpages.currentPage().getParameters().put('id' ,sO.id );
		try
		{
			obj = new SalesOrderPdf(std);
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage(), sO.Name +' is not Approved, You Cannot View Sales Order Pdf ');
		}
	}
}