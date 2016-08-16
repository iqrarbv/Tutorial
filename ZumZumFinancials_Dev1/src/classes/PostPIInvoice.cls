public class PostPIInvoice 
{
	public Purchase_Invoice__c POInvoiceInfo {get; set;}
	public list<POInvoiceWrapper> InvoiceDetailsList {get; set;}
	public boolean goBack {get;set;}
	public Id poId {get; set;}
	public PostPIInvoice( apexpages.Standardcontroller stdCon)
	{
		poId = apexpages.currentPage().getParameters().get('id');
		Apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , 'Are You Sure to Post this Invoice to Ledger?' , '' ) );
	}
	public void init()
	{
		try
		{
			//Id postId = apexpages.currentPage().getParameters().get('id');
			POInvoiceInfo = [Select p.Account__c , p.Account__r.Country__c , p.Type__c, p.Status__c, p.Settlement_due_days__c, p.Settlement_Discount__c, p.Purchase_Order__c, p.Payment_Status__c, p.POP_Number__c, p.Name, p.Invoice_Template__c, p.Invoice_Due_Date__c, p.Invoice_Date__c, p.Id, p.Dimension__c From Purchase_Invoice__c p where Id = :poId ];
			//poId = POInvoiceInfo.Id;
			if(POInvoiceInfo.Status__c == 'Posted')
			{
				goBack = true ;
				throw new customexception('This Invoice is already Posted to Ledger');
			}
			InvoiceDetailsList = new list<POInvoiceWrapper>();
			for (Purchase_Invoice_Line_Item__c poI : [Select p.Total_Net__c, p.Total_Gross__c, p.Tax_Rate__c, p.Tax_Rate__r.Tax_Rate__c,  p.Total_VAT__c, p.Serial_No__c, p.Ready_To_Pay__c, p.Quantity__c, p.Purchase_Invoice__c, p.Opportunity__c, p.Nominal_Account__c, p.Narrative__c, p.Name, p.Item_Received__c, p.Id, p.Amount__c From Purchase_Invoice_Line_Item__c p where p.Purchase_Invoice__c = :POInvoiceInfo.Id ])
			{
				POInvoiceWrapper tmpLineItem = new POInvoiceWrapper(poI);
				tmpLineItem.serialNumber = InvoiceDetailsList.size();
				tmpLineItem.taxRate = poI.Tax_Rate__r.Tax_Rate__c ;
				InvoiceDetailsList.add(tmpLineItem);
			}
			string AccountNumber = [select AccountNumber from Account where Id  = :POInvoiceInfo.Account__c limit 1 ].AccountNumber ;
			for(POInvoiceWrapper tr: InvoiceDetailsList)
			{
				Ledger objLg = new Ledger();
				objLg.AddPurchaseInvoice(POInvoiceInfo.Type__c , POInvoiceInfo.Name , tr.purchaseInvoiceLineItems.Narrative__c , tr.strTaxRate , AccountNumber, tr.purchaseInvoiceLineItems.Total_Gross__c , tr.purchaseInvoiceLineItems.Total_Net__c , tr.purchaseInvoiceLineItems.Total_VAT__c , tr.taxRate , POInvoiceInfo.Account__c , functions.isEuropean(POInvoiceInfo.Account__r.Country__c)==true?'E':'N' , POInvoiceInfo.Invoice_Date__c , false);
				objLg.Save() ;
			}
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.confirm , 'Purchase Invoice # ' + POInvoiceInfo.Name + ' Sucessfully Posted to Ledger' ));
			POInvoiceInfo.Status__c = 'Posted';
			update POInvoiceInfo ;
			goBack = true ;
			PageReference pdf = page.PurchaseInvoicePdf;     
            pdf.getParameters().put('id',POInvoiceInfo.Id);
            pdf.getParameters().put('directpdf','yes');   
            pdf.setRedirect(true);
            Blob b = pdf.getContent();
            Attachment att = new Attachment();
            att.Name = POInvoiceInfo.Name + '.pdf' ;
            att.Body = b ;
            att.ParentId = POInvoiceInfo.Id ;
            insert att ;
            //return new pagereference('/'+ att.id);	 
		}
		catch(exception e)
		{
			apexpages.addMessages(e);
		}
	}	
	public pagereference back()
	{
		return new pagereference('/'+ poId);	
	}
	private static testmethod void testPI()
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
		po.Type__c = 'Purchase Invoice';
		
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
		PostPIInvoice obj = new PostPIInvoice(std);
		obj.init();
	}
}