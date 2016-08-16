public class SalesOrderSubmit_Controller 
{
	/*
	public boolean sendBack {get; set;}
	public SalesOrderSubmit_Controller( apexpages.Standardcontroller submitSalesOrder)
	{
		//init();
	}
	public SalesOrderSubmit_Controller()
	{
		//init();
	}
	public void init()
	{
		Savepoint sp = Database.setsavepoint(); 
		try
		{
			Id orderId  = apexpages.currentPage().getParameters().get('id');
			if (orderId != null)
			{
				Sales_Order__c sOrder = [select Account__r.Name , Customer_Order_No__c , Status__c , Total_Gross__c, Supplier_Reference__c, OwnerId, Order_Date__c, Order_By__c, Order_By__r.Name ,  Name,  IsDeleted, Id, CreatedById,  Approved_By__c, Account__c from  Sales_Order__c where Id =:orderId limit 1];
				if ( sOrder.OwnerId != userinfo.getUserId() )
				{
					apexpages.addMessage(new apexpages.Message( apexpages.Severity.info  , 'You are not authorized to view or submitt Sales Order ' +sOrder.Name  , '' ) );
					sendBack = true ;
					return ;	
				}
				else if ( sOrder.Status__c == 'Submitted_For_Approval' )
				{
					apexpages.addMessage(new apexpages.Message( apexpages.Severity.info  , 'Sales Order SO# ' +sOrder.Name + ' Is Already Submitted for apprval' , '' ) );
					sendBack = true ;
					return ;	
				}
				else if (sOrder.Status__c == 'Approved')
				{
					apexpages.addMessage(new apexpages.Message( apexpages.Severity.info  , 'Sales Order SO# ' +sOrder.Name + ' Is Already Approved' , '' ) );
					sendBack = true ;
					return ;	
				}
				sOrder.Status__c = 'Submitted_For_Approval';
				update sOrder ;
				SalesOrder_model so = new SalesOrder_model(sOrder);
				so.SendApprovals();
				apexpages.addMessage(new apexpages.Message( apexpages.Severity.info  , 'Sales Order SO# ' +sOrder.Name + ' Is Submited for Approval' , '' ) );
				sendBack = true ; 
			}	
			else 
			{
				apexpages.addMessage(new apexpages.Message( apexpages.Severity.error  , 'Invalid Sales Order Id' , '' ) );	
				sendBack = true ;	
			}
		}
		catch(exception e)
		{
			sendBack = true ;
			Database.rollback(sp);
			apexpages.addMessages(e);
		}
	}
	public pagereference back()
	{
		return new pagereference('/' + apexpages.currentPage().getParameters().get('id')) ;
	}
	public static TestMethod void testDeleteSalesOrder()
	{
		Account act = new Account(Name='ABC Company',Type='Customer - Direct');
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, S_O__c = true, Name = 'Plumbering', Account_Code__c = 150);
		insert nm ;
		//List<Purchase_Order_Line_Items__c> poItems = new List<Purchase_Order_Line_Items__c>(); 
		Sales_Order__c Cont = new Sales_Order__c(Quote_Number__c = '0001' , Name = '00050' , Account__c = act.Id  , Order_Date__c = date.today() , Total_Gross__c = 22000 , Status__c = 'Pending' , Order_By__c = userinfo.getUserId());
		insert Cont ;
		Sales_Order_Line_Items__c tmpline = new Sales_Order_Line_Items__c();
		tmpline.Serial_No__c = 1 ;
		tmpline.Amount__c = 20 ;
		tmpline.Total_Gross__c = 22000 ;
		tmpline.Quantity__c = 1 ;
		tmpline.Narrative__c = 'item name' ;
		tmpline.VAT_Amount__c = 0 ;
		tmpline.Nominal_Account__c = nm.Id;
		tmpline.Tax_Rate__c = tx.id ;
		tmpline.Sales_Order__c = Cont.Id ;
		insert tmpline ;
		//Purchase_Order__c Cont = [select Id from Purchase_Order__c limit 1];
		ApexPages.currentPage ().getParameters ().put ('id', Cont.id);
		//ApexPages.currentPage ().getParameters ().put ('delID', Cont.id);    
        ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        SalesOrderSubmit_Controller obj  = new SalesOrderSubmit_Controller();
		obj.init();
		obj.back();
		Cont = new Sales_Order__c(Quote_Number__c = '0001' , Name = '00050' , Account__c = act.Id  , Order_Date__c = date.today() , Total_Gross__c = 5000 , Status__c = 'Pending' , Order_By__c = userinfo.getUserId());
		insert Cont ;
		tmpline = new Sales_Order_Line_Items__c();
		tmpline.Serial_No__c = 1 ;
		tmpline.Amount__c = 20 ;
		tmpline.Total_Gross__c = 5000 ;
		tmpline.Quantity__c = 1 ;
		tmpline.Narrative__c = 'item name' ;
		tmpline.VAT_Amount__c = 0 ;
		tmpline.Nominal_Account__c = nm.Id;
		tmpline.Tax_Rate__c = tx.id ;
		tmpline.Sales_Order__c = Cont.Id ;
		insert tmpline ;
		ApexPages.currentPage ().getParameters ().put ('id', Cont.id);
        obj.init();
        Cont = new Sales_Order__c(Quote_Number__c = '0001' , Name = '00050' , Account__c = act.Id  , Order_Date__c = date.today() , Total_Gross__c = 500000 , Status__c = 'Pending' , Order_By__c = userinfo.getUserId());
		insert Cont ;
		tmpline = new Sales_Order_Line_Items__c();
		tmpline.Serial_No__c = 1 ;
		tmpline.Amount__c = 20 ;
		tmpline.Total_Gross__c = 500000 ;
		tmpline.Quantity__c = 1 ;
		tmpline.Narrative__c = 'item name' ;
		tmpline.VAT_Amount__c = 0 ;
		tmpline.Nominal_Account__c = nm.Id;
		tmpline.Tax_Rate__c = tx.id ;
		tmpline.Sales_Order__c = Cont.Id ;
		insert tmpline ;
		ApexPages.currentPage ().getParameters ().put ('id', Cont.id);
        obj.init();
	}
	public static TestMethod void testDeleteSalesOrderNull()
	{
		//ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        Account act = new Account(Name='ABC Company',Type='Customer - Direct');
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, S_O__c = true, Name = 'Plumbering', Account_Code__c = 150);
		insert nm ;
		//List<Purchase_Order_Line_Items__c> poItems = new List<Purchase_Order_Line_Items__c>(); 
		List<SOLineItemWrapper> poItems = new List<SOLineItemWrapper>();
		Sales_Order_Line_Items__c tmpline = new Sales_Order_Line_Items__c();
		tmpline.Serial_No__c = 1 ;
		tmpline.Amount__c = 20 ;
		tmpline.Total_Gross__c = 20 ;
		tmpline.Quantity__c = 1 ;
		tmpline.Narrative__c = 'item name' ;
		tmpline.VAT_Amount__c = 0 ;
		tmpline.Nominal_Account__c = nm.Id;
		tmpline.Tax_Rate__c = tx.id ;
		//tmpline.Purchase_Order__c = po.id;
		//poItems.add(tmpline);
		poItems.add( new  SOLineItemWrapper(tmpline));
		//insert poItems;
		Sales_Order__c Cont = new Sales_Order__c(Quote_Number__c = '0001' ,  Name = '00050' , Account__c = act.Id  , Order_Date__c = date.today() , Total_Gross__c = 150 , Status__c = 'Approved' , Order_By__c = userinfo.getUserId());
		insert Cont ;
		tmpline = new Sales_Order_Line_Items__c();
		tmpline.Serial_No__c = 1 ;
		tmpline.Amount__c = 20 ;
		tmpline.Total_Gross__c = 20 ;
		tmpline.Quantity__c = 1 ;
		tmpline.Narrative__c = 'item name' ;
		tmpline.VAT_Amount__c = 0 ;
		tmpline.Nominal_Account__c = nm.Id;
		tmpline.Tax_Rate__c = tx.id ;
		tmpline.Sales_Order__c = Cont.Id ;
		insert tmpline ;
		//Purchase_Order__c Cont = [select Id from Purchase_Order__c limit 1];
		//ApexPages.currentPage ().getParameters ().put ('id', Cont.id);
		//ApexPages.currentPage ().getParameters ().put ('delID', Cont.id);    
        ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        SalesOrderSubmit_Controller obj  = new SalesOrderSubmit_Controller();
		obj.init();
	}
    public static TestMethod void testDeleteSalesOrderNouser()
	{
		//ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        Account act = new Account(Name='ABC Company',Type='Customer - Direct');
		insert act;
		Sales_Order__c Cont = new Sales_Order__c(Quote_Number__c = '0001' , Name = '00050' , Account__c = act.Id  , Order_Date__c = date.today() , Total_Gross__c = 150 , Status__c = 'Approved' , Order_By__c = null );
		insert Cont ;
		//Purchase_Order__c Cont = [select Id from Purchase_Order__c limit 1];
		ApexPages.currentPage ().getParameters ().put ('id', Cont.id);
		//ApexPages.currentPage ().getParameters ().put ('delID', Cont.id);    
        ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        SalesOrderSubmit_Controller obj  = new SalesOrderSubmit_Controller();
		obj.init();
    }
    public static TestMethod void testDeleteSalesApproved()
	{
		//ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        Account act = new Account(Name='ABC Company',Type='Customer - Direct');
		insert act;
		Sales_Order__c Cont = new Sales_Order__c(Quote_Number__c = '0001' , Name = '00050' , Account__c = act.Id  , Order_Date__c = date.today() , Total_Gross__c = 150 , Status__c = 'Approved' );
		insert Cont ;
		//Purchase_Order__c Cont = [select Id from Purchase_Order__c limit 1];
		ApexPages.currentPage ().getParameters ().put ('id', Cont.id);
		//ApexPages.currentPage ().getParameters ().put ('delID', Cont.id);    
        ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        SalesOrderSubmit_Controller obj  = new SalesOrderSubmit_Controller();
		obj.init();
    }
    */
}