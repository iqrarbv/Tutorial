public class Functions 
{
	public static Map<id,Nominal_Account__c> NominalIdMap = new Map<id,Nominal_Account__c> ([select id, Nominal_Code__c , Account_Code__c , Expense__c , Balance__c , P_O__c , S_O__c , Sub_Category__c , Tax_Rate__c , Credit_Balance__c , Debit_Balance__c from Nominal_Account__c limit 10000]);
	public static Map<string,Nominal_Account__c> NominalCodeMap
	{
		set
		{
			for(Nominal_Account__c na : [select id, Nominal_Code__c , Account_Code__c , Expense__c , Balance__c , P_O__c , S_O__c , Sub_Category__c , Tax_Rate__c , Credit_Balance__c , Debit_Balance__c from Nominal_Account__c limit 10000])
				NominalCodeMap.put(na.Nominal_Code__c , na);								
		}
		get;		
	}
	public static Map<string,Nominal_Account__c> NominalNameMap
	{
		set
		{
			for(Nominal_Account__c na : [select id, Nominal_Code__c , Account_Code__c , Expense__c , Balance__c , P_O__c , S_O__c , Sub_Category__c , Tax_Rate__c , Credit_Balance__c , Debit_Balance__c from Nominal_Account__c limit 10000])
				NominalNameMap.put(na.Name , na);								
		}
		get;		
	}
	
	public static list<General_Setup__c> Gsetup {get; set;}
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
	public static string getMonth(date datevalue)
	{
		return monthCodes.get(datevalue.month()) + '-' + datevalue.year();
	}
	public static string getMonthName(integer monthNumber)
	{
		return monthCodes.get(monthNumber);
	}
	public static integer getOrgFiscalYearStartMonth()
	{
		integer fiscalMonth = [Select o.FiscalYearStartMonth From Organization o limit 1].FiscalYearStartMonth ;
		if(fiscalMonth > 0)
		{			
			return 	fiscalMonth;
		}
		else
			throw new CustomException('Organization has not defined Fiscal Year Start Month');
	}
	public static decimal getTaxRate(string taxName)
	{
		List<Tax_Rate__c> tx = [select Tax_Rate__c from Tax_Rate__c where Name =: taxName];
		if(tx.size() > 0)
		{
			return tx[0].Tax_Rate__c;
		}
		else
			throw new CustomException('No Tax Rate found with this name');
		
	}
	public static string getTaxNameZero()
	{
		List<Tax_Rate__c> tx = [select Name from Tax_Rate__c where is_no_tax__c = true];
		if(tx.size() > 0)
		{
			return tx[0].Name;
		}
		else
			throw new CustomException('No tax found with this Zero Rate');		
	}
	public static string getNominalAccountCode(string ncName)
	{
		
		List<Nominal_Account__c> nc = [select Nominal_Code__c from Nominal_Account__c where Name =: ncName];
		if(nc.size() > 0)
		{
			return  nc[0].Nominal_Code__c ;
		}
		else
		{
			throw new CustomException('No Nominal Account Found with name: ' + ncName);
		}
	}
	public static string getNominalAccountId(string ncName)
	{
		//List<Nominal_Account__c> nc = [select Id , Nominal_Code__c from Nominal_Account__c where Name =: ncName]; ** commented this line becoz no nominal code is returned by this function so no need to query it.
		
		List<Nominal_Account__c> nc = [select Id from Nominal_Account__c where Name =: ncName];
		if(nc.size() > 0)
		{
			return  string.valueof(nc[0].Id) ;
		}
		else
		{
			throw new CustomException('No Nominal Account Found with This name : '+ncName);
		}
	}
	
	public static string getNominalAccountIdByCode(string code)
	{
		//List<Nominal_Account__c> nc = [select Id , Nominal_Code__c from Nominal_Account__c where Name =: ncName]; ** commented this line becoz no nominal code is returned by this function so no need to query it.
		
		List<Nominal_Account__c> nc = [select Id from Nominal_Account__c where Nominal_Code__c =: code];
		if(nc.size() > 0)
		{
			return  string.valueof(nc[0].Id) ;
		}
		else
		{
			throw new CustomException('No Nominal Account Found with This Code : '+code);
		}
	}
		
	public static string getAccountCodeById(string ncId)
	{
		List<Nominal_Account__c> nc = [select Nominal_Code__c from Nominal_Account__c where id =: ncID];
		if(nc.size() > 0)
		{
			return  string.valueof(nc[0].Nominal_Code__c) ;
		}
		else
		{
			throw new CustomException('No Nominal Account Found with this ID: '+ncID);
		}			
	}
	public static string getNominalAccountNameByID(string ncId)
	{
		List<Nominal_Account__c> nc = [select Name from Nominal_Account__c where id =: ncID];
		if(nc.size() > 0)
		{
			return  string.valueof(nc[0].Name) ;
		}
		else
		{
			throw new CustomException('No Nominal Account Found with this ID: '+ncID);
		}			
	}
	public static string getAccountNumberById(id AccttId)
	{
		List<Account> ac = [select AccountNumber from Account where id=: AccttID];
		if(ac.size() > 0)
		{
			return  string.valueof(ac[0].AccountNumber) ;
		}
		else
		{
			throw new CustomException('No Account Found with this ID: '+AccttID);
		}			
	}
	public static boolean isEuropean(string CountryName)
	{
		List<ISO_Countries__c> isoCountries = [Select Country_Name__c , Country_Code__c , Region__c from ISO_Countries__c limit 1000];
		if( isoCountries.size() > 0 )
		{
			for(ISO_Countries__c ct: isoCountries)
			{
				if(ct.Country_Name__c == CountryName && ct.Region__c == 'Europe' && ct.Country_Name__c != 'United Kingdom' )
					return true	;
			}
			return false;
		}
		else
		{
			throw new customexception('No Countries Found in Custom Setting, \nPlease Insert Countries in to Custom Setting');
		}

	}
	
	
	public static string getAccountCodeByName(string ncName) 
	{
		List<Control_Account__c> nc = new List<Control_Account__c>(); 
		if (ncName == 'Debtors Control')
		{
			nc = [select Debtors_Control__r.Nominal_Code__c from Control_Account__c where Name = :'Control Accounts' ];
			if(nc.size()> 0)
				return nc[0].Debtors_Control__r.Nominal_Code__c ;
			else
				throw new CustomException('No Entry In Control Accounts For '+ncName+' \n Please Check your Controll Accounts');	
		}
		else if(ncName == 'Creditors Control')
		{
			nc = [select Creditors_Control__r.Nominal_Code__c from Control_Account__c where Name = :'Control Accounts' ];
			if(nc.size()> 0)
				return nc[0].Creditors_Control__r.Nominal_Code__c ;
			else
				throw new CustomException('No Entry In Control Accounts For '+ncName+' \n Please Check your Controll Accounts');		
		}
		else
			return null ;
	}
	
	public static string GetDebtorsControlAccountCode()
	{
		List<Control_Account__c> nc = [select Debtors_Control__r.Nominal_Code__c from Control_Account__c where Name = :'Control Accounts' ];
		if(nc.size()==0)
		{
			throw new CustomException('Control Accounts entry not found.');
		}
		else if(nc[0].Debtors_Control__c==null)
		{
			throw new CustomException('Debtors Control Account Entry not found in Control Accounts.');
		}
		return nc[0].Debtors_Control__r.Nominal_Code__c ;
	}
	
	public static string GetCreditorsControlAccountCode()
	{
		List<Control_Account__c> nc = [select Creditors_Control__r.Nominal_Code__c from Control_Account__c where Name = :'Control Accounts' ];
		if(nc.size()==0)
		{
			throw new CustomException('Control Accounts entry not found.');
		}
		else if(nc[0].Creditors_Control__r==null)
		{
			throw new CustomException('Creditors Control Account Entry not found in Control Accounts.');
		}
		return nc[0].Creditors_Control__r.Nominal_Code__c ;
	}
	
	public static string[] getRegionWithCode(string CountryName)
	{
		list<ISO_Countries__c> cT = [select Country_Code__c , Country_Name__c , Region__c from ISO_Countries__c where Country_Name__c = : CountryName];
		if(cT.size() > 0)
		{
			string[] region = new string[]{};
			region.add(cT[0].Region__c==null?'':cT[0].Region__c);
			region.add(cT[0].Country_Code__c==null?'':cT[0].Country_Code__c);
			return region ;
		}
		else
			throw new customexception('No Country Code found wiith this Name');
	}
	/* 
	public static integer getOrderNumber(string objectType)
	{
		integer ordernumber ; 
		Gsetup = new List<General_Setup__c>() ;
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = :objectType limit 1] ; 
		if (Gsetup.size()>0)
		{
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
		return ordernumber ;
	}
	public static string getOrderNo(string orderNo)
	{
		system.debug(orderNo);
		if (orderNo.length() < 6)
		{
			integer ln = 6 - orderNo.length();
			for (integer i=0 ; i<ln ; i++)
			{
				orderNo  = '0'+ orderNo;
			}
		}
		system.debug(orderNo);
		return orderNo ;
	}
	*/
	/*
	public static void updateOrderNo(integer currentOrderNo , string objectType)
	{
		Gsetup = new List<General_Setup__c>() ;
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = :objectType limit 1] ; 
		Gsetup[0].Current_Document_Number__c = currentOrderNo ;
		update Gsetup ;
	}
	*/
	/*
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
	*/
	public static string getOrganisationCurrency(string parameter)
	{
		Organisation_Currency__c orgCu = Organisation_Currency__c.getInstance('Default_Currency'); 
		if (orgCu != null)
		{
			if (parameter == 'CurrencyName')
				return orgCu.Currency_Name__c;
			else if (parameter == 'CurrencySymbol')
				return orgCu.Currency_Symbol__c;
			else
				return null;
		}	
		else
		{
			return null ;
		}	
	}
	public static integer getListIndex(string sIndex)
	{
		decimal index = decimal.valueof(sIndex);
		integer intIndex = integer.valueof(string.valueof(index.divide(1,0,system.roundingmode.UNNECESSARY)));
		system.debug(intIndex);
		return intIndex ;
	}
	/*
	public static list<selectoption> getNominalAccounts()
	{
		list<selectoption> NominalAccounts = new list<selectoption>();
		for (Nominal_Account__c nm : [select Id , Name from Nominal_Account__c limit 1000])
		{
			NominalAccounts.add( new selectoption( nm.Id , nm.Name ) );	
		}
		return NominalAccounts;
	}
	*/
}