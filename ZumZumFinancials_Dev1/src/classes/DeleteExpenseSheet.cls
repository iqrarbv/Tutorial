public class DeleteExpenseSheet 
{
	public boolean disableDelete {get; set;}
	private Id deletId {get; set;}
	public DeleteExpenseSheet ( apexpages.Standardcontroller deleteExpenseSheet )
	{
		Id deletId = apexpages.currentPage().getParameters().get('delID');
		apexpages.addMessage(new apexpages.Message( apexpages.Severity.info , 'Are you Sure to Delete this Expense Sheet?', '' ) );
		disableDelete = true ;
	}
	public DeleteExpenseSheet ()
	{
	}
	public pagereference init()
	{
		Savepoint sp = Database.setsavepoint(); 	
		try 
		{
			Expense_Sheet__c expSheet = [Select Id , Name ,  Status__c from Expense_Sheet__c where Id = :deletId ] ;
			if (expSheet.Status__c == 'Submitted_For_Approval' ||  expSheet.Status__c == 'Approved')
			{
				disableDelete = false ;
				throw new CustomException( 'Expense Sheet Es# ' + expSheet.Name + ' is ' + expSheet.Status__c + ' It can\'t be deleted' );
				return null;
			}
			else 
			{
				delete expSheet ;
				return new pagereference( apexpages.currentPage().getParameters().get('retURL') );
			}
		}
		catch(exception e)
		{
			Database.rollback(sp);
			apexpages.addMessages(e);
			return null ;
		}
	}
	public pagereference back()
	{
		return new pagereference( '/' + apexpages.currentPage().getParameters().get('delID') );	
	}
	public static TestMethod void deleteExpenseSheet()
	{
		Expense_Sheet__c esinfo = new Expense_Sheet__c();
		esinfo.Month_Number__c = date.today().month();
		esinfo.Year__c = date.today().year();
		insert esinfo;
		apexpages.currentPage().getParameters().put('retURL' , 'https://ap1.salesforce.com/a06/o' );
		apexpages.currentPage().getParameters().put('delID' , esinfo.Id);
		DeleteExpenseSheet obj = new DeleteExpenseSheet();
		obj.init();
		obj.back();
		esinfo = new Expense_Sheet__c();
		esinfo.Month_Number__c = date.today().month();
		esinfo.Year__c = date.today().year();
		esinfo.Status__c = 'Submitted_For_Approval';
		insert esinfo;
		apexpages.currentPage().getParameters().put('delID' , esinfo.Id);
		try
		{
			obj.init();
		}
		catch(exception e)
		{
			system.assertEquals('Expense Sheet Es# ' + esinfo.Name + ' is ' + esinfo.Status__c + ' It can\'t be deleted', e.getMessage());
		}
		apexpages.currentPage().getParameters().put('delID' , null);
		obj.init();
	}
}