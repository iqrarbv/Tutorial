public class EditPurchaseInvoice 
{
	public boolean showPoInformation{get; set;}
	public Purchase_Invoice__c POInvoiceInfo {get; set;}
	public POInvoiceWrapper InvoiceDetails {get; set;}
	public list<POInvoiceWrapper> InvoiceDetailsList {get; set;}
	public List<Nominal_Account__c> ALLNominalAccounts {get; set;}
	public List<Opportunity> AllOpportunities {get; set;}
	public List<Tax_Rate__c> TaxRates {get; set;}
	public map<Id,Decimal> TaxRateMap {get; set;}
	public Map<Id,Id> NominalAccountstoTaxRate {get; set; }
	public string currencySymbol {get; set;}
	public List<Invoice_Template__c> InvoiceTmplt {get; set;}
	public Id tmeplateId {get; set;}
	public decimal PoAmount {get; set;}
	public decimal Defaulttaxrate {get; set; }
	public decimal totalTax {get; set;}
	public decimal  wtAmount  {get; set;}
	public decimal tax_rate {get; set;}
	public string hdnNcId {get; set;}
	public string htmlNcId {get; set;}
	public string ncName {get; set;}
	public map<Id , string[]> ncMap {get; set;}
	public boolean allowEdit {get; set;}
	public boolean ecsRates {get;set;}
	public Id editId {get; set;}
	public EditPurchaseInvoice ( apexpages.Standardcontroller invoiceController ) 
	{
		init();
	}
	public void init()
	{
		try
		{
			editId = apexpages.currentPage().getParameters().get('id');
			currencySymbol = Functions.getOrganisationCurrency('CurrencySymbol') ;
			PoAmount = 0.00 ;
			totalTax = 0.00 ;
			wtAmount  = 0.00 ;			
			AllNominalAccounts = [Select Id , Name ,Nominal_Code__c from Nominal_Account__c where P_O__c = true Order By Nominal_Code__c Asc limit 1000  ] ;
			//TaxRates = [select id , Name , Tax_Rate__c from Tax_Rate__c Order By Name Asc limit 1000 ] ;
			AllOpportunities = [select Id , Name  from Opportunity  where Sub_Project__c = null and StageName  != 'Closed Won' and  StageName != 'Closed Lost' Order By Name Asc limit 1000 ] ; 
			InvoiceTmplt = [Select Name from Invoice_Template__c limit 1000];
			InvoiceDetails = new POInvoiceWrapper(new Purchase_Invoice_Line_Item__c() );
			InvoiceDetailsList = new list<POInvoiceWrapper>();
			allowEdit = true ;
			POInvoiceInfo = [Select Purchase_Invoice__c.ownerid , p.Account__c , p.Account__r.Tax_Rate__c , p.Account__r.Country__c , p.Type__c, p.Status__c, p.Settlement_due_days__c, p.Settlement_Discount__c, p.Purchase_Order__c, p.Payment_Status__c, p.POP_Number__c, p.Name, p.Invoice_Template__c, p.Invoice_Due_Date__c, p.Invoice_Date__c, p.Id, p.Dimension__c From Purchase_Invoice__c p where Id = :editId ];
			//code by Fatima
			
			//endCode
			ecsRates = functions.isEuropean(POInvoiceInfo.Account__r.Country__c);
			if ( POInvoiceInfo.ownerid != userinfo.getUserId())
			{
				allowEdit = false;
				throw new CustomException('You are not authorized to changed this Purchase Invoice ' );
				return ;	
			} 
			else if ( POInvoiceInfo.Status__c == 'Pending' || POInvoiceInfo.Status__c == 'Rejected')
			{
				for (Purchase_Invoice_Line_Item__c poI : [Select p.Total_Net__c, p.Total_Gross__c, p.Tax_Rate__c, p.Tax_Rate__r.Tax_Rate__c,  p.Total_VAT__c, p.Serial_No__c, p.Ready_To_Pay__c, p.Quantity__c, p.Purchase_Invoice__c, p.Opportunity__c, p.Nominal_Account__c, p.Narrative__c, p.Name, p.Item_Received__c, p.Id, p.Amount__c From Purchase_Invoice_Line_Item__c p where p.Purchase_Invoice__c = :POInvoiceInfo.Id ])
				{
					POInvoiceWrapper tmpLineItem = new POInvoiceWrapper(poI);
					tmpLineItem.serialNumber = InvoiceDetailsList.size();
					tmpLineItem.taxRate = poI.Tax_Rate__r.Tax_Rate__c ;
					InvoiceDetailsList.add(tmpLineItem);
				}
				TaxRateMap = new map<Id,Decimal>();
				//for (Tax_Rate__c ratelist: TaxRates)
				for (Tax_Rate__c ratelist: [select Id , Tax_Rate__c from Tax_Rate__c limit 100])
				{
					taxRateMap.put(ratelist.Id , ratelist.Tax_Rate__c)	;
				}
				NominalAccountstoTaxRate = new Map<Id,Id>();
				list<Nominal_Account__c> nominalacounttaxrate  = [Select Tax_Rate__c From Nominal_Account__c limit 2000];
				for (Nominal_Account__c nomlinst : nominalacounttaxrate)
				{
					NominalAccountstoTaxRate.put(nomlinst.Id , nomlinst.Tax_Rate__c);	
				}	
				ncMap = new map<Id , string[]>();
				for (Nominal_Account__c nA : AllNominalAccounts) 
				{
					string[] ncCodeName = new string[]{nA.Nominal_Code__c, nA.Name} ;
					ncMap.put(nA.Id , ncCodeName);
				}
				InvoiceDetails = new POInvoiceWrapper(new Purchase_Invoice_Line_Item__c());
				InvoiceDetails.purchaseInvoiceLineItems.Tax_Rate__c = POInvoiceInfo.Account__r.Tax_Rate__c ;
				for(Tax_Rate__c lstTax : [select id , Tax_Rate__c, is_Default__c from Tax_Rate__c limit 100])
				{
					if (lstTax.is_Default__c == true)
						Defaulttaxrate = lstTax.Tax_Rate__c ;
					if(lstTax.id == InvoiceDetails.purchaseInvoiceLineItems.Tax_Rate__c)					
						tax_rate = lstTax.Tax_Rate__c;
				}
				initValues();
				calculateTotals();
			}
			else
			{
				allowEdit = false;
				throw new CustomException('Purchase Invoice Status is : ' + POInvoiceInfo.Status__c + ' You can\'t Change its content ' );
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
		if(POInvoiceInfo.Account__c !=null)
		{
			Account cusAccountInfo = [select Id , Tax_Rate__c , Tax_Rate__r.Tax_Rate__c, Type , Settlement_Due_Days__c from Account where id = :POInvoiceInfo.Account__c limit 1];
			if(cusAccountInfo.Settlement_Due_Days__c == null)
				throw new CustomException('Please Enter Invoice Settlement Date for this account');
			else
				POInvoiceInfo.Invoice_Due_Date__c = date.newinstance(POInvoiceInfo.Invoice_Date__c.Year(),
															POInvoiceInfo.Invoice_Date__c.Month(),
															integer.valueof(POInvoiceInfo.Invoice_Date__c.day()+cusAccountInfo.Settlement_Due_Days__c) ) ;
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
		InvoiceDetails.purchaseInvoiceLineItems.Narrative__c = 'Item Name' ;
		InvoiceDetails.purchaseInvoiceLineItems.Quantity__c  = 0 ; 
		InvoiceDetails.purchaseInvoiceLineItems.Amount__c  = 0.00 ;
		InvoiceDetails.purchaseInvoiceLineItems.Total_VAT__c = 0.00 ;
		InvoiceDetails.purchaseInvoiceLineItems.Total_Gross__c = 0.00 ;	
		InvoiceDetails.purchaseInvoiceLineItems.Total_Net__c = 0.00 ;
	}
	public void addproductnewproductitem()
	{
		try
		{
			PurchaseInvoiceModel.validateLineDetails(InvoiceDetails , hdnNcId );
			selectedTax();
			Purchase_Invoice_Line_Item__c tmpItem = new Purchase_Invoice_Line_Item__c();	
			tmpItem.Narrative__c  = InvoiceDetails.purchaseInvoiceLineItems.Narrative__c ; 
			tmpItem.Quantity__c  = InvoiceDetails.purchaseInvoiceLineItems.Quantity__c ; 
			system.debug('this is Nc Id ' + hdnNcId);
			tmpItem.Nominal_Account__c = hdnNcId ; //InvoiceDetails.purchaseInvoiceLineItems.Nominal_Account__c ;
			tmpItem.Amount__c  = InvoiceDetails.purchaseInvoiceLineItems.Amount__c ;
			tmpItem.Tax_Rate__c   = InvoiceDetails.purchaseInvoiceLineItems.Tax_Rate__c ;
			tmpItem.Ready_To_Pay__c = InvoiceDetails.purchaseInvoiceLineItems.Ready_To_Pay__c ;
			tmpItem.Total_VAT__c  = InvoiceDetails.purchaseInvoiceLineItems.Total_VAT__c.setScale(2) ;
			tmpItem.Total_Net__c = InvoiceDetails.purchaseInvoiceLineItems.Total_Net__c ; 
			tmpItem.Total_Gross__c   = InvoiceDetails.purchaseInvoiceLineItems.Total_Gross__c.setScale(2) ;
			tmpItem.Opportunity__c  = InvoiceDetails.purchaseInvoiceLineItems.Opportunity__c;
			POInvoiceWrapper tmwrap = new POInvoiceWrapper(tmpItem);
			tmwrap.serialNumber = InvoiceDetailsList.size();
			tmwrap.taxRate = tax_rate ;
			InvoiceDetailsList.add(tmwrap);	
			clearValues();
			calculateTotals();
		}
		catch(exception e)
		{
			setNcIdName();
			apexpages.addMessages(e);
			//setNcIdName();
		}
	}
	public void selectedTax()
	{
	 	setNcIdName();
	 	if ( InvoiceDetails.purchaseInvoiceLineItems.Tax_Rate__c != null )
	 	{
	 		if (taxRateMap.keyset().contains(InvoiceDetails.purchaseInvoiceLineItems.Tax_Rate__c))
	 			tax_rate = taxRateMap.get(InvoiceDetails.purchaseInvoiceLineItems.Tax_Rate__c) ;
	 		else
	 			tax_rate = [Select Tax_Rate__c from Tax_Rate__c where Id = : InvoiceDetails.purchaseInvoiceLineItems.Tax_Rate__c].Tax_Rate__c;
	 		decimal taxamount  = InvoiceDetails.purchaseInvoiceLineItems.Amount__c.divide(100,3,system.roundingmode.up);
			taxamount = taxamount * tax_rate ;
			InvoiceDetails.purchaseInvoiceLineItems.Total_Net__c = InvoiceDetails.purchaseInvoiceLineItems.Amount__c * InvoiceDetails.purchaseInvoiceLineItems.Quantity__c ;
			InvoiceDetails.purchaseInvoiceLineItems.Total_VAT__c = taxamount * InvoiceDetails.purchaseInvoiceLineItems.Quantity__c ; 
			InvoiceDetails.purchaseInvoiceLineItems.Total_Gross__c = (InvoiceDetails.purchaseInvoiceLineItems.Amount__c * InvoiceDetails.purchaseInvoiceLineItems.Quantity__c ) +  InvoiceDetails.purchaseInvoiceLineItems.Total_VAT__c;
		}
	}
	private void setNcIdName()
	{
		system.debug('this is Nc Id :' + hdnNcId);
		if(hdnNcId!=null && hdnNcId !='')
		{
			system.debug('this is hdnNcId: ' + hdnNcId );
			system.debug('this is map: ' + ncMap );
			if (ncMap.keyset().contains(hdnNcId))
			{
				htmlNcId = 	ncMap.get(hdnNcId)[0];
				ncName = ncMap.get(hdnNcId)[1];
			}
			else
			{
				Nominal_Account__c nc = [Select Id , Name ,Nominal_Code__c from Nominal_Account__c where id = :hdnNcId] ;
				if (nc !=null)
				{
					htmlNcId = 	nc.Nominal_Code__c ;
					ncName = nc.Name ;
				}
			}
		}	
	}
	public void deletLineItem()
	{
		string index = string.valueof(decimal.valueof(apexpages.currentPage().getParameters().get('deleteId'))) ;
		InvoiceDetailsList.remove(Functions.getListIndex(index) );
		removeListItems();
		calculateTotals();
	}
	public void removeListItems()
	{
		List<POInvoiceWrapper> titems = new List<POInvoiceWrapper>();
		for (POInvoiceWrapper po : InvoiceDetailsList)
		{
			po.serialNumber = titems.size();// + 1;
			titems.add(po);
		}
		InvoiceDetailsList = titems ;
	}
	public void editLineItem()
	{
		system.debug('this is test :' + apexpages.currentPage().getParameters().get('editId') );
		string sIndex = string.valueof(decimal.valueof(apexpages.currentPage().getParameters().get('editId'))) ;
		integer index = Functions.getListIndex(sIndex) ;
		InvoiceDetails.purchaseInvoiceLineItems.Nominal_Account__c = InvoiceDetailsList[index].purchaseInvoiceLineItems.Nominal_Account__c ;
		if (ncMap.keyset().contains(InvoiceDetailsList[index].purchaseInvoiceLineItems.Nominal_Account__c))
		{
			htmlNcId = 	ncMap.get(InvoiceDetailsList[index].purchaseInvoiceLineItems.Nominal_Account__c)[0];
			ncName = ncMap.get(InvoiceDetailsList[index].purchaseInvoiceLineItems.Nominal_Account__c)[1];
			hdnNcId = InvoiceDetailsList[index].purchaseInvoiceLineItems.Nominal_Account__c;
		}
		else
		{
			Nominal_Account__c nc = [Select Id , Name ,Nominal_Code__c from Nominal_Account__c where id = :InvoiceDetailsList[index].purchaseInvoiceLineItems.Nominal_Account__c] ;
			if (nc !=null)
			{
				hdnNcId = nc.id;
				htmlNcId = 	nc.Nominal_Code__c ;
				ncName = nc.Name ;
			}
		}
		InvoiceDetails.purchaseInvoiceLineItems.Narrative__c  = InvoiceDetailsList[index].purchaseInvoiceLineItems.Narrative__c ; 
		InvoiceDetails.purchaseInvoiceLineItems.Quantity__c  = InvoiceDetailsList[index].purchaseInvoiceLineItems.Quantity__c ; 
		InvoiceDetails.purchaseInvoiceLineItems.Amount__c  = InvoiceDetailsList[index].purchaseInvoiceLineItems.Amount__c ;
		InvoiceDetails.purchaseInvoiceLineItems.Tax_Rate__c   = InvoiceDetailsList[index].purchaseInvoiceLineItems.Tax_Rate__c ;
		InvoiceDetails.purchaseInvoiceLineItems.Ready_To_Pay__c   = InvoiceDetailsList[index].purchaseInvoiceLineItems.Ready_To_Pay__c ;
		InvoiceDetails.purchaseInvoiceLineItems.Total_VAT__c  = InvoiceDetailsList[index].purchaseInvoiceLineItems.Total_VAT__c ;
		InvoiceDetails.purchaseInvoiceLineItems.Total_Gross__c   = InvoiceDetailsList[index].purchaseInvoiceLineItems.Total_Gross__c ;
		InvoiceDetails.purchaseInvoiceLineItems.Opportunity__c  = InvoiceDetailsList[index].purchaseInvoiceLineItems.Opportunity__c;
		tax_rate = InvoiceDetailsList[index].taxRate;
		InvoiceDetailsList.remove(index);
		removeListItems();
		calculateTotals();
	}
	public void calculateTotals()
	{
		PoAmount = PurchaseInvoiceModel.getTotalAmountt(InvoiceDetailsList) ; //getTotalAmount() ;
	 	totalTax = PurchaseInvoiceModel.getToTalTaxx(InvoiceDetailsList) ; //getToTalTax() ;
	 	wtAmount = PurchaseInvoiceModel.getTotalAmountExcludingTaxx(InvoiceDetailsList) ; //getTotalAmountExcludingTax() ;
	}
	public void clearValues()
	{
		InvoiceDetails.purchaseInvoiceLineItems.Narrative__c = 'Item Name' ;
		InvoiceDetails.purchaseInvoiceLineItems.Quantity__c  = 0 ; 
		InvoiceDetails.purchaseInvoiceLineItems.Amount__c  = 0.00 ;
		InvoiceDetails.purchaseInvoiceLineItems.Total_VAT__c = 0.00 ;
		InvoiceDetails.purchaseInvoiceLineItems.Total_Gross__c = 0.00 ;
		InvoiceDetails.purchaseInvoiceLineItems.Total_Net__c = 0.00 ;		
		InvoiceDetails.purchaseInvoiceLineItems.Opportunity__c = null ;
		InvoiceDetails.purchaseInvoiceLineItems.Nominal_Account__c = null ;
		InvoiceDetails.purchaseInvoiceLineItems.Tax_Rate__c = POInvoiceInfo.Account__r.Tax_Rate__c ;	
		tax_rate = 0.00 ;
		hdnNcId = null ;
		htmlNcId = null ;
		ncName = '' ;
	}
	public pagereference savePOI()
	{
		//throw new customexception('No Line Item in Purchase Invoice, Please Enter Line Items');
		Savepoint sp = Database.setsavepoint(); 
		try
		{
			PurchaseInvoiceModel poI = new PurchaseInvoiceModel(POInvoiceInfo);
			poI.saveOrder(InvoiceDetailsList ,'UPDATE' );
			return new PageReference('/'+ poI.PInvoice.Id);
		}
		catch(exception e)
		{
			Database.rollback(sp);
			apexpages.addMessages(e);
			return null ;
		}
	}
	
	
	
	// Test Classes for this module
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
		po.Status__c = 'Pending';
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
		EditPurchaseInvoice obj = new EditPurchaseInvoice(std);
		
		obj.InvoiceDetails.purchaseInvoiceLineItems = LineItem ;
		obj.htmlNcId = nm.id ;
		obj.setNcIdName();
		try
		{
			obj.addproductnewproductitem() ;
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage() , 'Please Enter Nominal Account For Line Item');
		}
		obj.hdnNcId = nm.id ;
		obj.addproductnewproductitem() ;
		apexpages.currentPage().getParameters().put('editId' , '0');
		obj.editLineItem();
		obj.addproductnewproductitem() ;
		obj.addproductnewproductitem() ;
		//obj.getProductPrice();
		
		List<selectoption> projectList  = obj.getAllTaxes() ; 
		obj.savePOI();
	}
	private static testmethod void TestPurchase_Order_AddEditController()
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
		po.Status__c = 'Pending';
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
		EditPurchaseInvoice obj = new EditPurchaseInvoice(std);
		
		
		
		obj.InvoiceDetails.purchaseInvoiceLineItems = LineItem ;
		obj.htmlNcId = nm.id ;
		obj.setNcIdName();
		try
		{
			obj.addproductnewproductitem() ;
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage() , 'Please Enter Nominal Account For Line Item');
		}
		
		obj.hdnNcId = nm.id ;
		obj.addproductnewproductitem() ;
		apexpages.currentPage().getParameters().put('deleteId' , '0');
		obj.deletLineItem();
		//obj.getProductPrice();
		
		List<selectoption> projectList  = obj.getAllTaxes() ; 
		obj.savePOI();
	}
	// end of test classes
	
}