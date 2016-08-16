public class SupplierPaymentController
{
	public Map<Id, Bank_Account__c> bankMap;
		
	public DataTypeHelper__c supplierLookup {get;set;}
	public Id supplierId {get{return supplierLookup.Supplier_Account__c;}set{supplierLookup.Supplier_Account__c = value;}}
	
	public DataTypeHelper__c dateCalender {get;set;}
	public Date transactionDate {get{return dateCalender.date__c;}set{dateCalender.date__c = value;}}
	
	public List<LedgerEntry> InvoicesAndPayments {get;set;}
	public decimal SettlementAmount {get;set;}
	public decimal AnalysisTotal {get;set;}   
	public string Reference {get;set;}
	       
	private string supplierAccountNumber;
	
	public string CurrencySymbol
	{
		get
		{
			if(CurrencySymbol==null)			
				CurrencySymbol = Functions.getOrganisationCurrency('CurrencySymbol') ;
			return CurrencySymbol;	
		}
		set;
	}
	
	private decimal bankBalance;
	public DataTypeHelper__c BankBalanceCurrency
	{
		get
		{
			return new DataTypeHelper__c(Currency__c = bankBalance);	
		}		
	}
	
	public string BankId {get; set;}
	public List<SelectOption> BankSelectOptions
	{
		get
		{
			List<SelectOption> lst = new List<SelectOption>();
			for(Bank_Account__c b : bankMap.Values())
			{
				lst.Add(new SelectOption(b.Id, b.Nominal_Account__r.Nominal_Code__c+' - '+b.Name));
			}
			return lst; 
		}		
	}
	
	public SupplierPaymentController()
	{
		Init();	
	}
	
	private void Init()
	{
		supplierLookup = new DataTypeHelper__c();
		bankMap = new Map<Id, Bank_Account__c>([Select b.Nominal_Account__r.Balance__c, b.Nominal_Account__r.Nominal_Code__c, b.Nominal_Account__c, b.Name, b.Id From Bank_Account__c b limit 1000]);
		if(bankMap.size()>0)
		{
			BankId = Utility.GetDefaultBankId();			
			SetBankBalance();
		}
	}
	
	public void SetBankBalance()
	{		
		if(bankMap.keyset().contains(BankId))
		{
			bankBalance = bankMap.get(BankId).Nominal_Account__r.Balance__c;	
		}
		else
		{
			bankBalance = null;	
		}		
	}
	
	public void FetchInvoicesAndPayments()
	{		
		Account[] aclist = [select accountNumber from Account where Id=:supplierId];	
		if(aclist.size()>0)
		{			
			supplierAccountNumber = aclist[0].AccountNumber;	
			InvoicesAndPayments = new List<LedgerEntry>();
			if(supplierAccountNumber==null)
				return;
			AnalysisTotal = 0;
			SettlementAmount = 0;	
			/*
			for(Ledger__c l : [Select l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Code__c, 
							  l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, 
							  l.OwnerId, l.Nominal__c, l.Net__c, l.Name, l.Id, l.Doc_ID__c, l.Details__c, l.Amount__c 
							  From Ledger__c l
							  Where l.Type__c in ('PI','PR','PC','PA')
							  and l.Sub_Account__c=:supplierAccountNumber
							  and l.Show_On_Transaction__c=1
							  and l.Paid__c='N'
							  Order by Trans_Date__c asc])
			*/				  
			for(Ledger__c l : Ledger.GetSupplierPendingPurchasePayments(supplierAccountNumber))				  
		  	{
		  		InvoicesAndPayments.add(new LedgerEntry(l));		  		
		  	}
	  	}
	  	else 
	  	{ 	  		 
	  		supplierAccountNumber = null;
	  	}	
	}
	
	public pagereference Save()
	{
		decimal PIPR = 0;
		decimal PCPA = 0;
		Ledger lm = new Ledger();
		List<Ledger__c> ledgerList = new List<Ledger__c>();
		decimal chequeAmount = settlementAmount;
		Savepoint sp = database.setSavePoint();
		try
		{
			if(settlementAmount==0 && analysisTotal<0)
			{
				throw new CustomException('There is unallocated balance of '+(analysisTotal*-1)+'.\nPlease remove it before posting transaction.');
			}
			string supplierNominalCode = Functions.GetCreditorsControlAccountCode();
			string bankNominalCode = bankMap.get(bankId).Nominal_Account__r.Nominal_Code__c;
			string supplierNominalAccountId = Functions.getNominalAccountIdByCode(supplierNominalCode);
			string bankNominalAccountId = Functions.getNominalAccountIdByCode(bankNominalCode);
			List<LedgerEntry> pcpalist = new List<LedgerEntry>();
			//List<LedgerEntry> palist = new List<LedgerEntry>();
			List<LedgerEntry> piprlist = new List<LedgerEntry>();
			//List<LedgerEntry> prlist = new List<LedgerEntry>();
					
			for(LedgerEntry le : InvoicesAndPayments)
			{
				
				decimal paidToDate = le.Entry.Amount__c==null?0:le.Entry.Amount__c;
				decimal paid = le.Receipt==null?0:le.Receipt;
				decimal totalPaid = paidToDate + paid;
				decimal discount = 0;
				
				if(le.Entry.Type__c=='PI' || le.Entry.Type__c=='PR')
				{
					if(le.Entry.Type__c=='PI')
					{
						discount = le.Discount!=null? le.Discount : 0;				
					}				
					PIPR += paid;
				}
				else
				{
					PCPA += paid;
				}				
				
				if(paid!=0 || discount!=0)
				{
					le.Entry.Amount__c = totalPaid + discount;
					if((totalPaid+discount)==le.Entry.Net__c)
					{
						le.Entry.Paid__c = 'Y';
					}
					ledgerList.add(le.Entry);
				}		
				//new algorithm for deciding which line items are settled with which payment
				//Ledger__c entry = le.Entry.clone(false,true);
				if((le.Entry.Type__c=='PC' || le.Entry.Type__c=='PA') && (paid!=0 || discount!=0))
				{ 
					pcpalist.add(le);					
				}
				/*
				else if(le.Entry.Type__c=='PA' && le.Entry.Amount__c!=null && le.Entry.Amount__c!=0)
				{
					palist.add(entry);					
				}
				*/
				else if((le.Entry.Type__c=='PI' || le.Entry.Type__c=='PR') && (paid!=0 || discount!=0))
				{
					piprlist.add(le);
				}
				/*
				else if(le.Entry.Type__c=='PR' && le.Entry.Amount__c!=null && le.Entry.Amount__c!=0)
				{
					prlist.add(entry);
				}
				*/				
				//end: new algorithm for deciding which line items are settled with which payment		
			}
			//new algorithm for deciding which line items are settled with which payment
			//List<Ledger__c> piprlist = pilist;
			//piprlist.addall(prlist);
			//List<Ledger__c> pcpalist = pclist;
			//pcpalist.addall(palist);
			decimal chequeBalance = chequeAmount;
			List<Ledger_Payment_History__c> paymentHistory = new List<Ledger_Payment_History__c>();
			decimal discountAmount = 0;
			decimal receiptAmount = 0;			
			List<Ledger_Payment_History__c> discountPayments = new List<Ledger_Payment_History__c>();
			List<Ledger_Payment_History__c> receiptPayments = new List<Ledger_Payment_History__c>();
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel(); 
			for(LedgerEntry pie : piprlist)
			{
				Ledger__c pi = pie.Entry;
				decimal paid = pie.Receipt;
				decimal settled = 0;
				decimal remaining = paid;
				decimal discount = pie.Discount!=null? pie.Discount : 0; 
				if(discount>0 && pi.Type__c=='PI')
				{
					discountAmount += discount;
					discountPayments.Add(new Ledger_Payment_History__c(Parent_Transaction__c=pi.Id, Parent_Transaction_Number__c=pi.Trans_No__c, Payment_Transaction_Number__c=null, Type__c='PD', Payment_Reference__c=null, Details__c=remaining+' from PD ', Amount__c=discount));					
				}
				for(LedgerEntry pce : pcpalist)
				{
					Ledger__c pc = pce.Entry;
					decimal pcAmount = pce.Receipt;
					if(remaining>=pcAmount)
					{
						settled += pcAmount;
						remaining -= pcAmount;
						pce.Receipt = 0;
						paymentHistory.Add(new Ledger_Payment_History__c(Parent_Transaction__c=pi.Id, Parent_Transaction_Number__c=pi.Trans_No__c, Payment_Transaction_Number__c=pc.Trans_No__c, Type__c=pc.Type__c, Payment_Reference__c=null, Details__c=pcAmount+' from '+pc.Type__c+' '+pc.Trans_No__c, Amount__c=pcAmount));
					}
					else
					{
						settled += remaining;
						pce.Receipt -= remaining;
						paymentHistory.Add(new Ledger_Payment_History__c(Parent_Transaction__c=pi.Id, Parent_Transaction_Number__c=pi.Trans_No__c, Payment_Transaction_Number__c=pc.Trans_No__c, Type__c=pc.Type__c, Payment_Reference__c=null, Details__c=remaining+' from '+pc.Type__c+' '+pc.Trans_No__c, Amount__c=remaining)); 
						remaining = 0;
						break;	
					}	
				}
				if(remaining>0 && (pi.Type__c=='PI' || pi.Type__c=='PR'))
				{
					receiptAmount += remaining;
					receiptPayments.Add(new Ledger_Payment_History__c(Parent_Transaction__c=pi.Id, Parent_Transaction_Number__c=pi.Trans_No__c, Payment_Transaction_Number__c=null, Type__c='PP', Payment_Reference__c=null, Details__c=remaining+' from PP ', Amount__c=remaining));
				}
			}
			if(discountAmount>0)
			{
				lm.AddPurchaseDiscountTransaction(supplierAccountNumber, supplierNominalCode, discountAmount, reference+' adj with purchase discount', null);
				string discountNominalCode = Functions.getNominalAccountCode('Discounts Taken');
				updateNominalBudget.AddDebit(supplierNominalAccountId  , discountAmount , string.valueOf(date.today()));
				updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountIdByCode(discountNominalCode)) , discountAmount , string.valueOf(date.today()));
				double discountTransNo = lm.CurrentTransactionNo;
				for(Ledger_Payment_History__c p : discountPayments)
				{
					p.Payment_Transaction_Number__c = discountTransNo;
					p.Details__c += ''+discountTransNo;
				}
				paymentHistory.AddAll(discountPayments);
			}
			if(receiptAmount>0)
			{
				lm.AddPurchaseReceiptTransaction(bankNominalCode, supplierAccountNumber, supplierNominalCode, receiptAmount, reference+' adj with purchase receipt', null);
				updateNominalBudget.AddDebit(supplierNominalAccountId  , receiptAmount , string.valueOf(date.today()));
				updateNominalBudget.AddCredit(bankNominalAccountId , receiptAmount , string.valueOf(date.today()));
				double receiptTransNo = lm.CurrentTransactionNo;
				for(Ledger_Payment_History__c p : receiptPayments)
				{
					p.Payment_Transaction_Number__c = receiptTransNo;
					p.Details__c += ''+receiptTransNo;
				}
				paymentHistory.AddAll(receiptPayments);
			}
			//end: new algorithm for deciding which line items are settled with which payment
			decimal amountPaid = settlementAmount + PCPA - PIPR;
			if(amountPaid>0)
			{	
				lm.AddPurchasePaymentOnAccountTransaction(bankNominalCode, supplierAccountNumber, supplierNominalCode, amountPaid, reference);
				updateNominalBudget.AddDebit(supplierNominalAccountId  , amountPaid , string.valueOf(date.today()));
				updateNominalBudget.AddCredit(bankNominalAccountId , amountPaid , string.valueOf(date.today()));
			}
			lm.Save(); 
			updateNominalBudget.newSave();
			update ledgerList;
			insert paymentHistory;
			return new apexpages.Pagereference('/apex/bankMenu').setRedirect(true);
		}
		catch(Exception ex)
		{
			database.rollback(sp);
			apexpages.addMessages(ex);			
			return null;
		}
	}
	
	public pagereference Discard()
	{
		return new apexpages.Pagereference('/apex/supplierPayment').setRedirect(true);
	}
	
	//start of test functions
	private static testmethod void TestSupplierController()
	{
		//preparing data for unit testing
		Tax_Rate__c tx = new Tax_Rate__c(Name = 'VAT' , Tax_Rate__c = 15 );
		insert tx ;
		
		Nominal_Categories__c nc = new Nominal_Categories__c(Name = 'Overheads');
		insert nc ;
		Sub_Category__c sb = new Sub_Category__c(Name = 'Suspense & Mispostings' , Nominal_Categories__c  = nc.id , Range_From__c = 9998 , Range_To__c = 9998);
		insert sb ; 
		Nominal_Account__c nA = new Nominal_Account__c(Name = 'Suspense Account' , Account_Code__c = 1245, Expense__c = true , P_O__c = true ,  S_O__c = true ,  Sub_Category__c = sb.id ,  Tax_Rate__c = tx.id);
		insert nA;
		
		Nominal_Account__c nA1 = new Nominal_Account__c(Name = 'Hello Account' , Account_Code__c = 1245, Expense__c = true , P_O__c = true ,  S_O__c = true ,  Sub_Category__c = sb.id ,  Tax_Rate__c = tx.id);
		insert nA1;
		
		Account act = new Account(Name='ABC Company',Type='Supplier' , AccountNumber = 'TEST123' , Credit__c = 500, Debit__c = 200 , Country__c = 'UNITED KINGDOM' , Tax_Rate__c  = tx.id , Nominal_Account__c = nA1.id);
		insert act;		
		
		Bank_Account__c bankAccount = new Bank_Account__c(Account_IBAN_Code__c = 'sdsad' , Account_Number__c ='fdsfds' , 
															Nominal_Account__c = nA.id ,
															Sort_Branch_Code__c = 'sdsad' ,
															Status__c = 'Active' , 
															Type__c = 'Current/Saving');
		insert bankAccount;
		Ledger__c lg = new Ledger__c(
         								VAT__c = 'N', 
								         VAT_Return_No__c = '5', 
								         VAT_Return_Date__c = Date.today(), 
								         Type__c = 'PA' , 
								         Trans_Ref_Id__c = 'sdgfaasg3fd2dsgfa2', 
								         Trans_No__c = 12, 
								         Trans_Date__c = Date.today(), 
								         Tax__c = 0.0, 
								         Tax_Rate__c = 0.0, 
								         Tax_Code__c = 'T9', 
								         Sub_Account__c = act.AccountNumber, 
								         Sub_Account_Nominal__c = '2100', 
								         Show_On_Transaction__c = 1, 
								         Reference__c = 'test', 
								         Paid__c = 'N', 
								         Nominal__c = '5000',
								         Is_Deleted__c = false, 
								         Ext_Reference__c = 'this is test ledger', 
								         Doc_ID__c = '0001', 
								         Details__c ='this is test ledger', 
								         Debit__c = 0.00, 
								         Credit__c = 117.50, 
								         Bank_Reconcile__c = 'N', 
								         Bank_Reconcile_Date__c = null, 
								         Amount__c = 117.50);
         insert lg;
         
         Ledger__c lg1 = new Ledger__c(
         								VAT__c = 'N', 
								         VAT_Return_No__c = '5', 
								         VAT_Return_Date__c = Date.today(), 
								         Type__c = 'PR' , 
								         Trans_Ref_Id__c = 'sdgfaasg3fd2dsgfa2', 
								         Trans_No__c = 13, 
								         Trans_Date__c = Date.today(), 
								         Tax__c = 0.0, 
								         Tax_Rate__c = 0.0, 
								         Tax_Code__c = 'T9', 
								         Sub_Account__c = act.AccountNumber, 
								         Sub_Account_Nominal__c = '2100', 
								         Show_On_Transaction__c = 1, 
								         Reference__c = 'test', 
								         Paid__c = 'N', 
								         Nominal__c = '5000',
								         Is_Deleted__c = false, 
								         Ext_Reference__c = 'this is test ledger', 
								         Doc_ID__c = '0001', 
								         Details__c ='this is test ledger', 
								         Debit__c = 0.00, 
								         Credit__c = 117.50, 
								         Bank_Reconcile__c = 'N', 
								         Bank_Reconcile_Date__c = null, 
								         Amount__c = 117.50);
         insert lg1;
         Ledger__c lg2 = new Ledger__c(
         								VAT__c = 'N', 
								         VAT_Return_No__c = '5', 
								         VAT_Return_Date__c = Date.today(), 
								         Type__c = 'PC' , 
								         Trans_Ref_Id__c = 'sdgfaasg3fd2dsgfa2', 
								         Trans_No__c = 14, 
								         Trans_Date__c = Date.today(), 
								         Tax__c = 0.0, 
								         Tax_Rate__c = 0.0, 
								         Tax_Code__c = 'T9', 
								         Sub_Account__c = act.AccountNumber, 
								         Sub_Account_Nominal__c = '2100', 
								         Show_On_Transaction__c = 1, 
								         Reference__c = 'test', 
								         Paid__c = 'N', 
								         Nominal__c = '5000',
								         Is_Deleted__c = false, 
								         Ext_Reference__c = 'this is test ledger', 
								         Doc_ID__c = '0001', 
								         Details__c ='this is test ledger', 
								         Debit__c = 0.00, 
								         Credit__c = 117.50, 
								         Bank_Reconcile__c = 'N', 
								         Bank_Reconcile_Date__c = null, 
								         Amount__c = 117.50);
         insert lg2;
         Ledger__c lg3 = new Ledger__c(
         								VAT__c = 'N', 
								         VAT_Return_No__c = '5', 
								         VAT_Return_Date__c = Date.today(), 
								         Type__c = 'PI' , 
								         Trans_Ref_Id__c = 'sdgfaasg3fd2dsgfa2', 
								         Trans_No__c = 15, 
								         Trans_Date__c = Date.today(), 
								         Tax__c = 0.0, 
								         Tax_Rate__c = 0.0, 
								         Tax_Code__c = 'T9', 
								         Sub_Account__c = act.AccountNumber, 
								         Sub_Account_Nominal__c = '2100', 
								         Show_On_Transaction__c = 1, 
								         Reference__c = 'test', 
								         Paid__c = 'N', 
								         Nominal__c = '5000',
								         Is_Deleted__c = false, 
								         Ext_Reference__c = 'this is test ledger', 
								         Doc_ID__c = '0001', 
								         Details__c ='this is test ledger', 
								         Debit__c = 0.00, 
								         Credit__c = 117.50, 
								         Bank_Reconcile__c = 'N', 
								         Bank_Reconcile_Date__c = null, 
								         Amount__c = 117.50);
         insert lg3;
        
		
		LedgerEntry let = new LedgerEntry(lg);	
		let.Receipt = 2	;
		let.Discount = 5;
		
		LedgerEntry let1 = new LedgerEntry(lg1);	
		let1.Receipt = 1255;
		let1.Discount = 105;
		
		LedgerEntry let2 = new LedgerEntry(lg2);	
		let1.Receipt = 15;
		let1.Discount = 742;
		
		LedgerEntry let3 = new LedgerEntry(lg3);	
		let1.Receipt = 51; 
		let1.Discount = 50;
		
		Control_Account__c c = new Control_Account__c(Name = 'Control Accounts' , Creditors_Control__c = nA.id );
		insert c;
		c = new Control_Account__c(Name = 'Control Accounts' , Default_Bank__c = nA1.id );
		insert c;
		
		DataTypeHelper__c dth = new DataTypeHelper__c(Currency__c = 5000, Supplier_Account__c = act.id);
		insert dth;			
		
		SupplierPaymentController obj = new SupplierPaymentController();
		
		obj.dateCalender = new DataTypeHelper__c();
		obj.dateCalender.Date__c = Date.today(); 
		obj.Reference = 'abc';		
		
		obj.supplierId = dth.Supplier_Account__c;
		obj.BankId = bankAccount.id ;
		List<SelectOption> slctOpt = obj.BankSelectOptions;
		
		obj.SetBankBalance();
		obj.SettlementAmount = 0;
		obj.AnalysisTotal = -1;
		try
		{
			obj.Save();
		}
		catch(exception e)
		{}
		obj.InvoicesAndPayments = new List<LedgerEntry>();
		
		obj.FetchInvoicesAndPayments();
		obj.InvoicesAndPayments.add(let);		
		
		obj.InvoicesAndPayments.add(let1);
		obj.InvoicesAndPayments.add(let2);
		obj.InvoicesAndPayments.add(let3);
		
		obj.SettlementAmount = 23;
		obj.AnalysisTotal = 0;				
		obj.Save();
		obj.Discard();
		
	}
	// end of test functions
}