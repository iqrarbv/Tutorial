public class PurchaseOrderController 
{
	public Purchase_Order__c PurchaseOrderInfo {get; set;}
	public List<POLineItemWrapper> Lineitems {get; set;} 
	public POLineItemWrapper poItem {get; set;}
	//public Purchase_Order_Line_Items__c poItem {get; set;}
	public decimal taxrate {get; set;}
	public decimal totalrate {get; set;}
	private List<Tax_Rate__c> TaxRates;
	private List<Opportunity> AllOpportunities {get; set;}
	private List<Product2> AllProducts ; 
	public decimal tax_rate {get; set; }
	public Map<Id , decimal> taxRateMap  { get; set; }
	public Map<Id,Id> NominalAccountstoTaxRate {get; set; }
	public Map<Id,Decimal> ProductPrices {get; set; }
	public string currencySymbol {get; set;}
	public decimal PoAmount {get; set;}
	public decimal totalTax {get; set;}
	public decimal wtAmount {get; set;}
	public boolean ecsRates {get;set;}
	public Id defaultTax {get; set;}
	public decimal Defaulttaxrate {get; set; }
	public List<PricebookEntry> priceBook {get; set;}
	public PurchaseOrderController (ApexPages.Standardcontroller controller)
	{
		PurchaseOrderInfo = new Purchase_Order__c();
		Lineitems  = new List<POLineItemWrapper>();
		ecsRates = false ;
		init();
	}
	public PurchaseOrderController ()
	{
		PurchaseOrderInfo = new Purchase_Order__c();
		Lineitems  = new List<POLineItemWrapper>();
		init();	
	}
	public void init()
	{
		try
		{
			currencySymbol = Functions.getOrganisationCurrency('CurrencySymbol') ;
			//AllProducts = [Select p.ProductCode, p.Name From Product2 p where p.IsActive = true] ;
			priceBook = [Select p.UnitPrice, p.ProductCode, p.Product2.IsActive, p.Product2.ProductCode, p.Product2.Name, p.Product2.Id, p.Product2Id From PricebookEntry p where p.Product2.IsActive = true and p.Pricebook2.IsStandard = true order by p.Product2.ProductCode] ;
			TaxRates = [select id , is_default__c , Name , Tax_Rate__c  from Tax_Rate__c Order By Name Asc limit 1000 ] ;
			AllOpportunities = [select Id , Name  from Opportunity  where Sub_Project__c = null and StageName  != 'Closed Won' and  StageName != 'Closed Lost' Order By Name Asc limit 1000 ] ; 
			poItem = new POLineItemWrapper(new Purchase_Order_Line_Items__c());
			tax_rate = 0.00 ;
			PoAmount = 0.00 ;
			totalTax = 0.00 ;
			wtAmount = 0.00 ;
			PurchaseOrderInfo.Order_Date__c = date.today();
			taxRateMap = new Map<Id , decimal>() ;
			ProductPrices = new Map<Id,Decimal>();
			list<Tax_Rate__c> taxratelist = TaxRates ;//[select Id , Tax_Rate__c from Tax_Rate__c]; 
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
			initValues();
		}
		catch(exception e)
		{
			apexpages.addMessages(e);
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
		poItem.purchaseOrderLineItems.Narrative__c = 'Item Name' ;
		poItem.purchaseOrderLineItems.Quantity__c  = 0 ; 
		poItem.purchaseOrderLineItems.Amount__c  = 0.00 ;
		poItem.purchaseOrderLineItems.Total_VAT__c = 0.00 ;
		poItem.purchaseOrderLineItems.Total_Gross__c = 0.00 ;
		poItem.purchaseOrderLineItems.Tax_Rate__c = defaultTax ;
		tax_rate = Defaulttaxrate ;
	}
	public void addproductnewproductitem()
	{
		try
		{
			PurchaseOrder.validateLineDetails(poItem);
			selectedTax();
			Purchase_Order_Line_Items__c tmpItem = new Purchase_Order_Line_Items__c();	
			tmpItem.Product__c = poItem.purchaseOrderLineItems.Product__c ;
			tmpItem.Narrative__c  = poItem.purchaseOrderLineItems.Narrative__c ; 
			tmpItem.Quantity__c  = poItem.purchaseOrderLineItems.Quantity__c ; 
			tmpItem.Amount__c  = poItem.purchaseOrderLineItems.Amount__c ;
			tmpItem.Tax_Rate__c   = poItem.purchaseOrderLineItems.Tax_Rate__c ;
			tmpItem.Total_VAT__c  = poItem.purchaseOrderLineItems.Total_VAT__c.setScale(2) ;
			tmpItem.Total_Gross__c   = poItem.purchaseOrderLineItems.Total_Gross__c.setScale(2) ;
			tmpItem.Opportunity__c  = poItem.purchaseOrderLineItems.Opportunity__c;
			POLineItemWrapper tmwrap = new POLineItemWrapper(tmpItem);
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
	
	public PageReference savePO()
	{
		Savepoint sp = Database.setsavepoint(); 
		try
		{
			PurchaseOrder savePurchaseOrder = new PurchaseOrder(PurchaseOrderInfo);
			savePurchaseOrder.saveOrder(PurchaseOrderInfo, Lineitems ,'INSERT' );
			return new PageReference('/'+ savePurchaseOrder.po.Id);
		}
		catch(exception e)
		{
			Database.rollback(sp);
			apexpages.addMessages(e);
			return null ;
		}
	}
	public void selectedTax()
	{
	 	if ( poItem.purchaseOrderLineItems.Tax_Rate__c != null )
	 	{
	 		if (taxRateMap.keyset().contains(poItem.purchaseOrderLineItems.Tax_Rate__c))
	 			tax_rate = taxRateMap.get(poItem.purchaseOrderLineItems.Tax_Rate__c) ;
	 		else
	 			tax_rate = [Select Tax_Rate__c from Tax_Rate__c where Id = : poItem.purchaseOrderLineItems.Tax_Rate__c].Tax_Rate__c;
	 		decimal taxamount  = poItem.purchaseOrderLineItems.Amount__c.divide(100,3,system.roundingmode.up);
			taxamount = taxamount * tax_rate ;
			poItem.purchaseOrderLineItems.Total_VAT__c = taxamount * poItem.purchaseOrderLineItems.Quantity__c ; 
			poItem.purchaseOrderLineItems.Total_Gross__c = (poItem.purchaseOrderLineItems.Amount__c * poItem.purchaseOrderLineItems.Quantity__c ) +  poItem.purchaseOrderLineItems.Total_VAT__c; 
		}
	}
	public void getProductPrice()
	{
		if(ProductPrices.keyset().contains(poItem.purchaseOrderLineItems.Product__c))
			poItem.purchaseOrderLineItems.Amount__c = ProductPrices.get(poItem.purchaseOrderLineItems.Product__c);
		else
			poItem.purchaseOrderLineItems.Amount__c = [Select p.UnitPrice , p.Product2Id From PricebookEntry p where p.Product2Id = : poItem.purchaseOrderLineItems.Product__c].UnitPrice ;
	}
	public void deletLineItem()
	{
		string index = string.valueof(decimal.valueof(apexpages.currentPage().getParameters().get('deleteId'))) ;
		Lineitems.remove(Functions.getListIndex(index) );
		removeListItems();
		calculateTotals();
	}
	public void removeListItems()
	{
		List<POLineItemWrapper> titems = new List<POLineItemWrapper>();
		for (POLineItemWrapper po : Lineitems)
		{
			po.serialNumber = titems.size();// + 1;
			titems.add(po);
		}
		Lineitems = titems ;
	}
	public void editLineItem()
	{
		string sIndex = string.valueof(decimal.valueof(apexpages.currentPage().getParameters().get('editId'))) ;
		integer index = Functions.getListIndex(sIndex) ;
		poItem.purchaseOrderLineItems.Product__c = Lineitems[index].purchaseOrderLineItems.Product__c ;
		poItem.purchaseOrderLineItems.Narrative__c  = Lineitems[index].purchaseOrderLineItems.Narrative__c ; 
		poItem.purchaseOrderLineItems.Quantity__c  = Lineitems[index].purchaseOrderLineItems.Quantity__c ; 
		poItem.purchaseOrderLineItems.Amount__c  = Lineitems[index].purchaseOrderLineItems.Amount__c ;
		poItem.purchaseOrderLineItems.Tax_Rate__c   = Lineitems[index].purchaseOrderLineItems.Tax_Rate__c ;
		poItem.purchaseOrderLineItems.Total_VAT__c  = Lineitems[index].purchaseOrderLineItems.Total_VAT__c ;
		poItem.purchaseOrderLineItems.Total_Gross__c   = Lineitems[index].purchaseOrderLineItems.Total_Gross__c ;
		poItem.purchaseOrderLineItems.Opportunity__c  = Lineitems[index].purchaseOrderLineItems.Opportunity__c;
		tax_rate = Lineitems[index].taxRate;
		Lineitems.remove(index);
		removeListItems();
		calculateTotals();
	}
	public void calculateTotals()
	{
		PoAmount = PurchaseOrder.getTotalAmountt(Lineitems) ; //getTotalAmount() ;
	 	totalTax = PurchaseOrder.getToTalTaxx(Lineitems) ; //getToTalTax() ;
	 	wtAmount = PurchaseOrder.getTotalAmountExcludingTaxx(Lineitems) ; //getTotalAmountExcludingTax() ;
	}
	public void clearValues()
	{
		poItem.purchaseOrderLineItems.Narrative__c = 'Item Name' ;
		poItem.purchaseOrderLineItems.Quantity__c  = 0 ; 
		poItem.purchaseOrderLineItems.Amount__c  = 0.00 ;
		poItem.purchaseOrderLineItems.Total_VAT__c = 0.00 ;
		poItem.purchaseOrderLineItems.Total_Gross__c = 0.00 ;	
		poItem.purchaseOrderLineItems.Opportunity__c = null ;
		poItem.purchaseOrderLineItems.Product__c = null ;
		poItem.purchaseOrderLineItems.Tax_Rate__c = defaultTax ;	
		tax_rate = Defaulttaxrate ;
	}
	//this is Test Methods
	//*********************
	//*********************
	private static testmethod void Test_Purchase_Order_AddEditController()
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
		
		//PricebookEntry priceBook  = new PricebookEntry( UnitPrice = 20 , Product2Id = product.Id , IsActive = true , Pricebook2Id = proBook.id , UseStandardPrice = true ) ;
		//insert priceBook ;
		
		 
		//List<Purchase_Order_Line_Items__c> poItems = new List<Purchase_Order_Line_Items__c>(); 
		ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(new Purchase_Order__c());
		PurchaseOrderController obj = new PurchaseOrderController(std);
		Purchase_Order__c pO = new Purchase_Order__c ();
		po.Account__c = act.id;
		po.Name = '000';
		po.Order_By__c = userinfo.getUserId();
		po.Order_Date__c = date.today();
		po.Status__c = 'Pending';
		
		obj.PurchaseOrderInfo = po ;
		Purchase_Order_Line_Items__c LineItem = new Purchase_Order_Line_Items__c();
		LineItem.Product__c = product.id ; 
		LineItem.Narrative__c = 'I am Testing';
		LineItem.Opportunity__c = op.id ; 
		LineItem.Quantity__c = 1 ; 
		LineItem.Serial_No__c = 1 ;
		LineItem.Tax_Rate__c = tx.id ;
		LineItem.Amount__c = 10 ; 
		LineItem.Total_Amount__c = 10 ;
		LineItem.Total_VAT__c = 2 ; 
		LineItem.Total_Gross__c = 12 ;
		obj.poItem.purchaseOrderLineItems = LineItem ;
		obj.addproductnewproductitem() ;
		obj.poItem.purchaseOrderLineItems = LineItem ;
		obj.addproductnewproductitem() ;
		//obj.getProductPrice();
		
		List<selectoption> projectList  = obj.getALLProducts();
		projectList  = obj.getAllTaxes();
		//obj.savePO();
		apexpages.currentPage().getParameters().put('editId' , '0');
		obj.editLineItem();
		obj.addproductnewproductitem() ;
		obj.addproductnewproductitem() ;
		obj.addproductnewproductitem() ;
		obj.savePO();
		PurchaseOrderController obj1 = new PurchaseOrderController ();
	}
	private static testmethod void TestPurchaseOrder()
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
		
		//PricebookEntry priceBook  = new PricebookEntry( UnitPrice = 20 , Product2Id = product.Id , IsActive = true , Pricebook2Id = proBook.id , UseStandardPrice = true ) ;
		//insert priceBook ;
		
		 
		//List<Purchase_Order_Line_Items__c> poItems = new List<Purchase_Order_Line_Items__c>(); 
		ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(new Purchase_Order__c());
		PurchaseOrderController obj = new PurchaseOrderController(std);
		
		Purchase_Order_Line_Items__c LineItem = new Purchase_Order_Line_Items__c();
		LineItem.Product__c = product.id ; 
		LineItem.Narrative__c = 'I am Testing';
		LineItem.Opportunity__c = op.id ; 
		LineItem.Quantity__c = 1 ; 
		LineItem.Serial_No__c = 1 ;
		LineItem.Tax_Rate__c = tx.id ;
		LineItem.Amount__c = 10 ; 
		LineItem.Total_Amount__c = 10 ;
		LineItem.Total_VAT__c = 2 ; 
		LineItem.Total_Gross__c = 12 ;
		obj.poItem.purchaseOrderLineItems = LineItem ;
		obj.addproductnewproductitem() ;
		obj.poItem.purchaseOrderLineItems = LineItem ;
		obj.addproductnewproductitem() ;
		//obj.getProductPrice();
		
		List<selectoption> projectList  = obj.getALLProducts();
		projectList  = obj.getAllTaxes();
		
		Purchase_Order__c pO = new Purchase_Order__c ();
		po.Account__c = act.id;
		po.Name = '000';
		po.Order_By__c = userinfo.getUserId();
		po.Order_Date__c = date.today();
		po.Status__c = 'Pending';
		
		obj.PurchaseOrderInfo = po ;
		
		obj.savePO();
		
		
		apexpages.currentPage().getParameters().put('deleteId' , '0');
		obj.deletLineItem();
		PurchaseOrderController obj1 = new PurchaseOrderController ();
	}
	//*********************
	//*********************
	//end of test Methods
}