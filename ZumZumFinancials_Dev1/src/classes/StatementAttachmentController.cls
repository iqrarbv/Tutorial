public class StatementAttachmentController
{
	public string AccountId {get;set;}
	public Invoice_Template__c template {get; set;}
	public List<Ledger__c> GetLedgerList()
	{
		template = [Select i.Name, i.Margins_top_bottom__c, i.Margins_left_right_Inches__c, 
									i.Id, i.Heading_Text__c, i.Footer_Text__c, i.Font_Size__c, 
									i.Font_Face__c From Invoice_Template__c i 
									where i.Name = 'Statement Attachment' limit 1];
		List<Account> accountList = [select id,type,accountNumber from Account where Id =: AccountId];
		if(accountList.size()==0)
			return new List<Ledger__c>();
		if(accountList[0].Type=='Supplier')
		{
			return Ledger.GetSupplierPurchaseRecords(accountList[0].AccountNumber, Ledger.showOnTransactionStatus.YES, Ledger.paidStatus.ALL);	
		}
		else
		{
			return Ledger.GetCustomerSalesRecords(accountList[0].AccountNumber, Ledger.showOnTransactionStatus.YES, Ledger.paidStatus.ALL);
		}	
	}
}