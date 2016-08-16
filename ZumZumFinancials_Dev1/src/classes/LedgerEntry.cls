public class LedgerEntry
{
	public Ledger__c Entry {get;set;}
	public List<Ledger__c> PaymentDetails {get;set;}
	public DataTypeHelper__c AccountLookup {get;set;}
	
	public DataTypeHelper__c RemainingAmount
	{
		get
		{
			decimal netAmount = Entry.Net__c!=null ? Entry.Net__c : 0;
			decimal taxAmount = Entry.Tax__c!=null ? Entry.Tax__c : 0; 
			decimal paidAmount = Entry.Amount__c!=null ? Entry.Amount__c : 0; 
			return new DataTypeHelper__c(Currency__c=netAmount + taxAmount - paidAmount);
		}
	}
	public decimal Discount {get;set;}
	public decimal Receipt {get;set;}
	
	public LedgerEntry(Ledger__c e)
	{
		this.Entry = e;		
	}			
}