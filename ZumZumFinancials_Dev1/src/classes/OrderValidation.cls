public class OrderValidation 
{
	/*
	public static boolean valid_date(date orderDate)
	{
		if (orderDate >= date.today())
			return true ;
		else
		{
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , 'Please Enter Valid Date' , '') );
			return false ;
		}
	}
	*/
	/*
	public static boolean valid_OrderInfo(Sales_Order__c sOrderInfo)
	{
		if (sOrderInfo.Order_Date__c < date.today())
		{
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , 'Please Enter Valid Date' , '') );
			return false;
		}
		else if (sOrderInfo.Account__c == null)
		{
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , 'Please Enter Customer Name' , '') );
			return false;	
		}
		/* Commented on 25-1-2011
		else if (sOrderInfo.Customer_Order_No__c == '' || sOrderInfo.Customer_Order_No__c == null)
		{
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , 'Please Enter Customer Order No' , '') );
			return false;	
		}
		else if (sOrderInfo.Customer_Order_No__c != '' && sOrderInfo.Customer_Order_No__c != null)
		{
			Pattern a=Pattern.compile('^[a-zA-Z0-9]+$');
	        Matcher m=a.matcher(sOrderInfo.Customer_Order_No__c);
	        boolean adit_info=m.matches();
	       	if(adit_info == false)
	        {
	            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Customer Name Contains Invalid Characters' , 'Only Alphanumeric Value can be used'));
	            return false;
	        }
	        else
	        {
	        	return true ;
	        }	
		}
		
		else 
		{
			return true ;
		}
	}
	*/
	/*
	public static boolean validate_Purchase_Order(Purchase_Order__c pOrderInfo)
	{
		if ( pOrderInfo.Account__c == null )
		{
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , 'Please Select Account' , '') );
			return false;
		}
		/*
		if ( pOrderInfo.Supplier_Reference__c == null || pOrderInfo.Supplier_Reference__c == '')
		{
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , 'Please Enter Supplier Reference' , '') );
			return false;
		}
		//boolean valid_SupplierReference = character_validate(pOrderInfo.Supplier_Reference__c) ;
		
		else if (pOrderInfo.Supplier_Reference__c != null && pOrderInfo.Supplier_Reference__c != '')
		{
			Pattern a=Pattern.compile('^[a-zA-Z0-9]+$');
	        Matcher m=a.matcher(pOrderInfo.Supplier_Reference__c);
	        boolean adit_info=m.matches();
	       	if(adit_info == false)
	        {
	            apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'Supplier Reference Contains Invalid Characters' , 'Only Alphanumeric Value can be used'));
	            return false;
	        }
	        else
	        {
	        	return true ;
	        }
		}
		if ( pOrderInfo.Order_Date__c < date.today())
		{
			apexpages.addMessage( new apexpages.Message( apexpages.Severity.info , 'Please Enter Valid Date' , '') );
			return false;
		}
		else
		{
			return true ;
		}
	}
	/*
	public static boolean validate_expenseSheetDetails(Expense_Sheet_Detail__c expenseSheetDetail)
	{
		if (expenseSheetDetail.Date__c == null )
		{
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , 'Please Select Date' , '' ) );
			return false;
		}
		else if (expenseSheetDetail.Narrative__c == null || expenseSheetDetail.Narrative__c == '' )
		{
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , 'Please Insert Narrative Name' , '' ) );
			return false;
		}	
		else if (expenseSheetDetail.Project__c == null)
		{
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , 'Please Select Project' , '' ) );
			return false;
		}
		else if (timeSheetDetail.Sub_Project__c == null)
		{
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , 'Please Select Sub Project' , '' ) );
			return false;
		}
		else if (expenseSheetDetail.Quantity__c == null || expenseSheetDetail.Quantity__c == 0 )
		{
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , 'Please Valid Quantity' , '' ) );
			return false;
		}
		else if (expenseSheetDetail.Total_Net__c == null || expenseSheetDetail.Total_Net__c <= 0 )
		{
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , 'Please Enter Valid Amount' , '' ) );
			return false;
		}
		else 
		{
			return true ;
		}
	}
	*/
	/*
	public static boolean validate_timeSheetDetails(Time_Sheet_Detail__c timeSheetDetail)
	{
		
		if (timeSheetDetail.Date__c == null )
		{
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , 'Please Select Date' , '' ) );
			return false;
		}
		else if (timeSheetDetail.Narrative__c == null || timeSheetDetail.Narrative__c == '' )
		{
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , 'Please Insert Narrative Name' , '' ) );
			return false;
		}	
		else if (timeSheetDetail.Project__c == null)
		{
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , 'Please Select Project' , '' ) );
			return false;
		}	
		/*
		else if (timeSheetDetail.Sub_Project__c == null)
		{
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , 'Please Select Sub Project' , '' ) );
			return false;
		}
		else if (timeSheetDetail.Total_Hours__c == null || timeSheetDetail.Total_Hours__c <= 0 || timeSheetDetail.Total_Hours__c > 24 )
		{
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , 'Please Enter Valid Time' , '' ) );
			return false;
		}
		/*Commented on 2-2-2011
		else if (timeSheetDetail.Total_Miles__c == null || timeSheetDetail.Total_Miles__c < 0 )
		{
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , 'Please Enter Valid Number of Miles' , '' ) );
			return false;
		}
		*/
		/*
		else if (timeSheetDetail.Name_of_business_passenger__c == null || timeSheetDetail.Name_of_business_passenger__c == '' )
		{
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , 'Please Enter Business Passenger Name' , '' ) );
			return false;
		}
		else if (!Name_validate(timeSheetDetail.Name_of_business_passenger__c))
		{
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , 'Passenger name Contain Invalid character' , '' ) );
			return false;		
		}
		else 
		{
			return true ;
		}
	}
	*/
	/*
	public static boolean character_validate(string fieldValue)
    {
        if (fieldValue !=null || fieldValue !='')
        {
	        return (Pattern.matches('^[a-zA-Z0-9]+$', fieldValue));
	        return false;
	    }
	    else
	    {
	    	return true ;
	    }
    }
    public static boolean Name_validate(string fieldValue)
    {
        if (fieldValue == null || fieldValue == '')
               return true ;
        else
        {
            return (Pattern.matches('^[a-zA-Z]+$', fieldValue));
            return false;
        }
    }
    */
	public static boolean emailvalidate(string value)
    {
		string email  = value ;
		Pattern p = Pattern.compile('[\\w\\.-]*[0-9]*@[a-zA-Z]*.[a-zA-Z]*');
		Matcher m = p.matcher(email);
		boolean matchFound = m.matches();
		if (matchFound)
			return true;
		else
			return false;
    }
}