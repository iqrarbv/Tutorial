public class PurchaseInvoicePdf 
{
	public Purchase_Invoice__c POInvoiceInfo {get; set;}
	public list<POInvoiceWrapper> InvoiceDetailsList {get; set;}
	public boolean showpdf {get; set;}
	public string orderDate {get; set;}
	public Invoice_Template__c invoiceTmpl {get; set;}
	public string imageUrl {get; set;}
	public PurchaseInvoicePdf (apexpages.Standardcontroller stdCont)
	{
		init();
	}
	public void init()
	{
		try
		{
			Id viewId = apexpages.currentPage().getParameters().get('id');
			POInvoiceInfo = [Select p.Owner.Name , p.Total_Tax__c , p.Total_Gross__c , p.Total_Net__c  , p.Account__c , p.Type__c, p.Status__c, p.Settlement_due_days__c, p.Settlement_Discount__c, p.Purchase_Order__c, p.Payment_Status__c, p.POP_Number__c, p.Name, p.Invoice_Template__c, p.Invoice_Due_Date__c, p.Invoice_Date__c, p.Id, p.Dimension__c From Purchase_Invoice__c p where Id = :viewId ];
			if(apexpages.currentPage().getParameters().get('directpdf') == 'yes')
			{
				directPdf();
				return  ;	
			}
			if (POInvoiceInfo.Status__c == 'Pending' || POInvoiceInfo.Status__c == 'Rejected' || POInvoiceInfo.Status__c == 'Submitted_For_Approval' )
			{
				showPdf =false;
				throw new CustomException(POInvoiceInfo.Name +' is not Approved, You Cannot View Purchase Invoice Pdf ');
			}
			if(POInvoiceInfo.Invoice_Template__c == null )
				throw new CustomException('No Template Selected for this Invoice or Template Deleted');
			invoiceTmpl = [Select i.Footer_Text__c  , i.Name, i.Margins_top_bottom__c, i.Margins_left_right_Inches__c, i.Heading_Text__c, i.Font_Size__c, i.Font_Face__c From Invoice_Template__c i where i.Id = :POInvoiceInfo.Invoice_Template__c];
			List<Attachment> att = [Select a.ParentId, a.Name, a.Id, a.Description, a.ContentType, a.BodyLength, a.Body From Attachment a where a.ParentId = : POInvoiceInfo.Invoice_Template__c  limit 1];
			if(att.size() > 0 )
				imageUrl = 'https://'+apexpages.currentPage().getHeaders().get('host').substring(0 ,apexpages.currentPage().getHeaders().get('host').indexOf('.',2))+'.content.force.com/servlet/servlet.FileDownload?file='+string.valueof(att[0].id) ;
			else
				throw new CustomException('No Invoice Logo Found, Please Upload Logo for Invoice Template');	
			orderDate = POInvoiceInfo.Invoice_Date__c.format();
			showpdf = true;
			InvoiceDetailsList = new list<POInvoiceWrapper>();
			for (Purchase_Invoice_Line_Item__c poI : [Select p.UID__c , p.Total_Net__c, p.Total_Gross__c, p.Tax_Rate__c, p.Tax_Rate__r.Tax_Rate__c,  p.Total_VAT__c, p.Serial_No__c, p.Ready_To_Pay__c, p.Quantity__c, p.Purchase_Invoice__c, p.Opportunity__c, p.Nominal_Account__c, p.Narrative__c, p.Name, p.Item_Received__c, p.Id, p.Amount__c From Purchase_Invoice_Line_Item__c p where p.Purchase_Invoice__c = :POInvoiceInfo.Id ])
			{
				POInvoiceWrapper tmpLineItem = new POInvoiceWrapper(poI);
				tmpLineItem.serialNumber = InvoiceDetailsList.size();
				tmpLineItem.taxRate = poI.Tax_Rate__r.Tax_Rate__c ;
				InvoiceDetailsList.add(tmpLineItem);
			}
		}
		catch (Exception e)
		{
			apexpages.addMessages(e);
		}
	}
	public void directPdf()
	{
			Id viewId = apexpages.currentPage().getParameters().get('id');
			POInvoiceInfo = [Select p.Owner.Name , p.Total_Tax__c , p.Total_Gross__c , p.Total_Net__c  , p.Account__c , p.Type__c, p.Status__c, p.Settlement_due_days__c, p.Settlement_Discount__c, p.Purchase_Order__c, p.Payment_Status__c, p.POP_Number__c, p.Name, p.Invoice_Template__c, p.Invoice_Due_Date__c, p.Invoice_Date__c, p.Id, p.Dimension__c From Purchase_Invoice__c p where Id = :viewId ];
			if(POInvoiceInfo.Invoice_Template__c == null )
				throw new CustomException('No Template Selected for this Invoice or Template Deleted');
			invoiceTmpl = [Select i.Footer_Text__c  , i.Name, i.Margins_top_bottom__c, i.Margins_left_right_Inches__c, i.Heading_Text__c, i.Font_Size__c, i.Font_Face__c From Invoice_Template__c i where i.Id = :POInvoiceInfo.Invoice_Template__c];
			List<Attachment> att = [Select a.ParentId, a.Name, a.Id, a.Description, a.ContentType, a.BodyLength, a.Body From Attachment a where a.ParentId = : POInvoiceInfo.Invoice_Template__c  limit 1];
			if(att.size() > 0 )
				imageUrl = 'https://'+apexpages.currentPage().getHeaders().get('host').substring(0 ,apexpages.currentPage().getHeaders().get('host').indexOf('.',2))+'.content.force.com/servlet/servlet.FileDownload?file='+string.valueof(att[0].id) ;
			else
				throw new CustomException('No Invoice Logo Found, Please Upload Logo for Invoice Template');
			orderDate = POInvoiceInfo.Invoice_Date__c.format();
			POInvoiceInfo.Status__c = 'Posted';
			showpdf = true;
			InvoiceDetailsList = new list<POInvoiceWrapper>();
			for (Purchase_Invoice_Line_Item__c poI : [Select p.UID__c , p.Total_Net__c, p.Total_Gross__c, p.Tax_Rate__c, p.Tax_Rate__r.Tax_Rate__c,  p.Total_VAT__c, p.Serial_No__c, p.Ready_To_Pay__c, p.Quantity__c, p.Purchase_Invoice__c, p.Opportunity__c, p.Nominal_Account__c, p.Narrative__c, p.Name, p.Item_Received__c, p.Id, p.Amount__c From Purchase_Invoice_Line_Item__c p where p.Purchase_Invoice__c = :POInvoiceInfo.Id ])
			{
				POInvoiceWrapper tmpLineItem = new POInvoiceWrapper(poI);
				tmpLineItem.serialNumber = InvoiceDetailsList.size();
				tmpLineItem.taxRate = poI.Tax_Rate__r.Tax_Rate__c ;
				InvoiceDetailsList.add(tmpLineItem);
			}	
	}
	public static testmethod void Test_PDF()
	{
		//preparing data for unit testing
		Account act = new Account(Name='ABC Company',Type='Supplier' );
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Opportunity op = new Opportunity(Name = 'Opportunity abc' , StageName = 'IIT' , Activity_Start__c = date.today(), Activity_End__c = date.today().addDays(5) , CloseDate = date.today().addDays(5));
		insert op;
		Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		//Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		//insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Tax_Rate__c = tx.Id, P_O__c = true, Name = 'Plumbering', Account_Code__c = 150);
		insert nm ;
		
		Product2 product = new Product2 (ProductCode = 'TST', Name = 'Test Product', IsActive = true , Description = 'I am writing Test Classes');
		insert product ;
		
		Pricebook2 proBook = new Pricebook2(Name = 'Testing', IsActive = true , Description = 'Testing Description' );
		insert proBook ;
		proBook = new Pricebook2(Name = 'Testing 2', IsActive = true , Description = 'Testing Description ' );
		insert proBook ;
		
		Invoice_Template__c invTemplate = new Invoice_Template__c( Font_Face__c = 'Arial' , Font_Size__c = '12' , 
																	   Footer_Text__c = 'ZumZum Financials Footer' , 
																	   Heading_Text__c = 'ZumZum Financials Heading' ,
																	   Margins_left_right_Inches__c = .5 ,
																	   Margins_top_bottom__c = .5 ,
																	   Name = 'ZumZum Sample Template');

		insert invTemplate ;																	   
		
		//PricebookEntry priceBook  = new PricebookEntry( UnitPrice = 20 , Product2Id = product.Id , IsActive = true , Pricebook2Id = proBook.id , UseStandardPrice = true ) ;
		//insert priceBook ;
		
		 
		//List<Purchase_Order_Line_Items__c> poItems = new List<Purchase_Order_Line_Items__c>(); 
		
		Purchase_Invoice__c pO = new Purchase_Invoice__c ();
		po.Account__c = act.id;
		po.Name = '000041';
		po.Invoice_Date__c = Date.today();
		po.Invoice_Due_Date__c = date.today().adddays(+7);
		po.Invoice_Template__c = invTemplate.id ; 
		po.Paid_Amount__c = 150 ; 
		po.Payment_Status__c = 'Pending';
		po.POP_Number__c = '005421';
		po.Status__c = 'Approved';
		po.Type__c = 'Deaft';
		
		insert po;
		
		Purchase_Invoice_Line_Item__c LineItem = new Purchase_Invoice_Line_Item__c();
		//LineItem.Product__c = product.id ; 
		LineItem.Narrative__c = 'I am Testing';
		LineItem.Opportunity__c = op.id ; 
		LineItem.Nominal_Account__c = nm.id ;
		LineItem.Ready_To_Pay__c = true ;
		LineItem.Quantity__c = 1 ; 
		LineItem.Serial_No__c = 1 ;
		LineItem.Tax_Rate__c = tx.id ;
		LineItem.Amount__c = 10 ; 
		LineItem.Total_Amount__c = 10 ;
		LineItem.Total_VAT__c = 2 ; 
		LineItem.Total_Net__c = 12 ;
		LineItem.Total_Gross__c = 12 ;
		LineItem.Purchase_Invoice__c = po.id ;
		
		insert LineItem ;
		
		ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(po);
		apexpages.currentPage().getParameters().put('id' , po.id);
		PurchaseInvoicePdf obj = new PurchaseInvoicePdf(std);
		obj.directPdf();
	}
}