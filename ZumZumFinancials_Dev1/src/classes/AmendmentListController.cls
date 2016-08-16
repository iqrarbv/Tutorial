public class AmendmentListController
{
    public List<Ledger__c> LedgerRecords
    {
        get
        {
            return Ledger.GetRecordsForAmendment();
        }
    } 
    
    public AmendmentListController()
    {
        
    }
}