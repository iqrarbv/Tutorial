public class SalesInvoiceModel 
{
	public Sales_Invoice__c si {get; set;}
	private List<General_Setup__c> Gsetup {get; set;}
	public SalesInvoiceModel(Sales_Invoice__c soI)
	{
		si = soI ;
	}
	public static void validateLineDetails(SILineItemWrapper siItem)
	{
		if (siItem.salesInvoiceLineItems.Product__c == null )
			throw new CustomException('Please Select Product For Line Item');
		else if (siItem.salesInvoiceLineItems.Narrative__c == null || siItem.salesInvoiceLineItems.Narrative__c == '')
			throw new CustomException('Please Enter Narrative Description For Line Item');
		else if (siItem.salesInvoiceLineItems.Quantity__c == null || siItem.salesInvoiceLineItems.Quantity__c <= 0 )
			throw new CustomException('Quantity must be Greater than Zero');
		else if (siItem.salesInvoiceLineItems.Amount__c == null || siItem.salesInvoiceLineItems.Amount__c <= 0)
			throw new CustomException('Amount Must be Greator then Zero');
		else if (siItem.salesInvoiceLineItems.Tax_Rate__c == null )
			throw new CustomException('Please Select Tax Rate For Line Item');
	}
	public static decimal getTotalAmount(List<SILineItemWrapper> SILineItems)
	{
		decimal PoAmount = 0 ; 
		for (SILineItemWrapper a: SILineItems)
		{
		 	PoAmount += a.salesInvoiceLineItems.Total_Gross__c ;  
		}
		return PoAmount ;
	}
	public static decimal getTotalNetAmount(List<SILineItemWrapper> SILineItems)
	{
		decimal totalNet = 0 ; 
		for (SILineItemWrapper a: SILineItems)
		{
		 	totalNet += a.salesInvoiceLineItems.Total_Net__c ;  
		}
		return totalNet ;
	}
	public static decimal getToTalTax(List<SILineItemWrapper> SILineItems)
	{
		decimal totalTax = 0 ;
		for (SILineItemWrapper a: SILineItems)
		{
		 	totalTax += (a.salesInvoiceLineItems.VAT_Amount__c) ;// * a.salesInvoiceLineItems.Quantity__c ;  
		}
		return totalTax ;	
	}
	public static decimal getTotalAmountExcludingTax(List<SILineItemWrapper> SILineItems)
	{
		decimal wtAmount = 0 ;
		for (SILineItemWrapper a: SILineItems)
		{
		 	wtAmount += (a.salesInvoiceLineItems.Amount__c) * a.salesInvoiceLineItems.Quantity__c ;
		}
		return wtAmount ;	
	}
	public integer getOrderNumber()
	{
		integer ordernumber ; 
		Gsetup = new List<General_Setup__c>() ;
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'Sales Invoice' limit 1] ; 
		if (Gsetup.size()>0)
		{
			if (Gsetup[0].Current_Document_Number__c == null)
				throw new CustomException ('Please enter starting SI Transaction #. & current document number in GENERAL SETUP');
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
			throw new customException('Please enter starting SOI#. in GENERAL SETUP for Sales Orders');
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
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'Sales Invoice' limit 1] ; 
		Gsetup[0].Current_Document_Number__c = currentOrderNo ;
		update Gsetup ;
	}
	public void SaveOrder(list<SILineItemWrapper> siLineItems , string operationType)
	{
		//Savepoint sp = Database.setsavepoint(); 	
		try 
		{
			if (operationType == 'INSERT')
			{
				valid_OrderInfo(si);
				if(siLineItems.size() <= 0)
					throw new customexception('No Line Item in Sales Invoice, Please Enter Line Items') ;
				list<Sales_Invoice_Line_Item__c> lineItems = new  list<Sales_Invoice_Line_Item__c>();
				lineItems = getWrapperToObject(siLineItems);
				integer orderNo = getOrderNumber() ;
				si.Status__c = 'Pending' ;
				//si.Name = string.valueOf(orderNo) ;
				si.Name = getOrderNo(string.valueOf(orderNo)) ;
				insert si ;
			    updateOrderNo(orderNo);
			    lineItems = getSalesLineItems(lineItems , si.Id);
			    insert lineItems;
			    //doLedgerTarnsaction(siLineItems);
			}
			else if (operationType == 'UPDATE')
			{
				if(siLineItems.size() <= 0)  
					throw new customexception('No Line Item in Sales Invoice, Please Enter Line Items');
				delete [select Id from Sales_Invoice_Line_Item__c where Sales_Invoice__c = : si.id];
				list<Sales_Invoice_Line_Item__c> lineItems = new  list<Sales_Invoice_Line_Item__c>();
				lineItems = getWrapperToObject(siLineItems);
				si.Status__c = 'Pending' ;
				upsert si ;
			    lineItems = getSalesLineItems(lineItems , si.Id);
			    upsert lineItems;
			}
			
		}
		catch (exception e )
		{
			//Database.rollback(sp);
			si.clone(false,true);
			throw new CustomException( e.getMessage());
		}
	}
	private list<Sales_Invoice_Line_Item__c> getSalesLineItems(list<Sales_Invoice_Line_Item__c> siLineItems , Id orderId)
	{
		for (Sales_Invoice_Line_Item__c item : siLineItems)
		{
			item.Sales_Invoice__c = orderId ;
		}
		return siLineItems ; 
	}
	// start of validation Function
	private static void valid_OrderInfo(Sales_Invoice__c siOrderInfo)
	{
		if (siOrderInfo.Invoice_Date__c == null )
			throw new CustomException('Please Enter Invoice Date');
		else if (siOrderInfo.Invoice_Date__c < date.today())
			throw new CustomException('Please Enter Valid Date');
		else if (siOrderInfo.Account__c == null)
			throw new CustomException('Please Enter Customer Name');
		else if (siOrderInfo.Invoice_Due_Date__c == null )
			throw new CustomException('Please Enter Invoice Due Date');
		else if (siOrderInfo.Invoice_Due_Date__c < date.today())
			throw new CustomException('Please Enter valid Due Date');
		else if (siOrderInfo.Type__c == '' || siOrderInfo.Type__c == null )
			throw new CustomException('Please Select Invoice Type'); 
		//else if (siOrderInfo.Format_Type__c == '' || siOrderInfo.Format_Type__c == null )
			//throw new CustomException('Please Select Format Type');	
		else if (siOrderInfo.Invoice_Template__c == null )
			throw new CustomException('Please Select Invoice Template');
		//else if (siOrderInfo.Invoice_Status__c == '' || siOrderInfo.Invoice_Status__c == null )
			//throw new CustomException('Please Select Invoice Status');							
		/*
		else if (sirderInfo.Customer_Order_No__c == '' || sirderInfo.Customer_Order_No__c == null)
		{
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , 'Please Enter Customer Order No' , '') );
			return false;	
		}
		*/
		/*
		else if (siOrderInfo.Customer_Order_No__c != '' && siOrderInfo.Customer_Order_No__c != null)
		{
			Pattern a=Pattern.compile('^[a-zA-Z0-9 ]+$');
	        Matcher m=a.matcher(siOrderInfo.Customer_Order_No__c);
	        boolean adit_info=m.matches();
	       	if(adit_info == false)
	        	throw new CustomException('Customer Name Contains Invalid Characters');
	    }
	    */
	}
	private List<Sales_Invoice_Line_Item__c> getWrapperToObject(List<SiLineItemWrapper> wrappervalues)
	{	
		List<Sales_Invoice_Line_Item__c> lineItems = new List<Sales_Invoice_Line_Item__c>();
		for (siLineItemWrapper wrO :  wrappervalues)
		{
			Sales_Invoice_Line_Item__c lineitem = new Sales_Invoice_Line_Item__c();
			lineitem.Name = wrO.salesInvoiceLineItems.Narrative__c.length()>80?(wrO.salesInvoiceLineItems.Narrative__c.substring(0,75)+' ...'):wrO.salesInvoiceLineItems.Narrative__c ;
			lineitem.Narrative__c = wrO.salesInvoiceLineItems.Narrative__c ;
			lineitem.Quantity__c = wrO.salesInvoiceLineItems.Quantity__c ;
			if (lineitem.Quantity__c <= 0)
				throw new CustomException('Quantity Must Be Greater then 1 for Line Item' + wrO.serialNumber);			
			lineitem.Amount__c = wrO.salesInvoiceLineItems.Amount__c ;
			if (lineitem.Amount__c <= 0)
				throw new CustomException('Amount Must Be Greater then 1 for Line Item' + wrO.serialNumber);
			lineitem.VAT_Amount__c = wrO.salesInvoiceLineItems.VAT_Amount__c ;
			lineitem.Tax_Rate__c = wrO.salesInvoiceLineItems.Tax_Rate__c ;
			lineitem.Total_Gross__c = wrO.salesInvoiceLineItems.Total_Gross__c ; 
			lineitem.Opportunity__C = wrO.salesInvoiceLineItems.Opportunity__C ;
			lineitem.Total_Net__c = wrO.salesInvoiceLineItems.Total_Net__c ;
			lineitem.Product__c =  wrO.salesInvoiceLineItems.Product__c ;
			lineItems.add(lineitem);
		}
		return lineItems ;
	}
	/*
	public void doLedgerTarnsaction(List<siLineItemWrapper> transcationItem)
	{
		string AccountNumber = [select AccountNumber from Account where Id  = :si.Account__c limit 1 ].AccountNumber ;
		for(siLineItemWrapper tr: transcationItem)
		{
			Ledger objLg = new Ledger();
			objLg.AddSalesInvoice(si.Type__c , si.Name, tr.salesInvoiceLineItems.Narrative__c , tr.strTaxRate ,  AccountNumber, tr.salesInvoiceLineItems.Total_Gross__c , tr.salesInvoiceLineItems.Total_Net__c , tr.salesInvoiceLineItems.VAT_Amount__c , tr.taxRate , si.Account__c);
			objLg.Save() ;
		}
	}
	
	public void doLedgerTarnsaction(List<Sales_Invoice_Line_Item__c> transcationItem)
	{
		system.debug('this is line items: ' + transcationItem );
		boolean firstTransaction = false ;
		string AccountNumber = [select AccountNumber from Account where Id  = :si.Account__c limit 1 ].AccountNumber ;
		for(Sales_Invoice_Line_Item__c tr: transcationItem)
		{
			integer loopController = 3 ; 
			system.debug('this si tax rate: ' + tr.Tax_Rate__r.Name);
			Tax_Rate__c tx = [select Name , Tax_Rate__c from Tax_Rate__c where Id  = : tr.Tax_Rate__c limit 1] ; 
			string txCode = tx.Name ;
			Ledger objLg = new Ledger();
			objLg.AddSalesInvoice(si.Type__c , si.Name, tr.Narrative__c , txCode ,  AccountNumber, tr.Total_Gross__c , tr.Total_Net__c , tr.VAT_Amount__c);
			objLg.Save() ;
		}
	}
	*/
}