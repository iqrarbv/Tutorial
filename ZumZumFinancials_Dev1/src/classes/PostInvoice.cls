public class PostInvoice 
{
	public Sales_Invoice__c salesInvoiceInfo {get; set;}
	public boolean goBack {get;set;}
	public Id soId {get; set;}
	public PostInvoice( apexpages.Standardcontroller stdCon)
	{
		soId = apexpages.currentPage().getParameters().get('id'); 
		Apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , 'Are You Sure to Post this Invoice to Ledger?' , '' ) );
	}
	public void init()
	{
		try
		{
			//Id postId = apexpages.currentPage().getParameters().get('id');
			Sales_Invoice__c salesInvoiceInfo = [Select s.Account__r.Country__c ,  s.Type__c, s.Total_VAT__c, s.Total_Net__c, s.Total_Gross__c, s.Status__c, s.Settlement_Due_Days__c, s.Settlement_Discount__c, s.Sales_Order__c, s.SOP_Number__c, s.Quote_Number__c, s.OwnerId, s.Opportunity__c, s.Name, s.IsDeleted, s.Invoice_Template__c, s.Invoice_Due_Date__c, s.Invoice_Date__c, s.Id, s.Format_Type__c, s.Dimension__c, s.Account__c From Sales_Invoice__c s where Id = : soId];
			//soId = salesInvoiceInfo.Id;
			if(salesInvoiceInfo.Status__c == 'Posted')
			{
				goBack = true ;
				throw new customexception('This Invoice is already Posted to Ledger');
			}
			List<SILineItemWrapper> Lineitems  = new List<SILineItemWrapper>();
			for (Sales_Invoice_Line_Item__c soI: [Select s.VAT_Amount__c, s.Total_Net__c, s.Total_Gross__c, s.Tax_Rate__c, s.Tax_Rate__r.Tax_Rate__c ,
														 s.SystemModstamp, s.Sales_Invoice__c, s.Quantity__c, s.Product__c, 
														 s.Opportunity__c, s.Narrative__c, s.Name, s.Id, s.Amount__c 
														 From Sales_Invoice_Line_Item__c s
														 where s.Sales_Invoice__c = : salesInvoiceInfo.Id])
			{
				SILineItemWrapper tmpItem = new SILineItemWrapper(soI);
				tmpItem.serialNumber = Lineitems.size();
				tmpItem.taxRate = soI.Tax_Rate__r.Tax_Rate__c;
				Lineitems.add(tmpItem);
			}
			string AccountNumber = [select AccountNumber from Account where Id  = :salesInvoiceInfo.Account__c ].AccountNumber ;
			Ledger objLg = new Ledger();
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel();
			boolean isCloned = false;
			string DebitID = Functions.getNominalAccountId('Debtors Control Account');
			string CreditID = Functions.getNominalAccountId('Sales North');
			string TaxID = Functions.getNominalAccountId('Sales Tax Control Account');
			for(siLineItemWrapper tr: Lineitems)
			{				
				objLg.AddSalesInvoice(salesInvoiceInfo.Type__c , salesInvoiceInfo.Name, tr.salesInvoiceLineItems.Narrative__c , tr.strTaxRate ,  AccountNumber, tr.salesInvoiceLineItems.Total_Gross__c , tr.salesInvoiceLineItems.Total_Net__c , tr.salesInvoiceLineItems.VAT_Amount__c , tr.taxRate , salesInvoiceInfo.Account__c , functions.isEuropean(salesInvoiceInfo.Account__r.Country__c)==true?'E':'N' , salesInvoiceInfo.Invoice_Date__c , false);
				if(salesInvoiceInfo.Type__c == 'Sales Invoice')
				{				
					updateNominalBudget.AddDebit(DebitID , isCloned==true?(-tr.salesInvoiceLineItems.Total_Gross__c):tr.salesInvoiceLineItems.Total_Gross__c , string.valueof(salesInvoiceInfo.Invoice_Date__c)) ;					
					if(tr.salesInvoiceLineItems.VAT_Amount__c > 0)
					{
						updateNominalBudget.AddCredit(TaxID , isCloned==true?(-tr.salesInvoiceLineItems.VAT_Amount__c):tr.salesInvoiceLineItems.VAT_Amount__c , string.valueof(salesInvoiceInfo.Invoice_Date__c)) ;
					}
					updateNominalBudget.AddCredit(CreditID , isCloned==true?(-tr.salesInvoiceLineItems.Total_Net__c):tr.salesInvoiceLineItems.Total_Net__c  , string.valueof(salesInvoiceInfo.Invoice_Date__c)) ;
				}	
				else if (salesInvoiceInfo.Type__c == 'Sales Credit')
				{
					updateNominalBudget.AddCredit(DebitID , isCloned==true?(-tr.salesInvoiceLineItems.Total_Gross__c):tr.salesInvoiceLineItems.Total_Gross__c , string.valueof(salesInvoiceInfo.Invoice_Date__c)) ;
					if(tr.salesInvoiceLineItems.VAT_Amount__c > 0)
					{
						updateNominalBudget.AddDebit(TaxID , isCloned==true?(-tr.salesInvoiceLineItems.VAT_Amount__c):tr.salesInvoiceLineItems.VAT_Amount__c  , string.valueof(salesInvoiceInfo.Invoice_Date__c)) ;
					}
					updateNominalBudget.AddDebit(CreditID , isCloned==true?(-tr.salesInvoiceLineItems.Total_Net__c):tr.salesInvoiceLineItems.Total_Net__c  , string.valueof(salesInvoiceInfo.Invoice_Date__c)) ;
				}		
			}
			objLg.Save() ;
			updateNominalBudget.newSave();
			
			
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.confirm , 'Sales Invoice # ' + salesInvoiceInfo.Name + ' Sucessfully Posted to Ledger' ));
			salesInvoiceInfo.Status__c = 'Posted';
			update salesInvoiceInfo ;
			goBack = true ;
			PageReference pdf = page.SalesInvoicePDf;     
            pdf.getParameters().put('id',salesInvoiceInfo.Id);
            pdf.getParameters().put('directpdf','yes');   
            pdf.setRedirect(true);
            Blob b = pdf.getContent();
            Attachment att = new Attachment();
            att.Name = salesInvoiceInfo.Name + '.pdf' ;
            att.Body = b ;
            att.ParentId = salesInvoiceInfo.Id ;
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
		return new pagereference('/'+ soId);	
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
		sO.Type__c = 'Sales Invoice';
		
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
		PostInvoice obj = new PostInvoice(std);
		obj.init();
		obj.back();
		
		
		sO = new Sales_Invoice__c ();
		sO.Account__c = act.id;
		sO.Name = '00526';
		sO.Invoice_Date__c = Date.today();
		sO.Invoice_Due_Date__c = date.today().adddays(+7);
		sO.Invoice_Template__c = invTemplate.id ; 
		sO.Paid_Amount__c = 150 ; 
		sO.SOP_Number__c = '00526';
		sO.Status__c = 'Posted';
		sO.Type__c = 'Sales Invoice';
		
		insert sO ;
		Apexpages.currentPage().getParameters().put('id' ,sO.id );
		obj = new PostInvoice(std);
		try
		{
			obj.init();	
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage(), 'This Invoice is already Posted to Ledger');
		}
		
		
		sO = new Sales_Invoice__c ();
		sO.Account__c = act.id;
		sO.Name = '00526';
		sO.Invoice_Date__c = Date.today();
		sO.Invoice_Due_Date__c = date.today().adddays(+7);
		sO.Invoice_Template__c = invTemplate.id ; 
		sO.Paid_Amount__c = 150 ; 
		sO.SOP_Number__c = '00526';
		sO.Status__c = 'Pending';
		sO.Type__c = 'Sales Credit';
		
		insert sO ;
		Apexpages.currentPage().getParameters().put('id' ,sO.id );
		obj = new PostInvoice(std);
		obj.init();	
	}
	//Ending of test functions
}