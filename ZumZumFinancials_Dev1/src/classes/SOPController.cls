public class SOPController 
{
	public Sales_Order__c salesOrderInfo {get; set;}
	public List<SOLineItemWrapper> Lineitems {get; set;} 
	public SOLineItemWrapper poItem {get; set;}
	//public Purchase_Order_Line_Items__c poItem {get; set;}
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
	public List<PricebookEntry> priceBook {get; set;}
	public boolean showOpportunityInfo {get; set;}
	public boolean ecsRates {get;set;}
	public Id defaultTax {get; set;}
	public Account cusAccountInfo {get; set;}
	public SOPController( apexpages.Standardcontroller newSalseOrder)
	{
		salesOrderInfo = new Sales_Order__c();
		Lineitems  = new List<SOLineItemWrapper>();
		ecsRates = false ;
		init();
	}
	public void init()
	{
		try
		{
			currencySymbol = Functions.getOrganisationCurrency('CurrencySymbol') ;
			//AllProducts = [Select p.ProductCode, p.Name From Product2 p where p.IsActive = true] ;
			priceBook = [Select p.UnitPrice, p.ProductCode, p.Product2.IsActive, p.Product2.ProductCode, p.Product2.Name, p.Product2.Id, p.Product2Id From PricebookEntry p where p.Product2.IsActive = true and p.Pricebook2.IsStandard = true order by p.Product2.ProductCode] ;
			TaxRates = [select id , Name , Tax_Rate__c  from Tax_Rate__c Order By Name Asc limit 1000 ] ;
			AllOpportunities = [select Id , Name  from Opportunity  where Sub_Project__c = null and StageName  != 'Closed Won' and  StageName != 'Closed Lost' Order By Name Asc limit 1000 ] ; 
			poItem = new SOLineItemWrapper(new Sales_Order_Line_Items__c());
			cusAccountInfo = new Account();
			tax_rate = 0.00 ;
			PoAmount = 0.00 ;
			totalTax = 0.00 ;
			wtAmount = 0.00 ;
			salesOrderInfo.Order_Date__c = date.today();
			taxRateMap = new Map<Id , decimal>() ;
			ProductPrices = new Map<Id,Decimal>();
			list<Tax_Rate__c> taxratelist = [select Id , Tax_Rate__c , is_default__c from Tax_Rate__c limit 100]; 
			for (Tax_Rate__c ratelist: taxratelist)
			{
				taxRateMap.put(ratelist.Id , ratelist.Tax_Rate__c)	;
				if(ratelist.is_default__c == true)
				{
					defaultTax = ratelist.Id ;
					Defaulttaxrate  = ratelist.Tax_Rate__c ;
				}
			}
			if (defaultTax == null)
				throw new CustomException('No Default Tax Account Found, Please enter Default Tax from Setup tab');
			for (PricebookEntry pb: priceBook  )
			{
				ProductPrices.put(pb.Product2Id , pb.UnitPrice);	
			}
			if (apexpages.currentPage().getParameters().keyset().contains('opid'))
			{
				Id opID =  apexpages.currentPage().getParameters().get('opid');
				Opportunity opp = [select Id ,  AccountId from Opportunity where Id =:opID limit 1] ;
				salesOrderInfo.Opportunity__c = opp.Id	;
				getOpportunityProducts(opID);
				if(opp.AccountId !=null )
				{
					cusAccountInfo = [select Id , Tax_Rate__c ,Tax_Rate__r.Tax_Rate__c ,Type , Settlement_Due_Days__c from Account where id = :opp.AccountId limit 1];
					if(cusAccountInfo.Type != 'Customer')
						apexpages.addMessage( new apexpages.Message( apexpages.Severity.Info , 'Account againt this Opportunity is not a Customer' ));
					salesOrderInfo.Account__c = cusAccountInfo.Id ;
					if(cusAccountInfo.Tax_Rate__c !=null )
					{	
						poItem.salesOrderLineItems.Tax_Rate__c = cusAccountInfo.Tax_Rate__c ;
						tax_rate = cusAccountInfo.Tax_Rate__r.Tax_Rate__c;
					}
					else
					{	
						poItem.salesOrderLineItems.Tax_Rate__c = defaultTax ;
						tax_rate = Defaulttaxrate ;
					} 	
				}
			}
			if (apexpages.currentPage().getParameters().keyset().contains('qid'))
			{
				Quote QuoteIfo = [Select q.Opportunity.AccountId , q.QuoteNumber From Quote q where id = : apexpages.currentPage().getParameters().get('qid')] ; 
				salesOrderInfo.Quote_Number__c = QuoteIfo.QuoteNumber ;
				if(QuoteIfo.Opportunity.AccountId != null)
				{
					cusAccountInfo = [select Id , Tax_Rate__c ,Tax_Rate__r.Tax_Rate__c ,Type , Settlement_Due_Days__c from Account where id = :QuoteIfo.Opportunity.AccountId  limit 1];
					if(cusAccountInfo.Type != 'Customer')
						apexpages.addMessage( new apexpages.Message( apexpages.Severity.Info , 'Account againt this Opportunity is not a Customer' ));
					salesOrderInfo.Account__c = cusAccountInfo.Id ;
					if(cusAccountInfo.Tax_Rate__c != null )
					{	
						poItem.salesOrderLineItems.Tax_Rate__c = cusAccountInfo.Tax_Rate__c ;
						tax_rate = cusAccountInfo.Tax_Rate__r.Tax_Rate__c;
					}
					else
					{	
						poItem.salesOrderLineItems.Tax_Rate__c = defaultTax ;
						tax_rate = Defaulttaxrate ;
					} 
				}
				getQuoteProducts(QuoteIfo.Id) ;
			}
			initValues();
		}
		catch(exception e)
		{
			apexpages.addMessages(e);
		}	
	}
	public void getQuoteProducts(id quoteId)
	{
		for(QuoteLineItem opL : [Select q.UnitPrice, q.TotalPrice, q.Quote.OpportunityId , 
										q.QuoteId, q.Quantity, q.PricebookEntry.Product2Id, 
										q.PricebookEntryId, q.Description 
										From QuoteLineItem q 
										where q.QuoteId = :quoteId])
		{
			poItem.salesOrderLineItems.Product__c = opL.PricebookEntry.Product2Id ; 
			poItem.salesOrderLineItems.Narrative__c = opL.Description ; 
			poItem.salesOrderLineItems.Quantity__c = opL.Quantity ;
			poItem.salesOrderLineItems.Amount__c = opL.UnitPrice;	
			poItem.salesOrderLineItems.Tax_Rate__c = defaultTax ; //'a0f900000009KJf' ;
			poItem.salesOrderLineItems.Project__c = opL.Quote.OpportunityId ;
			addproductnewproductitem();
		}		
	}
	public void getOpportunityProducts(id oppId)
	{
		for(OpportunityLineItem opL : [Select o.UnitPrice, o.TotalPrice, o.PricebookEntry.Product2Id ,  
										o.Quantity, o.PricebookEntryId, o.OpportunityId,
										o.ListPrice, o.LastModifiedDate, o.LastModifiedById, o.IsDeleted, 
										o.Id, o.Description, o.CreatedDate, o.CreatedById 
										From OpportunityLineItem o 
										where o.OpportunityId = :oppId])
		{
			poItem.salesOrderLineItems.Product__c = opL.PricebookEntry.Product2Id ; 
			poItem.salesOrderLineItems.Narrative__c = opL.Description ; 
			poItem.salesOrderLineItems.Quantity__c = opL.Quantity ;
			poItem.salesOrderLineItems.Amount__c = opL.UnitPrice;	
			poItem.salesOrderLineItems.Tax_Rate__c = defaultTax ; //'a0f900000009KJf' ;
			poItem.salesOrderLineItems.Project__c = opL.OpportunityId ;
			addproductnewproductitem();
		}
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
		if(ecsRates)
		{
			system.debug('this is ecs: ' + ecsRates );
			TaxRates = [select id , Name , Tax_Rate__c  from Tax_Rate__c where is_EC_Sales__c = true Order By Name Asc limit 1000 ] ;
			system.debug(TaxRates);
		}	
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
	public void initValues()
	{
		poItem.salesOrderLineItems.Narrative__c = 'Item Name' ;
		poItem.salesOrderLineItems.Quantity__c  = 0 ; 
		poItem.salesOrderLineItems.Amount__c  = 0.00 ;
		poItem.salesOrderLineItems.VAT_Amount__c = 0.00 ;
		poItem.salesOrderLineItems.Total_Amount__c = 0.00 ;	
		
		tax_rate = Defaulttaxrate ; //defaultTax ;
		poItem.salesOrderLineItems.Tax_Rate__c = defaultTax ;
	}
	public void addproductnewproductitem()
	{
		try
		{
			SalesOrder_model.validateLineDetails(poItem);
			selectedTax();
			Sales_Order_Line_Items__c tmpItem = new Sales_Order_Line_Items__c();	
			tmpItem.Product__c = poItem.salesOrderLineItems.Product__c ;
			tmpItem.Narrative__c  = poItem.salesOrderLineItems.Narrative__c ; 
			tmpItem.Quantity__c  = poItem.salesOrderLineItems.Quantity__c ; 
			tmpItem.Amount__c  = poItem.salesOrderLineItems.Amount__c ;
			tmpItem.Tax_Rate__c   = poItem.salesOrderLineItems.Tax_Rate__c ;
			tmpItem.VAT_Amount__c  = poItem.salesOrderLineItems.VAT_Amount__c.setScale(2) ;
			tmpItem.Total_Net__c = poItem.salesOrderLineItems.Total_Net__c.setScale(2) ;
			tmpItem.Total_Amount__c   = poItem.salesOrderLineItems.Total_Amount__c.setScale(2) ;
			tmpItem.Project__c  = poItem.salesOrderLineItems.Project__c;
			SOLineItemWrapper tmwrap = new SOLineItemWrapper(tmpItem);
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
		if(poItem.salesOrderLineItems.Product__c !=null )
		{
			if(ProductPrices.keyset().contains(poItem.salesOrderLineItems.Product__c))
				poItem.salesOrderLineItems.Amount__c = ProductPrices.get(poItem.salesOrderLineItems.Product__c);
			else
				poItem.salesOrderLineItems.Amount__c = [Select p.UnitPrice , p.Product2Id From PricebookEntry p where p.Product2Id = : poItem.salesOrderLineItems.Product__c].UnitPrice ;
		}
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
		poItem.salesOrderLineItems.Product__c = Lineitems[index].salesOrderLineItems.Product__c ;
		poItem.salesOrderLineItems.Narrative__c  = Lineitems[index].salesOrderLineItems.Narrative__c ; 
		poItem.salesOrderLineItems.Quantity__c  = Lineitems[index].salesOrderLineItems.Quantity__c ; 
		poItem.salesOrderLineItems.Amount__c  = Lineitems[index].salesOrderLineItems.Amount__c ;
		poItem.salesOrderLineItems.Tax_Rate__c   = Lineitems[index].salesOrderLineItems.Tax_Rate__c ;
		poItem.salesOrderLineItems.VAT_Amount__c  = Lineitems[index].salesOrderLineItems.VAT_Amount__c ;
		poItem.salesOrderLineItems.Total_Amount__c   = Lineitems[index].salesOrderLineItems.Total_Amount__c ;
		poItem.salesOrderLineItems.Total_Net__c   = Lineitems[index].salesOrderLineItems.Total_Net__c ;
		poItem.salesOrderLineItems.Project__c  = Lineitems[index].salesOrderLineItems.Project__c;
		tax_rate = Lineitems[index].taxRate;
		Lineitems.remove(index);
		removeListItems();
		calculateTotals();
	}
	public void removeListItems()
	{
		List<SOLineItemWrapper> titems = new List<SOLineItemWrapper>();
		for (SOLineItemWrapper po : Lineitems)
		{
			po.serialNumber = titems.size();// + 1;
			titems.add(po);
		}
		Lineitems = titems ;
	}
	public void selectedTax()
	{
	 	if ( poItem.salesOrderLineItems.Tax_Rate__c != null )
	 	{
	 		if (taxRateMap.keyset().contains(poItem.salesOrderLineItems.Tax_Rate__c))
	 			tax_rate = taxRateMap.get(poItem.salesOrderLineItems.Tax_Rate__c) ;
	 		else
	 			tax_rate = [Select Tax_Rate__c from Tax_Rate__c where Id = : poItem.salesOrderLineItems.Tax_Rate__c].Tax_Rate__c;
	 		decimal taxamount  = poItem.salesOrderLineItems.Amount__c.divide(100,3,system.roundingmode.up);
			taxamount = taxamount * tax_rate ;
			poItem.salesOrderLineItems.VAT_Amount__c = taxamount * poItem.salesOrderLineItems.Quantity__c ; 
			poItem.salesOrderLineItems.Total_Net__c = (poItem.salesOrderLineItems.Amount__c * poItem.salesOrderLineItems.Quantity__c ) ;
			poItem.salesOrderLineItems.Total_Amount__c = (poItem.salesOrderLineItems.Amount__c * poItem.salesOrderLineItems.Quantity__c ) +  poItem.salesOrderLineItems.VAT_Amount__c; 
		}
	}
	public void clearValues()
	{
		poItem.salesOrderLineItems.Narrative__c = 'Item Name' ;
		poItem.salesOrderLineItems.Quantity__c  = 0 ; 
		poItem.salesOrderLineItems.Amount__c  = 0.00 ;
		poItem.salesOrderLineItems.VAT_Amount__c = 0.00 ;
		poItem.salesOrderLineItems.Total_Amount__c = 0.00 ;
		poItem.salesOrderLineItems.Total_Net__c = 0.00 ;		
		poItem.salesOrderLineItems.Project__c = null ;
		poItem.salesOrderLineItems.Product__c = null ;
		//poItem.salesOrderLineItems.Tax_Rate__c = null ;	
		//tax_rate = 0.00 ;
		if(cusAccountInfo.Tax_Rate__c !=null )
		{	
			poItem.salesOrderLineItems.Tax_Rate__c = cusAccountInfo.Tax_Rate__c ;
			tax_rate = cusAccountInfo.Tax_Rate__r.Tax_Rate__c;
		}
		else
		{	
			poItem.salesOrderLineItems.Tax_Rate__c = defaultTax ;
			tax_rate = Defaulttaxrate ;
		}
	}
	public void calculateTotals()
	{
		PoAmount = SalesOrder_model.getTotalAmount(Lineitems) ; //getTotalAmount() ;
	 	totalTax = SalesOrder_model.getToTalTax(Lineitems) ; //getToTalTax() ;
	 	wtAmount = SalesOrder_model.getTotalAmountExcludingTax(Lineitems) ; //getTotalAmountExcludingTax() ;
	}
	public PageReference savePO()
	{
		Savepoint sp = Database.setsavepoint(); 
		try
		{
			SalesOrder_model saveSalesOrder = new SalesOrder_model(salesOrderInfo);
			saveSalesOrder.saveOrder(salesOrderInfo, Lineitems ,'INSERT' );
			return new PageReference('/'+ saveSalesOrder.so.Id);
		}
		catch(exception e)
		{
			Database.rollback(sp);
			apexpages.addMessages(e);
			return null ;
		}
	}
	
	// Test Classes for this module
	private static testmethod void Test_SALES_ORDER_AddEditController()
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
		
		 
		//List<Purchase_Order_Line_Items__c> poItems = new List<Purchase_Order_Line_Items__c>(); 
		ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(new Purchase_Invoice__c());
		Apexpages.currentPage().getParameters().put('opId' ,op.id );
		SOPController obj = new SOPController(std);
		
		
		
		
		Sales_Order__c sO = new Sales_Order__c ();
		sO.Account__c = act.id;
		sO.Name = '000';
		sO.Order_By__c = userinfo.getUserId();
		sO.Order_Date__c = date.today();
		sO.Status__c = 'Pending';
		
		obj.salesOrderInfo = sO ;
		
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
		
		obj.poItem.salesOrderLineItems = LineItem ;
		obj.getProductPrice();
		try
		{
			obj.addproductnewproductitem() ;
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage() , 'Please Enter Nominal Account For Line Item');
		}
		obj.addproductnewproductitem() ;
		apexpages.currentPage().getParameters().put('editId' , '0');
		obj.editLineItem();
		obj.addproductnewproductitem() ;
		obj.addproductnewproductitem() ;
		List<selectoption> projectList  = obj.getAllTaxes() ; 
		projectList = obj.getAllTaxes();
		obj.savePO();
	}
	
	private static testmethod void SALES_Order_AddEditController()
	{
		//preparing data for unit testing
		Account act = new Account(Name='ABC Company',Type='Customer' );
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
		
		
		Pricebook2 proBook = [Select p.SystemModstamp, p.Name, p.LastModifiedDate, p.LastModifiedById, p.IsStandard, p.IsDeleted, p.IsActive, p.Id, p.Description, p.CreatedDate, p.CreatedById From Pricebook2 p where p.IsStandard = true limit 1] ;
		/*
		Pricebook2 proBook = new Pricebook2(Name = 'Testing', IsActive = true , Description = 'Testing Description' );
		insert proBook ;
		
		proBook = new Pricebook2(Name = 'Testing 2', IsActive = true , Description = 'Testing Description ' );
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
		
		Quote qt = new Quote(Name = 'Test Quote' , Description = 'I am testing this' , OpportunityId = op.id , Pricebook2Id = proBook.id );
		insert qt ;
		
		QuoteLineItem QLineItem = new QuoteLineItem (UnitPrice = 10 , QuoteId = qt.id , Quantity = 1 , PricebookEntryId = priceBook.id  , Description = 'this is Quote line item');
		insert QLineItem;
		
		//List<Purchase_Order_Line_Items__c> poItems = new List<Purchase_Order_Line_Items__c>(); 
		ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(new Purchase_Invoice__c());
		Apexpages.currentPage().getParameters().put('qid' ,qt.id );
		SOPController obj = new SOPController(std);
		Sales_Order__c sO = new Sales_Order__c ();
		sO.Account__c = act.id;
		sO.Name = '000';
		sO.Order_By__c = userinfo.getUserId();
		sO.Order_Date__c = date.today();
		sO.Status__c = 'Pending';
		
		obj.salesOrderInfo = sO ;
		
		Sales_Order_Line_Items__c LineItem = new Sales_Order_Line_Items__c();
		//LineItem.Product__c = product.id ; 
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
		
		obj.poItem.salesOrderLineItems = LineItem ;
		
		//try
		//{
			//obj.addproductnewproductitem() ;
		//}
		//catch(Exception e)
		//{
			//system.assertEquals(e.getMessage() , 'Please Enter Nominal Account For Line Item');
		//}
		obj.addproductnewproductitem() ;
		apexpages.currentPage().getParameters().put('deleteId' , '0');
		obj.deletLineItem();
		List<selectoption> projectList  = obj.getAllTaxes() ; 
		projectList = obj.getALLProducts() ; 
		projectList = obj.getAllTaxes();
		obj.savePO();
		
	}
	
}