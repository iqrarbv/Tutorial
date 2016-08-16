public class TimeSheet_Model 
{
	public Time_Sheet__c timeSheet {get; private set;}
	
	public TimeSheet_Model()
	{
		
	}
	
	public string serverURL
	{
		get
		{
			return ApexPages.currentPage().getHeaders().get('Host');
		}
	}
	
	public TimeSheet_Model(Time_Sheet__c ts)
	{
		timeSheet = ts;
	}
	
	public TimeSheet_Model(Id timeSheetId)
	{
		List<Time_Sheet__c> lst = [Select  Owner.Name , t.Month__c , t.Year__c ,t.Total_Hours__c, t.SystemModstamp, t.Status__c, t.OwnerId, t.Name, t.LastModifiedDate, t.LastModifiedById, t.IsDeleted, t.Id, t.CreatedDate, t.CreatedById, (Select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Date__c, Name_of_business_passenger__c, Narrative__c, Project__c, Status__c, Total_Hours__c, Activity_Code__c, Time_Sheet__c, Day__c, Date_String__c From Time_Sheet_Details__r) From Time_Sheet__c t Where Id=:timeSheetId];
		if(lst.size()==0)
			throw new CustomException('Time Sheet Record for Id \''+timeSheetId+'\' not found.');
		timeSheet = lst[0];	
	}	
	
	public void saveTimeSheetRecord(list<Time_Sheet_Detail__c> tsDetails , Time_Sheet__c timeSheetInfo , string opType) 
	{
		//Savepoint sp = Database.setsavepoint(); 
		try
		{
			if (opType == 'INSERT')
			{
				validateTimeSheetInfo(timeSheet);
				if (tsDetails.size() == 0)
					throw new CustomException('Time Sheet Detail Missing' + ' \nPlease Enter Time Sheet Detail');
				if( (Integer.valueof(timeSheetInfo.month__c) > date.today().Month() && Integer.valueof(timeSheetInfo.year__c) > date.today().year() )
					|| 
					(Integer.valueof(timeSheetInfo.month__c) > date.today().Month() && Integer.valueof(timeSheetInfo.year__c) == date.today().year() )
					||
					(Integer.valueof(timeSheetInfo.month__c) < date.today().Month() && Integer.valueof(timeSheetInfo.year__c) > date.today().year() )
				 )
					throw new CustomException('Future Time Sheet Can not be created ');
					
				List<Time_Sheet__c> ts = [select Id from Time_Sheet__c where Month__c = : timeSheet.Month__c and Year__c = :timeSheet.Year__c and ownerid = :userinfo.getUserId() ];
				if(ts.size() > 0)
					throw new CustomException('You have already created time sheet for this month, please select another month or edit previously created Time Sheet');
				insert timeSheet;
				tsDetails = gettimeSheetDetailParent(tsDetails , timeSheet.Id);
				insert tsDetails ; 
			}
			else if (opType == 'UPDATE')
			{
				validateTimeSheetInfo(timeSheet);
				if (tsDetails.size() == 0)
					throw new CustomException('Time Sheet Detail Missing' + ' \nPlease Enter Time Sheet Detail');
				upsert timeSheet;
				//tsDetails = gettimeSheetDetailParent(tsDetails , timeSheetInfo.Id);
				list<Time_Sheet_Detail__c> objValues = [select Id from Time_Sheet_Detail__c where Time_Sheet__c = :timeSheet.Id];
				if (objValues.size() > 0)
				{
					delete objValues ;		
				}
				tsDetails = gettimeSheetDetailParent(tsDetails , timeSheet.Id);
				upsert tsDetails ;
			}	
		}
		catch ( exception e )
		{
			//Database.rollback(sp);
			timeSheet.clone(false,true);
			throw new CustomException (e.getMessage());
		}
	}
	public list<Time_Sheet_Detail__c> gettimeSheetDetailParent(list<Time_Sheet_Detail__c> tsDetails , Id timeSheetInfoId)
	{
		for (Time_Sheet_Detail__c tsmID : tsDetails )
		{
			tsmID.Name = tsmID.Narrative__c.length()>80?(tsmID.Narrative__c.substring(0,75)+' ...'):tsmID.Narrative__c ;// tsmID.Narrative__c ;
			tsmID.Time_Sheet__c = timeSheetInfoId ;
		}
		return tsDetails;
	}
	
	//start of data validation fucntions 
	//*************************
	//*************************
	public void validateTimeSheetInfo(Time_Sheet__c timeSheetInfo)
	{
		if (timeSheetInfo.Name == null || timeSheetInfo.Name =='' )
			throw new CustomException('Please Insert Month Name');
		//apexpages.addMessage( new apexpages.Message( apexpages.Severity.error , 'Please Insert Month Name' , '' ) );
	}
	//*************************
	//*************************
	//end of data validation fucntions
	
	public void ValidateTSOnSave(list<timsheetDetailWrapper> tsDetails , 
																	integer month , 
																	integer year)
	{
		for (timsheetDetailWrapper lst : tsDetails)
		{
			if (lst.timeSheetDetail.Date__c == null )
				throw new CustomException('Please Select Date for Line Item: ' + (lst.Index +1));
			else if (lst.timeSheetDetail.Date__c.month() < month  ||   lst.timeSheetDetail.Date__c.month() > month )
				throw new CustomException('Please Select Correct Date of Time Sheet Line Item: ' + (lst.Index +1));	
			else if (lst.timeSheetDetail.Date__c.year() < year  ||   lst.timeSheetDetail.Date__c.year() > year )
				throw new CustomException('Please Select Correct Date of Time Sheet Line Item: ' + (lst.Index +1));	
		}	
	}
	
}