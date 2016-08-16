public class CustomerReceiptPaymentController
{
	public Map<Id, Bank_Account__c> bankMap;
		
	public DataTypeHelper__c customerLookup {get;set;}
	public Id CustomerId {get{return customerLookup.Customer_Account__c;}set{customerLookup.Customer_Account__c = value;}}
	
	public DataTypeHelper__c dateCalender {get;set;}
	public Date transactionDate {get{return dateCalender.date__c;}set{dateCalender.date__c = value;}}
	
	public List<LedgerEntry> InvoicesAndPayments {get;set;}
	public decimal SettlementAmount {get;set;}
	public decimal AnalysisTotal {get;set;}
	public string Reference {get;set;}
	
	private string customerAccountNumber;
	
	public decimal bankBalance {get;set;}
	public DataTypeHelper__c BankBalanceCurrency
	{
		get
		{
			return new DataTypeHelper__c(Currency__c = bankBalance);	
		}		
	}	
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
	
	public Id BankId {get; set;}
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
	
	public CustomerReceiptPaymentController()
	{
		Init();	
	}
	
	private void Init()
	{
		customerLookup = new DataTypeHelper__c();
		bankMap = new Map<Id, Bank_Account__c>([Select b.Id, b.Nominal_Account__r.Balance__c, b.Nominal_Account__r.Nominal_Code__c, b.Nominal_Account__c, b.Name From Bank_Account__c b limit 1000]);		
		if(bankMap.size()>0)
		{
			BankId = Utility.GetDefaultBankId();
			SetBankBalance();
		}
	}
	
	public void SetBankBalance()
	{		
		try
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
		catch(Exception e)
		{
			apexpages.addmessages(e);
		}		
	}
	
	public void FetchInvoicesAndPayments()
	{		
		Account[] aclist = [select accountNumber from Account where Id=:customerId];			
		if(aclist.size()>0)
		{									
			customerAccountNumber = aclist[0].AccountNumber;	
			InvoicesAndPayments = new List<LedgerEntry>();
			if(customerAccountNumber==null)
				return;
			AnalysisTotal = 0;
			SettlementAmount = 0;	
			for(Ledger__c l : Ledger.GetCustomerPendingSalesPayments(customerAccountNumber))				  
		  	{
		  		InvoicesAndPayments.add(new LedgerEntry(l));				  		
		  	}
	  	}
	  	else
	  	{
	  		customerAccountNumber = null;
	  	}	
	}
	public pagereference Save()
	{
		decimal SISP = 0;
		decimal SCSA = 0;
		Ledger lm = new Ledger();
		List<Ledger__c> ledgerList = new List<Ledger__c>();
		Savepoint sp = database.setSavePoint();
		decimal chequeAmount = settlementAmount;
		try
		{
			if(chequeAmount==0 && analysisTotal<0)
			{
				throw new CustomException('There is unallocated balance of '+(analysisTotal*-1)+'.\nPlease remove it before posting transaction.');
			}
			string customerNominalCode = Functions.GetDebtorsControlAccountCode();
			string bankNominalCode = bankMap.get(bankId).Nominal_Account__r.Nominal_Code__c;
			string customerNominalAccountId = Functions.getNominalAccountIdByCode(customerNominalCode);
			string bankNominalAccountId = Functions.getNominalAccountIdByCode(bankNominalCode);
			
			List<LedgerEntry> scsalist = new List<LedgerEntry>();
			List<LedgerEntry> sisplist = new List<LedgerEntry>();
			
			for(LedgerEntry le : InvoicesAndPayments)
			{
				decimal paidToDate = le.Entry.Amount__c==null?0:le.Entry.Amount__c;
				decimal paid = le.Receipt==null?0:le.Receipt;
				decimal totalPaid = paidToDate + paid;
				decimal discount = 0;
				
				if(le.Entry.Type__c=='SI' || le.Entry.Type__c=='SP')
				{
					if(le.Entry.Type__c=='SI')
					{
						discount = le.Discount!=null? le.Discount : 0;
					}				
					SISP += paid;
				}
				else
				{
					SCSA += paid;
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
				Ledger__c entry = le.Entry.clone(false,true);
				if((le.Entry.Type__c=='SC' || le.Entry.Type__c=='SA') && (paid!=0 || discount!=0))
				{
					scsalist.add(le);					
				}
				/*
				else if(le.Entry.Type__c=='SA' && le.Entry.Amount__c!=null && le.Entry.Amount__c!=0)
				{
					salist.add(entry);
				}
				*/
				else if((le.Entry.Type__c=='SI' || le.Entry.Type__c=='SP') && (paid!=0 || discount!=0))
				{
					sisplist.add(le);					
				}
				/*
				else if(le.Entry.Type__c=='SP' && le.Entry.Amount__c!=null && le.Entry.Amount__c!=0)
				{
					splist.add(entry);
				}
				*/				
				//end: new algorithm for deciding which line items are settled with which payment
			}
			//new algorithm for deciding which line items are settled with which payment
			//List<Ledger__c> sisplist = silist;
			//sisplist.addall(splist);
			//List<Ledger__c> scsalist = sclist;
			//scsalist.addall(salist);
			decimal chequeBalance = chequeAmount;
			List<Ledger_Payment_History__c> paymentHistory = new List<Ledger_Payment_History__c>();
			decimal discountAmount = 0;
			decimal receiptAmount = 0;
			List<Ledger_Payment_History__c> discountPayments = new List<Ledger_Payment_History__c>();
			List<Ledger_Payment_History__c> receiptPayments = new List<Ledger_Payment_History__c>();
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel();
			for(LedgerEntry sie : sisplist)
			{
				Ledger__c si = sie.Entry;
				decimal paid = sie.Receipt;
				decimal settled = 0;
				decimal remaining = paid;
				decimal discount = sie.Discount!=null? sie.Discount : 0;
				if(discount>0 && si.Type__c=='SI')
				{
					discountAmount += discount;
					discountPayments.Add(new Ledger_Payment_History__c(Parent_Transaction__c=si.Id, Parent_Transaction_Number__c=si.Trans_No__c, Payment_Transaction_Number__c=null, Type__c='SD', Payment_Reference__c=null, Details__c=remaining+' from SD ', Amount__c=discount));					
				}
				for(LedgerEntry sce : scsalist)
				{
					Ledger__c sc = sce.Entry;
					decimal scAmount = sce.Receipt;
					if(remaining>=scAmount)
					{
						settled += scAmount;
						remaining -= scAmount;
						sce.Receipt = 0;
						paymentHistory.Add(new Ledger_Payment_History__c(Parent_Transaction__c=si.Id, Parent_Transaction_Number__c=si.Trans_No__c, Payment_Transaction_Number__c=sc.Trans_No__c, Type__c=sc.Type__c, Payment_Reference__c=null, Details__c=scAmount+' from '+sc.Type__c+' '+sc.Trans_No__c, Amount__c=scAmount));						
					}
					else
					{
						settled += remaining;
						sce.Receipt -= remaining;
						paymentHistory.Add(new Ledger_Payment_History__c(Parent_Transaction__c=si.Id, Parent_Transaction_Number__c=si.Trans_No__c, Payment_Transaction_Number__c=sc.Trans_No__c, Type__c=sc.Type__c, Payment_Reference__c=null, Details__c=remaining+' from '+sc.Type__c+' '+sc.Trans_No__c, Amount__c=remaining)); 
						remaining = 0;						
						break;	
					}	
				}
				if(remaining>0 && (si.Type__c=='SI' || si.Type__c=='SP'))
				{
					receiptAmount += remaining;
					receiptPayments.Add(new Ledger_Payment_History__c(Parent_Transaction__c=si.Id, Parent_Transaction_Number__c=si.Trans_No__c, Payment_Transaction_Number__c=null, Type__c='SR', Payment_Reference__c=null, Details__c=remaining+' from SR ', Amount__c=remaining));
				}
			}
			if(discountAmount>0)
			{
				lm.AddSalesDiscountTransaction(customerAccountNumber, customerNominalCode, discountAmount, 'adj invoice with sales discount', null);
				string discountNominalCode = Functions.getNominalAccountCode('Discounts Allowed');
				updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountIdByCode(discountNominalCode)) , discountAmount , string.valueOf(date.today()));
				updateNominalBudget.AddCredit(customerNominalAccountId  , discountAmount , string.valueOf(date.today()));				
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
				lm.AddSalesReceiptTransaction(bankNominalCode, customerAccountNumber, customerNominalCode, receiptAmount, 'Sales Receipt', null);
				updateNominalBudget.AddDebit(bankNominalAccountId , receiptAmount , string.valueOf(date.today()));
				updateNominalBudget.AddCredit(customerNominalAccountId  , receiptAmount , string.valueOf(date.today()));				
				double receiptTransNo = lm.CurrentTransactionNo;
				for(Ledger_Payment_History__c p : receiptPayments)
				{
					p.Payment_Transaction_Number__c = receiptTransNo;
					p.Details__c += ''+receiptTransNo;
					//apexpages.addmessage(new apexpages.message(apexpages.severity.info,'Parent Transaction Id: '+p.Parent_Transaction_Number__c+' || Payment Transaction Id: '+p.Payment_Transaction_Number__c+' || '+p.Details__c));
				}
				paymentHistory.AddAll(receiptPayments);
			}
			//end: new algorithm for deciding which line items are settled with which payment
			decimal amountPaid = chequeAmount + SCSA - SISP;
			if(amountPaid>0)
			{	
				lm.AddSalesPaymentOnAccountTransaction(bankNominalCode, customerAccountNumber, customerNominalCode, amountPaid, reference);
				updateNominalBudget.AddDebit(bankNominalAccountId , amountPaid , string.valueOf(date.today()));
				updateNominalBudget.AddCredit(customerNominalAccountId  , amountPaid , string.valueOf(date.today()));				
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
		return new apexpages.Pagereference('/apex/customerReceiptPayment').setRedirect(true);
	}
	private static testMethod void TestCustomerReceiptPaymentController()
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
		
		Nominal_Account__c nA1 = new Nominal_Account__c(Name = 'Test Account' , Account_Code__c = 1245, Expense__c = true , P_O__c = true ,  S_O__c = true ,  Sub_Category__c = sb.id ,  Tax_Rate__c = tx.id);
		insert nA1;
		
		Account act = new Account(Name='ABC Company',Type='Customer' , AccountNumber = 'TEST123' , Credit__c = 500, Debit__c = 200 , Country__c = 'UNITED KINGDOM' , Tax_Rate__c  = tx.id , Nominal_Account__c = nA1.id);
		insert act;
		
		
		Bank_Account__c bankAccount = new Bank_Account__c(Account_IBAN_Code__c = 'sdsad' , Account_Number__c ='fdsfds' , 
															Nominal_Account__c = nA.id ,
															Sort_Branch_Code__c = 'sdsad' ,
															Status__c = 'Active' , 
															Type__c = 'Current/Saving');
		insert bankAccount;
		Ledger__c lg = new Ledger__c(	 VAT__c = 'N', 
								         VAT_Return_No__c = '5', 
								         VAT_Return_Date__c = Date.today(), 
								         Type__c = 'SA' , 
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
								         Type__c = 'SC' , 
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
								         Type__c = 'SP' , 
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
								         Type__c = 'SI' , 
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
        
		/*Control_Account__c c = new Control_Account__c(Name = 'Control Accounts' , Creditors_Control__c = nA.id );
		insert c;
		c = new Control_Account__c(Name = 'Control Accounts' , Default_Bank__c = nA1.id );
		insert c;
		*/
		DataTypeHelper__c dth = new DataTypeHelper__c(Currency__c = 5000, Customer_Account__c = act.id);
		insert dth;			
		
		CustomerReceiptPaymentController obj = new CustomerReceiptPaymentController();
		
		obj.BankId = bankAccount.id ;
		List<SelectOption> slctOpt = obj.BankSelectOptions;
		obj.SetBankBalance();
		
		DataTypeHelper__c crncy = obj.BankBalanceCurrency;
		obj.CustomerId = dth.Customer_Account__c;
		obj.FetchInvoicesAndPayments();
				
		obj.dateCalender = new DataTypeHelper__c();
		obj.dateCalender.Date__c = Date.today(); 
		string crncySmbl = obj.CurrencySymbol;
		obj.Reference = 'abc';	
		
		obj.SettlementAmount = 0;
		obj.AnalysisTotal = -1;
		try
		{
			obj.Save();
		}
		catch(exception e)
		{}		
		obj.SettlementAmount = 23;
		obj.AnalysisTotal = 0;				
		for(LedgerEntry lentry : obj.InvoicesAndPayments)
		{
			lentry.Receipt = 2	;
			lentry.Discount = 5 ;						
		}		
		obj.Save();
		obj.Discard();
		
	}
	// end of test functions
}