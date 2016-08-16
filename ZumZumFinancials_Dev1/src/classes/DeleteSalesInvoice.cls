public class DeleteSalesInvoice 
{
	public boolean disableDelete {get; set;}
	private id deleteId {get; set;}
	public DeleteSalesInvoice( apexpages.Standardcontroller deletePurchaseOrder )
	{
		deleteId = apexpages.currentPage().getParameters().get('delID');
		apexpages.addMessage(new apexpages.Message( apexpages.Severity.info , 'Are you Sure to Delete this Sales Invoice?', '' ) );
		disableDelete = true ;		
	}
	public DeleteSalesInvoice( )
	{
		
	}
	public pagereference init()
	{
		Savepoint sp = Database.setsavepoint(); 	
		try
		{
			if (deleteId != null || deleteId != '')
			{
				Sales_Invoice__c po = [select Id , Name ,Status__c from Sales_Invoice__c where Id  = :deleteId ];
				if (po.Status__c == 'Pending' || po.Status__c == 'Rejected' )
				{
					delete po ;
					return new pagereference (apexpages.currentPage().getParameters().get('retURL') ) ; 
				}
				else 
				{
					disableDelete = false ;
					throw new CustomException('Sales Invoice SI# ' + po.Name + ' is ' + po.Status__c + ' It can\'t be deleted'  );
					return null;	
				}
			}
			else 
			{
				return null;
			}
		}
		catch (exception e)
		{
			Database.rollback(sp);
			apexpages.addMessages(e);
			return null;
		}
	}
	public pagereference back()
	{
		return new pagereference ('/' +  deleteId ) ;	
	}
	
	
	// This is test code 
	private static TestMethod void  deleteSalesInvoice()
	{
		Account act = new Account(Name='ABC Company',Type='Customer');
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, P_O__c = true, Name = 'Plumbering', Account_Code__c = 150);
		insert nm ;
		Sales_Invoice__c Cont = new Sales_Invoice__c(Name = '00050' , Account__c = act.Id  , Status__c = 'Pending'  );
		insert Cont ;
		ApexPages.currentPage ().getParameters ().put ('id', Cont.id);
		ApexPages.currentPage ().getParameters ().put ('delID', Cont.id);
		ApexPages.currentPage ().getParameters ().put ('retURL', 'a0G/o');
		DeleteSalesInvoice del = new DeleteSalesInvoice();
		del.init();
		del.back();
		
	}
	private static TestMethod void  deleteSalesInvoiceexception()
	{
		Account act = new Account(Name='ABC Company',Type='Customer');
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, P_O__c = true, Name = 'Plumbering', Account_Code__c = 150);
		insert nm ;
		Sales_Invoice__c Cont = new Sales_Invoice__c(Name = '00050' , Account__c = act.Id  , Status__c = 'Pending'  );
		insert Cont ;
		//ApexPages.currentPage ().getParameters ().put ('id', Cont.id);
		//ApexPages.currentPage ().getParameters ().put ('delID', Cont.id);
		//ApexPages.currentPage ().getParameters ().put ('retURL', 'a0G/o');
		DeleteSalesInvoice del = new DeleteSalesInvoice();
		del.init();
		del.back();
		
	}
}