public class ExpenseSheet_Model 
{
	public static list<General_Setup__c> Gsetup {get; set;}
	public static string errorMessage {get; set;}
	public static string level1Text = 'Level 1 - General Approval from Line Manager';
	public static string level2Text = 'Level 2 - Business Head';
	
	public Expense_Sheet__c expenseSheet {get;set;}
	
	/*
	public ExpenseSheet_Model(Id expenseSheetId)
	{
		List<Expense_Sheet__c> lst = [Select e.Total_VAT__c, e.Total_Net__c, e.Total_Gross__c, 
									  e.Status__c,e.Owner.UserRoleId, e.Owner.Email, e.Owner.Name, 
									  e.Owner.FirstName, e.Owner.LastName, e.Owner.Username, 
									  e.Owner.Id, e.OwnerId, e.Name, e.Month__c, e.IsDeleted, 
									  e.Id, e.CreatedDate, e.CreatedById, e.Claim_No__c 
									  From Expense_Sheet__c e 
									  Where Id=:expenseSheetId];
		if(lst.size()>0)
		{
			expenseSheet = lst[0];
		}	
		else
		{
			throw new CustomException('Expense Sheet Record not found for Id:'+expenseSheetId);
		}
	}
	*/
	public ExpenseSheet_Model( Expense_Sheet__c expenseSheetexpenseSheet)
	{
		expenseSheet = expenseSheetexpenseSheet ;	
	}
	
	
	public void saveExpenseSheet(List<expenseSheetDetailWrapper> expenseSheetItems , Expense_Sheet__c expenseSheetInfo , string opType)
	{
		//SavePoint sp = Database.setSavepoint();
		try
		{
			if (opType == 'INSERT')
			{
				if (expenseSheet.type__c ==null || expenseSheet.type__c == '')
					throw new CustomException('Please Select Expense Sheet Type');	
				if (expenseSheetItems.size() == 0)
					throw new CustomException('Expense Sheet Detail Missing' + ' \n Please Enter Expense Sheet Detail');
				if (expenseSheet.Year__c < date.today().year()  || expenseSheet.Month_Number__c < date.today().month())
					expenseSheet.Back_Dated__c = true ;
				ValidateIOnSave(expenseSheetItems , integer.valueof(expenseSheet.Month_Number__c) , integer.valueof(expenseSheet.Year__c)) ;
				insert expenseSheet ;  
				updateOrderNo(integer.valueof(expenseSheet.Claim_No__c) );
				List<Expense_Sheet_Detail__c> lineItems = new List<Expense_Sheet_Detail__c>();
				lineItems = getExpenseSheetDetailParent(expenseSheetItems , expenseSheet.Id );
				insert lineItems ;
			}
			else if (opType == 'UPDATE')
			{
				if (expenseSheet.type__c ==null || expenseSheet.type__c == '')
					throw new CustomException('Please Select Expense Sheet Type');
				if (expenseSheetItems.size() == 0)
					throw new CustomException('Expense Sheet Detail Missing' + ' \n Please Enter Expense Sheet Detail');
				ValidateIOnSave(expenseSheetItems , integer.valueof(expenseSheet.Month_Number__c) , integer.valueof(expenseSheet.Year__c)) ;
				upsert expenseSheet ;
				delete [select Id from Expense_Sheet_Detail__c where Expense_Sheet__c = :expenseSheet.Id];
				List<Expense_Sheet_Detail__c> lineItems = new List<Expense_Sheet_Detail__c>();
				lineItems = getExpenseSheetDetailParent(expenseSheetItems , expenseSheet.Id );
				upsert lineItems ;	
			}
		}
		catch ( exception e )
		{
			//Database.rollback(sp);
			expenseSheet.clone(false,true);
			throw new CustomException( e.getMessage());
		}
	}
	public static string getDayString(date datevalue)
	{
		datetime dtValue = datetime.newInstance(datevalue.year() , datevalue.month() , datevalue.day());
		system.debug(dtValue.format('E'));
		return dtValue.format('E');
	}
	public static string getDateWithMonth(date datevalue)
	{
		datetime dtValue = datetime.newInstance(datevalue.year() , datevalue.month() , datevalue.day());
		system.debug(dtValue.format('E'));
		string month = monthCodes.get(datevalue.month());
		return dtValue.format('d') + ' ' + month.substring(0,3);		
	}
	public static string getMonth(integer month ,  string year)
	{
		return monthCodes.get(month) + ' ' + year;
	}
	public static map<integer , string> monthCodes = new map<integer , string>{
													1 => 'January' ,
											        2 => 'February' ,
											        3 => 'March' ,
											        4 => 'April' ,
											        5 => 'May' ,
											        6 => 'June' ,
											        7 => 'July' ,
											        8 => 'August' ,
											        9 => 'September' ,
											       10 => 'October' ,
											       11 => 'November' ,
											       12 => 'December' 
											       };
	public static void updateOrderNo(integer currentOrderNo)
	{
		Gsetup = new List<General_Setup__c>() ;
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'Expenses' limit 1] ; 
		Gsetup[0].Current_Document_Number__c = currentOrderNo ;
		update Gsetup ;
	}
	public static integer getOrderNumber(string objectType)
	{
		integer ordernumber ; 
		Gsetup = new List<General_Setup__c>() ;
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'Expenses' limit 1] ; 
		if (Gsetup.size()>0)
		{
			if (Gsetup[0].Current_Document_Number__c == null)
				throw new CustomException ('Please enter starting ES Claim #. & current document number in GENERAL SETUP');
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
			throw new CustomException('Please enter starting ES#. in GENERAL SETUP for Expense Sheet');
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
	public List<Expense_Sheet_Detail__c> getExpenseSheetDetailParent(List<expenseSheetDetailWrapper> expenseSheetItems , 
																	Id parentId 
																	)
	{
		List<Expense_Sheet_Detail__c> expenseList = new List<Expense_Sheet_Detail__c>();
		for (expenseSheetDetailWrapper lst : expenseSheetItems)
		{
			if (lst.expenseSheetDetail.Expense_Sheet__c == null ) 
				lst.expenseSheetDetail.Expense_Sheet__c = 	parentId ;
			lst.expenseSheetDetail.Name = expenseSheet.Month__c ;
			expenseList.add(lst.expenseSheetDetail.clone(false,true));
		}
		return expenseList ;
	}
	private void ValidateIOnSave(List<expenseSheetDetailWrapper> expenseSheetItems , 
																	integer month , 
																	integer year)
	{
		for (expenseSheetDetailWrapper lst : expenseSheetItems)
		{
			if (lst.expenseSheetDetail.Date__c == null )
				throw new CustomException('Please Select Date for Line Item: ' + lst.Index);
			else if (lst.expenseSheetDetail.Date__c.month() < month  ||   lst.expenseSheetDetail.Date__c.month() > month )
				throw new CustomException('Please Select Date of Expense Sheet Month for Line Item: ' + lst.Index);	
			else if (lst.expenseSheetDetail.Date__c.year() < year  ||   lst.expenseSheetDetail.Date__c.year() > year )
				throw new CustomException('Please Select Date of Expense Sheet year for Line Item: ' + lst.Index);	
			else if (lst.expenseSheetDetail.Nominal_Account__c == null )
				throw new CustomException('Please Select Nominal Account for Line Item: ' + lst.Index );	
			else if (lst.expenseSheetDetail.Narrative__c == null || lst.expenseSheetDetail.Narrative__c == '' )
				throw new CustomException('Please Insert Narrative Name for Line Item: ' + lst.Index);
			else if (lst.expenseSheetDetail.Quantity__c == null || lst.expenseSheetDetail.Quantity__c == 0 )
				throw new CustomException('Please Enter Valid Quantity for Line Item: ' + lst.Index );
			else if (lst.expenseSheetDetail.Unit_Amount__c == null || lst.expenseSheetDetail.Unit_Amount__c <= 0 )
				throw new CustomException('Please Enter Valid Amount for Line Item: ' + lst.Index);	
			else if (lst.expenseSheetDetail.Tax_Rate__c == null)
				throw new CustomException('Please Select Tax Rate for Line Item: ' + lst.Index);	
		}	
	}
	public static void validate_expenseSheetDetails(Expense_Sheet_Detail__c expenseSheetDetail , integer month , integer year)//date monthdate)
	{
		if (expenseSheetDetail.Date__c == null )
			throw new CustomException('Please Select Date');
		else if (expenseSheetDetail.Date__c.month() < month  ||   expenseSheetDetail.Date__c.month() > month )
			throw new CustomException('Please Select Date of Expense Sheet Month');	
		else if (expenseSheetDetail.Date__c.year() < year  ||   expenseSheetDetail.Date__c.year() > year )
			throw new CustomException('Please Select Date of Expense Sheet year');	
		else if (expenseSheetDetail.Nominal_Account__c == null )
			throw new CustomException('Please Select Nominal Account');	
		else if (expenseSheetDetail.Narrative__c == null || expenseSheetDetail.Narrative__c == '' )
			throw new CustomException('Please Insert Narrative Name');
		else if (expenseSheetDetail.Quantity__c == null || expenseSheetDetail.Quantity__c == 0 )
			throw new CustomException('Please Enter Valid Quantity');
		else if (expenseSheetDetail.Unit_Amount__c == null || expenseSheetDetail.Unit_Amount__c <= 0 )
			throw new CustomException('Please Enter Valid Amount');	
		else if (expenseSheetDetail.Tax_Rate__c == null)
			throw new CustomException('Please Select Tax Rate');
		//else if (expenseSheetDetail.Project__c == null)
			//throw new CustomException('Please Select Project');
		/*
		else if (timeSheetDetail.Sub_Project__c == null)
		{
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , 'Please Select Sub Project' , '' ) );
			return false;
		}
		*/
	}
	
	
	public static integer getListIndex(string sIndex)
	{
		decimal index = decimal.valueof(sIndex);
		integer intIndex = integer.valueof(string.valueof(index.divide(1,0,system.roundingmode.UNNECESSARY)));
		system.debug(intIndex);
		return intIndex ;
	}
	public static decimal getTotal(list<expenseSheetDetailWrapper> lstExpenseSheetDetail , string fieldName)
	{
		system.debug(lstExpenseSheetDetail);
		decimal totalValue = 0 ;
		if (fieldName == 'VAT')
		{
			for(expenseSheetDetailWrapper exp : lstExpenseSheetDetail)
			{
				totalValue += exp.expenseSheetDetail.Total_VAT__c  ;	
			}
			return totalValue ;	
		}
		else if (fieldName == 'NET')
		{
			for(expenseSheetDetailWrapper exp : lstExpenseSheetDetail)
			{
				totalValue += exp.expenseSheetDetail.Total_Net__c ;	
			}
			return totalValue ;	
		}
		else if (fieldName == 'GROSS')
		{
			for(expenseSheetDetailWrapper exp : lstExpenseSheetDetail)
			{
				totalValue += exp.expenseSheetDetail.Total_Gross__c ;
			}
			return totalValue ;	
		}
		else if (fieldName == 'MILES')
		{
			for(expenseSheetDetailWrapper exp : lstExpenseSheetDetail)
			{
				if (exp.expenseSheetDetail.Miles__c != null)
					totalValue += exp.expenseSheetDetail.Miles__c ;
			}
			return totalValue ;	
		}
		else if (fieldName == 'UNITAMOUNT')
		{
			for(expenseSheetDetailWrapper exp : lstExpenseSheetDetail)
			{
				if (exp.expenseSheetDetail.Unit_Amount__c != null)
					totalValue += exp.expenseSheetDetail.Unit_Amount__c ;
			}
			return totalValue ;	
		}
		else
			return 0;
	}
}