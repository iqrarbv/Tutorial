public class PurchaseOrder_Pdf 
{
	public Purchase_Order__c PurchaseOrderinfo {get; set;}
	public List<Purchase_Order_Line_Items__c> PoLineItems {get; set;} 
	public string UserName {get; set;}
	public string orderDate {get; set;}
	public decimal PoAmount {get;  set ; }
	public decimal totalTax {get; set;}
	public decimal wtAmount {get; set;}
	public boolean allowedit {get; set;}
	public decimal totalVat {get; set;}
	public decimal totalNetAmunt {get; set;}
	public boolean showPdf {get; set;}
	public List<POLineItemWrapper> Lineitems {get; set;}
	public string imageUrl {get; set;}
	public Invoice_Template__c invoiceTmpl {get; set;}
	public PurchaseOrder_Pdf( apexpages.Standardcontroller generatePdf )
	{
		//init();	
	}
	public PurchaseOrder_Pdf(  )
	{
		//init();	
	}
	public void init()
	{
		try
		{
			Id purchaseOrderId = apexpages.currentPage().getParameters().get('id');
			PurchaseOrderinfo  = [ Select p.CreatedBy.Name , p.Total_VAT__c, p.Total_Net__c, p.Total_Gross__c, p.Total_Amount__c, p.Supplier_Reference__c, p.Status__c, p.OwnerId, p.Order_Date__c, p.Order_By__c, p.Name, p.Id, p.Approved_By__c, p.Account__c From Purchase_Order__c p where p.Id = :purchaseOrderId limit 1];
			if (PurchaseOrderinfo.Status__c == 'Pending' || PurchaseOrderinfo.Status__c == 'Submitted_For_Approval' || PurchaseOrderinfo.Status__c == 'Rejected' )
			{
				showPdf =false;
				throw new CustomException(PurchaseOrderinfo.Name +' is not Approved, You Cannot View Purchase Order Pdf ');
			}
			List<Invoice_Template__c> invTmpl = [Select i.Footer_Text__c  , i.Name, i.Margins_top_bottom__c, i.Margins_left_right_Inches__c, i.Heading_Text__c, i.Font_Size__c, i.Font_Face__c From Invoice_Template__c i where Is_Default__c = true];
			if(invTmpl.size() == 0)
				throw new CustomException('No Default Template Found , Please select Template as default');
			else
				invoiceTmpl = invTmpl[0] ;
			List<Attachment> att = [Select a.ParentId, a.Name, a.Id, a.Description, a.ContentType, a.BodyLength, a.Body From Attachment a where a.ParentId = : invoiceTmpl.id  limit 1];
			if(att.size() > 0 )
				imageUrl = 'https://'+apexpages.currentPage().getHeaders().get('host').substring(0 ,apexpages.currentPage().getHeaders().get('host').indexOf('.',2))+'.content.force.com/servlet/servlet.FileDownload?file='+string.valueof(att[0].id) ;
			else
				throw new CustomException('No Invoice Logo Found for Default Template, Please Upload Logo for Default Template');
			showPdf = true ;
			orderDate = PurchaseOrderinfo.Order_Date__c.format();
			Lineitems = new List<POLineItemWrapper>();
			for (Purchase_Order_Line_Items__c poI : [Select p.UID__c, p.Total_Gross__c, p.Total_Amount__c, p.Tax_Rate__c, p.Tax_Rate__r.Tax_Rate__c,p.Total_VAT__c, p.Serial_No__c, p.Quantity__c, p.Purchase_Order__c, p.Product__c,p.Product__r.Name, p.Opportunity__c,p.Opportunity__r.Name, p.Narrative__c, p.Name, p.Item_Received__c, p.IsDeleted, p.Id, p.Amount__c From Purchase_Order_Line_Items__c p where p.Purchase_Order__c = :purchaseOrderId])
			{
				POLineItemWrapper tmwrap = new POLineItemWrapper(poI);
				tmwrap.serialNumber = Lineitems.size();
				tmwrap.taxRate = poI.Tax_Rate__r.Tax_Rate__c ;
				Lineitems.add(tmwrap);	
			}
		}
		catch(exception e)
		{
			apexpages.addMessages(e);	
		}
		
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
		Purchase_Order__c Cont = new Purchase_Order__c(Name = '00050' , Account__c = act.Id  , Order_Date__c = date.today() , Status__c = 'Approved' , Order_By__c = userinfo.getUserId());
		insert Cont ;
		Purchase_Order_Line_Items__c tmpline = new Purchase_Order_Line_Items__c();
		tmpline.Serial_No__c = 1 ;
		tmpline.Amount__c = 20 ;
		tmpline.Total_Gross__c = 20 ;
		tmpline.Quantity__c = 1 ;
		tmpline.Narrative__c = 'item name' ;
		tmpline.Total_VAT__c = 0 ;
		//tmpline.Nominal_Account__c = nm.Id;
		tmpline.Tax_Rate__c = tx.id ;
		tmpline.Purchase_Order__c = Cont.id;
		insert tmpline ;
		//Purchase_Order__c Cont = [select Id from Purchase_Order__c limit 1];
		ApexPages.currentPage ().getParameters ().put ('deleteId', Cont.id);
		ApexPages.currentPage ().getParameters ().put ('id', Cont.id);    
        ApexPages.StandardController stdCon = new ApexPages.StandardController (Cont);
        PurchaseOrder_Pdf objj  = new PurchaseOrder_Pdf(stdCon);
        objj.init();
        Cont = new Purchase_Order__c(Name = '00050' , Account__c = act.Id  , Order_Date__c = date.today() , Status__c = 'Pending' , Order_By__c = userinfo.getUserId());
		insert Cont ;
		ApexPages.currentPage ().getParameters ().put ('id', Cont.id);
		try
		{
			objj.init();
		}
		catch (exception e)
		{
			system.assertEquals(Cont.Name +' is not Approved, You Cannot View Purchase Order Pdf ', e.getMessage());
		}
		ApexPages.currentPage ().getParameters ().put ('id', null );
		objj.init();
		
	}
}