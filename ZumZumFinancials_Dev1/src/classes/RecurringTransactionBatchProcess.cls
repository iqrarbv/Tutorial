global class RecurringTransactionBatchProcess implements Database.Batchable<sObject>
{
	global RecurringTransactionBatchProcess()
	{
	
	}
	
	global Database.QueryLocator Start(Database.BatchableContext bc)
	{
		return Database.GetQueryLocator([Select r.VAT__c, r.TransactionType__c, r.Tax_Rate__c, r.Tax_Rate__r.Name, r.Suspend_Posting__c, r.Start_Date__c, 
									r.Required_Posting__c, r.Reference__c, r.Nominal_Account__r.Nominal_Code__c, r.No_of__c, r.Net_Amount__c, 
									r.Name_of__c, r.Name, r.Last_Posted__c, r.Id, r.Finish_Date__c, r.Details__c, r.Bank_Account__c, r.Bank_Account__r.Nominal_Account__r.Nominal_Code__c 
									From RecurringTransaction__c r
									Where Next_Transaction_Date__c=:date.today()
									and r.Finish_Date__c<=:date.today()]);
	}
	
	global void Execute(Database.BatchableContext bc, List<sObject> scope)
	{
		Savepoint sp = database.SetSavePoint();
		try
		{
			Ledger lTransaction = new Ledger();
			List<RecurringTransaction__c> transactionRecords = (List<RecurringTransaction__c>) scope;
			for(RecurringTransaction__c trans : transactionRecords)
			{
				if(trans.TransactionType__c=='Bank/Cash/Credit Card Payment')
				{
					lTransaction.AddBankPaymentTransaction(trans.Net_Amount__c,trans.Bank_Account__r.Nominal_Account__r.Nominal_Code__c,trans.Nominal_Account__r.Nominal_Code__c,trans.Details__c,trans.Reference__c,trans.Tax_Rate__r.Name,trans.VAT__c);					
				}
				else if(trans.TransactionType__c=='Bank/Cash/Credit Card Receipt')
				{
					lTransaction.AddBankReceiptTransaction(trans.Net_Amount__c,trans.Bank_Account__r.Nominal_Account__r.Nominal_Code__c,trans.Nominal_Account__r.Nominal_Code__c,trans.Details__c,trans.Reference__c,trans.Tax_Rate__c,trans.VAT__c);
				}
				else if(trans.TransactionType__c=='Bank/Cash/Credit Card Transfer')
				{
					lTransaction.AddBankTransferTransaction(trans.Net_Amount__c, trans.Bank_Account__r.Nominal_Account__r.Nominal_Code__c, trans.Nominal_Account__r.Nominal_Code__c, trans.Details__c , trans.Reference__c, date.today());
				}
				else if(trans.TransactionType__c=='Customer payment on Account')
				{
					lTransaction.AddSalesPaymentOnAccountTransaction(trans.Bank_Account__r.Nominal_Account__r.Nominal_Code__c, 'put customer account number here', trans.Nominal_Account__r.Nominal_Code__c, trans.Net_Amount__c, trans.Reference__c);
				}
				controllerRecurringTransaction.SetNextRunDate(trans);
			}
			lTransaction.Save();
			update transactionRecords;
		}
		catch(Exception ex)
		{
			database.rollback(sp);		
		}
	}
	
	global void Finish(Database.BatchableContext bc)
	{
		
	}
}