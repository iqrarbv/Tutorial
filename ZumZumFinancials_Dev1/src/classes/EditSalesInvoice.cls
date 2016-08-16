public class EditSalesInvoice 
{
	public Sales_Invoice__c salesInvoiceInfo {get; set;}
	public List<SILineItemWrapper> Lineitems {get; set;} 
	public SILineItemWrapper siItem {get; set;}
	//public Purchase_Order_Line_Items__c siItem {get; set;}
	public decimal taxrate {get; set;}
	public decimal totalrate {get; set;}
	private List<Tax_Rate__c> TaxRates;
	private List<Opportunity> AllOpportunities {get; set;}
	private List<Product2> AllProducts ; 
	public decimal tax_rate {get; set; }
	public decimal Defaulttaxrate {get; set; }
	public Map<Id , decimal> taxRateMap  { get; set; }
	public Map<Id,Id> NominalAccountstoTaxRate {get; set; }
	public Map<Id,Decimal> ProductPrices {get; set; }
	public string currencySymbol {get; set;}
	public decimal PoAmount {get; set;}
	public decimal totalTax {get; set;}
	public decimal wtAmount {get; set;}
	public List<Invoice_Template__c> InvoiceTmplt {get; set;}	
	public List<PricebookEntry> priceBook {get; set;}
	public boolean showOpportunityInfo {get; set;}
	public boolean allowedit {get; set;}
	public boolean ecsRates {get;set;}
	public Id editId {get; set;}
	public Id defaultTax {get; set;}
	public EditSalesInvoice ( apexpages.Standardcontroller invoiceController ) 
	{
		salesInvoiceInfo = new Sales_Invoice__c();
		Lineitems  = new List<SILineItemWrapper>();
		init();
	}
	public void init()
	{
		try
		{
			tax_rate = 0.00 ;
			PoAmount = 0.00 ;
			totalTax = 0.00 ;
			wtAmount = 0.00 ;
			currencySymbol = Functions.getOrganisationCurrency('CurrencySymbol') ;
			editId = apexpages.currentPage().getParameters().get('id');
			salesInvoiceInfo = [Select s.Account__r.Tax_Rate__c , s.Account__r.Tax_Rate__r.Tax_Rate__c  ,s.Account__r.Country__c , s.Type__c, s.Total_VAT__c, s.Total_Net__c, s.Total_Gross__c, s.Status__c, s.Settlement_Due_Days__c, s.Settlement_Discount__c, s.Sales_Order__c, s.SOP_Number__c, s.Quote_Number__c, s.OwnerId, s.Opportunity__c, s.Name, s.IsDeleted, s.Invoice_Template__c, s.Invoice_Due_Date__c, s.Invoice_Date__c, s.Id, s.Format_Type__c, s.Dimension__c, s.Account__c From Sales_Invoice__c s where Id = : editId];
			ecsRates = functions.isEuropean(salesInvoiceInfo.Account__r.Country__c);
			allowedit = true ; 
			if ( salesInvoiceInfo.ownerid != userinfo.getUserId())
			{
				allowEdit = false;
				throw new CustomException('You are not authorized to change contents of this Invoice' );
				return ;	
			}
			if( salesInvoiceInfo.Status__c == 'Pending' || salesInvoiceInfo.Status__c == 'Rejected' )
			{
				priceBook = [Select p.UnitPrice, p.ProductCode, p.Product2.IsActive, p.Product2.ProductCode, p.Product2.Name, p.Product2.Id, p.Product2Id From PricebookEntry p where p.Product2.IsActive = true and p.Pricebook2.IsStandard = true order by p.Product2.ProductCode] ;
				TaxRates = [select id , Name , Tax_Rate__c  from Tax_Rate__c Order By Name Asc limit 1000 ] ;
				AllOpportunities = [select Id , Name  from Opportunity  where Sub_Project__c = null and StageName  != 'Closed Won' and  StageName != 'Closed Lost' Order By Name Asc limit 1000 ] ; 
				InvoiceTmplt = [Select Name from Invoice_Template__c limit 1000];
				siItem = new SILineItemWrapper(new Sales_Invoice_Line_Item__c());
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
				initValues();
				/*
				if (apexpages.currentPage().getParameters().keyset().contains('soid'))
					salesInvoiceInfo.SOP_Number__c = [select Name from Sales_Order__c where Id =: apexpages.currentPage().getParameters().get('soid') ].Name;
				if (apexpages.currentPage().getParameters().keyset().contains('qid'))
					salesInvoiceInfo.Quote_Number__c = [Select q.QuoteNumber From Quote q where id = : apexpages.currentPage().getParameters().get('qid')].QuoteNumber ;
				if (apexpages.currentPage().getParameters().keyset().contains('opid'))
				{
					Id opID =  apexpages.currentPage().getParameters().get('opid');
					salesInvoiceInfo.Opportunity__c = [select Id from Opportunity where Id =:opID ].Id	;
				}
				*/
				salesInvoiceInfo.Invoice_Date__c = date.today();
				salesInvoiceInfo.Invoice_Due_Date__c = date.today();
				taxRateMap = new Map<Id , decimal>() ;
				ProductPrices = new Map<Id,Decimal>();
				list<Tax_Rate__c> taxratelist = [select Id , is_Default__c ,Tax_Rate__c from Tax_Rate__c]; 
				for (Tax_Rate__c ratelist: taxratelist)
				{
					taxRateMap.put(ratelist.Id , ratelist.Tax_Rate__c)	;
					if(ratelist.is_default__c == true)
					{	
						defaultTax = ratelist.Id ;
						Defaulttaxrate = ratelist.Tax_Rate__c ; 
					}
				}
				if (defaultTax == null)
					throw new CustomException('No Default Tax Account Found, Please enter Default Tax from Setup tab');
				for (PricebookEntry pb: priceBook  )
				{
					ProductPrices.put(pb.Product2Id , pb.UnitPrice);	
				}
				if (salesInvoiceInfo.Account__r.Tax_Rate__c != null )
				{	
					siItem.salesInvoiceLineItems.Tax_Rate__c = salesInvoiceInfo.Account__r.Tax_Rate__c ;
					tax_rate = salesInvoiceInfo.Account__r.Tax_Rate__r.Tax_Rate__c ;
				}
				else
				{	
					siItem.salesInvoiceLineItems.Tax_Rate__c = defaultTax ;
					tax_rate = Defaulttaxrate ;
				}	
				calculateTotals();	
			}
			else
			{
				allowEdit = false;
				throw new CustomException('Sales Invoice Status is :' + salesInvoiceInfo.Status__c + ' You can\'t Change its content ' );
				return ;	
			}
		}
		catch(exception e)	
		{
			apexpages.addMessages(e);
		}
	}
	public void DueDate()
	{
		if(salesInvoiceInfo.Account__c !=null)
		{
			Account cusAccountInfo = [select Id , Tax_Rate__c , Tax_Rate__r.Tax_Rate__c, Type , Settlement_Due_Days__c from Account where id = :salesInvoiceInfo.Account__c limit 1];
			if(cusAccountInfo.Settlement_Due_Days__c == null)
				throw new CustomException('Please Enter Invoice Settlement Date for this account');
			else
				salesInvoiceInfo.Invoice_Due_Date__c = date.newinstance(salesInvoiceInfo.Invoice_Date__c.Year(),
															salesInvoiceInfo.Invoice_Date__c.Month(),
															integer.valueof(salesInvoiceInfo.Invoice_Date__c.day()+cusAccountInfo.Settlement_Due_Days__c) ) ;
			if(cusAccountInfo.Tax_Rate__c != null)
				tax_rate = cusAccountInfo.Tax_Rate__r.Tax_Rate__c ;		
			else
				tax_rate = 	Defaulttaxrate ;		
		}
	}
	public pagereference back()
	{
		return new pagereference ('/' +  editId ) ;	
	}   
	public List<SelectOption> getALLProducts()
	{
		List<SelectOption> Products = new List<SelectOption> ();
		Products.add(new SelectOption('', 'Select Product'));
		if (priceBook.size() > 0)
		{
			string code  = '' ;
			for (PricebookEntry pr : priceBook )  
			{
				if (pr.Product2.ProductCode != null)
					code = pr.Product2.ProductCode + ' - ' + pr.Product2.Name;
				else
					code = pr.Product2.Name ; 
				Products.add(new SelectOption(pr.Product2Id , code ));
			}
		}
		else 
			throw new customexception('No Products Found, Please Enter Product to continue');
		return Products; 
	}
	public List<selectoption> getAllTaxes()
	{
		List<selectoption> AllTaxes = new List<selectoption> ();
		AllTaxes.add(new selectoption('', 'Select Tax Rate')) ;
		//if(ecsRates)
			//TaxRates = [select id , Name , Tax_Rate__c  from Tax_Rate__c where is_EC_Sales__c = true Order By Name Asc limit 1000 ] ;
		TaxRates = [select id , Name , Tax_Rate__c  from Tax_Rate__c Order By Name Asc limit 100] ;
		if (TaxRates.size() > 0)
		{
			for (Tax_Rate__c tx : TaxRates)
			{
				AllTaxes.add(new selectoption(tx.Id, tx.Tax_Rate__c + '% ' +tx.Name ));
			}
		}
		else 
			throw new customexception('Tax Rate Not Entered, Please Enter Tax Rate for your Organisation');
		return AllTaxes ; 
	}
	/*
	public list<selectoption> getAllProjects()
	{
		list<selectoption> AllProjects = new list<selectoption>();
		AllProjects.add(new selectoption('', 'Select Project')) ;
		if (AllOpportunities.size() > 0 )
		{
			string code  = '' ;
			for (Opportunity op : AllOpportunities)
			{
				if (op.Code__c != null)
					code = op.Code__c + ' - ' + op.Name;
				else
					code = op.Name;
				AllProjects.add(new selectoption(op.Id , code)) ;	
			}
		}
		else 
			throw new customexception('No project Exist , Please Enter Projects');
		return AllProjects;
	}
	*/
	public list<selectoption> getAllTemplates()
	{
		list<selectoption> AllTemplates = new list<selectoption>();
		AllTemplates.add(new selectoption('', 'Select Template')) ;
		if (InvoiceTmplt.size() > 0 )
		{
			for (Invoice_Template__c tp : InvoiceTmplt)
			{
				AllTemplates.add(new selectoption(tp.Id , tp.Name)) ;	
			}
		}
		else 
			throw new customexception('No Template Exist , Please Enter Templates');
		return AllTemplates;	
	}
	public void initValues()
	{
		siItem.salesInvoiceLineItems.Narrative__c = 'Item Name' ;
		siItem.salesInvoiceLineItems.Quantity__c  = 0 ; 
		siItem.salesInvoiceLineItems.Amount__c  = 0.00 ;
		siItem.salesInvoiceLineItems.VAT_Amount__c = 0.00 ;
		siItem.salesInvoiceLineItems.Total_Gross__c = 0.00 ;	
	}
	public void addproductnewproductitem()
	{
		try
		{
			SalesInvoiceModel.validateLineDetails(siItem);
			selectedTax();
			Sales_Invoice_Line_Item__c tmpItem = new Sales_Invoice_Line_Item__c();	
			tmpItem.Product__c = siItem.salesInvoiceLineItems.Product__c ;
			tmpItem.Narrative__c  = siItem.salesInvoiceLineItems.Narrative__c ; 
			tmpItem.Quantity__c  = siItem.salesInvoiceLineItems.Quantity__c ; 
			tmpItem.Amount__c  = siItem.salesInvoiceLineItems.Amount__c ;
			tmpItem.Tax_Rate__c   = siItem.salesInvoiceLineItems.Tax_Rate__c ;
			tmpItem.VAT_Amount__c  = siItem.salesInvoiceLineItems.VAT_Amount__c.setScale(2) ;
			tmpItem.Total_Net__c = siItem.salesInvoiceLineItems.Total_Net__c.setScale(2) ;
			tmpItem.Total_Gross__c   = siItem.salesInvoiceLineItems.Total_Gross__c.setScale(2) ;
			tmpItem.Opportunity__c  = siItem.salesInvoiceLineItems.Opportunity__c;
			SILineItemWrapper tmwrap = new SILineItemWrapper(tmpItem);
			tmwrap.serialNumber = Lineitems.size();
			tmwrap.taxRate = tax_rate ;
			Lineitems.add(tmwrap);
			clearValues();
			calculateTotals();
		}
		catch(exception e)
		{
			apexpages.addMessages(e);
		}
	}
	public void getProductPrice()
	{
		if(ProductPrices.keyset().contains(siItem.salesInvoiceLineItems.Product__c))
			siItem.salesInvoiceLineItems.Amount__c = ProductPrices.get(siItem.salesInvoiceLineItems.Product__c);
		else
			siItem.salesInvoiceLineItems.Amount__c = [Select p.UnitPrice , p.Product2Id From PricebookEntry p where p.Product2Id = : siItem.salesInvoiceLineItems.Product__c].UnitPrice ;
	}
	public void deletLineItem()
	{
		string index = string.valueof(decimal.valueof(apexpages.currentPage().getParameters().get('deleteId'))) ;
		Lineitems.remove(Functions.getListIndex(index) );
		removeListItems();
		calculateTotals();
	}
	public void editLineItem()
	{
		string sIndex = string.valueof(decimal.valueof(apexpages.currentPage().getParameters().get('editId'))) ;
		integer index = Functions.getListIndex(sIndex) ;
		siItem.salesInvoiceLineItems.Product__c = Lineitems[index].salesInvoiceLineItems.Product__c ;
		siItem.salesInvoiceLineItems.Narrative__c  = Lineitems[index].salesInvoiceLineItems.Narrative__c ; 
		siItem.salesInvoiceLineItems.Quantity__c  = Lineitems[index].salesInvoiceLineItems.Quantity__c ; 
		siItem.salesInvoiceLineItems.Amount__c  = Lineitems[index].salesInvoiceLineItems.Amount__c ;
		siItem.salesInvoiceLineItems.Tax_Rate__c   = Lineitems[index].salesInvoiceLineItems.Tax_Rate__c ;
		siItem.salesInvoiceLineItems.VAT_Amount__c  = Lineitems[index].salesInvoiceLineItems.VAT_Amount__c ;
		siItem.salesInvoiceLineItems.Total_Gross__c   = Lineitems[index].salesInvoiceLineItems.Total_Gross__c ;
		siItem.salesInvoiceLineItems.Total_Net__c   = Lineitems[index].salesInvoiceLineItems.Total_Net__c ;
		siItem.salesInvoiceLineItems.Opportunity__c  = Lineitems[index].salesInvoiceLineItems.Opportunity__c;
		tax_rate = Lineitems[index].taxRate;
		Lineitems.remove(index);
		removeListItems();
		calculateTotals();
	}
	public void removeListItems()
	{
		List<SILineItemWrapper> titems = new List<SILineItemWrapper>();
		for (SILineItemWrapper po : Lineitems)
		{
			po.serialNumber = titems.size();// + 1;
			titems.add(po);
		}
		Lineitems = titems ;
	}
	public void selectedTax()
	{
	 	if ( siItem.salesInvoiceLineItems.Tax_Rate__c != null )
	 	{
	 		if (taxRateMap.keyset().contains(siItem.salesInvoiceLineItems.Tax_Rate__c))
	 			tax_rate = taxRateMap.get(siItem.salesInvoiceLineItems.Tax_Rate__c) ;
	 		else
	 			tax_rate = [Select Tax_Rate__c from Tax_Rate__c where Id = : siItem.salesInvoiceLineItems.Tax_Rate__c].Tax_Rate__c;
	 		decimal taxamount  = siItem.salesInvoiceLineItems.Amount__c.divide(100,3,system.roundingmode.up);
			taxamount = taxamount * tax_rate ;
			siItem.salesInvoiceLineItems.VAT_Amount__c = taxamount * siItem.salesInvoiceLineItems.Quantity__c ; 
			siItem.salesInvoiceLineItems.Total_Net__c = (siItem.salesInvoiceLineItems.Amount__c * siItem.salesInvoiceLineItems.Quantity__c ) ;
			siItem.salesInvoiceLineItems.Total_Gross__c = (siItem.salesInvoiceLineItems.Amount__c * siItem.salesInvoiceLineItems.Quantity__c ) +  siItem.salesInvoiceLineItems.VAT_Amount__c; 
		}
	}
	public void clearValues()
	{
		siItem.salesInvoiceLineItems.Narrative__c = 'Item Name' ;
		siItem.salesInvoiceLineItems.Quantity__c  = 0 ; 
		siItem.salesInvoiceLineItems.Amount__c  = 0.00 ;
		siItem.salesInvoiceLineItems.VAT_Amount__c = 0.00 ;
		siItem.salesInvoiceLineItems.Total_Gross__c = 0.00 ;
		siItem.salesInvoiceLineItems.Total_Net__c = 0.00 ;		
		siItem.salesInvoiceLineItems.Opportunity__c = null ;
		siItem.salesInvoiceLineItems.Product__c = null ;
		//siItem.salesInvoiceLineItems.Tax_Rate__c = salesInvoiceInfo.Account__r.Tax_Rate__c ;
		if (salesInvoiceInfo.Account__r.Tax_Rate__c != null )
			{	
				siItem.salesInvoiceLineItems.Tax_Rate__c = salesInvoiceInfo.Account__r.Tax_Rate__c ;
				tax_rate = salesInvoiceInfo.Account__r.Tax_Rate__r.Tax_Rate__c ; 
			}
			else
			{	
				siItem.salesInvoiceLineItems.Tax_Rate__c = defaultTax ;
				tax_rate = Defaulttaxrate ;
			}
	}
	public void calculateTotals()
	{
		PoAmount = SalesInvoiceModel.getTotalAmount(Lineitems) ; //getTotalAmount() ;
	 	totalTax = SalesInvoiceModel.getToTalTax(Lineitems) ; //getToTalTax() ;
	 	wtAmount = SalesInvoiceModel.getTotalAmountExcludingTax(Lineitems) ; //getTotalAmountExcludingTax() ;
	}
	public PageReference savePO()
	{
		Savepoint sp = Database.setsavepoint(); 
		try
		{
			SalesInvoiceModel saveSIOrder = new SalesInvoiceModel(salesInvoiceInfo);
			saveSIOrder.saveOrder(Lineitems ,'UPDATE' );
			return new PageReference('/'+ saveSIOrder.si.Id);
		}
		catch(exception e)
		{
			Database.rollback(sp);
			apexpages.addMessages(e);
			return null ;
		}
	}	
	
	
	// Staring of test functions
	private static testmethod void TestEditSalesInvoice()
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
		sO.Status__c = 'Pending';
		sO.Type__c = 'Pending';
		
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
		EditSalesInvoice obj = new EditSalesInvoice(std);
		
		obj.salesInvoiceInfo = sO ;
		obj.siItem.salesInvoiceLineItems = LineItem ;
		obj.getProductPrice();
		obj.addproductnewproductitem();
		
		Apexpages.currentPage().getParameters().put('editId' ,'0' );
		obj.editLineItem();
		obj.addproductnewproductitem();
		obj.addproductnewproductitem();
		obj.addproductnewproductitem();
		
		Apexpages.currentPage().getParameters().put('deleteId' ,'0' );
		obj.deletLineItem();
		
		List<SelectOption> listMethods = obj.getALLProducts();
		listMethods = obj.getAllTaxes();
		listMethods = obj.getAllTemplates(); 
		obj.back();
		obj.savePO();
		
		
		sO = new Sales_Invoice__c ();
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
		
		Apexpages.currentPage().getParameters().put('id' ,sO.id );
		try
		{
			obj = new EditSalesInvoice(std);
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage(), 'Sales Invoice Status is :' + sO.Status__c + ' You can\'t Change its content ');
		}
		
	}
	// end of test functions
}