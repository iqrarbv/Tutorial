public class timsheetDetailWrapper 
{
	public Time_Sheet_Detail__c timeSheetDetail {get; set;}
	public string projectApprovalStatus {get;set;}
	public string EntryCode {get;set;}
	public integer Index {get; set;}
	public timsheetDetailWrapper(Time_Sheet_Detail__c timeSheet)
	{
		init(timeSheet);	
	}
	
	public timsheetDetailWrapper(Time_Sheet_Detail__c timeSheet, string status )
	{
		init(timeSheet);
		projectApprovalStatus = status;
	}	
	
	private void init(Time_Sheet_Detail__c timeSheet)
	{
		timeSheetDetail = new Time_Sheet_Detail__c(); 
		timeSheetDetail = timeSheet ;
		timeSheetDetail.Date_String__c = timeSheet.Date_String__c ;	
	}
	public string totalHours
	{
		get
		{
			if (timeSheetDetail.Total_Hours__c == null || timeSheetDetail.Total_Hours__c == 0 )
				return '0.00';
			else
				return string.valueof(timeSheetDetail.Total_Hours__c.setScale(2));
		}
		
	}
	/*
	public string totalMiles
	{
		get
		{
			if (timeSheetDetail.Total_Miles__c == null || timeSheetDetail.Total_Miles__c == 0 )
				return '0.00';
			else
				return string.valueof(timeSheetDetail.Total_Miles__c.setScale(2));
		}
		
	}
	public string  subProjectName
	{
		get
		{
			string code  = '' ;
			Opportunity op  = AllProjects.get(timeSheetDetail.Sub_Project__c);
			if (op !=null)
			{
				if (op.Code__c != null)
					code = op.Code__c + ' - ' + op.Name;
				else
					code = op.Name;
				return code ;
			}
			else if (!AllProjects.keyset().contains(timeSheetDetail.Sub_Project__c) && timeSheetDetail.Sub_Project__c !=null )
			{
				op = [Select Id , Name , Code__c from Opportunity where Id = :timeSheetDetail.Sub_Project__c];
				if (op.Code__c != null)
					code = op.Code__c + ' - ' + op.Name;
				else
					code = op.Name;
				return code ;
			}
			return code ;
		}
		set;
	}
	*/
	public string activityCode
	{
		get
		{
			string code  = '' ;
			Activity_Code__c op = AllActivities.get(timeSheetDetail.Activity_Code__c);
			if (op !=null)
			{
				if (op.Code__c != null)
					code = op.Code__c + ' - ' + op.Name;
				else
					code = op.Name;
				return code ;	
			}
			else if (!AllActivities.keyset().contains(timeSheetDetail.Activity_Code__c) && timeSheetDetail.Activity_Code__c !=null)
			{
				op = [select Id, Name , Code__c from Activity_Code__c where id = : timeSheetDetail.Activity_Code__c];
				if (op.Code__c != null)
					code = op.Code__c + ' - ' + op.Name;
				else
					code = op.Name;
				return code ;	
			}
			else
				return code ;
		}
		set;
	}
	public static void validateTimeSheetDetail(Time_Sheet_Detail__c timeSheetDetail , integer month , integer year)
	{
		if (timeSheetDetail.Date__c == null )
			throw new CustomException('Please Select Date');
		else if (timeSheetDetail.Date__c.month() < month  ||   timeSheetDetail.Date__c.month() > month)
			throw new CustomException('Please Select Correct Date for Line item');
		else if (timeSheetDetail.Date__c.year() < year  ||   timeSheetDetail.Date__c.year() > year)
			throw new CustomException('Please Select Correct Date for Line item');
		else if (timeSheetDetail.Narrative__c == null || timeSheetDetail.Narrative__c == '' )
			throw new CustomException('Please Insert Narrative Name');
		/*
		else if (timeSheetDetail.Project__c == null)
			throw new CustomException('Please Select Project');
		
		else if (timeSheetDetail.Sub_Project__c == null)
		{
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , 'Please Select Sub Project' , '' ) );
			return false;
		}
		*/
		else if (timeSheetDetail.Total_Hours__c == null || timeSheetDetail.Total_Hours__c <= 0 || timeSheetDetail.Total_Hours__c > 24 )
			throw new CustomException('Please Enter Valid Time');
		
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
		
		else if (timeSheetDetail.Activity_Code__c == null)
			throw new CustomException('Please Select Activity Code');
		else if (!Name_validate(timeSheetDetail.Name_of_business_passenger__c))
			throw new CustomException('Passenger name Contain Invalid character');
			apexpages.addMessage(new apexpages.Message( apexpages.Severity.error , 'Passenger name Contain Invalid character' , '' ) );
			return false;		
		*/		
	}
	public static boolean Name_validate(string fieldValue)
    {
        if (fieldValue == null || fieldValue == '')
               return true ;
        else
        {
            return (Pattern.matches('^[a-zA-Z ]+$', fieldValue));
            return false;
        }
    }
    public static string getDayString(date datevalue)
	{
		datetime dtValue = datetime.newInstance(datevalue.year() , datevalue.month() , datevalue.day());
		return dtValue.format('E');
	}
	public static string getDateWithMonth(date datevalue)
	{
		datetime dtValue = datetime.newInstance(datevalue.year() , datevalue.month() , datevalue.day());
		string month = monthCodes.get(datevalue.month());
		return dtValue.format('d') + ' ' + month.substring(0,3);		
	}
	public static integer getListIndex(string sIndex)
	{
		decimal index = decimal.valueof(sIndex);
		integer intIndex = integer.valueof(string.valueof(index.divide(1,0,system.roundingmode.UNNECESSARY)));
		return intIndex ;
	}
	public static map<integer , string> monthCodes = new map<integer , string>{1 => 'Janurery' ,
											   2 => 'February' ,
											   3 => 'March' ,
											   4 => 'April' ,
											   5 => 'May' ,
											   6 => 'June' ,
											   7 => 'Jully' ,
											   8 => 'August' ,
											   9 => 'September' ,
											   10 => 'October' ,
											   11 => 'November' ,
											   12 => 'December' 
											  };
	public static map<Id , Opportunity> AllProjects = new Map<Id, Opportunity>([select Id,name ,(select Id,name from Opportunities__r where StageName  != 'Closed Won' and  StageName != 'Closed Lost' ) from Opportunity where StageName  != 'Closed Won' and  StageName != 'Closed Lost' ]);
	public static map<Id, Activity_Code__c> AllActivities = new map<Id, Activity_Code__c>([select Id, Name , Code__c from Activity_Code__c ]);									  
}