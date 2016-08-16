/******************************************************************************************/
//Name                : NominalAccountSearchController
//Author              : Mustafa Turab Ali
//Date                : 28 February, 2011
//Description         : Popup Search controller for Nominal Accounts
/******************************************************************************************/
public class NominalAccountSearchController
{
	public string qry {get;set;}
	public string search_type {get;set;}
	public string lookupDisplayData {get;set;}
	public List<Nominal_Account__c> listData {get;set;}
	public String filter;
	//Constructor
	public NominalAccountSearchController()
	{
		listData = new List<Nominal_Account__c>();
		lookupDisplayData = '';        
		qry  = ApexPages.currentPage().getParameters().get('q');
		search_type= ApexPages.currentPage().getParameters().get('search_type');
		String query = '';
		listData  = getQuery(); 
		lookupDisplayData = getDisplayData(listData);
	}
	/**
	//GetContactQuery
	//Gives query to be fired for 'Contact' popup Page
	*/
	private List<Nominal_Account__c> getQuery()
	{
		filter = '%' + qry + '%';
		return [SELECT id, Name, Nominal_Code__c from Nominal_Account__c WHERE (name like :filter) or (Nominal_Code__c like :filter) order by Name limit 20];
	}
	/**
	//getContactDisplayData
	//Gives output as string from contact data list to show on screen
	*/
	private string getDisplayData(List<Nominal_Account__c> dataList)
	{
		string output = '';
		for(Nominal_Account__c item: dataList)
		{
			output += item.Nominal_Code__c + ', ' + item.Name + '|' + item.Name + '|' + item.id + '|' + item.Nominal_Code__c +'\n';
		}
		return output;
	}
	
	@isTest
    private static void testClass(){
        ApexPages.currentPage().getParameters().put('q','ab');
        NominalAccountSearchController controller = new NominalAccountSearchController();
    }
}