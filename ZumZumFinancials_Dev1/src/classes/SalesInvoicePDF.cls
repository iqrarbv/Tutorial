public class SalesInvoicePDF 
{
	public Sales_Invoice__c salesInvoiceInfo {get; set;}
	public List<SILineItemWrapper> InvoiceDetailsList {get; set;}
	public boolean showpdf {get; set;}
	public string orderDate {get; set;}
	public Invoice_Template__c invoiceTmpl {get; set;}
	public string imageUrl {get; set;}
	public SalesInvoicePDF( apexpages.Standardcontroller stdCon )
	{
		init();
	}
	public void init()
	{
		try
		{
			Id viewId = apexpages.currentPage().getParameters().get('id');
			salesInvoiceInfo = [Select s.CreatedBy.Name , s.Type__c, s.Total_VAT__c, s.Total_Net__c, s.Total_Gross__c, s.Status__c, s.Settlement_Due_Days__c, s.Settlement_Discount__c, s.Sales_Order__c, s.SOP_Number__c, s.Quote_Number__c, s.OwnerId, s.Opportunity__c, s.Name, s.Invoice_Template__c, s.Invoice_Due_Date__c, s.Invoice_Date__c, s.Id, s.Format_Type__c, s.Dimension__c, s.Account__c From Sales_Invoice__c s where Id = :viewId ];
			if(apexpages.currentPage().getParameters().get('directpdf') == 'yes')
			{
				directPdf();
				return  ;	
			}
			//if (salesInvoiceInfo.Status__c != 'Approved' ||  salesInvoiceInfo.Status__c != 'Posted')
			system.debug('this is status: ' + salesInvoiceInfo.Status__c);
			if ( salesInvoiceInfo.Status__c == 'Rejected' || salesInvoiceInfo.Status__c == 'Pending' )
			{
				showPdf =false;
				throw new CustomException( salesInvoiceInfo.Name +' is not Approved, You Cannot View Sales Invoice Pdf ');
				return ;
			}
			if(salesInvoiceInfo.Invoice_Template__c == null )
				throw new CustomException('No Template Selected for this Invoice or Template Deleted');
			invoiceTmpl = [Select i.Footer_Text__c  , i.Name, i.Margins_top_bottom__c, i.Margins_left_right_Inches__c, i.Heading_Text__c, i.Font_Size__c, i.Font_Face__c From Invoice_Template__c i where i.Id = :salesInvoiceInfo.Invoice_Template__c];
			List<Attachment> att = [Select a.ParentId, a.Name, a.Id, a.Description, a.ContentType, a.BodyLength, a.Body From Attachment a where a.ParentId = : salesInvoiceInfo.Invoice_Template__c  limit 1];
			if(att.size() > 0 )
				imageUrl = 'https://'+apexpages.currentPage().getHeaders().get('host').substring(0 ,apexpages.currentPage().getHeaders().get('host').indexOf('.',2))+'.content.force.com/servlet/servlet.FileDownload?file='+string.valueof(att[0].id) ;
			else
				throw new CustomException('No Invoice Logo Found, Please Upload Logo for Invoice Template');	
			orderDate = salesInvoiceInfo.Invoice_Date__c.format();
			showpdf = true;
			InvoiceDetailsList = new list<SILineItemWrapper>();
			for (Sales_Invoice_Line_Item__c soI : [Select s.UID__c , s.Tax_Rate__r.Tax_Rate__c , s.VAT_Amount__c, s.Total_Net__c, s.Total_Gross__c, s.Tax_Rate__c, s.Sales_Invoice__c, s.Quantity__c, s.Product__c, s.Opportunity__c, s.Narrative__c, s.Name, s.Id, s.Amount__c From Sales_Invoice_Line_Item__c s where s.Sales_Invoice__c = :salesInvoiceInfo.Id ])
			{
				SILineItemWrapper tmpItem = new SILineItemWrapper(soI);
				tmpItem.serialNumber = InvoiceDetailsList.size();
				tmpItem.taxRate = soI.Tax_Rate__r.Tax_Rate__c;
				InvoiceDetailsList.add(tmpItem);
			}
		}
		catch (Exception e)
		{
			apexpages.addMessages(e);
		}
	}
	public void directPdf()
	{
		try
		{
			Id viewId = apexpages.currentPage().getParameters().get('id');
			salesInvoiceInfo = [Select s.CreatedBy.Name , s.Type__c, s.Total_VAT__c, s.Total_Net__c, s.Total_Gross__c, s.Status__c, s.Settlement_Due_Days__c, s.Settlement_Discount__c, s.Sales_Order__c, s.SOP_Number__c, s.Quote_Number__c, s.OwnerId, s.Opportunity__c, s.Name, s.Invoice_Template__c,  s.Invoice_Due_Date__c, s.Invoice_Date__c, s.Id, s.Format_Type__c, s.Dimension__c, s.Account__c From Sales_Invoice__c s where Id = :viewId ];
			if(salesInvoiceInfo.Invoice_Template__c == null )
				throw new CustomException('No Template Selected for this Invoice or Template Deleted');
			invoiceTmpl = [Select i.Footer_Text__c  , i.Name, i.Margins_top_bottom__c, i.Margins_left_right_Inches__c, i.Heading_Text__c, i.Font_Size__c, i.Font_Face__c From Invoice_Template__c i where i.Id = :salesInvoiceInfo.Invoice_Template__c];
			List<Attachment> att = [Select a.ParentId, a.Name, a.Id, a.Description, a.ContentType, a.BodyLength, a.Body From Attachment a where a.ParentId = : salesInvoiceInfo.Invoice_Template__c  limit 1];
			if(att.size() > 0 )
				imageUrl = 'https://'+apexpages.currentPage().getHeaders().get('host').substring(0 ,apexpages.currentPage().getHeaders().get('host').indexOf('.',2))+'.content.force.com/servlet/servlet.FileDownload?file='+string.valueof(att[0].id) ;
			else
				throw new CustomException('No Invoice Logo Found, Please Upload Logo for Invoice Template');
			salesInvoiceInfo.Status__c = 'Posted';
			orderDate = salesInvoiceInfo.Invoice_Date__c.format();
			showpdf = true;
			InvoiceDetailsList = new list<SILineItemWrapper>();
			for (Sales_Invoice_Line_Item__c soI : [Select s.UID__c , s.Tax_Rate__r.Tax_Rate__c , s.VAT_Amount__c, s.Total_Net__c, s.Total_Gross__c, s.Tax_Rate__c, s.Sales_Invoice__c, s.Quantity__c, s.Product__c, s.Opportunity__c, s.Narrative__c, s.Name, s.Id, s.Amount__c From Sales_Invoice_Line_Item__c s where s.Sales_Invoice__c = :salesInvoiceInfo.Id ])
			{
				SILineItemWrapper tmpItem = new SILineItemWrapper(soI);
				tmpItem.serialNumber = InvoiceDetailsList.size();
				tmpItem.taxRate = soI.Tax_Rate__r.Tax_Rate__c;
				InvoiceDetailsList.add(tmpItem);
			}
		}
		catch (Exception e)
		{
			apexpages.addMessages(e);
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
		SalesInvoicePDF obj = new SalesInvoicePDF(std);
		
		Apexpages.currentPage().getParameters().put('directpdf' , 'yes' );
		obj = new SalesInvoicePDF(std);
		
		
		sO = new Sales_Invoice__c ();
		sO.Account__c = act.id;
		sO.Name = '00526';
		sO.Invoice_Date__c = Date.today();
		sO.Invoice_Due_Date__c = date.today().adddays(+7);
		sO.Invoice_Template__c = invTemplate.id ; 
		sO.Paid_Amount__c = 150 ; 
		sO.SOP_Number__c = '00526';
		sO.Status__c = 'Pending';
		sO.Type__c = 'Pending';
		
		insert sO ;
		Apexpages.currentPage().getParameters().put('id' ,sO.id );
		try
		{
			obj = new SalesInvoicePDF(std);
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage(), sO.Name +' is not Approved, You Cannot View Sales Invoice Pdf ' );
		}
	}
	//Ending of test functions
}