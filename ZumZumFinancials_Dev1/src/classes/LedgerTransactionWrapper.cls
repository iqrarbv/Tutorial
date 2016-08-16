public class LedgerTransactionWrapper 
{
	public Decimal Amount {get;set;}
	public String BankReconcile {get;set;}
	public Date ReconcileDate {get;set;}
	public Decimal Credit {get;set;}
	public Decimal Debit {get;set;}
	public String Details {get;set;}
	public String Doc {get;set;}
	public String Nominal {get;set;}
	public String Paid {get;set;}
	public String Reference {get;set;}
	public Decimal ShowOnTransaction {get;set;}
	public String SubAccount {get;set;}
	public String SubAccountNominal {get;set;}
	public Decimal Tax {get;set;}
	public string TaxCode {get;set;}
	public Decimal TransNo {get;set;}
	public String TransRefId {get;set;}
	public Date TransDate {get;set;}
	public String TrType {get;set;}
	public String VAT {get;set;}
	public Date VATReturnDate {get;set;}
	public String VATReturnNo {get;set;}
	
	public LedgerTransactionWrapper()
	{
		
	}
	
	public LedgerTransactionWrapper(Ledger__c ledgerRecord)
	{
		this.Amount = ledgerRecord.Amount__c;
		this.BankReconcile = ledgerRecord.Bank_Reconcile__c;
		this.ReconcileDate = ledgerRecord.Bank_Reconcile_Date__c;
		this.Credit = ledgerRecord.Credit__c;
		this.Debit = ledgerRecord.Debit__c;
		this.Details = ledgerRecord.Details__c;
		this.Doc = ledgerRecord.Doc_ID__c;
		this.Nominal = ledgerRecord.Nominal__c;
		this.Paid = ledgerRecord.Paid__c;
		this.Reference = ledgerRecord.Reference__c;
		this.ShowOnTransaction = ledgerRecord.Show_On_Transaction__c;
		this.SubAccount = ledgerRecord.Sub_Account__c;
		this.SubAccountNominal = ledgerRecord.Sub_Account_Nominal__c; 
		this.Tax = ledgerRecord.Tax__c;
		this.TaxCode = ledgerRecord.Tax_Code__c;
		this.TransRefId = ledgerRecord.Trans_Ref_Id__c;
		this.TransDate = ledgerRecord.Trans_Date__c;
		this.TrType = ledgerRecord.Type__c;
		this.VAT = ledgerRecord.VAT__c;
		this.VATReturnDate = ledgerRecord.VAT_Return_Date__c;
		this.VATReturnNo = ledgerRecord.VAT_Return_No__c;
	}
}