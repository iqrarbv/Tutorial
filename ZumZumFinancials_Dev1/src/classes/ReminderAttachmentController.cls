public class ReminderAttachmentController
{
	public Id AccountId {get;set;}
	public Integer NumberOfDays {get;set;}
	public string BeforeOrAfter {get;set;}
	public Invoice_Template__c template {get; set;}
	//public List<Sales_Invoice__c> InvoiceList {get;set;}
	
	public ReminderAttachmentController()
	{
		//InvoiceList = new List<Sales_Invoice__c>();
		//GetRecords();		
	}
	
	public List<Sales_Invoice__c> GetInvoiceList()
	{
		template = [Select i.Name, i.Margins_top_bottom__c, i.Margins_left_right_Inches__c, 
									i.Id, i.Heading_Text__c, i.Footer_Text__c, i.Font_Size__c, 
									i.Font_Face__c From Invoice_Template__c i 
									where i.Name = 'Reminder Statements' limit 1];
		integer days = BeforeOrAfter=='Before'?NumberOfDays:NumberOfDays*-1;
		date dueDate = date.Today().addDays(days);
		return [select Id, Name, Invoice_Template__r.Font_Face__c  , 
									Invoice_Template__r.Font_Size__c,  
									Invoice_Template__r.Heading_Text__c ,Invoice_Due_Date__c,
									Invoice_Template__r.Margins_top_bottom__c, Invoice_Template__r.Footer_Text__c ,
									Total_Net__c from Sales_Invoice__c where Account__c=:AccountId and Invoice_Due_Date__c=:dueDate and Paid__c='N'];
	}
}