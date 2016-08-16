public class PurchaseInvoiceModel 
{
	public Purchase_Invoice__c PInvoice {get; set;}
	private list<General_Setup__c> Gsetup {get; set;}
	public PurchaseInvoiceModel(Purchase_Invoice__c invoice)
	{
		PInvoice = 	invoice ;	
	}
	public static decimal getTotalAmountt(list<POInvoiceWrapper> PiLineItems)
	{
		decimal PoAmount = 0 ;
		for (POInvoiceWrapper a: PiLineItems)
		{
		 	PoAmount += a.purchaseInvoiceLineItems.Total_Gross__c ;  
		}
		return PoAmount ;
	}
	
	public static decimal getToTalTaxx(list<POInvoiceWrapper> PiLineItems)
	{
		decimal totalTax = 0 ;
		for (POInvoiceWrapper a: PiLineItems)
		{
		 	totalTax += (a.purchaseInvoiceLineItems.Total_VAT__c);//  * a.purchaseOrderLineItems.Quantity__c ;  
		}
		return totalTax ;	
	}
	
	public static decimal getTotalAmountExcludingTaxx(list<POInvoiceWrapper> PiLineItems)
	{
		decimal wtAmount = 0 ;
		for (POInvoiceWrapper a: PiLineItems)
		{
		 	wtAmount += (a.purchaseInvoiceLineItems.Amount__c) * a.purchaseInvoiceLineItems.Quantity__c ;
		}
		return wtAmount ;	
	}
	public void saveOrder( List<POInvoiceWrapper> wrrapedPoLineItems ,  string actionType )
	{
		//Savepoint sp = Database.setsavepoint(); 	
		try 
		{
			if (actionType == 'INSERT')
			{
				validatPOPInfo(PInvoice);
				if (wrrapedPoLineItems.size() <= 0)
					throw new customexception('No Line Item in Purchase Invoice, Please Enter Line Items');
				list<Purchase_Invoice_Line_Item__c> POPLineItems = new list<Purchase_Invoice_Line_Item__c>();
				POPLineItems = getWrapperToObject(wrrapedPoLineItems) ;	
				integer orderNumber = getOrderNumber();
				PInvoice.Name = getOrderNo(string.valueOf(orderNumber));
				PInvoice.Status__c = 'Pending' ;
				insert PInvoice ;
				updateOrderNo(orderNumber);
				POPLineItems = getPurchaseOrderLineItems(POPLineItems , PInvoice.Id );
				insert POPLineItems ;
				//doLedgerTarnsaction(wrrapedPoLineItems);
			}
			else if (actionType == 'UPDATE')      
			{
				validatPOPInfo(PInvoice);              
				if (wrrapedPoLineItems.size() <= 0)
					throw new customexception('No Line Item in Purchase Invoice, Please Enter Line Items');	
				list<Purchase_Invoice_Line_Item__c> POPLineItems = new list<Purchase_Invoice_Line_Item__c>();
				POPLineItems = getWrapperToObject(wrrapedPoLineItems) ;	
				delete [select Id from Purchase_Invoice_Line_Item__c where Purchase_Invoice__c = : PInvoice.Id ];
				upsert PInvoice ;
				POPLineItems = getPurchaseOrderLineItems(POPLineItems , PInvoice.Id );
				upsert POPLineItems ;
			}
		}
		catch(exception e)
		{
			//Database.rollback(sp);
			PInvoice.clone(false,true);
			throw new CustomException( e.getMessage() ) ; 
		}	
	}
	public list<Purchase_Invoice_Line_Item__c> getPurchaseOrderLineItems(list<Purchase_Invoice_Line_Item__c> popLineItems , Id orderId)
	{
		for (Purchase_Invoice_Line_Item__c item : popLineItems)
		{
			item.Purchase_Invoice__c = orderId ;
		}
		return popLineItems ; 
	}
	public List<Purchase_Invoice_Line_Item__c> getWrapperToObject(List<POInvoiceWrapper> wrappervalues)
	{	
		List<Purchase_Invoice_Line_Item__c> lineItems = new List<Purchase_Invoice_Line_Item__c>();
		for (POInvoiceWrapper wrO :  wrappervalues)
		{
			Purchase_Invoice_Line_Item__c lineitem = new Purchase_Invoice_Line_Item__c();
			lineitem.Name = wrO.purchaseInvoiceLineItems.Narrative__c.length()>80?(wrO.purchaseInvoiceLineItems.Narrative__c.substring(0,75)+' ...'):wrO.purchaseInvoiceLineItems.Narrative__c ;
			lineitem.Narrative__c = wrO.purchaseInvoiceLineItems.Narrative__c ;
			if (wrO.purchaseInvoiceLineItems.Nominal_Account__c ==  null)
				throw new CustomException('Please Select Nominal Code for Line Item ' + wrO.serialNumber);
			lineitem.Nominal_Account__c = wrO.purchaseInvoiceLineItems.Nominal_Account__c ;
			if (wrO.purchaseInvoiceLineItems.Quantity__c <= 0)
				throw new CustomException('Quantity Must be Greater then 0 for Line Item ' + wrO.serialNumber);
			lineitem.Quantity__c = wrO.purchaseInvoiceLineItems.Quantity__c ;
			if (wrO.purchaseInvoiceLineItems.Amount__c <= 0)
				throw new CustomException('Amount Must Be Greator then 0  for Line Item ' + wrO.serialNumber);	
			lineitem.Amount__c = wrO.purchaseInvoiceLineItems.Amount__c ;
			lineitem.Total_VAT__c = wrO.purchaseInvoiceLineItems.Total_VAT__c ;
			if (wrO.purchaseInvoiceLineItems.Tax_Rate__c == null )
			 	throw new CustomException('Select Tax Rate for Line Item Line Item ' + wrO.serialNumber);		
			lineitem.Tax_Rate__c = wrO.purchaseInvoiceLineItems.Tax_Rate__c ;
			lineitem.Total_Gross__c = wrO.purchaseInvoiceLineItems.Total_Gross__c ;
			lineitem.Opportunity__c = wrO.purchaseInvoiceLineItems.Opportunity__c ;
			lineitem.Ready_To_Pay__c = wrO.purchaseInvoiceLineItems.Ready_To_Pay__c ;
			lineitem.Total_Net__c = wrO.purchaseInvoiceLineItems.Total_Net__c ;
			lineItems.add(lineitem);
		}
		return lineItems ;
	}
	private void validatPOPInfo(Purchase_Invoice__c POPInfo)
	{
		if(POPInfo.Account__c == null )
			throw new CustomException('Please Select Customer Name For Invoice');	
		else if ( POPInfo.Invoice_Date__c == null )
			throw new CustomException('Please Enter Order Date');
		else if ( POPInfo.Invoice_Date__c < date.today())
			throw new CustomException('Please Enter Valid Date');
		else if ( POPInfo.Invoice_Due_Date__c == null )
			throw new CustomException('Please Enter Due Date');
		else if ( POPInfo.Invoice_Due_Date__c < date.today())
			throw new CustomException('Please Enter Valid Due Date');	
		else if (POPInfo.Type__c == null || POPInfo.Type__c == '')
			throw new CustomException('Please Select Invoice Type');
		//else if (POPInfo.Dimension__c == null )
			//throw new CustomException('Please Select Dimension');
		else if (POPInfo.Invoice_Template__c == null )
			throw new CustomException('Please Select Invoice Template');
		//else if (POPInfo.Status__c == null || POPInfo.Status__c == '')
			//throw new CustomException('Please Select Invoice Satus');		
		
	}
	public static void validateLineDetails(POInvoiceWrapper poItem , string ncId)
	{
		system.debug('this id : ' + ncId);
		if (ncId == null || ncId == '')
			throw new CustomException('Please Enter Nominal Account For Line Item');
		//else
			//poItem.purchaseInvoiceLineItems.Nominal_Account__c = ncId ;	
		else if (poItem.purchaseInvoiceLineItems.Narrative__c == null || poItem.purchaseInvoiceLineItems.Narrative__c == '')
			throw new CustomException('Please Enter Narrative Description For Line Item');
		else if (poItem.purchaseInvoiceLineItems.Quantity__c == null || poItem.purchaseInvoiceLineItems.Quantity__c <= 0 )
			throw new CustomException('Quantity must be Greater than Zero');
		else if (poItem.purchaseInvoiceLineItems.Amount__c == null || poItem.purchaseInvoiceLineItems.Amount__c <= 0)
			throw new CustomException('Amount Must be Greator then Zero');
		else if (poItem.purchaseInvoiceLineItems.Tax_Rate__c == null )
			throw new CustomException('Please Select Tax Rate For Line Item');
	}
	public integer getOrderNumber()
	{
		integer ordernumber ; 
		Gsetup = new List<General_Setup__c>() ;
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'Purchase Invoice' limit 1] ; 
		if (Gsetup.size()>0)
		{
			if (Gsetup[0].Current_Document_Number__c == null)
				throw new CustomException ('Please enter starting PI Transaction #. & current document number in GENERAL SETUP');
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
			throw new customException('Please enter starting POI#. in GENERAL SETUP for Sales Orders'); 
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
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where  Object__c = 'Purchase Invoice' limit 1] ; 
		Gsetup[0].Current_Document_Number__c = currentOrderNo ;
		update Gsetup ;
	}
	/*
	public void doLedgerTarnsaction(List<POInvoiceWrapper> transcationItem)
	{
		system.debug('this is line items: ' + transcationItem );
		string AccountNumber = [select AccountNumber from Account where Id  = :PInvoice.Account__c limit 1 ].AccountNumber ;
		for(POInvoiceWrapper tr: transcationItem)
		{
			//string txCode = [select Name from Tax_Rate__c where Id  = : tr.Tax_Rate__c limit 1].Name;
			Ledger objLg = new Ledger();
			objLg.AddPurchaseInvoice(PInvoice.Name , tr.purchaseInvoiceLineItems.Narrative__c , tr.strTaxRate , AccountNumber, tr.purchaseInvoiceLineItems.Total_Gross__c , tr.purchaseInvoiceLineItems.Total_Net__c , tr.purchaseInvoiceLineItems.Total_VAT__c , tr.taxRate , PInvoice.Account__c);
			objLg.Save();
		}
	}
	*/
	/*
	public void doLedgerTarnsaction(List<Purchase_Invoice_Line_Item__c> transcationItem)
	{
		system.debug('this is line items: ' + transcationItem );
		boolean firstTransaction = false ;
		List<LedgerTransactionWrapper> trcItems = new List<LedgerTransactionWrapper> ();
		for(Purchase_Invoice_Line_Item__c tr: transcationItem)
		{
			string txCode = [select Name from Tax_Rate__c where Id  = : tr.Tax_Rate__c limit 1].Name;
			string AccountNumber = [select AccountNumber from Account where Id  = :PInvoice.Account__c limit 1 ].AccountNumber ;
			Ledger objLg = new Ledger();
			objLg.AddPurchaseInvoice(PInvoice.Name , tr.Narrative__c , txCode, AccountNumber, tr.Total_Gross__c , tr.Total_Net__c , tr.Total_VAT__c);
			objLg.Save();
		}
	}
	*/
}