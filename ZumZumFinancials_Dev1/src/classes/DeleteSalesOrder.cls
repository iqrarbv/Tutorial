public class DeleteSalesOrder 
{
	public boolean disableDelete {get; set;}
	private id deleteId {get; set;}
	public DeleteSalesOrder( apexpages.Standardcontroller deleteSalesOrder )
	{
		deleteId = apexpages.currentPage().getParameters().get('delID');
		apexpages.addMessage(new apexpages.Message( apexpages.Severity.info , 'Are you Sure to Delete this Sales Order?', '' ) );
		disableDelete = true ;		
	}
	public DeleteSalesOrder( )
	{
		
	}
	public pagereference init()
	{
		Savepoint sp = Database.setsavepoint(); 
		try
		{
			if ( deleteId !=null || deleteId !='' )
			{
				Sales_Order__c sO = [select Id , Status__c , Name from Sales_Order__c where Id =: deleteId ];
				if ( sO.Status__c == 'Pending' || sO.Status__c == 'Rejected' )
				{
					delete sO;
					return new pagereference( apexpages.currentPage().getParameters().get('retURL'));
				}
				else 
				{
					disableDelete = false ;
					throw new CustomException( 'Sales Order PO# ' + sO.Name + ' is ' + sO.Status__c + ' It can\'t be deleted' );
					return null ;	
				}
			}
			else 
			{
				return null ;
			}
		}
		catch (exception e)
		{
			Database.rollback(sp);
			apexpages.addMessages(e);
			return null ;
		}
	}
	public pagereference back()
	{
		return new pagereference ('/' +  deleteId  ) ;	
	}
	//start of test Methods
	//*********************
	//*********************
	public static TestMethod void testDeleteSalesOrder()
	{
		Account act = new Account(Name='ABC Company',Type='Customer');
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
		tmpline.Total_Amount__c = 20 ;
		tmpline.Quantity__c = 1 ;
		tmpline.Narrative__c = 'item name' ;
		tmpline.VAT_Amount__c = 0 ;
		tmpline.Nominal_Account__c = nm.Id;
		tmpline.Tax_Rate__c = tx.id ;
		//tmpline.Purchase_Order__c = po.id;
		//poItems.add(tmpline);
		poItems.add( new  SOLineItemWrapper(tmpline));
		//insert poItems;
		Sales_Order__c Cont = new Sales_Order__c(Quote_Number__c = '0001' , Name = '00050' , Account__c = act.Id  , Order_Date__c = date.today() , Status__c = 'Pending' , Order_By__c = userinfo.getUserId());
		insert Cont ;
		tmpline = new Sales_Order_Line_Items__c();
		tmpline.Serial_No__c = 1 ;
		tmpline.Amount__c = 20 ;
		tmpline.Total_Amount__c = 20 ;
		tmpline.Quantity__c = 1 ;
		tmpline.Narrative__c = 'item name' ;
		tmpline.VAT_Amount__c = 0 ;
		tmpline.Nominal_Account__c = nm.Id;
		tmpline.Tax_Rate__c = tx.id ;
		tmpline.Sales_Order__c = Cont.Id ;
		insert tmpline ;
		//Purchase_Order__c Cont = [select Id from Purchase_Order__c limit 1];
		ApexPages.currentPage ().getParameters ().put ('retURL', Cont.id);
		ApexPages.currentPage ().getParameters ().put ('delID', Cont.id);    
        ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        DeleteSalesOrder obj  = new DeleteSalesOrder();
		obj.init();
		obj.back();
	}
	public static TestMethod void testDeleteSalesOrderNull()
	{
		//ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        DeleteSalesOrder obj  = new DeleteSalesOrder();
		obj.init();
		obj.back();
	}
	public static TestMethod void testDeleteSalesOrderSubmitted()
	{
		Account act = new Account(Name='ABC Company',Type='Customer');
		insert act;
		Sales_Order__c Cont = new Sales_Order__c( Quote_Number__c = '0001' , Name = '00050' , Account__c = act.Id  , Order_Date__c = date.today() , Status__c = 'Submitted_For_Approval' , Order_By__c = userinfo.getUserId());
		insert Cont ;
		ApexPages.currentPage ().getParameters ().put ('retURL', Cont.id);
		ApexPages.currentPage ().getParameters ().put ('delID', Cont.id);
		ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        DeleteSalesOrder obj  = new DeleteSalesOrder();
		try{
		obj.init();
		}
		catch(exception e)
		{
			system.assertEquals('Sales Order PO# ' + Cont.Name + ' is ' + Cont.Status__c + ' It can\'t be deleted', e.getMessage());
		}
		obj.back();
	}
	//*********************
	//*********************
	//end of test Methods 
}