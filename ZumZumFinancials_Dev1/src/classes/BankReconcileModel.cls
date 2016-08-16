public class BankReconcileModel {
	public BankReconcile__c curObjectBankReconcile{get;set;}
	public integer serialReconcile;	
	private List<General_Setup__c> Gsetup {get; set;}
		
	public BankReconcileModel(BankReconcile__c bnk)
	{			
		serialReconcile = getOrderNumber();
		serialReconcile = serialReconcile+1;
		curObjectBankReconcile = bnk;	 
	} 
	public void Save()
	{
		savePoint sp = DataBase.setSavepoint(); 
		try
		{													
			insert curObjectBankReconcile;
			updateOrderNo(serialReconcile);			
		}
		catch(exception e)
		{
			Database.rollback(sp);
			throw new CustomException('Unable to Save \n'+ e.getMessage());
		}
	}	
	public integer getOrderNumber()
	{
		integer ordernumber ; 
		Gsetup = new List<General_Setup__c>() ;
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'Reconcile Transaction' limit 1] ; 
		if (Gsetup.size()>0)
		{
			if (Gsetup[0].Current_Document_Number__c == null)
				throw new CustomException ('Please enter starting Bank Reconcile #. & current document number in GENERAL SETUP');
			if (Gsetup[0].Current_Document_Number__c == -1)
			{
				ordernumber  = 	integer.valueof(Gsetup[0].Starting_Document_No__c) ; 
			}
			else 
			{
				string dc_curentno = string.valueof(Gsetup[0].Current_Document_Number__c);
                ordernumber  = 	integer.valueof(dc_curentno);                
			}
		}
		else
		{
			throw new customException('Please enter starting Reconcile Transaction #. in GENERAL SETUP.');
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
	public void updateOrderNo(integer currentOrderNo)
	{
		Gsetup = new List<General_Setup__c>() ;
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'Reconcile Transaction' limit 1] ; 
		Gsetup[0].Current_Document_Number__c = currentOrderNo ;
		update Gsetup ;
	}
	private static testMethod void BankReconcileModel_Test()
	{
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
    	Nominal_Categories__c  nc = new Nominal_Categories__c (Name = 'this is test');
		insert nc ; 
		Sub_Category__c sb = new Sub_Category__c(Nominal_Categories__c = nc.Id , Range_To__c = 200, Range_From__c=10, Name = 'testSubcatagories');
		insert sb;
		Nominal_Account__c nm = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, Expense__c = true, Name = 'Plumbering', Account_Code__c = 1222);
		insert nm ;
		Nominal_Account__c nm1 = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, Expense__c = true, Name = 'Plumbering', Account_Code__c = 1142);
		insert nm1 ;
		Nominal_Account__c nm2 = new Nominal_Account__c (Sub_Category__c = sb.Id , Tax_Rate__c = tx.Id, Expense__c = true, Name = 'Plumbering', Account_Code__c = 1500);
		insert nm2 ;
		Bank_Account__c ba = new Bank_Account__c (Nominal_Account__c = nm.id, Status__c = 'Active' , Name = 'Bank Receipt Account' , Account_Number__c = 'B745');
		insert ba;
		BankReconcile__c br = new BankReconcile__c(Bank_Account__c = ba.id ,Reference__c = 'testRefer',Ending_Balance__c = 10 ,Statement_Date__c= Date.today() , Interest_Amount__c =  20 ,Interest_Date__c = Date.today() , Interest_Nominal_Account__c = nm1.id ,Charges_Amount__c= 10, Charges_Date__c = Date.today(),Charges_Nominal_Account__c = nm2.id);
		insert br;		 
		BankReconcileModel brModel = new BankReconcileModel(br);
		brModel.serialReconcile = brModel.getOrderNumber();
		BankReconcileModel.getOrderNo('2'); 
		brModel.updateOrderNo(brModel.serialReconcile);
		try
		{
			brModel.Save();
		}
		catch(exception e)
		{
			system.debug(e.getMessage());
		}  
	}  
	
}