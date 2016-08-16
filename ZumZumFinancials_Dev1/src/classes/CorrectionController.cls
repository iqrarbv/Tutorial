public class CorrectionController
{
	public Ledger__c newEntry {get;set;}
	private Ledger__c oldEntry;
	public string dueDate {get; set;}
	public Account ordAcc {get; set;}
	public Purchase_Invoice_Line_Item__c  pInvoice {get; set;}
	public Sales_Invoice_Line_Item__c  sInvoice {get; set;}
	public string docTitle {get; set;}
	public map<string , string[]> ncMap {get; set;}
	public string hdnNcId {get; set;}
	public string htmlNcId {get; set;}       
	public string ncName {get; set;}
	public string createdOn {get; set;}
	public string postedOn {get; set;}
	public decimal totalAmount {get; set;}
	public boolean isInvoice {get; set;} 
	public boolean isBPayment {get; set;} 
	public boolean isDirectPayment {get; set;}
	public boolean isReciept {get; set;}
	public boolean isOpeningBalance {get; set;}
	public boolean showPage {get; set;}
	public boolean containPaymentHis {get; set;}
	public Id entryId
	{
		get;set;
	}
	public List<LedgerPaymentHistory> History {get; private set;}
	
	public list<selectoption> getAllTaxes()
	{
		list<selectoption> sList = new list<selectoption>();
		sList.add(new selectoption('Select Tax', 'Select Tax'));
		for(Tax_Rate__c tx: [select Id , Name , Tax_Rate__c from Tax_Rate__c limit 1000])
		{         
			sList.add(new selectoption(tx.Name + ' - ' + tx.Tax_Rate__c + ' %'  ,tx.Name + ' - ' + tx.Tax_Rate__c + ' %' ));
		}
		return sList ;
	}
	public CorrectionController(Apexpages.standardController std)
	{
		isOpeningBalance = false ;
		entryId = std.getId(); 
		ncMap = new map<string , string[]>();
		for (Nominal_Account__c nA : [Select Id , Name ,Nominal_Code__c from Nominal_Account__c where P_O__c = true Order By Nominal_Code__c Asc limit 1000  ]) 
		{
			string[] ncCodeName = new string[]{nA.Nominal_Code__c, nA.Name} ;
			ncMap.put(nA.Id , ncCodeName);
		} 
	} 
	
	public void PageInit()
	{
		try
		{
			 GetRecord();
		}
		catch(Exception e)
		{
			newEntry = new Ledger__c();
			apexpages.AddMessages(e);
		}
	}
	
	private void GetRecord()
	{
		newEntry = Ledger.GetLedgerEntryById(entryId);
		postedOn = newEntry.CreatedDate.format('dd/MM/yyyy');
		showPage = true ;
		if(newEntry.Amount__c == null )
			newEntry.Amount__c = 0.00 ;	
		// fetching info from Account/Bank Object based on Ledger Entry Tyep
		if(newEntry.Type__c == 'SI' || newEntry.Type__c == 'SC' || newEntry.Type__c == 'PI' || newEntry.Type__c == 'PC' )
		{	
			List<Account> acc = [Select a.ytdRevenue__c, a.ytdPurchases__c, a.mtdRevenue__c, a.mtdPurchases__c, a.Website, a.VAT_Reg_No__c, a.Use_Default_Tax_for_Sales__c, a.UpsellOpportunity__c, a.Type, a.TickerSymbol, a.Terms__c, a.Terms_Agreed__c, a.Tax_Rate__c, a.SystemModstamp, a.Sort_Code__c, a.Site__c, a.Site, a.Sic, a.ShippingStreet, a.ShippingState, a.ShippingPostalCode, a.ShippingCountry, a.ShippingCity, a.Settlement_Due_Days__c, a.Settlement_Discount__c, a.SO_Start__c, a.SO_Amount__c, a.SLA__c, a.SLASerialNumber__c, a.SLAExpirationDate__c, a.Roll_Number__c, a.Relationship__c, a.Region__c, a.Rating, a.Phone, a.Payment_Due_Days__c, a.ParentId, a.Ownership, a.OwnerId, a.NumberofLocations__c, a.NumberOfEmployees, a.Nominal_Account__c, a.Name, a.MasterRecordId, a.LastModifiedDate, a.LastModifiedById, a.LastActivityDate, a.IsDeleted, a.Industry, a.Id, a.IBAN__c, a.Fax, a.Entity_Email__c, a.Description, a.Debit__c, a.DUNS_Number__c, a.CustomerPriority__c, a.Credit__c, a.Credit_Limit__c, a.CreatedDate, a.CreatedById, a.Country__c, a.Country_Code__c, a.Co_Reg_No__c, a.Billing_Contact__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity, a.Bank_name__c, a.Bank_Sort_Code__c, a.Bank_Address__c, a.Bank_Account_No__c, a.Bank_Account_Name__c, a.Balance__c, a.BACS_Ref__c, a.AnnualRevenue, a.Additional_Reference__c, a.Active__c, a.Accountshop__c, a.AccountNumber From Account a where AccountNumber = :newEntry.Sub_Account__c limit 1];
			if(acc.size() > 0)
				ordAcc = 	acc[0];
			else
				throw new CustomException('No Account Found found for this Ledger Entry');
			//ordAcc = [Select a.ytdRevenue__c, a.ytdPurchases__c, a.mtdRevenue__c, a.mtdPurchases__c, a.Website, a.VAT_Reg_No__c, a.Use_Default_Tax_for_Sales__c, a.UpsellOpportunity__c, a.Type, a.TickerSymbol, a.Terms__c, a.Terms_Agreed__c, a.Tax_Rate__c, a.SystemModstamp, a.Sort_Code__c, a.Site__c, a.Site, a.Sic, a.ShippingStreet, a.ShippingState, a.ShippingPostalCode, a.ShippingCountry, a.ShippingCity, a.Settlement_Due_Days__c, a.Settlement_Discount__c, a.SO_Start__c, a.SO_Amount__c, a.SLA__c, a.SLASerialNumber__c, a.SLAExpirationDate__c, a.Roll_Number__c, a.Relationship__c, a.Region__c, a.Rating, a.Phone, a.Payment_Due_Days__c, a.ParentId, a.Ownership, a.OwnerId, a.NumberofLocations__c, a.NumberOfEmployees, a.Nominal_Account__c, a.Name, a.MasterRecordId, a.LastModifiedDate, a.LastModifiedById, a.LastActivityDate, a.IsDeleted, a.Industry, a.Id, a.IBAN__c, a.Fax, a.Entity_Email__c, a.Description, a.Debit__c, a.DUNS_Number__c, a.CustomerPriority__c, a.Credit__c, a.Credit_Limit__c, a.CreatedDate, a.CreatedById, a.Country__c, a.Country_Code__c, a.Co_Reg_No__c, a.Billing_Contact__c, a.BillingStreet, a.BillingState, a.BillingPostalCode, a.BillingCountry, a.BillingCity, a.Bank_name__c, a.Bank_Sort_Code__c, a.Bank_Address__c, a.Bank_Account_No__c, a.Bank_Account_Name__c, a.Balance__c, a.BACS_Ref__c, a.AnnualRevenue, a.Additional_Reference__c, a.Active__c, a.Accountshop__c, a.AccountNumber From Account a where AccountNumber = :newEntry.Sub_Account__c limit 1];
		}// end of code
		htmlNcId = newEntry.Nominal__c ;
		setNcIdName ();     
		if(newEntry.Type__c == 'JD' || newEntry.Type__c == 'JC' )
		{
			showPage = false ;
			throw new customexception('Transaction Type: ' + newEntry.Type__c + ' can\'t be amended');
			return  ;
		}
		if(newEntry.Type__c == 'SI' || newEntry.Type__c == 'SC')
		{	
			if(newEntry.Nominal__c == Functions.getNominalAccountCode('Suspense Account'))   
			{
				
				isOpeningBalance = true ;
				isReciept = true ;
				createdOn = newEntry.CreatedDate.format('dd/MM/yyyy');
				docTitle = 'Cutomer Opening Balance for Account# ' + newEntry.Sub_Account__c ; 
				totalAmount = newEntry.Credit__c==null? newEntry.Debit__c:newEntry.Credit__c ;
			}	
			else
			{
				isInvoice = true ;
				sInvoice = [Select s.VAT_Amount__c, s.UID__c, s.Total_Net__c, s.Total_Gross__c, s.Tax_Rate__c, s.SystemModstamp, s.Sales_Invoice__r.Paid_Amount__c, s.Sales_Invoice__r.Paid__c, s.Sales_Invoice__r.Status__c, s.Sales_Invoice__r.Total_VAT__c, s.Sales_Invoice__r.Total_Gross__c, s.Sales_Invoice__r.Total_Net__c, s.Sales_Invoice__r.Type__c, s.Sales_Invoice__r.Settlement_Due_Days__c, s.Sales_Invoice__r.Settlement_Discount__c, s.Sales_Invoice__r.Sales_Order__c, s.Sales_Invoice__r.SOP_Number__c, s.Sales_Invoice__r.Quote_Number__c, s.Sales_Invoice__r.Opportunity__c, s.Sales_Invoice__r.Invoice_Template__c, s.Sales_Invoice__r.Invoice_Due_Date__c, s.Sales_Invoice__r.Invoice_Date__c, s.Sales_Invoice__r.Format_Type__c, s.Sales_Invoice__r.Dimension__c, s.Sales_Invoice__r.Account__c, s.Sales_Invoice__r.SystemModstamp, s.Sales_Invoice__r.LastModifiedById, s.Sales_Invoice__r.LastModifiedDate, s.Sales_Invoice__r.CreatedById, s.Sales_Invoice__r.CreatedDate, s.Sales_Invoice__r.Name, s.Sales_Invoice__r.IsDeleted, s.Sales_Invoice__r.OwnerId, s.Sales_Invoice__r.Id, s.Sales_Invoice__c, s.Quantity__c, s.Product__c, s.Opportunity__c, s.Narrative__c, s.Name, s.LastModifiedDate, s.LastModifiedById, s.IsDeleted, s.Id, s.CreatedDate, s.CreatedById, s.Amount__c From Sales_Invoice_Line_Item__c s where s.Sales_Invoice__r.Name =: newEntry.Doc_ID__c] ;
				createdOn = sInvoice.CreatedDate.format('dd/MM/yyyy');
				dueDate = sInvoice.Sales_Invoice__r.Invoice_Due_Date__c.format();
				docTitle = sInvoice.Sales_Invoice__r.Name + ', ' ;
				docTitle += newEntry.Type__c=='SI'?'Sales Invoice':'Sales Credit';
				totalAmount = newEntry.Type__c=='SI'?(newEntry.Debit__c.setScale(2)):(newEntry.Credit__c.setScale(2));
			}
		}
		if(newEntry.Type__c == 'PI' || newEntry.Type__c == 'PC')
		{	
			system.debug('this is acocuut: ' + Functions.getNominalAccountCode('Suspense Account') );
			if(newEntry.Nominal__c == Functions.getNominalAccountCode('Suspense Account'))   
			{
				
				isOpeningBalance = true ;
				isReciept = true ;
				createdOn = newEntry.CreatedDate.format('dd/MM/yyyy');
				docTitle = 'Supplier Opening Balance for Account# ' + newEntry.Sub_Account__c ; 
				totalAmount = newEntry.Credit__c==null? newEntry.Debit__c:newEntry.Credit__c ;
			}
			else
			{
				isInvoice = true ;
				pInvoice = [Select p.Purchase_Invoice__r.Name , p.UID__c, p.Total_VAT__c, p.Total_Net__c, p.Total_Gross__c, p.Total_Amount__c, p.Tax_Rate__c, p.SystemModstamp, p.Serial_No__c, p.Ready_To_Pay__c, p.Quantity__c, p.Purchase_Invoice__r.Paid__c, p.Purchase_Invoice__r.Total_Tax__c, p.Purchase_Invoice__r.Total_Net__c, p.Purchase_Invoice__r.Total_Gross__c, p.Purchase_Invoice__r.POP_Number__c, p.Purchase_Invoice__r.Invoice_Due_Date__c, p.Purchase_Invoice__r.Invoice_Date__c, p.Purchase_Invoice__c, p.Opportunity__c, p.Nominal_Account__c, p.Narrative__c, p.Name, p.LastModifiedDate, p.LastModifiedById, p.Item_Received__c, p.IsDeleted, p.Id, p.CreatedDate, p.CreatedById, p.Amount__c From Purchase_Invoice_Line_Item__c p where p.Purchase_Invoice__r.Name =: newEntry.Doc_ID__c] ;
				createdOn = pInvoice.CreatedDate.format('dd/MM/yyyy');
				dueDate = pInvoice.Purchase_Invoice__r.Invoice_Due_Date__c.format();
				docTitle = pInvoice.Purchase_Invoice__r.Name +  ', ';
				docTitle += + newEntry.Type__c=='PI'?'Purchase Invoice':'Purchase Credit';
				totalAmount = newEntry.Type__c=='PI'?(newEntry.Credit__c.setScale(2)):(newEntry.Debit__c.setScale(2));
			}
		}
		if(newEntry.Type__c == 'BP')
		{
			isBPayment = true ;	
			createdOn = newEntry.CreatedDate.format('dd/MM/yyyy');
			docTitle = 'Bank Payment';
			totalAmount = newEntry.Credit__c.setScale(2); 
		}
		if(newEntry.Type__c == 'BR')
		{
			isBPayment = true ;	
			createdOn = newEntry.CreatedDate.format('dd/MM/yyyy');
			docTitle = 'Bank Reciept';
			totalAmount = newEntry.Debit__c.setScale(2); 
		}
		if(newEntry.Type__c == 'BR')
		{
			isBPayment = true ;	
			createdOn = newEntry.CreatedDate.format('dd/MM/yyyy');
			docTitle = 'Bank Reciept';
			totalAmount = newEntry.Debit__c.setScale(2); 
		}
		if(newEntry.Type__c == 'SA')
		{
			isDirectPayment = true ;	
			createdOn = newEntry.CreatedDate.format('dd/MM/yyyy');
			docTitle = 'Payment agianst Customer Account# ' + newentry.Sub_Account__c ;
			totalAmount = newEntry.Credit__c.setScale(2); 
		}
		if(newEntry.Type__c == 'PA')
		{
			isDirectPayment = true ;	
			createdOn = newEntry.CreatedDate.format('dd/MM/yyyy');
			docTitle = 'Payment agianst Supplier Account# ' + newentry.Sub_Account__c ;
			totalAmount = newEntry.Debit__c.setScale(2); 
		}
		if(newEntry.Type__c == 'SR')   
		{
			isReciept = true ;   	   
			createdOn = newEntry.CreatedDate.format('dd/MM/yyyy');
			docTitle = 'Payment agianst Sales Reciept' ;
			totalAmount = newEntry.Credit__c.setScale(2); 
		}
		if(newEntry.Type__c == 'PP')   
		{
			isReciept = true ;   	   
			createdOn = newEntry.CreatedDate.format('dd/MM/yyyy');
			docTitle = 'Payment agianst Purchase Payment' ;
			totalAmount = newEntry.Debit__c.setScale(2); 
		}
		if(newEntry.Type__c == 'SP')   
		{
			isReciept = true ;   	   
			createdOn = newEntry.CreatedDate.format('dd/MM/yyyy');
			docTitle = 'Customer Opening Balance for Account # '+  newEntry.Sub_Account__c ;
			totalAmount = newEntry.Debit__c.setScale(2); 
		}
		if(newEntry.Type__c == 'PR')   
		{
			isReciept = true ;   	   
			createdOn = newEntry.CreatedDate.format('dd/MM/yyyy');
			docTitle = 'Supploer Opening Balance for Account # '+  newEntry.Sub_Account__c ;
			totalAmount = newEntry.Credit__c.setScale(2); 
		}
		if(newEntry.Type__c == 'SD')   
		{
			isReciept = true ;   	   
			createdOn = newEntry.CreatedDate.format('dd/MM/yyyy');
			docTitle = 'Sales Discount for Account # '+  newEntry.Sub_Account__c ;
			totalAmount = newEntry.Credit__c.setScale(2); 
		}
		if(newEntry.Type__c == 'PD')   
		{
			isReciept = true ;   	   
			createdOn = newEntry.CreatedDate.format('dd/MM/yyyy');
			docTitle = 'Purchase Discount for Account # '+  newEntry.Sub_Account__c ;
			totalAmount = newEntry.Debit__c.setScale(2); 
		}
		oldEntry = newEntry.clone(false,true);
		History = new List<LedgerPaymentHistory>();
		boolean isBPayment = Ledger.PaymentTypes.Contains(newEntry.Type__c);   
		for(Ledger_Payment_History__c hist : Ledger.GetLedgerPaymentHistoryByTransactionNumber(newEntry.Type__c, (double) newEntry.Trans_No__c))
		{
			string details = isBPayment==true
							 ?hist.Amount__c+' to '+hist.Type__c+'  '+hist.Parent_Transaction_Number__c
							 :hist.Amount__c+' from '+hist.Type__c+'  '+hist.Payment_Transaction_Number__c;
			History.Add(new LedgerPaymentHistory(hist, details));
		}
		if(History.size()> 0)
			containPaymentHis = true ;
	}
	private void validateDate()
	{   
		if(totalAmount == null || totalAmount < 0)
			throw new customexception('Incorrect Total Amount. \nPlease Enter Valid Amount');
		if(newEntry.Type__c == 'SI')
		{	
			if(isOpeningBalance )
			{
				if(newEntry.Credit__c== null || newEntry.Credit__c ==0)
					newEntry.Debit__c = totalAmount ;
				else
					newEntry.Credit__c = totalAmount ;			
			}
			else
			{
				newEntry.Debit__c = totalAmount ;
			}
		}
		if	(newEntry.Type__c == 'SC')
		{
			newEntry.Credit__c = totalAmount ;
		} 
		if	(newEntry.Type__c == 'PI')
		{
			if(isOpeningBalance )
			{
				if(newEntry.Credit__c==null || newEntry.Credit__c ==0)
					newEntry.Debit__c = totalAmount ;
				else
					newEntry.Credit__c = totalAmount ;			
			}
			else
			{
				newEntry.Credit__c = totalAmount ;
			}
		}  
		if	(newEntry.Type__c == 'PC')
		{
			newEntry.Debit__c = totalAmount ;
		}
		if(newEntry.Type__c == 'BP')
		{
			newEntry.Credit__c = totalAmount ;	
		}
		if(newEntry.Type__c == 'BR')
		{
			newEntry.Debit__c = totalAmount ;	
		}   
		if(newEntry.Type__c == 'SA')
		{
			newEntry.Credit__c = totalAmount ;	
		}
		if(newEntry.Type__c == 'PA')
		{
			newEntry.Debit__c = totalAmount ;	
		}
		if(newEntry.Type__c == 'SR')
		{
			newEntry.Credit__c = totalAmount ;	
		}
		if(newEntry.Type__c == 'PP')
		{
			newEntry.Debit__c = totalAmount ;	
		}
		if(newEntry.Type__c == 'SP')
		{
			newEntry.Debit__c = totalAmount ;	
		}
		if(newEntry.Type__c == 'PR')
		{
			newEntry.credit__c = totalAmount ;	
		}
		if(newEntry.Type__c == 'SD')   
		{
			newEntry.credit__c = totalAmount ;
		}
		if(newEntry.Type__c == 'PD')   
		{
			newEntry.Debit__c = totalAmount ;
		}
	}     
	public pageReference SaveLedger()      
	{    
		Savepoint sp = database.setSavePoint();
		//try
		{
			validateDate();
			Ledger l = new Ledger();
			if(newEntry.Type__c == 'SI')
			{
				if(isOpeningBalance )
					l.SaveCustomerOpeningBalanceAmendment(oldEntry, newEntry);
				else
					l.SaveSalesInvoiceAmendment(oldEntry, newEntry);
			}
			if(newEntry.Type__c == 'SC')
				l.SaveSalesCreditAmendment(oldEntry, newEntry);
			if(newEntry.Type__c == 'PI')
			{
				if(isOpeningBalance )
					l.SaveSupplierOpeningBalanceAmendment(oldEntry, newEntry);
				else	
					l.SavePurchaseInvoiceAmendment(oldEntry, newEntry);
			}
			if(newEntry.Type__c == 'PC')
				l.SavePurchaseCreditAmendment(oldEntry, newEntry);		
			if(newEntry.Type__c == 'BP')
				l.SaveBankPaymentAmendment(oldEntry, newEntry);	
			if(newEntry.Type__c == 'BR')	
				l.SaveBankReceiptAmendment(oldEntry, newEntry);
			if(newEntry.Type__c == 'SA')	
				l.SaveSalesPaymentOnAccountAmendment(oldEntry, newEntry);
			if(newEntry.Type__c == 'PA')
				l.SavePurchasePaymentOnAccountAmendment(oldEntry, newEntry);
			if(newEntry.Type__c == 'SR')
				l.SaveSalesReceiptAmendment(oldEntry, newEntry);
			if(newEntry.Type__c == 'PP')
				l.SavePurchasePaymentAmendment(oldEntry, newEntry);	
			if(newEntry.Type__c == 'SP')
				l.SaveSalesRefundAmendment(oldEntry, newEntry);	
			if(newEntry.Type__c == 'PR')
				l.SavePurchaseRefundAmendment(oldEntry, newEntry);
			if(newEntry.Type__c == 'SD')
				l.SaveSalesDiscountAmendment(oldEntry, newEntry);
			if(newEntry.Type__c == 'PD')
				l.SavePurchaseDiscountAmendment(oldEntry, newEntry);										
			system.debug('oldEntry after save: '+oldEntry);
			system.debug('newEntry after save: '+newEntry);
			return new PageReference('/apex/TransactionsMenu');
			
		}
		//catch(Exception e)
		//{
		//	database.rollback(sp);
		//	apexpages.addmessages(e);                                               
		//	return null;
		//}
	}
	
	public class LedgerPaymentHistory
	{
		public Ledger_Payment_History__c history {get; private set;}
		public string Details {get; private set;}
		
		public LedgerPaymentHistory(Ledger_Payment_History__c h, string d)
		{
			history = h;
			Details = d;
		}		
	}
	private void setNcIdName()
	{
		if(htmlNcId!=null && htmlNcId !='')
		{
			if (ncMap.keyset().contains(htmlNcId))
			{
				htmlNcId = 	ncMap.get(htmlNcId)[0];
				ncName = ncMap.get(htmlNcId)[1];         
			}
			else
			{
				Nominal_Account__c nc = [Select Id , Name ,Nominal_Code__c from Nominal_Account__c where Nominal_Code__c = :htmlNcId] ;
				if (nc !=null)
				{
					htmlNcId = 	nc.Nominal_Code__c ;
					ncName = nc.Name ;
				}
			}
		}	
	}
	
	
	// This is test Code
		
	private static testmethod void TestConrrectionSO()
	{
		Account act = new Account(Name='ABC Company',Type='Customer',  AccountNumber = 'TESTSI' );
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		
		Opportunity op = new Opportunity(Name = 'Opportunity abc' , StageName = 'IIT' , Activity_Start__c = date.today(), Activity_End__c = date.today().addDays(5) , CloseDate = date.today().addDays(5));
		insert op;
		
		Invoice_Template__c invTemplate = new Invoice_Template__c( Font_Face__c = 'Arial' , Font_Size__c = '12' , 
																	   Footer_Text__c = 'ZumZum Financials Footer' , 
																	   Heading_Text__c = 'ZumZum Financials Heading' ,
																	   Margins_left_right_Inches__c = .5 ,
																	   Margins_top_bottom__c = .5 ,
																	   Name = 'ZumZum Sample Template');

		insert invTemplate ;
		
		Product2 product = new Product2 (ProductCode = 'TST', Name = 'Test Product', IsActive = true , Description = 'I am writing Test Classes');
		insert product ;
		
		Sales_Invoice__c sO = new Sales_Invoice__c ();
		sO.Account__c = act.id;
		sO.Name = '00526';
		sO.Invoice_Date__c = Date.today();
		sO.Invoice_Due_Date__c = date.today().adddays(+7);
		sO.Invoice_Template__c = invTemplate.id ; 
		sO.Paid_Amount__c = 150 ; 
		sO.SOP_Number__c = '00526';
		sO.Status__c = 'Posted';
		sO.Type__c = 'Posted';
		
		insert sO;
		
		Sales_Invoice_Line_Item__c LineItem = new Sales_Invoice_Line_Item__c();
		//LineItem.Product__c = product.id ; 
		LineItem.Narrative__c = 'I am Testing';
		LineItem.Opportunity__c = op.id ; 
		//LineItem.Nominal_Account__c = nm.id ;
		LineItem.Quantity__c = 1 ; 
		LineItem.Tax_Rate__c = tx.id ;
		LineItem.Amount__c = 10 ; 
		LineItem.Total_Gross__c = 10 ;
		LineItem.VAT_Amount__c = 2 ; 
		LineItem.Total_Net__c = 12 ;
		LineItem.Product__c = product.id ;
		LineItem.Sales_Invoice__c = sO.id ;
		insert LineItem ;
		
		Ledger__c journal = new Ledger__c();
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'SI', Sub_Account__c = 'TESTSI', Details__c = 'Sales Invoice', Doc_ID__c = '00526', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-5) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , Credit__c =  117.50 ,  VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		
		
		Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(journal);
		CorrectionController obj = new CorrectionController(std);
		obj.PageInit();
		list<selectoption> selectlist = obj.getAllTaxes();
		//obj.totalAmount = 200 ;
		try
		{
			obj.SaveLedger();
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage(), 'Incorrect Total Amount. \nPlease Enter Valid Amount');
		}
		obj.totalAmount = 200 ;
		obj.SaveLedger();
	}
	
	private static testmethod void TestConrrectionPO()
	{
		Account act = new Account(Name='ABC Company',Type='Supplier',  AccountNumber = 'TEST123' );
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Opportunity op = new Opportunity(Name = 'Opportunity abc' , StageName = 'IIT' , Activity_Start__c = date.today(), Activity_End__c = date.today().addDays(5) , CloseDate = date.today().addDays(5));
		insert op;
		
		Invoice_Template__c invTemplate = new Invoice_Template__c( Font_Face__c = 'Arial' , Font_Size__c = '12' , 
																	   Footer_Text__c = 'ZumZum Financials Footer' , 
																	   Heading_Text__c = 'ZumZum Financials Heading' ,
																	   Margins_left_right_Inches__c = .5 ,
																	   Margins_top_bottom__c = .5 ,
																	   Name = 'ZumZum Sample Template');

		insert invTemplate ;
		
		Purchase_Invoice__c pO = new Purchase_Invoice__c ();
		po.Account__c = act.id;
		po.Name = '000041';
		po.Invoice_Date__c = Date.today();
		po.Invoice_Due_Date__c = date.today().adddays(+7);
		po.Invoice_Template__c = invTemplate.id ; 
		po.Paid_Amount__c = 150 ; 
		po.Payment_Status__c = 'Pending';
		po.POP_Number__c = '000041';
		po.Status__c = 'Pending';
		po.Type__c = 'Posted';
		
		insert pO ;
		
		Purchase_Invoice_Line_Item__c LineItem = new Purchase_Invoice_Line_Item__c();
		//LineItem.Product__c = product.id ; 
		LineItem.Narrative__c = 'I am Testing';
		LineItem.Opportunity__c = op.id ; 
		//LineItem.Nominal_Account__c = nA.id ;
		LineItem.Ready_To_Pay__c = true ;
		LineItem.Quantity__c = 1 ; 
		LineItem.Serial_No__c = 1 ;
		LineItem.Tax_Rate__c = tx.id ;
		LineItem.Amount__c = 10 ; 
		LineItem.Total_Amount__c = 10 ;
		LineItem.Total_VAT__c = 2 ; 
		LineItem.Total_Net__c = 12 ;
		LineItem.Total_Gross__c = 12 ;
		LineItem.Purchase_Invoice__c = pO.id ;
		insert LineItem ;
		
		
		Ledger__c journal = new Ledger__c();
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PI', Sub_Account__c = 'TEST123', Details__c = 'Purchase Invoice', Doc_ID__c = '000041', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-5) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , Credit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		
		Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(journal);
		CorrectionController obj = new CorrectionController(std);
		obj.PageInit();
		try
		{
			obj.SaveLedger();
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage(), 'Incorrect Total Amount. \nPlease Enter Valid Amount');
		}
		obj.totalAmount = 200 ;
		obj.SaveLedger();
	}
	
	private static testmethod void TestConrrectionBR()
	{
		Account act = new Account(Name='ABC Company',Type='Supplier',  AccountNumber = 'TESTBR' );
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Ledger__c journal = new Ledger__c();
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'BR', Sub_Account__c = act.AccountNumber , Details__c = 'Balance Recienpt', Doc_ID__c = '000041', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-5) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , Credit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		
		Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(journal);
		CorrectionController obj = new CorrectionController(std);
		obj.PageInit();
		try
		{
			obj.SaveLedger();
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage(), 'Incorrect Total Amount. \nPlease Enter Valid Amount');
		}
		obj.totalAmount = 200 ;
		obj.SaveLedger();
	}
	
	
	private static testmethod void TestConrrectionBP()
	{
		Account act = new Account(Name='ABC Company',Type='Supplier',  AccountNumber = 'TESTBP' );
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Ledger__c journal = new Ledger__c();
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'BP', Sub_Account__c = act.AccountNumber , Details__c = 'Balance Recienpt', Doc_ID__c = '000041', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-5) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , Credit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		
		
		Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(journal);
		CorrectionController obj = new CorrectionController(std);
		obj.PageInit();
		try
		{
			obj.SaveLedger();
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage(), 'Incorrect Total Amount. \nPlease Enter Valid Amount');
		}
		obj.totalAmount = 200 ;
		obj.SaveLedger();
	}
	
	private static testmethod void TestConrrectionSA()
	{
		Account act = new Account(Name='ABC Company',Type='Supplier',  AccountNumber = 'TESTSA' );
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Ledger__c journal = new Ledger__c();
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'SA', Sub_Account__c = act.AccountNumber , Details__c = 'Sales on Account', Doc_ID__c = '000041', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-5) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , Credit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		
		
		Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(journal);
		CorrectionController obj = new CorrectionController(std);
		obj.PageInit();
		try
		{
			obj.SaveLedger();
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage(), 'Incorrect Total Amount. \nPlease Enter Valid Amount');
		}
		obj.totalAmount = 200 ;
		obj.SaveLedger();
	}
	
	private static testmethod void TestConrrectionPA()
	{
		Account act = new Account(Name='ABC Company',Type='Supplier',  AccountNumber = 'TESTPA' );
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Ledger__c journal = new Ledger__c();
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PA', Sub_Account__c = act.AccountNumber , Details__c = 'Payment on Account', Doc_ID__c = '000041', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-5) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , Credit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		
		
		Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(journal);
		CorrectionController obj = new CorrectionController(std);
		obj.PageInit();
		try
		{
			obj.SaveLedger();
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage(), 'Incorrect Total Amount. \nPlease Enter Valid Amount');
		}
		obj.totalAmount = 200 ;
		obj.SaveLedger();
	}
	
	private static testmethod void TestConrrectionSR()
	{
		Account act = new Account(Name='ABC Company',Type='Supplier',  AccountNumber = 'TESTSR' );
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Ledger__c journal = new Ledger__c();
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'SR', Sub_Account__c = act.AccountNumber , Details__c = 'SalesReciept', Doc_ID__c = '000041', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-5) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , Credit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		
		
		Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(journal);
		CorrectionController obj = new CorrectionController(std);
		obj.PageInit();
		try
		{
			obj.SaveLedger();
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage(), 'Incorrect Total Amount. \nPlease Enter Valid Amount');
		}
		obj.totalAmount = 200 ;
		obj.SaveLedger();
	}
	
	private static testmethod void TestConrrectionPP()
	{
		Account act = new Account(Name='ABC Company',Type='Supplier',  AccountNumber = 'TESTPP' );
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Ledger__c journal = new Ledger__c();
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PP', Sub_Account__c = act.AccountNumber , Details__c = 'Purchase Payment', Doc_ID__c = '000041', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-5) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , Credit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		
		
		Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(journal);
		CorrectionController obj = new CorrectionController(std);
		obj.PageInit();
		try
		{
			obj.SaveLedger();
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage(), 'Incorrect Total Amount. \nPlease Enter Valid Amount');
		}
		obj.totalAmount = 200 ;
		obj.SaveLedger();
	}
	
	
	private static testmethod void TestConrrectionSP()
	{
		Account act = new Account(Name='ABC Company',Type='Supplier',  AccountNumber = 'TESTSP' );
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Ledger__c journal = new Ledger__c();
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'SP', Sub_Account__c = act.AccountNumber , Details__c = 'Sales Payment', Doc_ID__c = '000041', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-5) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , Credit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		
		
		Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(journal);
		CorrectionController obj = new CorrectionController(std);
		obj.PageInit();
		try
		{
			obj.SaveLedger();
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage(), 'Incorrect Total Amount. \nPlease Enter Valid Amount');
		}
		obj.totalAmount = 200 ;
		obj.SaveLedger();
	}
	
	
	private static testmethod void TestConrrectionPR()
	{
		Account act = new Account(Name='ABC Company',Type='Supplier',  AccountNumber = 'TESTPR' );
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Ledger__c journal = new Ledger__c();
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PR', Sub_Account__c = act.AccountNumber , Details__c = 'Payment Payment', Doc_ID__c = '000041', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-5) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , Credit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		
		
		Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(journal);
		CorrectionController obj = new CorrectionController(std);
		obj.PageInit();
		try
		{
			obj.SaveLedger();
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage(), 'Incorrect Total Amount. \nPlease Enter Valid Amount');
		}
		obj.totalAmount = 200 ;
		obj.SaveLedger();
	}
	
	
	private static testmethod void TestConrrectionSD()
	{
		Account act = new Account(Name='ABC Company',Type='Supplier',  AccountNumber = 'TESTSD' );
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Ledger__c journal = new Ledger__c();
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'SD', Sub_Account__c = act.AccountNumber , Details__c = 'Sales Dicount', Doc_ID__c = '000041', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-5) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , Credit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		
		
		Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(journal);
		CorrectionController obj = new CorrectionController(std);
		obj.PageInit();
		try
		{
			obj.SaveLedger();
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage(), 'Incorrect Total Amount. \nPlease Enter Valid Amount');
		}
		obj.totalAmount = 200 ;
		obj.SaveLedger();
	}
	
	
	private static testmethod void TestConrrectionPD()
	{
		Account act = new Account(Name='ABC Company',Type='Supplier',  AccountNumber = 'TESTPD' );
		insert act;
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		Ledger__c journal = new Ledger__c();
		journal = new Ledger__c(Trans_No__c=256,Type__c = 'PD', Sub_Account__c = act.AccountNumber , Details__c = 'Purchase Dicount', Doc_ID__c = '000041', Tax__c =  17.50,
									Reference__c = 'testing legder from system debug', Tax_Code__c = 'T2 - 17.5%' , Paid__c = 'N', Trans_Date__c = Date.today().addmonths(-5) , Tax_Rate__c = 17.5, 
									Debit__c =  117.50 , Credit__c =  117.50 , VAT__c = 'N' , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = '2100' , Nominal__c = '4000'
									);
		insert journal ;
		
		
		Apexpages.Standardcontroller std = new Apexpages.Standardcontroller(journal);
		CorrectionController obj = new CorrectionController(std);
		obj.PageInit();
		try
		{
			obj.SaveLedger();
		}
		catch(Exception e)
		{
			system.assertEquals(e.getMessage(), 'Incorrect Total Amount. \nPlease Enter Valid Amount');
		}
		obj.totalAmount = 200 ;
		obj.SaveLedger();
	}
	// End of test code  
}