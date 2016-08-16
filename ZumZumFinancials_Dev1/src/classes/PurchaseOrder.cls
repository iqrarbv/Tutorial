public class PurchaseOrder 
{
	public static string errorMessage {get; set;}
	public CompanySetup__c cs {get; set; }
	public Purchase_Order__c po {get;set;}
	private List<General_Setup__c> Gsetup {get; set;}
	
	public PurchaseOrder(Purchase_Order__c p)
	{
		po = p;	
	}
	
	/*
	public PurchaseOrder()
	{}
	public PurchaseOrder(Id poId)
	{
		List<Purchase_Order__c> polist = [Select p.Total_Gross__c, p.Supplier_Reference__c, p.Status__c, p.OwnerId, p.Owner.Name, p.Owner.Email, p.Owner.UserRoleId, p.Order_Date__c, p.Name, p.IsDeleted, p.Id, p.CreatedDate, p.CreatedById, p.Approved_By__c, p.Account__c , Account__r.Name From Purchase_Order__c p Where Id=: poId];
		if(polist.size()==0)
		{
			throw new CustomException('Purchase Order record not found for id:'+poId);
		}
		po = polist[0];		
	}
	*/
	public static void validateLineDetails(POLineItemWrapper poItem)
	{
		if (poItem.purchaseOrderLineItems.Product__c == null )
			throw new CustomException('Please Select Product For Line Item');
		else if (poItem.purchaseOrderLineItems.Narrative__c == null || poItem.purchaseOrderLineItems.Narrative__c == '')
			throw new CustomException('Please Enter Narrative Description For Line Item');
		else if (poItem.purchaseOrderLineItems.Quantity__c == null || poItem.purchaseOrderLineItems.Quantity__c <= 0 )
			throw new CustomException('Quantity must be Greater than Zero');
		else if (poItem.purchaseOrderLineItems.Amount__c == null || poItem.purchaseOrderLineItems.Amount__c <= 0)
			throw new CustomException('Amount Must be Greator then Zero');
		else if (poItem.purchaseOrderLineItems.Tax_Rate__c == null )
			throw new CustomException('Please Select Tax Rate For Line Item');
	}
	public static decimal getTotalAmountt(List<POLineItemWrapper> PoLineItems)
	{
		decimal PoAmount = 0 ;
		for (POLineItemWrapper a: PoLineItems)
		{
		 	PoAmount += a.purchaseOrderLineItems.Total_Gross__c ;  
		}
		return PoAmount ;
	}
	
	public static decimal getToTalTaxx(List<POLineItemWrapper> PoLineItems)
	{
		decimal totalTax = 0 ;
		for (POLineItemWrapper a: PoLineItems)
		{
		 	totalTax += (a.purchaseOrderLineItems.Total_VAT__c);//  * a.purchaseOrderLineItems.Quantity__c ;  
		}
		return totalTax ;	
	}
	
	public static decimal getTotalAmountExcludingTaxx(List<POLineItemWrapper> PoLineItems)
	{
		decimal wtAmount = 0 ;
		for (POLineItemWrapper a: PoLineItems)
		{
		 	wtAmount += (a.purchaseOrderLineItems.Amount__c) * a.purchaseOrderLineItems.Quantity__c ;
		}
		return wtAmount ;	
	}
	public integer getOrderNumber()
	{
		integer ordernumber ; 
		Gsetup = new List<General_Setup__c>() ;
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'Purchase Order' limit 1] ; 
		if (Gsetup.size()>0)
		{
			if (Gsetup[0].Current_Document_Number__c == null)
				throw new CustomException ('Please enter starting PO Transaction #. & current document number in GENERAL SETUP');
			if (Gsetup[0].Current_Document_Number__c == -1)
			{
				ordernumber  = 	integer.valueof(Gsetup[0].Starting_Document_No__c) ; 
			}
			else 
			{
				string dc_curentno = string.valueof(Gsetup[0].Current_Document_Number__c);
                ordernumber  = 	integer.valueof(dc_curentno) ;
                ordernumber += 1 ;	
			}
		}
		else
		{
			throw new customException('Please enter starting PO#. in GENERAL SETUP for Sales Orders');
		}
		return ordernumber ;
	}
	public static string getOrderNo(string orderNo)
	{
		if (orderNo.length() < 6)
		{
			integer ln = 6 - orderNo.length();
			for (integer i=0 ; i<ln ; i++)
			{
				orderNo  = '0'+ orderNo;
			}
		}
		return orderNo ;
	}
	public void updateOrderNo(integer currentOrderNo)
	{
		Gsetup = new List<General_Setup__c>() ;
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'Purchase Order' limit 1] ; 
		Gsetup[0].Current_Document_Number__c = currentOrderNo ;
		update Gsetup ;
	}
	// start Of DML code 
	// start of Data Validation function
	//*********************************
	//*********************************
	public void saveOrder(Purchase_Order__c PurchaseOrders , List<POLineItemWrapper> wrrapedPoLineItems ,  string actionType)
	{
		//Savepoint sp = Database.setsavepoint(); 	
		try 
		{
			if (actionType == 'INSERT')
			{
				validate_Purchase_Order(po);
				if (wrrapedPoLineItems.size() <= 0)
					throw new customexception('No Line Item in Purchase Order, Please Enter Line Items');
				list<Purchase_Order_Line_Items__c> PoLineItems = new list<Purchase_Order_Line_Items__c>();
				PoLineItems = getWrapperToObject(wrrapedPoLineItems) ;
				integer orderNumber = getOrderNumber();
				po.Name = getOrderNo(string.valueOf(orderNumber));
				po.Status__c = 'Pending' ;
				upsert po ;
				updateOrderNo(orderNumber);
				PoLineItems = getPurchaseOrderLineItems(PoLineItems , po.Id );
				upsert PoLineItems ;
			}
			else if (actionType == 'UPDATE')
			{
				validate_Purchase_Order(po);
				if (wrrapedPoLineItems.size() <= 0)
					throw new customexception('No Line Item in Purchase Order, Please Enter Line Items');
				po.Status__c = 'Pending' ;
				list<Purchase_Order_Line_Items__c> PoLineItems = new list<Purchase_Order_Line_Items__c>();
				PoLineItems = getWrapperToObject(wrrapedPoLineItems) ;
				delete [select Id from Purchase_Order_Line_Items__c where Purchase_Order__c = :po.Id ];
				upsert po ;
				PoLineItems = getPurchaseOrderLineItems(PoLineItems , po.Id );
				upsert PoLineItems ;
			}
		}
		catch(exception e  )
		{
			//Database.rollback(sp);
			po.clone(false,true);
			throw new CustomException( e.getMessage() ) ; 
		}
	}
	public list<Purchase_Order_Line_Items__c> getPurchaseOrderLineItems(list<Purchase_Order_Line_Items__c> sOLineItems , Id orderId)
	{
		for (Purchase_Order_Line_Items__c item : sOLineItems)
		{
			item.Purchase_Order__c = orderId ;
		}
		return sOLineItems ; 
	}
	//*********************************
	//*********************************
	// end of DML Code
	// start of Data Validation function
	//*********************************
	//*********************************
	private void validate_Purchase_Order(Purchase_Order__c pOrderInfo)
	{
		if(pOrderInfo.Account__c == null )
			throw new CustomException('Please Select Account for Purchase Order');	
		else if ( pOrderInfo.Order_Date__c == null )
			throw new CustomException('Please Enter Order Date');
		else if ( pOrderInfo.Order_Date__c < date.today())
			throw new CustomException('Please Enter Valid Date');
		else if (pOrderInfo.Supplier_Reference__c != null && pOrderInfo.Supplier_Reference__c != '')
		{
			Pattern a=Pattern.compile('^[a-zA-Z0-9 ]+$');
	        Matcher m=a.matcher(pOrderInfo.Supplier_Reference__c);
	        boolean adit_info=m.matches();
	       	if(adit_info == false)
	        	throw new CustomException('Supplier Reference Contains Invalid Characters');
	        else
	        {
	        	//return true ;
	        }
		}
	}
	
	//*********************************
	//*********************************
	// end of Data Validation functions
	// Start of utility fucntions
	//*********************************
	//*********************************
	public List<Purchase_Order_Line_Items__c> getWrapperToObject(List<POLineItemWrapper> wrappervalues)
	{	
		List<Purchase_Order_Line_Items__c> lineItems = new List<Purchase_Order_Line_Items__c>();
		for (POLineItemWrapper wrO :  wrappervalues)
		{
			Purchase_Order_Line_Items__c lineitem = new Purchase_Order_Line_Items__c();
			lineitem.Name = wrO.purchaseOrderLineItems.Narrative__c.length()>80?(wrO.purchaseOrderLineItems.Narrative__c.substring(0,75)+' ...'):wrO.purchaseOrderLineItems.Narrative__c ;
			lineitem.Narrative__c = wrO.purchaseOrderLineItems.Narrative__c ;
			string nomAccounrt = wrO.purchaseOrderLineItems.Product__c ; 
			if (wrO.purchaseOrderLineItems.Product__c  == null )
				throw new CustomException('Please Select Nominal Account for Line Item ' + wrO.serialNumber );
			lineitem.Product__c = wrO.purchaseOrderLineItems.Product__c;
			if (wrO.purchaseOrderLineItems.Quantity__c <= 0)
				throw new CustomException('Quantity Must be Greater then 0 for Line Item ' + wrO.serialNumber);
			lineitem.Quantity__c = wrO.purchaseOrderLineItems.Quantity__c ;
			if (wrO.purchaseOrderLineItems.Amount__c <= 0)
				throw new CustomException('Amount Must Be Greater then 0  for Line Item ' + wrO.serialNumber);	
			lineitem.Amount__c = wrO.purchaseOrderLineItems.Amount__c ;
			lineitem.Total_VAT__c = wrO.purchaseOrderLineItems.Total_VAT__c ;
			if (wrO.purchaseOrderLineItems.Tax_Rate__c == null )
			 	throw new CustomException('Select Tax Rate for Line Item Line Item ' + wrO.serialNumber);		
			lineitem.Tax_Rate__c = wrO.purchaseOrderLineItems.Tax_Rate__c ;
			lineitem.Total_Gross__c = wrO.purchaseOrderLineItems.Total_Gross__c ;
			lineitem.Opportunity__c = wrO.purchaseOrderLineItems.Opportunity__c ;
			lineItems.add(lineitem);
		}
		return lineItems ;
	}
}