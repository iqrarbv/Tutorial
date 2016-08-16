public class PurchaseOrderSubmit_Controller 
{
	/*
	public boolean sendBack {get; set;}
	public PurchaseOrderSubmit_Controller( apexpages.Standardcontroller submitPurchaseOrder )
	{
		
	}
	public void init()
	{
		Savepoint sp = Database.setsavepoint();
		try
		{
			Id poId = apexpages.currentPage().getParameters().get('id');
			PurchaseOrder pOrder = new PurchaseOrder(poId); 
			pOrder.SendApprovals(userinfo.getUserId());
			sendBack = true ;
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.confirm  , 'Purchase Order PO# ' +pOrder.po.Name + ' Is Submited for Approval' , '' ) );
		}
		catch(Exception ex)
		{
			sendBack = true ;
			Database.rollback(sp);
			apexpages.addmessages(ex);
		}
		
	}
	public pagereference back()
	{
		return new pagereference('/' + apexpages.currentPage().getParameters().get('id')) ;
	}
	private static testmethod void Test_Purchase_Order_AddEditController()
	{
		//preparing data for unit testing
		Account act = new Account(Name='ABC Company',Type='Supplier');
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, P_O__c = true, Name = 'Plumbering', Account_Code__c = 150);
		insert nm ;
		Opportunity op = new Opportunity(Name = 'Opportunity abc' , StageName = 'IIT' , Activity_Start__c = date.today(), Activity_End__c = date.today().addDays(5) , CloseDate = date.today().addDays(5));
		insert op;
		Opportunity subOp = new Opportunity(Name = 'Opportunity abc' , StageName = 'IIT' , Activity_Start__c = date.today(), Activity_End__c = date.today().addDays(5) , Sub_Project__c =op.Id , CloseDate = date.today().addDays(5));
		insert subOp;
		Approval_Limit__c aplimit = new Approval_Limit__c(Type__c = 'PurchaseOrder', Role_Name__c = 'FD', RoleId__c = '00E90000000QaFaEAK' , Amount__c = 1500) ;
		insert aplimit;
		Purchase_Order__c Cont = new Purchase_Order__c(Name = '00050' , Account__c = act.Id  , Order_Date__c = date.today() , Total_Gross__c = 25000 , Order_By__c = userinfo.getUserId() , Status__c = 'Pending');
		insert Cont ;
		//PurchaseOrderApprovals__c ap = new PurchaseOrderApprovals__c(User__c = userinfo.getUserId() , Status__c = 'Pending', Purchase_Order__c = Cont.Id, Level__c = 'Level1' , Is_Archived__c = false);
		//insert ap ;
		Purchase_Order_Line_Items__c tmpline = new Purchase_Order_Line_Items__c();
		tmpline.Serial_No__c = 1 ;
		tmpline.Amount__c = 7862164 ;
		tmpline.Total_Gross__c = 7862164 ;
		tmpline.Quantity__c = 1 ;
		tmpline.Narrative__c = 'item name' ;
		tmpline.VAT_Amount__c = 12 ;
		tmpline.Nominal_Account__c = nm.Id;
		tmpline.Tax_Rate__c = tx.id ;
		tmpline.Purchase_Order__c = Cont.id;
		tmpline.Project__c = op.Id ;
		tmpline.Sub_Project__c = subOp.Id ;
		insert tmpline ;
		//Purchase_Order__c Cont = [select Id from Purchase_Order__c limit 1];
		ApexPages.currentPage ().getParameters ().put ('id', Cont.id);    
        ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        PurchaseOrderSubmit_Controller objj  = new PurchaseOrderSubmit_Controller(stdCon);
        objj.init();
        objj.back();
        
        ApexPages.currentPage ().getParameters ().put ('id', null);
        objj.init();
	}
	*/
}