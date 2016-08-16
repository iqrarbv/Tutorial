public class Edit_Sales_Order 
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
	public boolean allowEdit {get; set;}
	public boolean ecsRates {get;set;}
	public Id editId {get; set;}
	public Id defaultTax {get; set;}
	public Edit_Sales_Order( apexpages.Standardcontroller newSalseOrder)
	{
		salesOrderInfo = new Sales_Order__c();
		Lineitems  = new List<SOLineItemWrapper>();
		init();
	}
	public void init()
	{
		try
		{
			allowEdit = true;
			currencySymbol = Functions.getOrganisationCurrency('CurrencySymbol') ;
			//AllProducts = [Select p.ProductCode, p.Name From Product2 p where p.IsActive = true] ;
			editid = apexpages.currentPage().getParameters().get('id');
			salesOrderInfo = [Select s.Account__r.Tax_Rate__r.Tax_Rate__c , s.Account__r.Tax_Rate__c , s.OwnerId , s.Total_VAT__c, s.Status__c  , s.Total_Net__c, s.Total_Gross__c, s.Supplier_Reference__c, s.Quote_Number__c, s.Placed_By__c, s.Order_Date__c, s.Order_By__c, s.Opportunity__c, s.Net_Amount__c, s.Name, s.IsDeleted, s.Id, s.Customer_Order_No__c, s.Approved_By__c, s.Account__c , s.Account__r.Country__c From Sales_Order__c s where Id = : editId];
			ecsRates = functions.isEuropean(salesOrderInfo.Account__r.Country__c);
			if ( salesOrderInfo.OwnerId != userinfo.getUserId())
			{
				allowEdit = false;
				throw new CustomException('You are not authorized to changed content on this Sales order ' );
				return ;	
			} 
			if (salesOrderInfo.Status__c == 'Pending' || salesOrderInfo.Status__c == 'Rejected')
			{
				for (Sales_Order_Line_Items__c po : [Select s.Total_Net__c, s.Total_Amount__c, s.Tax_Rate__c, s.Tax_Rate__r.Tax_Rate__c , s.VAT_Amount__c, s.SystemModstamp, s.Serial_No__c, s.Sales_Order__c, s.Quantity__c, s.Project__c, s.Product__c, s.Nominal_Account__c, s.Narrative__c, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.Delete__c, s.CreatedDate, s.CreatedById, s.Amount__c From Sales_Order_Line_Items__c s where s.Sales_Order__c = :salesOrderInfo.Id  ])
				{
					SOLineItemWrapper tmwrap = new SOLineItemWrapper(po);
					tmwrap.serialNumber = Lineitems.size();
					tmwrap.taxRate = po.Tax_Rate__r.Tax_Rate__c ;
					Lineitems.add(tmwrap);	
				}
				priceBook = [Select p.UnitPrice, p.ProductCode, p.Product2.IsActive, p.Product2.ProductCode, p.Product2.Name, p.Product2.Id, p.Product2Id From PricebookEntry p where p.Product2.IsActive = true and p.Pricebook2.IsStandard = true order by p.Product2.ProductCode] ;
				//TaxRates = [select id , Name , Tax_Rate__c  from Tax_Rate__c Order By Name Asc limit 1000 ] ;
				AllOpportunities = [select Id , Name  from Opportunity  where Sub_Project__c = null and StageName  != 'Closed Won' and  StageName != 'Closed Lost' Order By Name Asc limit 1000 ] ; 
				poItem = new SOLineItemWrapper(new Sales_Order_Line_Items__c());
				initValues();
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
					    Defaulttaxrate = ratelist.Tax_Rate__c ;
					}
				}
				if (defaultTax == null)
					throw new CustomException('No Default Tax Account Found, Please enter Default Tax from Setup tab');
				for (PricebookEntry pb: priceBook  )
				{
					ProductPrices.put(pb.Product2Id , pb.UnitPrice);	
				}
				if (salesOrderInfo.Account__r.Tax_Rate__c != null) 
				{	
					poItem.salesOrderLineItems.Tax_Rate__c = salesOrderInfo.Account__r.Tax_Rate__c ;
					tax_rate = salesOrderInfo.Account__r.Tax_Rate__r.Tax_Rate__c ;
				}
				else
				{	
					poItem.salesOrderLineItems.Tax_Rate__c = defaultTax ;
					tax_rate = Defaulttaxrate ;
				}
				calculateTotals();
			}
			else
			{
				allowEdit = false;
				throw new CustomException('Sales Order Status is :' + salesOrderInfo.Status__c + ' You can\'t Change its content ' );
				return ;
			}
		}
		catch(exception e)
		{
			apexpages.addMessages(e);
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
		//else
			TaxRates = [select id , Name , Tax_Rate__c  from Tax_Rate__c Order By Name Asc limit 1000 ] ;
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
		if(poItem.salesOrderLineItems.Product__c !=null)
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
		//poItem.salesOrderLineItems.Tax_Rate__c = salesOrderInfo.Account__r.Tax_Rate__c ;	
		//tax_rate = 0.00 ;
		if (salesOrderInfo.Account__r.Tax_Rate__c != null) 
		{	
			poItem.salesOrderLineItems.Tax_Rate__c = salesOrderInfo.Account__r.Tax_Rate__c ;
			tax_rate = salesOrderInfo.Account__r.Tax_Rate__r.Tax_Rate__c ;
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
	public PageReference saveSO()
	{
		Savepoint sp = Database.setsavepoint(); 
		try
		{
			SalesOrder_model saveSalesOrder = new SalesOrder_model(salesOrderInfo);
			saveSalesOrder.saveOrder(salesOrderInfo, Lineitems ,'UPDATE' );
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
		
		 
		Sales_Order__c sO = new Sales_Order__c ();
		sO.Account__c = act.id;
		sO.Name = '000';
		sO.Order_By__c = userinfo.getUserId();
		sO.Order_Date__c = date.today();
		sO.Status__c = 'Pending';
		
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
		
		//List<Purchase_Order_Line_Items__c> poItems = new List<Purchase_Order_Line_Items__c>(); 
		ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(new Sales_Order__c());
		Apexpages.currentPage().getParameters().put('id' ,sO.id );
		Edit_Sales_Order obj = new Edit_Sales_Order(std);
		
		obj.salesOrderInfo = sO ;
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
		obj.addproductnewproductitem();
		obj.addproductnewproductitem();
		obj.addproductnewproductitem();
		apexpages.currentPage().getParameters().put('deleteId' , '0');
		obj.deletLineItem();
		
		List<selectoption> projectList  = obj.getAllTaxes() ; 
		projectList = obj.getAllTaxes();
		obj.saveSO();
	}
}