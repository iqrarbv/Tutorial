public class RecievedGoodsController 
{
	public Purchase_Order__c PurchaseOrders {set; get;}
	public list<Purchase_Order_Line_Items__c> PoLineItems {get; set;}
	public decimal totalTax {get; set;}
	public decimal wtAmount {get; set;}
	public decimal PoAmount {get; set;}
	public string UserName {get; set;}
	public string orderdate {get; set;}
	public string accountName {get; set;}
	public List<POLineItemWrapper> Lineitems {get; set;}
	public string currencySymbol {get; set;}
	public boolean showPage {get; set;}
	public Id PoId {get; set;}
	public RecievedGoodsController (apexpages.Standardcontroller goodsController)
	{
		init();	
	}
	public void init()
	{
		try
		{
			PoId = apexpages.currentPage().getParameters().get('id');
			PurchaseOrders  = [Select Status__c , Total_VAT__c  , Total_Net__c , Total_Gross__c, Supplier_Reference__c, OwnerId, Order_Date__c, Order_By__c, Name, IsDeleted, Id, CreatedById, Approved_By__c, Account__c From Purchase_Order__c where Id = :PoId];
			if(PurchaseOrders.Status__c == 'Pending' || PurchaseOrders.Status__c == 'Rejected')
			{
				showPage = false;
				throw new customexception('Purchase Order # ' + PurchaseOrders.Name + ' is not approved you can\'t send order for recieving goods');
			}
			showPage = true ;
			UserName = [Select Name from User where Id = :PurchaseOrders.OwnerId].Name ; 
			accountName = [select Name from Account where Id = : PurchaseOrders.Account__c].Name;
			PoLineItems = [Select Item_Received__c , Total_Gross__c, Total_VAT__c, Quantity__c, Purchase_Order__c, Narrative__c, Name, Id, Delete__c, Amount__c , Tax_Rate__c , Serial_No__c From Purchase_Order_Line_Items__c where Purchase_Order__c = :PurchaseOrders.Id] ;
			currencySymbol = Functions.getOrganisationCurrency('CurrencySymbol') ;
			Lineitems = new List<POLineItemWrapper>();
			for (Purchase_Order_Line_Items__c po : [Select p.Item_Received__c ,p.Tax_Rate__r.Tax_Rate__c , p.Total_Gross__c  ,p.Tax_Rate__c ,p.Amount__c  , p.Total_VAT__c, p.Quantity__c, p.Purchase_Order__c, p.Product__c, p.Product__r.Name,p.Opportunity__c, p.Narrative__c, p.Name From Purchase_Order_Line_Items__c p where p.Purchase_Order__c = : PurchaseOrders.Id ])
			{
				POLineItemWrapper tmwrap = new POLineItemWrapper(po);
				tmwrap.serialNumber = Lineitems.size();
				tmwrap.taxRate = po.Tax_Rate__r.Tax_Rate__c ;
				Lineitems.add(tmwrap);	
			}
			orderdate = PurchaseOrders.Order_Date__c.format();
		}
		catch (exception e )
		{
			apexpages.addMessages( e);
		}
	}
	public pagereference back()
	{
		return new pagereference('/' + PoId);
	}
	public void Save_order()
	{
		Savepoint sp = Database.setsavepoint();
		try 
		{	
			string status = 'All Items Received' ;
			for (POLineItemWrapper lm : Lineitems)
			{
				if (lm.purchaseOrderLineItems.Item_Received__c == false)
					status = 'Goods Partially Recieved' ;
				update lm.purchaseOrderLineItems;
			}
			PurchaseOrders.Status__c = status ;
			upsert PurchaseOrders ;
			//upsert Lineitems.purchaseOrderLineItems ;
			apexpages.addMessage( new apexpages.Message(apexpages.severity.info , 'Goods information Updated' , '' ));
		}
		catch (exception e )
		{
			Database.rollback(sp);
			apexpages.addMessage( new apexpages.Message(apexpages.severity.error , e.getMessage() , '' ));
		}
	}
	private static testmethod void GoodsRecieved()
	{
		//preparing data for unit testing
		Account act = new Account(Name='ABC Company',Type='Supplier');
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Nominal_Account__c nm = new Nominal_Account__c (Tax_Rate__c = tx.Id, P_O__c = true, Name = 'Plumbering', Account_Code__c = 150);
		insert nm ;
		//List<Purchase_Order_Line_Items__c> poItems = new List<Purchase_Order_Line_Items__c>(); 
		List<POLineItemWrapper> poItems = new List<POLineItemWrapper>();
		Purchase_Order_Line_Items__c tmpline = new Purchase_Order_Line_Items__c();
		tmpline.Serial_No__c = 1 ;
		tmpline.Amount__c = 20 ;
		tmpline.Total_Gross__c = 20 ;
		tmpline.Quantity__c = 1 ;
		tmpline.Narrative__c = 'item name' ;
		tmpline.Total_VAT__c = 0 ;
		tmpline.Tax_Rate__c = tx.id ;
		poItems.add( new  POLineItemWrapper(tmpline));
		//insert poItems;
		tmpline = new Purchase_Order_Line_Items__c();
		tmpline.Serial_No__c = 1 ;
		tmpline.Amount__c = 20 ;
		tmpline.Total_Gross__c = 20 ;
		tmpline.Quantity__c = 1 ;
		tmpline.Narrative__c = 'item name' ;
		tmpline.Total_VAT__c = 0 ;
		tmpline.Tax_Rate__c = tx.id ;
		tmpline.Item_Received__c = false ;
		POLineItemWrapper powrapper = new POLineItemWrapper(tmpline);
		powrapper.taxselected = false ;
		poItems.add(powrapper);
		Purchase_Order__c Cont = new Purchase_Order__c(Name = '00050' , Account__c = act.Id  , Order_Date__c = date.today() );
		insert Cont ;
		//Purchase_Order__c Cont = [select Id from Purchase_Order__c limit 1];
		ApexPages.currentPage ().getParameters ().put ('deleteId', Cont.id);
		ApexPages.currentPage ().getParameters ().put ('id', Cont.id);    
        ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        RecievedGoodsController objj  = new RecievedGoodsController(stdCon);
        objj.init();
        objj.Save_order();
	}
	private static testmethod void GoodsRecievednull()
	{
		//preparing data for unit testing
		Account act = new Account(Name='ABC Company',Type='Supplier');
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Opportunity op = new Opportunity(Name = 'Opportunity abc' , StageName = 'IIT' , Activity_Start__c = date.today(), Activity_End__c = date.today().addDays(5) , CloseDate = date.today().addDays(5));
		insert op;
		
		Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Nominal_Account__c nm = new Nominal_Account__c (Tax_Rate__c = tx.Id, P_O__c = true, Name = 'Plumbering', Account_Code__c = 150);
		insert nm ;  
		//List<Purchase_Order_Line_Items__c> poItems = new List<Purchase_Order_Line_Items__c>(); 
		
		Product2 product = new Product2 (ProductCode = 'TST', Name = 'Test Product', IsActive = true , Description = 'I am writing Test Classes');
		insert product ;
		
		Pricebook2 proBook = new Pricebook2(Name = 'Testing', IsActive = true , Description = 'Testing Description' );
		insert proBook ;
		proBook = new Pricebook2(Name = 'Testing 2', IsActive = true , Description = 'Testing Description ' );
		insert proBook ;
		
		Purchase_Order__c Cont = new Purchase_Order__c(Name = '00050' , Account__c = act.Id  , Order_Date__c = date.today() , status__c = 'Approved' );
		insert Cont ;
		
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
		LineItem.Purchase_Order__c = Cont.Id ;
		insert LineItem ;
		
		//Purchase_Order__c Cont = [select Id from Purchase_Order__c limit 1];
		//ApexPages.currentPage ().getParameters ().put ('deleteId', Cont.id);
		ApexPages.currentPage ().getParameters ().put ('id', Cont.id);    
        ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        RecievedGoodsController objj  = new RecievedGoodsController(stdCon);
    	objj.init();
    	objj.PurchaseOrders = null;
    	objj.Save_order();
    	objj.back();
    }
}