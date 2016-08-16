public class Ledger {	
	Ledger__c ledger{get;set;}
	public Ledger__c newLedger;
	public Ledger__c taxLedger;	
	public List<Ledger__c> lstledger;
	private List<General_Setup__c> Gsetup {get; set;}	
	public integer currentNo;
	public decimal CurrentTransactionNo {Get{return currentNo;}}
	public string otherID;
	public list<Ledger__c> ledgerTransaction {get; set;}
	private boolean isFirst=true;	
	public enum showOnTransactionStatus {NO,YES,ALL}
	public enum paidStatus {N,Y,ALL}
		
	public integer getOrderNumber()
	{
		integer ordernumber ; 
		Gsetup = new List<General_Setup__c>() ;
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'Ledger Transaction' limit 1] ; 
		if (Gsetup.size()>0)
		{
			if (Gsetup[0].Current_Document_Number__c == null)
				throw new CustomException ('Please enter starting Ledger Transaction #. & current document number in GENERAL SETUP');
			if (Gsetup[0].Current_Document_Number__c == -1)
			{
				ordernumber  = 	integer.valueof(Gsetup[0].Starting_Document_No__c) ; 
			}
			else 
			{
				string dc_curentno = string.valueof(Gsetup[0].Current_Document_Number__c);
                ordernumber  = 	integer.valueof(dc_curentno);                
			}
		}
		else
		{
			throw new customException('Please enter starting Ledger Transaction #. in GENERAL SETUP.');
		}
		return ordernumber ;
	}
	public static string getOrderNo(string orderNo)
	{
		if (orderNo.length() < 6)
		{
			integer ln = 6 - orderNo.length();
			for (integer i=0 ; i<ln ; i++)
			{
				orderNo  = '0'+ orderNo;
			}
		}
		return orderNo ;
	}
	public void updateOrderNo(integer currentOrderNo)
	{
		Gsetup = new List<General_Setup__c>() ;
		Gsetup = [select Starting_Document_No__c , Current_Document_Number__c from General_setup__c where Object__c = 'Ledger Transaction' limit 1] ; 
		Gsetup[0].Current_Document_Number__c = currentOrderNo ;
		update Gsetup ;
	}
	
	public static set<string> PaymentTypes = new set<string>{'SC','PC','SA','PA','SD','PD','SR','PP'}; 
	public void updateTransactionID()
	{
		updateOrderNo(currentNo);		
	}
	
	public Ledger(Ledger__c l)
	{
		ledger = l;		
		lstledger = new List<Ledger__c>();
		currentNo = currentNo+1 ;
		ledger.Trans_No__c = currentNo;
		if(ledger.Tax__c > 0.0)
			ledger.VAT__c = 'N'; 
		//currentNo.Ledger_Transaction_No__c = currentNo;
	}
	
	public Ledger()
	{
		lstledger = new List<Ledger__c>();
		currentNo = getOrderNumber();		
	}	
	/*
	public Ledger(List<LedgerTransactionWrapper> tranValues , string TrType)
	{		
		if( TrType == 'SI')
			saveSITransaction(tranValues);
		system.debug('this si trType: ' + TrType);
		if (TrType == 'PI')
			savePITransaction(tranValues);
	}
	
	public void saveSITransaction(List<LedgerTransactionWrapper> tranValues)
	{		
		currentNo = currentNo+1 ;
		getTransactionToLedger(tranValues);
		system.debug('this is ledger: SI ' + ledgerTransaction) ;
		insert ledgerTransaction ;
		updateTransactionID();		
	}
	public void savePITransaction(List<LedgerTransactionWrapper> tranValues)
	{
		system.debug('This is PI Transaction: ' + tranValues);
		currentNo = currentNo+1 ;
		getTransactionToLedger(tranValues);
		system.debug('this is ledger: PI ' + ledgerTransaction) ;
		insert ledgerTransaction ;
		updateTransactionID();		
	}
	
	public void getTransactionToLedger(List<LedgerTransactionWrapper> tranValues)
	{
		system.debug('this is ledger object function' + tranValues ) ;
		List<Ledger__c> ledg = new List<Ledger__c>();
		for (LedgerTransactionWrapper tr : tranValues)
		{
			Ledger__c tmpledg = new Ledger__c() ;
			tmpledg.Amount__c = tr.Amount ;
			tmpledg.Bank_Reconcile__c = tr.BankReconcile ;
			tmpledg.Bank_Reconcile_Date__c = tr.ReconcileDate ;
			tmpledg.Credit__c = tr.Credit ;
			tmpledg.Debit__c = tr.Debit ;
			tmpledg.Details__c = tr.Details ;
			tmpledg.Doc_ID__c = tr.Doc ;
			tmpledg.Nominal__c = tr.Nominal ;
			tmpledg.Paid__c = tr.Paid ;
			tmpledg.Reference__c = tr.Reference ;
			tmpledg.Show_On_Transaction__c = tr.ShowOnTransaction ;
			tmpledg.Sub_Account__c = tr.SubAccount ;
			tmpledg.Sub_Account_Nominal__c = tr.SubAccountNominal ; 
			tmpledg.Tax__c = tr.Tax ;
			tmpledg.Tax_Code__c = tr.TaxCode ;
			tmpledg.Trans_No__c = currentNo ;
			tmpledg.Trans_Ref_Id__c = tr.TransRefId ;
			tmpledg.Trans_Date__c = tr.TransDate ;
			tmpledg.Type__c = tr.TrType ;
			tmpledg.VAT__c = tr.VAT ;
			tmpledg.VAT_Return_Date__c = tr.VATReturnDate ;
			tmpledg.VAT_Return_No__c = tr.VATReturnNo ;
			ledg.add(tmpledg);
		}
		ledgerTransaction = ledg ;
		//insert ledgerTransaction ;
	}
	*/
	public void Save()
	{						
		Savepoint sp =  DataBase.setSavepoint();
		try
		{						
			upsert lstledger;
			updateTransactionID();			
		} 						
		catch(exception e)
		{
			Database.rollback(sp);
			throw new CustomException('Unable to Save. Model exception '+e.getMessage(),e);
		}		
	}
	public void Save(string creditId,string debitId)
	{
		if(ledger.Credit__c > 0.0)
		{
			newLedger = new Ledger__c(Trans_No__c= ledger.Trans_No__c,Debit__c = ledger.Credit__c,Type__c = ledger.Type__c,Sub_Account_Nominal__c = ledger.Nominal__c,Details__c= ledger.Details__c,VAT_Return_Date__c = ledger.VAT_Return_Date__c,VAT_Return_No__c = ledger.VAT_Return_No__c, Reference__c = ledger.Reference__c, Tax_Code__c = ledger.Tax_Code__c,Tax__c = ledger.Tax__c, Paid__c= ledger.Paid__c,Amount__c = ledger.Amount__c, Trans_Date__c = ledger.Trans_Date__c);
			if(newLedger.Sub_Account_Nominal__c >= '1200' && newLedger.Sub_Account_Nominal__c <= '1299')
				newLedger.Bank_Reconcile__c = 'N';
			lstledger.add(newLedger); 			
			lstledger.add(ledger);
		}
		else
		{
			newLedger = new Ledger__c(Trans_No__c= ledger.Trans_No__c,Credit__c = ledger.Debit__c,Type__c = ledger.Type__c,Sub_Account_Nominal__c = ledger.Nominal__c, Details__c= ledger.Details__c,VAT_Return_Date__c = ledger.VAT_Return_Date__c,VAT_Return_No__c = ledger.VAT_Return_No__c, Reference__c = ledger.Reference__c, Tax_Code__c = ledger.Tax_Code__c,Tax__c = ledger.Tax__c, Paid__c= ledger.Paid__c,Amount__c = ledger.Amount__c, Trans_Date__c = ledger.Trans_Date__c);			
			if(newLedger.Sub_Account_Nominal__c >= '1200' && newLedger.Sub_Account_Nominal__c <= '1299')
				newLedger.Bank_Reconcile__c = 'N';
			lstledger.add(ledger);
			lstledger.add(newLedger);
		}
		this.Save();
		
	}
	public void addObjects(Ledger__c ledger)
	{				
		try
		{		
			newLedger = new Ledger__c(Trans_No__c= ledger.Trans_No__c,Credit__c = ledger.Credit__c,Type__c = ledger.Type__c,Sub_Account_Nominal__c = ledger.Nominal__c, Details__c= ledger.Details__c,VAT_Return_Date__c = ledger.VAT_Return_Date__c,VAT_Return_No__c = ledger.VAT_Return_No__c, Reference__c = ledger.Reference__c, Tax_Code__c = ledger.Tax_Code__c,Tax__c = ledger.Tax__c, Paid__c= ledger.Paid__c,Amount__c = ledger.Amount__c, Trans_Date__c = ledger.Trans_Date__c);				
			newledger.Tax__c = 0.00;			
			if(ledger.Credit__c > 0)
			{
				newLedger.Credit__c = null;
				if(ledger.Tax__c > 0.0)
				{
					newLedger.Debit__c = ledger.Credit__c - ledger.Tax__c;
					lstledger.add(newLedger);
					addTax(ledger);
				}
				else
				{
					newLedger.Debit__c = ledger.Credit__c;
					lstledger.add(newLedger);
				}					
				lstledger.add(ledger);
			}
			else
			{
				newLedger.Debit__c = null;
				lstledger.add(ledger);
				if(ledger.Tax__c > 0.0)
				{
					newLedger.Credit__c = ledger.Debit__c - ledger.Tax__c;
					lstledger.add(newLedger);
					addTax(ledger);
				}
				else
				{
					newLedger.Credit__c = ledger.Debit__c;
					lstledger.add(newLedger);
				}				
			}		
		}		
		catch(exception ex)
		{
			throw new CustomException('newLedger can not b identical'+ ex.getMessage());
		}		
			
	}	
	public void addTax(Ledger__c ledger)
	{		
		try
		{
			taxLedger = new Ledger__c(Trans_No__c= ledger.Trans_No__c,Credit__c = ledger.Credit__c,Type__c = ledger.Type__c,Sub_Account_Nominal__c = ledger.Sub_Account_Nominal__c, Details__c= ledger.Details__c,VAT_Return_Date__c = ledger.VAT_Return_Date__c,VAT_Return_No__c = ledger.VAT_Return_No__c, Reference__c = ledger.Reference__c, Tax_Code__c = ledger.Tax_Code__c,Tax__c = ledger.Tax__c, Paid__c= ledger.Paid__c,Amount__c = ledger.Amount__c, Trans_Date__c = ledger.Trans_Date__c);				
			TaxCode(ledger);			
			taxLedger.Tax__c = 0.00;						 		
			if(ledger.Credit__c > 0)
			{
				taxLedger.Debit__c = ledger.Tax__c;
				taxLedger.Credit__c = null;
			}
			else 
			{
				taxLedger.Credit__c = ledger.Tax__c;
				taxLedger.Debit__c = null;
			}		
			lstledger.add(taxLedger);		
		}
		catch(exception ex)
		{
			throw new CustomException('taxLedger can not b identical'+ ex.getMessage());
		}
	}		
	public void TaxCode(Ledger__c ledger)
	{
		try
		{
			if(ledger.Type__c == 'BP')
				taxLedger.Sub_Account_Nominal__c = [select Nominal_Code__c from Nominal_Account__c where Name =: 'Purchase Tax Control Account'].Nominal_Code__c;
			if(ledger.Type__c == 'BR')
				taxLedger.Sub_Account_Nominal__c = [select Nominal_Code__c from Nominal_Account__c where Name =: 'Sales Tax Control Account'].Nominal_Code__c;
			
		}
		catch(exception ex)
		{
			throw new CustomException('taxLedger can not b identical'+ ex.getMessage());
		}
	}
	//public void	
	public void AddBankPaymentTransaction(decimal Amount, string SubAccountNominal,string NominalAccount,string detail, string reference,string TaxName, decimal TaxAmount)
	{
		Ledger__c journal;
		currentNo++;		
		journal = new Ledger__c(Trans_No__c=currentNo,Type__c = 'BP',Debit__c = Amount-TaxAmount , Sub_Account_Nominal__c = NominalAccount, Details__c = detail, Reference__c = reference, Tax_Code__c = TaxName, Paid__c = 'Y', Trans_Date__c = Date.today());
		lstLedger.add(journal);
		if(TaxAmount > 0)
		{
			journal = new Ledger__c(Trans_No__c=currentNo,Type__c = 'BP',Debit__c = TaxAmount , Sub_Account_Nominal__c = Functions.getNominalAccountCode('Purchase Tax Control Account'), Details__c = detail, Reference__c = reference, Tax_Code__c = TaxName, Paid__c = 'Y', Trans_Date__c = Date.today());
			lstLedger.add(journal);
		}
		journal = new Ledger__c(Show_On_Transaction__c = 1,Trans_No__c=currentNo,Type__c = 'BP' ,Credit__c = Amount,Sub_Account__c= SubAccountNominal, Sub_Account_Nominal__c = SubAccountNominal, Nominal__c = NominalAccount, Details__c = detail, Reference__c = reference, Tax_Code__c = TaxName, Tax__c = TaxAmount, Paid__c = 'Y',Amount__c = Amount, Trans_Date__c = Date.today());
		if(TaxName != Functions.getTaxNameZero())
			journal.VAT__C = 'N';
		if(SubAccountNominal >= '1200' && SubAccountNominal <= '1299')
			journal.Bank_Reconcile__c = 'N';		
		lstLedger.add(journal);			
	}
	
	public void AddSalesInvoice(string TrType ,  string DocId , string Reference , string TaxCode , string SubAccount , decimal TotalGross , Decimal TotalNet , decimal VATAmount , decimal TaxRate , Id AccountID ,  string VAT_Type , date InvoiceDate , boolean isCloned)
	{
		AddSalesInvoice(TrType, DocId, Reference, TaxCode, SubAccount, TotalGross, TotalNet, VATAmount, TaxRate, AccountID, VAT_Type, InvoiceDate, isCloned, null);				
	}
	
	public void AddSalesInvoice(string TrType ,  string DocId , string Reference , string TaxCode , string SubAccount , decimal TotalGross , Decimal TotalNet , decimal VATAmount , decimal TaxRate , Id AccountID ,  string VAT_Type , date InvoiceDate , boolean isCloned, double oldTransactionNumber)
	{
		if (TrType == 'Sales Invoice')
		{			
			Ledger__c journal;
			currentNo++;					
			journal = new Ledger__c(Trans_No__c=currentNo,Type__c = 'SI', Sub_Account__c = SubAccount , Details__c = isCloned==true?'Deleted - see tran '+oldTransactionNumber:'Sales Invoice', Doc_ID__c = DocId , Tax__c =  VATAmount ,
									Reference__c = Reference, Tax_Code__c = TaxCode , Paid__c = 'N', Trans_Date__c = InvoiceDate , Tax_Rate__c = TaxRate , 
									Debit__c = TotalGross , VAT__c = VAT_Type , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = Functions.getAccountCodeByName('Debtors Control') , 
									Nominal__c = Functions.getNominalAccountCode('Sales North') ,
									Is_Deleted__c =  isCloned==true?true:false
									);
			lstLedger.add(journal);			
			if(!isCloned)
				updateAccount(AccountID ,  null , TotalGross );
			if(VATAmount > 0)
			{
				journal = new Ledger__c(Trans_No__c=currentNo,Type__c = 'SI', Details__c = isCloned==true?'Deleted - see tran '+oldTransactionNumber:'Sales Invoice', Doc_ID__c = DocId ,                      
									Reference__c = Reference, Tax_Code__c = TaxCode , Paid__c = 'N', Trans_Date__c = InvoiceDate , 
									Credit__c = VATAmount ,Tax__c =0.00 , VAT__c = null ,
									Sub_Account_Nominal__c = Functions.getNominalAccountCode('Sales Tax Control Account') ,
									Is_Deleted__c =  isCloned==true?true:false
									);
				lstLedger.add(journal);				
			}
			journal = new Ledger__c(Trans_No__c=currentNo,Type__c = 'SI', Details__c = isCloned==true?'Deleted - see tran '+oldTransactionNumber:'Sales Invoice', Doc_ID__c = DocId , 
									Reference__c = Reference, Tax_Code__c = TaxCode , Paid__c = 'N', Trans_Date__c = InvoiceDate , 
									Credit__c = TotalNet ,Tax__c =0.00 , VAT__c = null , Show_On_Transaction__c = null ,
									Sub_Account_Nominal__c = Functions.getNominalAccountCode('Sales North') ,
									Is_Deleted__c =  isCloned==true?true:false
									);
			lstLedger.add(journal);			
		} 
		else if (TrType == 'Sales Credit')
		{
			Ledger__c journal;
			currentNo++;					
			journal = new Ledger__c(Trans_No__c=currentNo,Type__c = 'SC', Sub_Account__c = SubAccount , Details__c = isCloned==true?'Deleted - see tran '+oldTransactionNumber:'Sales Credit', Doc_ID__c = DocId , 
									Reference__c = Reference, Tax_Code__c = TaxCode , Paid__c = 'N', Trans_Date__c = InvoiceDate , Tax__c =  VATAmount ,
									Credit__c = TotalGross , VAT__c = 'N' , Show_On_Transaction__c = 1 , Tax_Rate__c = TaxRate , 
									Sub_Account_Nominal__c = Functions.getAccountCodeByName('Debtors Control') , 
									Nominal__c = Functions.getNominalAccountCode('Sales North'),
									Is_Deleted__c =  isCloned==true?true:false 
									);
			lstLedger.add(journal);			
			if(!isCloned)
				updateAccount(AccountID , TotalGross , null );
			if(VATAmount > 0)
			{
				journal = new Ledger__c(Trans_No__c=currentNo,Type__c = 'SC', Details__c = isCloned==true?'Deleted - see tran '+oldTransactionNumber:'Sales Credit', Doc_ID__c = DocId , 
									Reference__c = Reference, Tax_Code__c = TaxCode , Paid__c = 'N', Trans_Date__c = InvoiceDate , 
									Debit__c = VATAmount ,Tax__c =0.00 , VAT__c = null ,
									Sub_Account_Nominal__c = Functions.getNominalAccountCode('Sales Tax Control Account') ,
									Is_Deleted__c =  isCloned==true?true:false
									);
				lstLedger.add(journal);				
			}
			journal = new Ledger__c(Trans_No__c=currentNo,Type__c = 'SC', Details__c = isCloned==true?'Deleted - see tran '+oldTransactionNumber:'Sales Credit', Doc_ID__c = DocId ,  
									Reference__c = Reference, Tax_Code__c = TaxCode , Paid__c = 'N', Trans_Date__c = InvoiceDate , 
									Debit__c = TotalNet ,Tax__c =0.00 , VAT__c = null , Show_On_Transaction__c = null ,
									Sub_Account_Nominal__c = Functions.getNominalAccountCode('Sales North') ,
									Is_Deleted__c =  isCloned==true?true:false
									);
			lstLedger.add(journal);			
		}					
	}
	public void updateAccount(Id AccountID , decimal credit , decimal debit)
	{	
		Account ac = [select credit__c , debit__c from Account where Id = : AccountID ];
		if(credit != null )
			ac.credit__c += credit ;
		if( debit != null)
			ac.debit__c += debit;
		update ac ;
	}
	public void AddPurchaseInvoice(string TrType , string DocId , string Reference , string TaxCode , string SubAccount , decimal TotalGross , Decimal TotalNet , decimal VATAmount , decimal TaxRate, Id AccountID, string VAT_Type , date InvoiceDate , boolean isCloned)
	{
		AddPurchaseInvoice(TrType, DocId, Reference, TaxCode, SubAccount, TotalGross, TotalNet, VATAmount, TaxRate, AccountID, VAT_Type, InvoiceDate, isCloned, null);
	}
	public void AddPurchaseInvoice(string TrType , string DocId , string Reference , string TaxCode , string SubAccount , decimal TotalGross , Decimal TotalNet , decimal VATAmount , decimal TaxRate, Id AccountID, string VAT_Type , date InvoiceDate , boolean isCloned, double oldTransactionNumber)
	{
		if (TrType == 'Purchase Invoice')
		{
			Ledger__c journal;
			currentNo++;		
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel();
			NominalModel nmEntry = new NominalModel();
			journal = new Ledger__c(Trans_No__c=currentNo,Type__c = 'PI', Sub_Account__c = SubAccount , Details__c = isCloned==true?'Deleted - see tran '+oldTransactionNumber:'Purchase Invoice', Doc_ID__c = DocId , 
									Reference__c = Reference, Tax_Code__c = TaxCode , Paid__c = 'N', Trans_Date__c = InvoiceDate , Tax__c =  VATAmount , Tax_Rate__c = TaxRate , 
									Credit__c = TotalGross , VAT__c = VAT_Type , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = Functions.getAccountCodeByName('Creditors Control') , 
									Nominal__c= Functions.getNominalAccountCode('Materials Purchased'),
									Is_Deleted__c =  isCloned==true?true:false
									);
			lstLedger.add(journal);
			//NominalModel nmEntry = new NominalModel( Functions.getNominalAccountId('Creditors Control Account') ,  '' , TotalGross  );
			//nmEntry.save();
			//nmEntry.AddCredit(Functions.getNominalAccountId('Creditors Control Account'), isCloned==true?(-TotalGross):TotalGross );
			updateNominalBudget.AddCredit(Functions.getNominalAccountId('Creditors Control Account') , isCloned==true?(-TotalGross):TotalGross  , string.valueOf(InvoiceDate));
			//CustomerRefund_BudgetModel mnActuals = new CustomerRefund_BudgetModel(Functions.getNominalAccountId('Creditors Control Account') , null , TotalGross );
			//mnActuals.save();
			if(!isCloned)
				updateAccount(AccountID , TotalGross , null );
			if(VATAmount > 0)
			{
				journal = new Ledger__c(Trans_No__c=currentNo,Type__c = 'PI',  Details__c = isCloned==true?'Deleted - see tran '+oldTransactionNumber:'Purchase Invoice', Doc_ID__c = DocId , 
									Reference__c = Reference, Tax_Code__c = TaxCode , Paid__c = 'N', Trans_Date__c = InvoiceDate , 
									Debit__c = VATAmount ,Tax__c =0.00 , VAT__c = null ,
									Sub_Account_Nominal__c = Functions.getNominalAccountCode('Purchase Tax Control Account')  ,
									Is_Deleted__c =  isCloned==true?true:false
									);
				lstLedger.add(journal);
				//nmEntry = new NominalModel( '' , Functions.getNominalAccountId('Purchase Tax Control Account') , VATAmount );
				//nmEntry.save();
				//nmEntry.AddDebit(Functions.getNominalAccountId('Purchase Tax Control Account'), isCloned==true?(-VATAmount):VATAmount );
				updateNominalBudget.AddDebit(Functions.getNominalAccountId('Purchase Tax Control Account') , isCloned==true?(-VATAmount):VATAmount  , string.valueOf(InvoiceDate));
				//mnActuals = new CustomerRefund_BudgetModel(null , Functions.getNominalAccountId('Purchase Tax Control Account') , VATAmount  );
				//mnActuals.save();
			}
			journal = new Ledger__c(Trans_No__c=currentNo,Type__c = 'PI', Details__c = isCloned==true?'Deleted - see tran '+oldTransactionNumber:'Purchase Invoice', Doc_ID__c = DocId , 
									Reference__c = Reference, Tax_Code__c = TaxCode , Paid__c = 'N', Trans_Date__c = InvoiceDate , 
									Debit__c = TotalNet ,Tax__c =0.00 , VAT__c = null , Show_On_Transaction__c = null ,
									Sub_Account_Nominal__c = Functions.getNominalAccountCode('Materials Purchased'),
									Is_Deleted__c =  isCloned==true?true:false 
									);
			lstLedger.add(journal);
			//nmEntry = new NominalModel( '' , Functions.getNominalAccountId('Materials Purchased') , TotalNet );
			//nmEntry.save();
			//nmEntry.AddDebit(Functions.getNominalAccountId('Materials Purchased'), isCloned==true?(-TotalNet):TotalNet );
			updateNominalBudget.AddDebit(Functions.getNominalAccountId('Materials Purchased') , isCloned==true?(-TotalNet):TotalNet  , string.valueOf(InvoiceDate));
			//mnActuals = new CustomerRefund_BudgetModel(null , Functions.getNominalAccountId('Materials Purchased') , TotalNet );
			//mnActuals.save();
			updateNominalBudget.newSave();
			//nmEntry.newSave() ;
		}
		else if (TrType == 'Purchase Credit')
		{
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel();
			NominalModel nmEntry = new NominalModel();
			Ledger__c journal;
			currentNo++;		
			journal = new Ledger__c(Trans_No__c=currentNo,Type__c = 'PC', Sub_Account__c = SubAccount , Details__c = isCloned==true?'Deleted - see tran '+oldTransactionNumber:'Purchase Credit', Doc_ID__c = DocId , 
									Reference__c = Reference, Tax_Code__c = TaxCode , Paid__c = 'N', Trans_Date__c = InvoiceDate , Tax__c =  VATAmount , Tax_Rate__c = TaxRate , 
									Debit__c = TotalGross , VAT__c = VAT_Type , Show_On_Transaction__c = 1 ,
									Sub_Account_Nominal__c = Functions.getAccountCodeByName('Creditors Control') , 
									Nominal__c= Functions.getNominalAccountCode('Materials Purchased') ,
									Is_Deleted__c =  isCloned==true?true:false
									);
			lstLedger.add(journal);
			//NominalModel nmEntry = new NominalModel( Functions.getNominalAccountId('Creditors Control Account') ,  '' , TotalGross  );
			//nmEntry.save();
			//nmEntry.AddDebit(Functions.getNominalAccountId('Creditors Control Account') , isCloned==true?(-TotalGross):TotalGross ) ;
			updateNominalBudget.AddDebit(Functions.getNominalAccountId('Creditors Control Account') , isCloned==true?(-TotalGross):TotalGross  , string.valueOf(InvoiceDate));
			//CustomerRefund_BudgetModel mnActuals = new CustomerRefund_BudgetModel(Functions.getNominalAccountId('Creditors Control Account') , null , TotalGross );
			//mnActuals.save();
			if(!isCloned)
				updateAccount(AccountID , TotalGross , null );
			if(VATAmount > 0)
			{
				journal = new Ledger__c(Trans_No__c=currentNo,Type__c = 'PC',  Details__c = isCloned==true?'Deleted - see tran '+oldTransactionNumber:'Purchase Credit', Doc_ID__c = DocId , 
									Reference__c = Reference, Tax_Code__c = TaxCode , Paid__c = 'N', Trans_Date__c = InvoiceDate , 
									Credit__c = VATAmount ,Tax__c =0.00 , VAT__c = null ,
									Sub_Account_Nominal__c = Functions.getNominalAccountCode('Purchase Tax Control Account') ,
									Is_Deleted__c =  isCloned==true?true:false
									);
				lstLedger.add(journal);
				//nmEntry = new NominalModel( '' , Functions.getNominalAccountId('Purchase Tax Control Account') , VATAmount );
				//nmEntry.save();
				//nmEntry.AddCredit(Functions.getNominalAccountId('Purchase Tax Control Account') , isCloned==true?(-VATAmount):VATAmount ) ;
				updateNominalBudget.AddCredit(Functions.getNominalAccountId('Purchase Tax Control Account') , isCloned==true?(-VATAmount):VATAmount  , string.valueOf(InvoiceDate));
				//mnActuals = new CustomerRefund_BudgetModel(null , Functions.getNominalAccountId('Purchase Tax Control Account') , VATAmount  );
				//mnActuals.save();
			}
			journal = new Ledger__c(Trans_No__c=currentNo,Type__c = 'PC', Details__c = isCloned==true?'Deleted - see tran '+oldTransactionNumber:'Purchase Credit', Doc_ID__c = DocId ,    
									Reference__c = Reference, Tax_Code__c = TaxCode , Paid__c = 'N', Trans_Date__c = InvoiceDate , 
									Credit__c = TotalNet ,Tax__c =0.00 , VAT__c = null , Show_On_Transaction__c = null ,
									Sub_Account_Nominal__c = Functions.getNominalAccountCode('Materials Purchased'),
									Is_Deleted__c =  isCloned==true?true:false 
									);
			lstLedger.add(journal);
			//nmEntry = new NominalModel( '' , Functions.getNominalAccountId('Materials Purchased') , TotalNet );
			//nmEntry.save();
			//nmEntry.AddCredit( Functions.getNominalAccountId('Materials Purchased') , isCloned==true?(-TotalNet):TotalNet ) ;
			updateNominalBudget.AddCredit(Functions.getNominalAccountId('Materials Purchased') , isCloned==true?(-TotalNet):TotalNet   , string.valueOf(InvoiceDate));
			//mnActuals = new CustomerRefund_BudgetModel(null , Functions.getNominalAccountId('Materials Purchased') , TotalNet );
			//mnActuals.save();	
			updateNominalBudget.newSave();
			//nmEntry.newSave() ;
		}
	}
	public void AddBankReceiptTransaction(decimal Amount, string SubAccountNominal,string NominalAccount,string detail, string reference,string TaxName, decimal TaxAmount)
	{
		Ledger__c journal;
		currentNo++;	
		journal = new Ledger__c(Show_On_Transaction__c = 1,Trans_No__c=currentNo,Type__c = 'BR' ,Debit__c = Amount,Sub_Account__c= SubAccountNominal , Sub_Account_Nominal__c = SubAccountNominal, Nominal__c = NominalAccount, Details__c = detail, Reference__c = reference, Tax_Code__c = TaxName, Tax__c = TaxAmount, Paid__c = 'Y',Amount__c = Amount, Trans_Date__c = Date.today());
		if(TaxName != Functions.getTaxNameZero())
			journal.VAT__C = 'N';
		if(SubAccountNominal >= '1200' && SubAccountNominal <= '1299')
			journal.Bank_Reconcile__c = 'N';		
		lstLedger.add(journal);	
		journal = new Ledger__c(Trans_No__c=currentNo,Type__c = 'BR',Credit__c = Amount-TaxAmount , Sub_Account_Nominal__c = NominalAccount, Details__c = detail, Reference__c = reference, Tax_Code__c = TaxName, Paid__c = 'Y', Trans_Date__c = Date.today());
		lstLedger.add(journal);
		if(TaxAmount > 0)
		{
			journal = new Ledger__c(Trans_No__c=currentNo,Type__c = 'BR',Credit__c = TaxAmount , Sub_Account_Nominal__c = Functions.getNominalAccountCode('Sales Tax Control Account'), Details__c = detail, Reference__c = reference, Tax_Code__c = TaxName, Paid__c = 'Y', Trans_Date__c = Date.today());
			lstLedger.add(journal);
		}					
	}
	public void AddCustomerRefund(decimal Amount ,string SubAccount ,string SubAccountNominal ,string  NominalAccount  ,string reference ,Date dt)
	{
		Ledger__c journal;
		currentNo++; 
		journal = new Ledger__c(Show_On_Transaction__c = 1,Trans_No__c=currentNo, Debit__c =Amount ,Type__c = 'SP', Sub_Account__c = SubAccount , Sub_Account_Nominal__c = SubAccountNominal , Nominal__c = NominalAccount , Details__c= 'Sales Payment', Reference__c = reference,  Tax_Code__c = Functions.getTaxNameZero(), Tax__c = 0.00,Paid__c = 'N',Amount__c = 0.00, Trans_Date__c = dt);
		lstLedger.add(journal);
		journal = new Ledger__c(Trans_No__c=currentNo, Credit__c =Amount ,Type__c = 'SP',  Sub_Account_Nominal__c = SubAccountNominal , Details__c= 'Sales Payment', Reference__c = reference,  Tax_Code__c = 'T9', Tax__c = 0.00,Paid__c = 'N',Amount__c = 0.00, Bank_Reconcile__c = 'N', Trans_Date__c = dt);
		lstLedger.add(journal);				
	}
	public void AddSupplierRefund(decimal Amount ,string SubAccount ,string SubAccountNominal ,string  NominalAccount  ,string reference ,Date dt)
	{
		Ledger__c journal;
		currentNo++;		
		journal = new Ledger__c(Trans_No__c=currentNo, Debit__c =Amount ,Type__c = 'PR',  Sub_Account_Nominal__c = NominalAccount  , Details__c= 'Purchase Receipt', Reference__c = reference,  Tax_Code__c = 'T9', Tax__c = 0.00,Paid__c = 'N',Amount__c = 0.00, Bank_Reconcile__c = 'N', Trans_Date__c = dt);
		lstLedger.add(journal);
		journal = new Ledger__c(Show_On_Transaction__c = 1,Trans_No__c=currentNo, Credit__c = Amount ,Type__c = 'PR', Sub_Account__c=SubAccount , Sub_Account_Nominal__c = SubAccountNominal , Nominal__c = NominalAccount , Details__c= 'Purchase Receipt', Reference__c = reference,  Tax_Code__c = Functions.getTaxNameZero(), Tax__c = 0.00,Paid__c = 'N',Amount__c = 0.00, Trans_Date__c = dt);
		lstLedger.add(journal);				
	}
	public void AddJournalCreditEntry(decimal Amount ,string SubAccountNominal , string details  ,string reference , string TaxName , Date dt)
	{
		Ledger__c journal1;
		currentNo++;				
		journal1 = new Ledger__c(Show_On_Transaction__c = 1,Trans_No__c=currentNo, Credit__c = Amount , Type__c = 'JC',  Sub_Account_Nominal__c = SubAccountNominal , Nominal__c = SubAccountNominal , Details__c= details , Reference__c = reference,  Tax_Code__c = TaxName , Paid__c = 'Y',Amount__c = Amount , Trans_Date__c = dt);
		if(journal1.Sub_Account_Nominal__c >= '1200' && journal1.Sub_Account_Nominal__c <= '1299')
			journal1.Bank_Reconcile__c = 'N';					
		journal1.Tax__c = (Amount * Functions.getTaxRate(TaxName))/100;
		if(TaxName != Functions.getTaxNameZero())
			journal1.VAT__c = 'N';
		lstLedger.add(journal1);				
	}
	public void AddJournalDebitEntry(decimal Amount ,string SubAccountNominal , string details , string reference , string TaxName , Date dt)
	{
		Ledger__c journal2;
		currentNo++;				
		journal2 = new Ledger__c(Show_On_Transaction__c = 1,Trans_No__c=currentNo, Debit__c = Amount , Type__c = 'JD',  Sub_Account_Nominal__c = SubAccountNominal , Nominal__c = SubAccountNominal , Details__c= details , Reference__c = reference,  Tax_Code__c = TaxName , Paid__c = 'Y',Amount__c = Amount , Trans_Date__c = dt);
		if(journal2.Sub_Account_Nominal__c >= '1200' && journal2.Sub_Account_Nominal__c <= '1299')
			journal2.Bank_Reconcile__c = 'N';					
		journal2.Tax__c = (Amount * Functions.getTaxRate(TaxName))/100;
		if(TaxName != Functions.getTaxNameZero())
			journal2.VAT__c = 'N';
		lstLedger.add(journal2);						
	}
	public void AddDebitOpeningBalances(string typ , decimal Amount , string details ,  string SubAccount , string SubAccountNominal , string NominalAccount , Date dt)
	{
		Ledger__c journal;
		currentNo++;						
		journal = new Ledger__c(Show_On_Transaction__c = 1,Trans_No__c=currentNo, Debit__c = Amount , Type__c = typ ,  Sub_Account__c = SubAccount , Sub_Account_Nominal__c = SubAccountNominal ,Nominal__c =  NominalAccount, Details__c= details , Reference__c = 'Opening Balance',  Tax_Code__c = Functions.getTaxNameZero() ,  Tax__c = 0.0 , Paid__c = 'N',Amount__c = 0.0 , Trans_Date__c = dt);		
		lstLedger.add(journal);
		journal = new Ledger__c(Trans_No__c=currentNo, Credit__c = Amount , Type__c = typ , Sub_Account_Nominal__c = NominalAccount, Details__c= details , Reference__c = 'Opening Balance',  Tax_Code__c = Functions.getTaxNameZero() ,  Tax__c = 0.0 , Paid__c = 'N',Amount__c = 0.0 , Trans_Date__c = dt);		
		lstLedger.add(journal);		
	}	
	public void AddCreditOpeningBalances(string typ , decimal Amount , string details ,  string SubAccount , string SubAccountNominal , string NominalAccount , Date dt)
	{
		Ledger__c journal; 
		currentNo++;						
		journal = new Ledger__c(Trans_No__c=currentNo, Debit__c = Amount , Type__c = typ , Sub_Account_Nominal__c = NominalAccount, Details__c= details , Reference__c = 'Opening Balance',  Tax_Code__c = Functions.getTaxNameZero(),  Tax__c = 0.0 , Paid__c = 'N',Amount__c = 0.0 , Trans_Date__c = dt);		
		lstLedger.add(journal);
		journal = new Ledger__c(Show_On_Transaction__c = 1,Trans_No__c=currentNo, Credit__c = Amount , Type__c = typ ,  Sub_Account__c = SubAccount , Sub_Account_Nominal__c = SubAccountNominal ,Nominal__c =  NominalAccount, Details__c= details , Reference__c = 'Opening Balance',  Tax_Code__c = Functions.getTaxNameZero() ,  Tax__c = 0.0 , Paid__c = 'N',Amount__c = 0.0 , Trans_Date__c = dt);			
		lstLedger.add(journal);		
	}	
	public void AddBankTransferTransaction(decimal amount, string toId, string fromId, string description , string reference, date dt)
	{		
		this.AddJournalDebitEntry(amount,Functions.getAccountCodeById(toId),Description , reference , Functions.getTaxNameZero(), dt);
 		this.AddJournalCreditEntry(amount ,Functions.getAccountCodeById(fromId),Description , reference , Functions.getTaxNameZero(), dt);
	}	
	public void AddBankReconcileTransaction(decimal DebitAmount, decimal CreditAmount, string DebitID, string CreditId, string reference, date DebitDate , date CreditDate)
	{		
		this.AddJournalDebitEntry(DebitAmount,Functions.getAccountCodeById(DebitID), '' , reference , Functions.getTaxNameZero(), DebitDate);
 		this.AddJournalCreditEntry(CreditAmount ,Functions.getAccountCodeById(CreditId),'', reference , Functions.getTaxNameZero(), CreditDate);
	}
	
	public void AddSalesReceiptTransaction(string bankNominalCode, string customerAccountNumber, string customerNominalCode, decimal amountPaid, string reference, string invoiceDocId)
	{
		currentNo = currentNo+1;
		Ledger__c SR1 = new Ledger__c(Show_On_Transaction__c = 0, Trans_No__c = currentNo, Type__c = 'SR', Sub_Account__c = null, Sub_Account_Nominal__c = bankNominalCode, Nominal__c = null, Debit__c = amountPaid, Credit__c = null, Details__c = 'Sales Receipt', Reference__c = reference, Tax_Code__c = 'T9', Tax__c = null, Paid__c = 'Y', Amount__c = amountPaid, Bank_Reconcile__c = 'N', Bank_Reconcile_Date__c = null, Vat__c = null, Vat_Return_No__c = null, Vat_Return_Date__c = null, Doc_ID__c = invoiceDocId, Trans_Date__c = date.today(), Trans_Ref_Id__c = null);
		lstLedger.add(SR1);
		Ledger__c SR2 = new Ledger__c(Show_On_Transaction__c = 1, Trans_No__c = currentNo, Type__c = 'SR', Sub_Account__c =customerAccountNumber, Sub_Account_Nominal__c = customerNominalCode, Nominal__c = bankNominalCode, Debit__c = null, Credit__c = amountPaid, Details__c = 'Sales Receipt', Reference__c = reference, Tax_Code__c = 'T9', Tax__c = null, Paid__c = 'Y', Amount__c = amountPaid, Bank_Reconcile__c = 'N', Bank_Reconcile_Date__c = null, Vat__c = null, Vat_Return_No__c = null, Vat_Return_Date__c = null, Doc_ID__c = invoiceDocId, Trans_Date__c = date.today(), Trans_Ref_Id__c = null);
		lstLedger.add(SR2);
	}
	
	public void AddSalesDiscountTransaction(string customerAccountNumber, string customerNominalCode, decimal discount, string reference, string invoiceDocId)
	{
		currentNo = currentNo+1;
		string discountNominalCode = Functions.getNominalAccountCode('Discounts Allowed');
		Ledger__c SD1 = new Ledger__c(Show_On_Transaction__c = 0, Trans_No__c = currentNo, Type__c = 'SD', Sub_Account__c = null, Sub_Account_Nominal__c = discountNominalCode, Nominal__c = null, Debit__c = discount, Credit__c = null, Details__c = 'Sales Discount for invoice '+invoiceDocId, Reference__c = reference, Tax_Code__c = 'T9', Tax__c = null, Paid__c = 'Y', Amount__c = discount, Bank_Reconcile__c = null, Bank_Reconcile_Date__c = null, Vat__c = null, Vat_Return_No__c = null, Vat_Return_Date__c = null, Doc_ID__c = invoiceDocId, Trans_Date__c = date.today(), Trans_Ref_Id__c = null);
		lstLedger.add(SD1);
		Ledger__c SD2 = new Ledger__c(Show_On_Transaction__c = 1, Trans_No__c = currentNo, Type__c = 'SD', Sub_Account__c =customerAccountNumber, Sub_Account_Nominal__c = customerNominalCode, Nominal__c = discountNominalCode, Debit__c = null, Credit__c = discount, Details__c = 'Sales Discount for invoice '+invoiceDocId, Reference__c = reference, Tax_Code__c = 'T9', Tax__c = null, Paid__c = 'Y', Amount__c = discount, Bank_Reconcile__c = null, Bank_Reconcile_Date__c = null, Vat__c = null, Vat_Return_No__c = null, Vat_Return_Date__c = null, Doc_ID__c = invoiceDocId, Trans_Date__c = date.today(), Trans_Ref_Id__c = null);
		lstLedger.Add(SD2);		
	}
	
	public void AddSalesPaymentOnAccountTransaction(string bankNominalCode, string customerAccountNumber, string customerNominalCode, decimal amountPaid, string reference)
	{
		currentNo = currentNo+1;
		Ledger__c SA1 = new Ledger__c(Show_On_Transaction__c = 0, Trans_No__c = currentNo, Type__c = 'SA', Sub_Account__c = null, Sub_Account_Nominal__c = bankNominalCode, Nominal__c = null, Debit__c = amountPaid, Credit__c = null, Details__c = 'Payment on Account', Reference__c = reference, Tax_Code__c = 'T9', Tax__c = null, Paid__c = 'N', Amount__c = null, Bank_Reconcile__c = 'N', Bank_Reconcile_Date__c = null, Vat__c = null, Vat_Return_No__c = null, Vat_Return_Date__c = null, Doc_ID__c = null, Trans_Date__c = date.today(), Trans_Ref_Id__c = null);
		lstLedger.add(SA1);
		Ledger__c SA2 = new Ledger__c(Show_On_Transaction__c = 1, Trans_No__c = currentNo, Type__c = 'SA', Sub_Account__c = customerAccountNumber, Sub_Account_Nominal__c = customerNominalCode, Nominal__c = bankNominalCode, Debit__c = null, Credit__c = amountPaid, Details__c = 'Payment on Account', Reference__c = reference, Tax_Code__c = 'T9', Tax__c = null, Paid__c = 'N', Amount__c = null, Bank_Reconcile__c = 'N', Bank_Reconcile_Date__c = null, Vat__c = '', Vat_Return_No__c = null, Vat_Return_Date__c = null, Doc_ID__c = null, Trans_Date__c = date.today(), Trans_Ref_Id__c = null);
		lstLedger.add(SA2);
	}
	
	public void AddPurchaseReceiptTransaction(string bankNominalCode, string supplierAccountNumber, string supplierNominalCode, decimal amountPaid, string reference, string invoiceDocId)
	{
		currentNo = currentNo+1;
		Ledger__c PP1 = new Ledger__c(Show_On_Transaction__c = 1, Trans_No__c = currentNo, Type__c = 'PP', Sub_Account__c =supplierAccountNumber, Sub_Account_Nominal__c = supplierNominalCode, Nominal__c = bankNominalCode, Debit__c = amountPaid, Credit__c = null, Details__c = 'Purchase payment for invoice '+invoiceDocId, Reference__c = reference, Tax_Code__c = 'T9', Tax__c = null, Paid__c = 'Y', Amount__c = amountPaid, Bank_Reconcile__c = 'N', Bank_Reconcile_Date__c = null, Vat__c = null, Vat_Return_No__c = null, Vat_Return_Date__c = null, Doc_ID__c = invoiceDocId, Trans_Date__c = date.today(), Trans_Ref_Id__c = null);
		lstLedger.add(PP1);
		Ledger__c PP2 = new Ledger__c(Show_On_Transaction__c = 0, Trans_No__c = currentNo, Type__c = 'PP', Sub_Account__c = null, Sub_Account_Nominal__c = bankNominalCode, Nominal__c = null, Debit__c = null, Credit__c = amountPaid, Details__c = 'Purchase payment for invoice '+invoiceDocId, Reference__c = reference, Tax_Code__c = 'T9', Tax__c = null, Paid__c = 'Y', Amount__c = amountPaid, Bank_Reconcile__c = 'N', Bank_Reconcile_Date__c = null, Vat__c = null, Vat_Return_No__c = null, Vat_Return_Date__c = null, Doc_ID__c = invoiceDocId, Trans_Date__c = date.today(), Trans_Ref_Id__c = null);
		lstLedger.add(PP2);		
	}
	
	public void AddPurchaseDiscountTransaction(string supplierAccountNumber, string supplierNominalCode, decimal discount, string reference, string invoiceDocId)
	{
		currentNo = currentNo+1;
		string discountNominalCode = Functions.getNominalAccountCode('Discounts Taken');
		Ledger__c PD1 = new Ledger__c(Show_On_Transaction__c = 1, Trans_No__c = currentNo, Type__c = 'PD', Sub_Account__c =supplierAccountNumber, Sub_Account_Nominal__c = supplierNominalCode, Nominal__c = discountNominalCode, Debit__c = discount, Credit__c = null, Details__c = 'Purchase Discount for invoice '+invoiceDocId, Reference__c = reference,             Tax_Code__c = 'T9', Tax__c = null, Paid__c = 'Y', Amount__c = discount, Bank_Reconcile__c = null, Bank_Reconcile_Date__c = null, Vat__c = null, Vat_Return_No__c = null, Vat_Return_Date__c = null, Doc_ID__c = invoiceDocId, Trans_Date__c = date.today(), Trans_Ref_Id__c = null);
		lstLedger.add(PD1);
		Ledger__c PD2 = new Ledger__c(Show_On_Transaction__c = 0, Trans_No__c = currentNo, Type__c = 'PD', Sub_Account__c = null, Sub_Account_Nominal__c = discountNominalCode, Nominal__c = null, Debit__c = null, Credit__c = discount, Details__c = 'Purchase Discount for invoice '+invoiceDocId, Reference__c = reference,             Tax_Code__c = 'T9', Tax__c = null, Paid__c = 'Y', Amount__c = discount, Bank_Reconcile__c = null, Bank_Reconcile_Date__c = null, Vat__c = null, Vat_Return_No__c = null, Vat_Return_Date__c = null, Doc_ID__c = invoiceDocId, Trans_Date__c = date.today(), Trans_Ref_Id__c = null);
		lstLedger.add(PD2);				
	}
	
	public void AddPurchasePaymentOnAccountTransaction(string bankNominalCode, string supplierAccountNumber, string supplierNominalCode, decimal amountPaid, string reference)
	{
		currentNo = currentNo+1;
		Ledger__c PA1 = new Ledger__c(Show_On_Transaction__c = 1, Trans_No__c = currentNo, Type__c = 'PA', Sub_Account__c = supplierAccountNumber, Sub_Account_Nominal__c = supplierNominalCode, Nominal__c = bankNominalCode, Debit__c = amountPaid, Credit__c = null, Details__c = 'Payment on Account', Reference__c = reference, Tax_Code__c = 'T9', Tax__c = null, Paid__c = 'N', Amount__c = null, Bank_Reconcile__c = 'N', Bank_Reconcile_Date__c = null, Vat__c = null, Vat_Return_No__c = null, Vat_Return_Date__c = null, Doc_ID__c = null, Trans_Date__c = date.today(), Trans_Ref_Id__c = null);
		
		lstLedger.add(PA1);
		Ledger__c PA2 = new Ledger__c(Show_On_Transaction__c = 0, Trans_No__c = currentNo, Type__c = 'PA', Sub_Account__c = null, Sub_Account_Nominal__c = bankNominalCode, Nominal__c = null, Debit__c = null, Credit__c = amountPaid, Details__c = 'Payment on Account', Reference__c = reference, Tax_Code__c = 'T9', Tax__c = null, Paid__c = 'N', Amount__c = null, Bank_Reconcile__c = 'N', Bank_Reconcile_Date__c = null, Vat__c = null, Vat_Return_No__c = null, Vat_Return_Date__c = null, Doc_ID__c = null, Trans_Date__c = date.today(), Trans_Ref_Id__c = null);
		lstLedger.add(PA2);
	}
	
	public static set<Integer> GetShowOnTransactionStatusSet(Ledger.showOnTransactionStatus status)
	{
		set<Integer> showOnTransactionStatusSet = new set<Integer>();
		if(status == Ledger.showOnTransactionStatus.ALL)
		{
			for(showOnTransactionStatus s : showOnTransactionStatus.values())
			{
				if(s != showOnTransactionStatus.ALL)
				{
					showOnTransactionStatusSet.Add(s.ordinal());				
				}
			}
		}
		else
		{
			showOnTransactionStatusSet.Add(status.ordinal());
		}
		return showOnTransactionStatusSet;
	}
	
	public static set<string> GetTransactionPaidStatusSet(Ledger.paidStatus paid)
	{
		set<string> paidStatusSet = new set<string>();
		if(paid==Ledger.paidStatus.ALL)
		{
			for(paidStatus s : paidStatus.values())
			{
				if(s != paidStatus.ALL)
				{
					paidStatusSet.Add(s.name());				
				}
			}
		}
		else
		{
			paidStatusSet.Add(paid.name());
		}
		return paidStatusSet;
	}
	
	public static List<Ledger__c> GetRecordsByAccountAndType(string accountNumber, set<string> types, Ledger.showOnTransactionStatus showOnTransaction, Ledger.paidStatus paid)
	{
		set<Integer> showOnTransactionStatusSet = GetShowOnTransactionStatusSet(showOnTransaction);		
		set<string> paidStatusSet = GetTransactionPaidStatusSet(paid);
		
		return [SELECT Amount__c, Bank_Reconcile__c, Bank_Reconcile_Date__c, CreatedById, CreatedDate, Credit__c, Debit__c, IsDeleted, Details__c, Doc_ID__c, LastModifiedById, LastModifiedDate, Name, Net__c, Nominal__c, OwnerId, Paid__c, Id, Reference__c, Show_On_Transaction__c, Sub_Account__c, Sub_Account_Nominal__c, SystemModstamp, Tax__c, Tax_Code__c, Trans_Date__c, Trans_No__c, Trans_Ref_Id__c, Type__c, VAT__c, VAT_Return_Date__c, VAT_Return_No__c, Ext_Reference__c 
				FROM Ledger__c 
				WHERE Type__c in : types
				and Sub_Account__c=:accountNumber
				and Show_On_Transaction__c in : showOnTransactionStatusSet
				and Paid__c in : paidStatusSet
				and Is_Deleted__c = false
				ORDER BY Trans_No__c asc];
	}
	
	public static List<Ledger__c> GetCustomerPendingSalesPayments(string customerAccountNumber)
	{
		return GetCustomerSalesRecords(customerAccountNumber, Ledger.showOnTransactionStatus.YES, Ledger.paidStatus.N);
	}
	
	public static List<Ledger__c> GetCustomerSalesRecords(string customerAccountNumber, Ledger.showOnTransactionStatus status, Ledger.paidStatus paid)
	{
		set<string> types = new set<string>{'SI','SP','SC','SA'};
		return GetRecordsByAccountAndType(customerAccountNumber, types, status, paid);
	}
	
	public static List<Ledger__c> GetSupplierPendingPurchasePayments(string supplierAccountNumber)
	{
		return GetSupplierPurchaseRecords(supplierAccountNumber, Ledger.showOnTransactionStatus.YES, Ledger.paidStatus.N);
	}
	
	public static List<Ledger__c> GetSupplierPurchaseRecords(string supplierAccountNumber,Ledger.showOnTransactionStatus show, Ledger.paidStatus paid)
	{
		set<string> types = new set<string>{'PI','PR','PC','PA'};
		return GetRecordsByAccountAndType(supplierAccountNumber, types, show, paid);
	}
	
	public static List<Ledger__c> GetRecordsForAmendment()
	{
		set<string> types = new set<string>{'SI','SP','SC','SA','PI','PR','PC','PA','JD','JC'};
		set<Integer> showOnTransactionStatusSet = GetShowOnTransactionStatusSet(Ledger.showOnTransactionStatus.YES);		
		return [SELECT Amount__c, Bank_Reconcile__c, Bank_Reconcile_Date__c, CreatedById, CreatedDate, Credit__c, Debit__c, IsDeleted, Details__c, Doc_ID__c, LastModifiedById, LastModifiedDate, Name, Net__c, Nominal__c, OwnerId, Paid__c, Id, Reference__c, Show_On_Transaction__c, Sub_Account__c, Sub_Account_Nominal__c, SystemModstamp, Tax__c, Tax_Code__c, Trans_Date__c, Trans_No__c, Trans_Ref_Id__c, Type__c, VAT__c, VAT_Return_Date__c, VAT_Return_No__c, Ext_Reference__c 
				FROM Ledger__c 
				WHERE Type__c in : types
				and Show_On_Transaction__c in : showOnTransactionStatusSet
				ORDER BY Trans_No__c asc];
	}
	
	public static Ledger__c GetLedgerEntryById(Id ledgerId)
	{
		system.debug('this is: ' + ledgerId );
		List<Ledger__c> ledgerRecord = [SELECT Amount__c, Bank_Reconcile__c, Bank_Reconcile_Date__c, CreatedById, 
											CreatedDate, Credit__c, Debit__c, IsDeleted, Details__c, Doc_ID__c, 
											LastModifiedById, LastModifiedDate, Name, Net__c, Nominal__c, OwnerId, 
											Paid__c, Id, Reference__c, Show_On_Transaction__c, Sub_Account__c, Tax_Rate__c , 
											Sub_Account_Nominal__c, SystemModstamp, Tax__c, Tax_Code__c, 
											Trans_Date__c, Trans_No__c, Trans_Ref_Id__c, Type__c, VAT__c, 
											VAT_Return_Date__c, VAT_Return_No__c, Ext_Reference__c
										FROM Ledger__c 
										WHERE Id=:ledgerId and Show_On_Transaction__c = 1
										limit 1];
		system.debug('this is Ledger obect: ' + ledgerRecord);
		If(ledgerRecord.size()==0)
			throw new CustomException('No Transaction Record Found.');
		return ledgerRecord[0];			
	}
	
	public static List<Ledger_Payment_History__c> GetLedgerPaymentHistoryByTransactionNumber(string entryType, double transctionNumber)
	{
		system.debug('This is entryType: ' + entryType ) ;
		system.debug('This is transaction number: ' + transctionNumber ) ;
		List<Ledger_Payment_History__c> payments = new List<Ledger_Payment_History__c>();
		boolean isPayment = Ledger.PaymentTypes.contains(entryType);
		if(isPayment==true)
		{
			payments = [select id, parent_transaction__c, parent_transaction_number__c, payment_transaction_number__c, payment_reference__c, details__c, type__c, amount__c, date__c from Ledger_Payment_History__c where Payment_Transaction_number__c=:transctionNumber];
		}
		else
		{
			payments = [select id, parent_transaction__c, parent_transaction_number__c, payment_transaction_number__c, payment_reference__c, details__c, type__c, amount__c, date__c from Ledger_Payment_History__c where Parent_Transaction_number__c=:transctionNumber];
		}
		system.debug('ledger entry for this record: ' + payments);
		//If(payments.size()==0)
			//throw new CustomException('No Transaction Record Found.');
		return payments;
	}
	
	public void ClonePILedgerEntry ( string DocId , decimal oldTotalGross , decimal oldNet , decimal oldTax , Id AccountId, double oldTransactionNumber )
	{
		list<Ledger__c> lg = [Select l.VAT__c, l.VAT_Return_No__c, l.VAT_Return_Date__c, l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Rate__c, l.Tax_Code__c, l.SystemModstamp, l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, l.OwnerId, l.Nominal__c, l.Net__c, l.Name, l.LastModifiedDate, l.LastModifiedById, l.IsDeleted, l.Id, l.Ext_Reference__c, l.Doc_ID__c, l.Details__c, l.Debit__c, l.Credit__c, l.CreatedDate, l.CreatedById, l.Bank_Reconcile__c, l.Bank_Reconcile_Date__c, l.Amount__c From Ledger__c l where l.Doc_Id__c = :DocId and Show_On_Transaction__c =1 AND Type__c IN('PI','PC')]  ;
		if(lg.size() > 0)	
		{
			AddPurchaseInvoice(lg[0].Details__c, lg[0].Doc_Id__c , lg[0].Doc_Id__c, lg[0].Tax_Code__c , lg[0].Sub_Account__c, lg[0].Type__c=='PI'?lg[0].Credit__c:lg[0].Debit__c , lg[0].Net__c, lg[0].Tax__c, lg[0].Tax_Rate__c, AccountId, lg[0].VAT__c , date.today() , true, oldTransactionNumber) ;			
			Save();	
		}	
		else
			throw new customexception('No Ledger Entry Found for this Record'); 	
	}
	
	public void CloneSILedgerEntry ( string DocId , decimal oldTotalGross , decimal oldNet , decimal oldTax , Id AccountId, double oldTransactionNumber )
	{
		system.debug('this is from clone function: ' + oldTotalGross );
		list<Ledger__c> lg = [Select l.VAT__c, l.VAT_Return_No__c, l.VAT_Return_Date__c, l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Rate__c, l.Tax_Code__c, l.SystemModstamp, l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, l.OwnerId, l.Nominal__c, l.Net__c, l.Name, l.LastModifiedDate, l.LastModifiedById, l.IsDeleted, l.Id, l.Ext_Reference__c, l.Doc_ID__c, l.Details__c, l.Debit__c, l.Credit__c, l.CreatedDate, l.CreatedById, l.Bank_Reconcile__c, l.Bank_Reconcile_Date__c, l.Amount__c From Ledger__c l where l.Doc_Id__c = :DocId and Show_On_Transaction__c =1 AND Type__c IN('SI','SC')]  ;
		system.debug('this is from clone function list : ' + lg );
		if(lg.size() > 0)	
		{
			system.debug('this is type: ' + lg[0].Details__c);
			AddSalesInvoice(lg[0].Details__c, lg[0].Doc_Id__c , lg[0].Doc_Id__c, lg[0].Tax_Code__c , lg[0].Sub_Account__c, lg[0].type__c=='SI'?lg[0].Debit__c:lg[0].Credit__c , lg[0].Net__c, lg[0].Tax__c, lg[0].Tax_Rate__c, AccountId, lg[0].VAT__c , date.today() , true, oldTransactionNumber ) ;
			//AddSalesInvoice(lg[0].Details__c, lg[0].Doc_Id__c , lg[0].Doc_Id__c, lg[0].Tax_Code__c , lg[0].Sub_Account__c, 2000 , lg[0].Net__c, lg[0].Tax__c, lg[0].Tax_Rate__c, AccountId, lg[0].VAT__c , date.today() , true, oldTransactionNumber ) ;
			Save();			
		}		
		else
			throw new customexception('No Ledger Entry Found for this Record'); 	
	}
	
	public void CancelLedgerEntry(Ledger__c oldEntry)
	{
		currentNo = currentNo + 1;
		List<Ledger__c> otherEntries = [Select l.VAT__c, l.VAT_Return_No__c, l.VAT_Return_Date__c, l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Rate__c, l.Tax_Code__c, l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, l.Nominal__c, l.Net__c, l.Id, l.Ext_Reference__c, l.Doc_ID__c, l.Details__c, l.Debit__c, l.Credit__c, l.Amount__c From Ledger__c l Where Trans_No__c=:oldEntry.Trans_No__c and Show_On_Transaction__c IN(0,null) and Is_Deleted__c=false];
		system.debug('this is old ladegre entries: ' +otherEntries );
		for(Ledger__c l : otherEntries)
		{
			l.Details__c = 'Deleted - see tran '+oldEntry.Trans_No__c;
			l.Trans_No__c = currentNo;
			l.Is_Deleted__c = true;
			lstLedger.add(l.clone(false,true));
		}
		oldEntry.Details__c = 'Deleted - see tran '+oldEntry.Trans_No__c;
		oldEntry.Trans_No__c = currentNo;
		oldEntry.Is_Deleted__c = true;
		lstLedger.add(oldEntry);
	}
	
	public void SaveSalesInvoiceAmendment(Ledger__c oldEntry, Ledger__c newEntry)
	{
		
		decimal newGross = newEntry.Debit__c ; //newEntry.Net__c + newEntry.Tax__c;
		decimal newNet = newEntry.Debit__c - newEntry.Tax__c ; //newEntry.Net__c;
		decimal newTax = newEntry.Tax__c;
		
		decimal oldGross = oldEntry.Net__c + oldEntry.Tax__c;
		decimal oldNet =  oldEntry.Net__c;
		decimal oldTax =  oldEntry.Tax__c;
		
		//save old invoice with new transaction number
		Id AccountId = [select Id from Account where AccountNumber = :oldEntry.Sub_Account__c ].Id;      
		CloneSILedgerEntry(oldEntry.Doc_Id__c , oldGross, oldNet, oldTax, AccountId, (double) oldEntry.Trans_No__c);
		//CloneSILedgerEntry(oldEntry.Doc_Id__c , newGross, newNet, newTax, AccountId, (double) oldEntry.Trans_No__c);   
		
		//Save newEntry
		lstLedger.add(newEntry);
		if(newNet != oldNet || newTax != oldTax)
		{
			if(newGross > oldGross)
			{
				newEntry.Paid__c='N';
			}
			else if(newGross < oldGross)
			{
				if(newGross == newEntry.Amount__c)
				{
					newEntry.Paid__c = 'Y';				
				}
				else if(newGross < newEntry.Amount__c)
				{
					newEntry.Amount__c = 0;
					newEntry.Paid__c = 'N';
			
					//update previous payments
					/*
					map<double, decimal> transactionAmounts = new map<double, decimal>();
					set<double> transactionNumbers = new set<double>();
					List<Ledger_Payment_History__c> history = GetLedgerPaymentHistoryByTransactionNumber(newEntry.Type__c, (double) newEntry.Trans_No__c);
					for(Ledger_Payment_History__c l : history)
					{
						transactionNumbers.add(l.Payment_Transaction_Number__c);
						transactionAmounts.put(l.Payment_Transaction_Number__c, l.Amount__c);
						
						l.Payment_Reference__c='Cancel';
						l.Amount__c = 0;
					}
					update history;
					
					for(Ledger__c lger : [select trans_No__c, type__c, paid__c, amount__c from ledger__c where Is_Deleted__c=false and trans_No__c in : transactionAmounts.keyset() and Show_On_Transaction__c =: showOnTransactionStatus.YES.ordinal()])
					{
						lger.Amount__c -= transactionAmounts.get(lger.trans_No__c);
						lger.Paid__c = 'N';
						if(lger.Type__c=='SR')
						{
							lger.Type__c='SA';
						}
						lstLedger.add(lger);
					}
					*/
					AmendSalesInvoicePayments(newEntry);
				}
			}
			
			//update secondary entries
			List<Ledger__c> otherEntries = [Select l.VAT__c, l.VAT_Return_No__c, l.VAT_Return_Date__c, l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Rate__c, l.Tax_Code__c, l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, l.Nominal__c, l.Net__c, l.Id, l.Ext_Reference__c, l.Doc_ID__c, l.Details__c, l.Debit__c, l.Credit__c, l.Amount__c From Ledger__c l Where Trans_No__c=:newEntry.Trans_No__c and Show_On_Transaction__c IN (0,null) and Is_Deleted__c=false];
			system.debug('this is legder Old entries: ' + otherEntries );
			for(Ledger__c l : otherEntries)
			{
				if(l.Sub_Account_Nominal__c == Functions.getNominalAccountCode('Sales North'))
				{
					l.Credit__c = newNet;
					l.Reference__c = newEntry.Reference__c ;
				}
				if(l.Sub_Account_Nominal__c == Functions.getNominalAccountCode('Sales Tax Control Account'))
				{
					l.Credit__c = newTax;
					l.Reference__c = newEntry.Reference__c ;
				}
				l.Paid__c = newEntry.Paid__c;
				lstLedger.add(l);
			}
			Save();
			//update balances
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel();
			//add new entry amount			
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Debtors Control Account'))  , newGross , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Sales Tax Control Account')) , newTax , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Sales North')) , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.newSave();
		}
		//Done	
	}
	
	public void SavePurchaseInvoiceAmendment(Ledger__c oldEntry, Ledger__c newEntry)
	{
		decimal newGross = newEntry.Credit__c ;
		decimal newNet = newEntry.Credit__c - newEntry.Tax__c ;
		decimal newTax = newEntry.Tax__c;
		
		decimal oldGross = oldEntry.Net__c + oldEntry.Tax__c;
		decimal oldNet = oldEntry.Net__c;
		decimal oldTax = oldEntry.Tax__c;
		
		//save old invoice with new transaction number
		Id AccountId = [select Id from Account where AccountNumber = :oldEntry.Sub_Account__c ].Id;
		ClonePILedgerEntry(oldEntry.Doc_Id__c, oldGross, oldNet, oldTax, AccountId, (double) oldEntry.Trans_No__c);
		
		//Save newEntry
		lstLedger.add(newEntry);
		if(newNet != oldNet || newTax != oldTax)
		{
			if(newGross > oldGross)
			{
				newEntry.Paid__c='N';
			}
			else if(newGross < oldGross)
			{
				if(newGross == newEntry.Amount__c)
				{
					newEntry.Paid__c = 'Y';				
				}
				else if(newGross < newEntry.Amount__c)
				{
					newEntry.Amount__c = 0;
					newEntry.Paid__c = 'N';
			
					//update previous payments
					/*
					map<double, decimal> transactionAmounts = new map<double, decimal>();
					set<double> transactionNumbers = new set<double>();
					List<Ledger_Payment_History__c> history = GetLedgerPaymentHistoryByTransactionNumber(newEntry.Type__c, (double) newEntry.Trans_No__c);
					for(Ledger_Payment_History__c l : history)
					{
						transactionNumbers.add(l.Payment_Transaction_Number__c);
						transactionAmounts.put(l.Payment_Transaction_Number__c, l.Amount__c);
						
						l.Payment_Reference__c='Cancel';
						l.Amount__c = 0;
					}
					update history;
					
					for(Ledger__c lger : [select trans_No__c, type__c, paid__c, amount__c from ledger__c where trans_No__c in : transactionNumbers])
					{
						lger.Amount__c -= transactionAmounts.get(lger.trans_No__c);
						lger.Paid__c = 'N';
						if(lger.Type__c=='PP')
						{
							lger.Type__c='PA';
						}
						lstLedger.add(lger);
					}
					*/
					AmendPurchaseInvoicePayments(newEntry);
				}
			}
			
			//update secondary entries
			List<Ledger__c> otherEntries = [Select l.VAT__c, l.VAT_Return_No__c, l.VAT_Return_Date__c, l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Rate__c, l.Tax_Code__c, l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, l.Nominal__c, l.Net__c, l.Id, l.Ext_Reference__c, l.Doc_ID__c, l.Details__c, l.Debit__c, l.Credit__c, l.Amount__c From Ledger__c l Where Trans_No__c=:newEntry.Trans_No__c and Show_On_Transaction__c IN (0,null) and Is_Deleted__c=false];
			for(Ledger__c l : otherEntries)
			{
				if(l.Sub_Account_Nominal__c == Functions.getNominalAccountCode('Purchase Tax Control Account'))
				{
					l.Debit__c = newTax;
					l.Reference__c = newEntry.Reference__c ;
				}
				if(l.Sub_Account_Nominal__c == Functions.getNominalAccountCode('Materials Purchased'))
				{
					l.Debit__c = newNet;
					l.Reference__c = newEntry.Reference__c ;
				}
				l.Paid__c = newEntry.Paid__c;
				lstLedger.add(l);
			}
			save();
			//update balances
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel();
			//add new entry amount
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Creditors Control Account'))  , newGross , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Purchase Tax Control Account')) , newTax , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Materials Purchased')) , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.newSave();
		}	
		//Done
	}
	
	public void SaveCustomerOpeningBalanceAmendment(Ledger__c oldEntry, Ledger__c newEntry)
	{
		
		decimal newGross = 0.00 ;
		decimal newNet = 0.00 ;
		decimal newTax = 0.00 ;
		if(newEntry.Credit__c == null || newEntry.Credit__c == 0)
		{
			newGross = newEntry.Debit__c  ;
			newNet = newEntry.Debit__c ;
			newTax = newEntry.Tax__c;
		}
		else
		{
			newGross = newEntry.Credit__c ; 
			newNet = newEntry.Credit__c ; 
			newTax = newEntry.Tax__c;
		}
		
		decimal oldGross = oldEntry.Net__c + oldEntry.Tax__c;
		decimal oldNet = oldEntry.Net__c;
		decimal oldTax = oldEntry.Tax__c;
		//save old invoice with new transaction number
		CancelLedgerEntry(oldEntry);
		
		//Save newEntry
		lstLedger.add(newEntry);
		if(newNet != oldNet || newTax != oldTax)
		{
			if(newGross > oldGross)
			{
				newEntry.Paid__c='N';
			}
			else if(newGross < oldGross)
			{
				if(newGross == newEntry.Amount__c)
				{
					newEntry.Paid__c = 'Y';				
				}
				else if(newGross < newEntry.Amount__c)
				{
					newEntry.Amount__c = 0;
					newEntry.Paid__c = 'N';
			
					//update previous payments
					/*
					map<double, decimal> transactionAmounts = new map<double, decimal>();
					set<double> transactionNumbers = new set<double>();
					List<Ledger_Payment_History__c> history = GetLedgerPaymentHistoryByTransactionNumber(newEntry.Type__c, (double) newEntry.Trans_No__c);
					for(Ledger_Payment_History__c l : history)
					{
						transactionNumbers.add(l.Payment_Transaction_Number__c);
						transactionAmounts.put(l.Payment_Transaction_Number__c, l.Amount__c);
						
						l.Payment_Reference__c='Cancel';
						l.Amount__c = 0;
					}
					update history;
					
					for(Ledger__c lger : [select trans_No__c, type__c, paid__c, amount__c from ledger__c where trans_No__c in : transactionNumbers])
					{
						lger.Amount__c -= transactionAmounts.get(lger.trans_No__c);
						lger.Paid__c = 'N';
						if(lger.Type__c=='SR')
						{
							lger.Type__c='SA';
						}
						lstLedger.add(lger);
					}
					*/
					AmendSalesInvoicePayments(newEntry);
				}
			}
			
			//update secondary entries
			List<Ledger__c> otherEntries = [Select l.VAT__c, l.VAT_Return_No__c, l.VAT_Return_Date__c, l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Rate__c, l.Tax_Code__c, l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, l.Nominal__c, l.Net__c, l.Id, l.Ext_Reference__c, l.Doc_ID__c, l.Details__c, l.Debit__c, l.Credit__c, l.Amount__c From Ledger__c l Where Trans_No__c=:newEntry.Trans_No__c and Show_On_Transaction__c IN(0,null) and Is_Deleted__c=false];
			for(Ledger__c l : otherEntries)
			{
				if(l.Credit__c == null || l.Credit__c ==0)
					l.Debit__c = newNet;
				else
					l.Credit__C = newNet;
				l.Paid__c = newEntry.Paid__c;
				l.Reference__c  = newEntry.Reference__c ; 
				lstLedger.add(l);
			}
			save();
			//update balances
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel();
			//subtract old entry amount			
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Debtors Control Account'))  , -oldGross , string.valueOf(oldEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Suspense Account')) , -oldGross , string.valueOf(oldEntry.Trans_Date__c));
			//add new entry amount			
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Debtors Control Account'))  , newGross , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Suspense Account')) , newGross , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.newsave();
		}
		//Done but same error on Duplicate ID
	}
	
	public void SaveSupplierOpeningBalanceAmendment(Ledger__c oldEntry, Ledger__c newEntry)
	{
		system.debug('this is supplier amadments');
		decimal newGross = 0.00 ;
		decimal newNet = 0.00 ;
		decimal newTax = 0.00 ;
		if(newEntry.Credit__c == null || newEntry.Credit__c == 0)
		{
			newGross = newEntry.Debit__c  ;
			newNet = newEntry.Debit__c ;
			newTax = newEntry.Tax__c;
		}
		else
		{
			newGross = newEntry.Credit__c ; 
			newNet = newEntry.Credit__c ; 
			newTax = newEntry.Tax__c;   
		}
		decimal oldGross = oldEntry.Net__c + oldEntry.Tax__c;
		decimal oldNet = oldEntry.Net__c;
		decimal oldTax = oldEntry.Tax__c; 
		
		//save old invoice with new transaction number
		CancelLedgerEntry(oldEntry);
		
		//Save newEntry
		lstLedger.add(newEntry);
		if(newNet != oldNet || newTax != oldTax)
		{
			if(newGross > oldGross)
			{
				newEntry.Paid__c='N';
			}
			else if(newGross < oldGross)
			{
				if(newGross == newEntry.Amount__c)
				{
					newEntry.Paid__c = 'Y';				
				}
				else if(newGross < newEntry.Amount__c)
				{
					newEntry.Amount__c = 0;
					newEntry.Paid__c = 'N';
			
					//update previous payments
					/*
					map<double, decimal> transactionAmounts = new map<double, decimal>();
					set<double> transactionNumbers = new set<double>();
					List<Ledger_Payment_History__c> history = GetLedgerPaymentHistoryByTransactionNumber(newEntry.Type__c, (double) newEntry.Trans_No__c);
					for(Ledger_Payment_History__c l : history)
					{
						transactionNumbers.add(l.Payment_Transaction_Number__c);
						transactionAmounts.put(l.Payment_Transaction_Number__c, l.Amount__c);
						
						l.Payment_Reference__c='Cancel';
						l.Amount__c = 0;
					}
					update history;
					
					for(Ledger__c lger : [select trans_No__c, type__c, paid__c, amount__c from ledger__c where trans_No__c in : transactionNumbers])
					{
						lger.Amount__c -= transactionAmounts.get(lger.trans_No__c);
						lger.Paid__c = 'N';
						if(lger.Type__c=='PP')
						{
							lger.Type__c='PA';
						}
						lstLedger.add(lger);
					}
					*/
					AmendPurchaseInvoicePayments(newEntry);
				}
			}
			
			//update secondary entries
			List<Ledger__c> otherEntries = [Select l.VAT__c, l.VAT_Return_No__c, l.VAT_Return_Date__c, l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Rate__c, l.Tax_Code__c, l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, l.Nominal__c, l.Net__c, l.Id, l.Ext_Reference__c, l.Doc_ID__c, l.Details__c, l.Debit__c, l.Credit__c, l.Amount__c From Ledger__c l Where Trans_No__c=:newEntry.Trans_No__c and Show_On_Transaction__c IN(0,null) and Is_Deleted__c=false];
			for(Ledger__c l : otherEntries)
			{
				if(l.Credit__c == null || l.Credit__c ==0)
					l.Debit__c = newNet;
				else
					l.Credit__C = newNet;
				l.Paid__c = newEntry.Paid__c;
				l.Reference__c = newEntry.Reference__c;
				lstLedger.add(l);
			}
			save();
			//update balances
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel();
			//subtract old entry amount
			//updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Creditors Control Account'))  , -oldGross , string.valueOf(oldEntry.Trans_Date__c));
			//updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Suspense Account')) , -oldGross , string.valueOf(oldEntry.Trans_Date__c));
			//add new entry amount
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Creditors Control Account'))  , newGross , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Suspense Account')) , newGross , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.newsave();
		}
		//Done but same error on Duplicate ID
	}
	
	public void SaveSalesRefundAmendment(Ledger__c oldEntry, Ledger__c newEntry)
	{
		decimal newGross = newEntry.Debit__c ;
		decimal newNet = newEntry.Debit__c ;
		decimal newTax = newEntry.Tax__c==null?0:newEntry.Tax__c;
		
		decimal oldGross = oldEntry.Net__c + oldEntry.Tax__c;
		decimal oldNet = oldEntry.Net__c;
		decimal oldTax = oldEntry.Tax__c;
		
		//save old invoice with new transaction number
		CancelLedgerEntry(oldEntry);		
		
		//Save newEntry
		lstLedger.add(newEntry);
		if(newNet != oldNet || newTax != oldTax)
		{
			if(newGross > oldGross)
			{
				newEntry.Paid__c='N';
			}
			else if(newGross < oldGross)
			{
				if(newGross == newEntry.Amount__c)
				{
					newEntry.Paid__c = 'Y';				
				}
				else if(newGross < newEntry.Amount__c)
				{
					newEntry.Amount__c = 0;
					newEntry.Paid__c = 'N';
			
					//update previous payments
					/*
					map<double, decimal> transactionAmounts = new map<double, decimal>();
					set<double> transactionNumbers = new set<double>();
					List<Ledger_Payment_History__c> history = GetLedgerPaymentHistoryByTransactionNumber(newEntry.Type__c, (double) newEntry.Trans_No__c);
					for(Ledger_Payment_History__c l : history)
					{
						transactionNumbers.add(l.Payment_Transaction_Number__c);
						transactionAmounts.put(l.Payment_Transaction_Number__c, l.Amount__c);
						
						l.Payment_Reference__c='Cancel';
						l.Amount__c = 0;
					}
					update history;
					
					for(Ledger__c lger : [select trans_No__c, type__c, paid__c, amount__c from ledger__c where trans_No__c in : transactionNumbers])
					{
						lger.Amount__c -= transactionAmounts.get(lger.trans_No__c);
						lger.Paid__c = 'N';
						if(lger.Type__c=='SR')
						{
							lger.Type__c='SA';
						}
						lstLedger.add(lger);
					}
					*/
					AmendSalesInvoicePayments(newEntry);
				}
			}
			
			//update secondary entries
			List<Ledger__c> otherEntries = [Select l.VAT__c, l.VAT_Return_No__c, l.VAT_Return_Date__c, l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Rate__c, l.Tax_Code__c, l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, l.Nominal__c, l.Net__c, l.Id, l.Ext_Reference__c, l.Doc_ID__c, l.Details__c, l.Debit__c, l.Credit__c, l.Amount__c From Ledger__c l Where Trans_No__c=:newEntry.Trans_No__c and Show_On_Transaction__c IN(0,null) and Is_Deleted__c=false];
			for(Ledger__c l : otherEntries)
			{
				l.Credit__c = newNet;
				l.Paid__c = newEntry.Paid__c;
				l.Reference__c = newEntry.Reference__c ; 
				lstLedger.add(l);
			}
			
			save();
			//update balances
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel();
			//subtract old entry amount
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Debtors Control Account'))  , -oldNet , string.valueOf(oldEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountIdByCode(newEntry.Nominal__c)) , -oldNet , string.valueOf(oldEntry.Trans_Date__c));
			//add new entry amount			
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Debtors Control Account'))  , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountIdByCode(newEntry.Nominal__c)) , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.newsave();
		}	
		// Done same error when try to save duplicate Id for model;	
	}
	
	public void SavePurchaseRefundAmendment(Ledger__c oldEntry, Ledger__c newEntry)
	{
		
		decimal newGross = newEntry.Credit__c ;
		decimal newNet = newEntry.Credit__c ; 
		decimal newTax = newEntry.Tax__c==null?0:newEntry.Tax__c;
		
		decimal oldGross = oldEntry.Net__c + oldEntry.Tax__c;
		decimal oldNet = oldEntry.Net__c;
		decimal oldTax = oldEntry.Tax__c==null?0:oldEntry.Tax__c;
		
		//save old invoice with new transaction number
		CancelLedgerEntry(oldEntry);
				
		//Save newEntry
		lstLedger.add(newEntry);
		if(newNet != oldNet || newTax != oldTax)
		{
			if(newGross > oldGross)
			{
				newEntry.Paid__c='N';
			}
			else if(newGross < oldGross)
			{
				if(newGross == newEntry.Amount__c)
				{
					newEntry.Paid__c = 'Y';				
				}
				else if(newGross < newEntry.Amount__c)
				{
					newEntry.Amount__c = 0;
					newEntry.Paid__c = 'N';
			
					//update previous payments
					/*
					map<double, decimal> transactionAmounts = new map<double, decimal>();
					set<double> transactionNumbers = new set<double>();
					List<Ledger_Payment_History__c> history = GetLedgerPaymentHistoryByTransactionNumber(newEntry.Type__c, (double) newEntry.Trans_No__c);
					for(Ledger_Payment_History__c l : history)
					{
						transactionNumbers.add(l.Payment_Transaction_Number__c);
						transactionAmounts.put(l.Payment_Transaction_Number__c, l.Amount__c);
						
						l.Payment_Reference__c='Cancel';
						l.Amount__c = 0;
					}
					update history;
					
					for(Ledger__c lger : [select trans_No__c, type__c, paid__c, amount__c from ledger__c where trans_No__c in : transactionNumbers])
					{
						lger.Amount__c -= transactionAmounts.get(lger.trans_No__c);
						lger.Paid__c = 'N';
						if(lger.Type__c=='PP')
						{
							lger.Type__c='PA';
						}
						lstLedger.add(lger);
					}
					*/
					AmendPurchaseInvoicePayments(newEntry);
				}
			}
			
			//update secondary entries
			List<Ledger__c> otherEntries = [Select l.VAT__c, l.VAT_Return_No__c, l.VAT_Return_Date__c, l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Rate__c, l.Tax_Code__c, l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, l.Nominal__c, l.Net__c, l.Id, l.Ext_Reference__c, l.Doc_ID__c, l.Details__c, l.Debit__c, l.Credit__c, l.Amount__c From Ledger__c l Where Trans_No__c=:newEntry.Trans_No__c and Show_On_Transaction__c IN(0,null) and Is_Deleted__c=false];
			for(Ledger__c l : otherEntries)
			{
				l.Debit__c = newNet;
				l.Paid__c = newEntry.Paid__c;
				l.Reference__c = newEntry.Reference__c ; 
				lstLedger.add(l);
			}
			
			save();
			//update balances
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel();   
			//subtract old entry amounts
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Creditors Control Account'))  , -oldNet , string.valueOf(oldEntry.Trans_Date__c));
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountIdByCode(newEntry.Nominal__c)) , -oldNet , string.valueOf(oldEntry.Trans_Date__c));
			//add new entry amounts
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Creditors Control Account'))  , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountIdByCode(newEntry.Nominal__c)) , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.newsave();
		}
		// Done same error when try to save duplicate Id for model;		
	}
	
	public void SaveSalesCreditAmendment(Ledger__c oldEntry, Ledger__c newEntry)
	{
		decimal newGross = newEntry.Credit__c + newEntry.Tax__c;
		decimal newNet = newEntry.Credit__c;
		decimal newTax = newEntry.Tax__c;
		
		decimal oldGross = oldEntry.Net__c + oldEntry.Tax__c;
		decimal oldNet = oldEntry.Net__c;
		decimal oldTax = oldEntry.Tax__c;
		
		//save old credit(same function works for invoices and credits) with new transaction number
		Id AccountId = [select Id from Account where AccountNumber = :oldEntry.Sub_Account__c ].Id;   
		CloneSILedgerEntry(oldEntry.Doc_Id__c, oldGross, oldNet, oldTax, AccountId, (double) oldEntry.Trans_No__c);
		
		//Save newEntry
		lstLedger.add(newEntry);
		if(newNet != oldNet || newTax != oldTax)
		{
			if(newGross > oldGross)
			{
				newEntry.Paid__c='N';
			}
			else if(newGross < oldGross)
			{
				if(newGross == newEntry.Amount__c)
				{
					newEntry.Paid__c = 'Y';				
				}
				else if(newGross < newEntry.Amount__c)
				{
					newEntry.Amount__c = 0;
					newEntry.Paid__c = 'N';
			
					//update previous payments
					AmendPaymentLineItems(newEntry);
				}
			}
			
			//update secondary entries
			List<Ledger__c> otherEntries = [Select l.VAT__c, l.VAT_Return_No__c, l.VAT_Return_Date__c, l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Rate__c, l.Tax_Code__c, l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, l.Nominal__c, l.Net__c, l.Id, l.Ext_Reference__c, l.Doc_ID__c, l.Details__c, l.Debit__c, l.Credit__c, l.Amount__c From Ledger__c l Where Trans_No__c=:newEntry.Trans_No__c and Show_On_Transaction__c IN (0,null) and Is_Deleted__c=false];
			for(Ledger__c l : otherEntries)
			{
				if(l.Sub_Account_Nominal__c == Functions.getNominalAccountCode('Sales North'))
				{
					l.Debit__c = newNet;  
					l.Reference__c = newEntry.Reference__c;
				}
				if(l.Sub_Account_Nominal__c == Functions.getNominalAccountCode('Sales Tax Control Account'))
				{
					l.Debit__c = newTax ;
					l.Reference__c = newEntry.Reference__c;
				}
				l.Paid__c = newEntry.Paid__c;
				lstLedger.add(l);
			}
			save();
			//update balances
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel();			
			//add new entry amounts
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Debtors Control Account'))  , newGross , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Sales Tax Control Account')) , newTax , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Sales North')) , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.newSave();
		}
		//Done	
	}
	
	public void SavePurchaseCreditAmendment(Ledger__c oldEntry, Ledger__c newEntry)
	{
		decimal newGross = newEntry.Debit__c ;
		decimal newNet = newEntry.Debit__c - newEntry.Tax__c ;
		decimal newTax = newEntry.Tax__c;
		
		decimal oldGross = oldEntry.Net__c + oldEntry.Tax__c;
		decimal oldNet = oldEntry.Net__c;
		decimal oldTax = oldEntry.Tax__c;
		
		//save old invoice with new transaction number
		Id AccountId = [select Id from Account where AccountNumber = :oldEntry.Sub_Account__c ].Id;
		ClonePILedgerEntry(oldEntry.Doc_Id__c, oldGross, oldNet, oldTax, AccountId, (double) oldEntry.Trans_No__c);		
		
		//Save newEntry
		lstLedger.add(newEntry);
		if(newNet != oldNet || newTax != oldTax)
		{
			if(newGross > oldGross)
			{
				newEntry.Paid__c='N';
			}
			else if(newGross < oldGross)
			{
				if(newGross == newEntry.Amount__c)
				{
					newEntry.Paid__c = 'Y';				
				}
				else if(newGross < newEntry.Amount__c)
				{
					newEntry.Amount__c = 0;
					newEntry.Paid__c = 'N';
			
					//update previous payments
					AmendPaymentLineItems(newEntry);
				}
			}
			
			//update secondary entries
			List<Ledger__c> otherEntries = [Select l.VAT__c, l.VAT_Return_No__c, l.VAT_Return_Date__c, l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Rate__c, l.Tax_Code__c, l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, l.Nominal__c, l.Net__c, l.Id, l.Ext_Reference__c, l.Doc_ID__c, l.Details__c, l.Debit__c, l.Credit__c, l.Amount__c From Ledger__c l Where Trans_No__c=:newEntry.Trans_No__c and Show_On_Transaction__c IN (0,null) and Is_Deleted__c=false];
			for(Ledger__c l : otherEntries)
			{
				if(l.Sub_Account_Nominal__c == Functions.getNominalAccountCode('Purchase Tax Control Account'))
				{
					l.Credit__c = newTax;
					l.Reference__c = newEntry.Reference__c ;
				}
				if(l.Sub_Account_Nominal__c == Functions.getNominalAccountCode('Materials Purchased'))
				{
					l.Credit__c = newNet;
					l.Reference__c = newEntry.Reference__c ;
				}
				l.Paid__c = newEntry.Paid__c;
				lstLedger.add(l);
			}
			save();
			//update balances
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel();
			//add new entry amounts
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Creditors Control Account'))  , newGross , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Purchase Tax Control Account')) , newTax , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Materials Purchased')) , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.newsave();
		}	
		//Done
	}
	
	public void SaveSalesPaymentOnAccountAmendment(Ledger__c oldEntry, Ledger__c newEntry)
	{
		decimal newGross = newEntry.Credit__c ;
		decimal newNet = newEntry.Credit__c ; 
		decimal newTax = newEntry.Tax__c==null?0:newEntry.Tax__c;
		
		decimal oldGross = oldEntry.Net__c ;
		decimal oldNet = oldEntry.Net__c;
		decimal oldTax = oldEntry.Tax__c==null?0:oldEntry.Tax__c;
		
		//save old credit(same function works for invoices and credits) with new transaction number
		CancelLedgerEntry(oldEntry);
		
		//Save newEntry
		lstLedger.add(newEntry);
		if(newNet != oldNet || newTax != oldTax)
		{
			if(newGross > oldGross)
			{
				newEntry.Paid__c='N';
			}
			else if(newGross < oldGross)
			{
				if(newGross == newEntry.Amount__c)
				{
					newEntry.Paid__c = 'Y';				
				}
				else if(newGross < newEntry.Amount__c)
				{
					newEntry.Amount__c = 0;
					newEntry.Paid__c = 'N';
			
					//update previous payments
					AmendPaymentLineItems(newEntry);
				}
			}
			
			//update secondary entries
			List<Ledger__c> otherEntries = [Select l.VAT__c, l.VAT_Return_No__c, l.VAT_Return_Date__c, l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Rate__c, l.Tax_Code__c, l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, l.Nominal__c, l.Net__c, l.Id, l.Ext_Reference__c, l.Doc_ID__c, l.Details__c, l.Debit__c, l.Credit__c, l.Amount__c From Ledger__c l Where Trans_No__c=:newEntry.Trans_No__c and Show_On_Transaction__c IN (0,null) and Is_Deleted__c=false];
			for(Ledger__c l : otherEntries)
			{
				l.Debit__c = newNet;
				l.Paid__c = newEntry.Paid__c;
				lstLedger.add(l);
			}
			save();
			//update balances
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel();			
			//subbtract old entry amounts
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Debtors Control Account'))  , -oldNet , string.valueOf(oldEntry.Trans_Date__c));
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountIdByCode(newEntry.Nominal__c)) , -oldNet , string.valueOf(oldEntry.Trans_Date__c));
			//add new entry amounts
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Debtors Control Account'))  , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountIdByCode(newEntry.Nominal__c)) , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.newsave();
		}	
		// main coding is done but on save this error occurs "Unable to Save Budget Duplicate id in list: a0m900000002lv3AAA"  
	}
	
	public void SavePurchasePaymentOnAccountAmendment(Ledger__c oldEntry, Ledger__c newEntry)
	{
		decimal newGross = newEntry.Debit__c ; 
		decimal newNet = newEntry.Debit__c;
		decimal newTax = newEntry.Tax__c==null?0:newEntry.Tax__c;
		
		decimal oldGross = oldEntry.Debit__c ;
		decimal oldNet = oldEntry.Debit__c;
		decimal oldTax = oldEntry.Tax__c==null?0:oldEntry.Tax__c;
		
		//save old invoice with new transaction number
		CancelLedgerEntry(oldEntry);
		
		//Save newEntry
		lstLedger.add(newEntry);
		if(newNet != oldNet || newTax != oldTax)
		{
			if(newGross > oldGross)
			{
				newEntry.Paid__c='N';
			}
			else if(newGross < oldGross)
			{
				if(newGross == newEntry.Amount__c)
				{
					newEntry.Paid__c = 'Y';				
				}
				else if(newGross < newEntry.Amount__c)
				{
					newEntry.Amount__c = 0;
					newEntry.Paid__c = 'N';
			
					//update previous payments
					AmendPaymentLineItems(newEntry);
				}
			}
			
			//update secondary entries
			List<Ledger__c> otherEntries = [Select l.VAT__c, l.VAT_Return_No__c, l.VAT_Return_Date__c, l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Rate__c, l.Tax_Code__c, l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, l.Nominal__c, l.Net__c, l.Id, l.Ext_Reference__c, l.Doc_ID__c, l.Details__c, l.Debit__c, l.Credit__c, l.Amount__c From Ledger__c l Where Trans_No__c=:newEntry.Trans_No__c and Show_On_Transaction__c IN(0,null) and Is_Deleted__c=false];
			for(Ledger__c l : otherEntries)
			{
				l.Credit__c = newNet;
				l.Paid__c = newEntry.Paid__c;
				lstLedger.add(l);
			}
			save();
			//update balances
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel();
			//subtract old entry amounts
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Creditors Control Account'))  , -oldNet , string.valueOf(oldEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountIdByCode(newEntry.Nominal__c)) , -oldNet , string.valueOf(oldEntry.Trans_Date__c));
			//add new entry amounts
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Creditors Control Account'))  , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountIdByCode(newEntry.Nominal__c)) , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.newsave();
		}
		// main coding is done but on save this error occurs "Unable to Save Budget Duplicate id in list: a0m900000002lv3AAA"  	
	}
	
	public void SaveSalesReceiptAmendment(Ledger__c oldEntry, Ledger__c newEntry)
	{
		decimal newGross = newEntry.Credit__c ;  
		decimal newNet = newEntry.Credit__c  ;//-  newEntry.Tax__c==null?0:newEntry.Tax__c ;
		decimal newTax = newEntry.Tax__c==null?0:newEntry.Tax__c ;
		
		decimal oldGross = oldEntry.credit__c ;
		decimal oldNet = oldEntry.Net__c;
		decimal oldTax = oldEntry.Tax__c==null?0:oldEntry.Tax__c ;
		
		CancelLedgerEntry(oldEntry);
		
		//Save newEntry
		lstLedger.add(newEntry);
		if(newNet != oldNet || newTax != oldTax)
		{
			apexpages.addmessage(new apexpages.message(apexpages.severity.info,'newNet != oldNet || newTax != oldTax'));
			if(newGross > oldGross)
			{
				apexpages.addmessage(new apexpages.message(apexpages.severity.info,'newGross > oldGross'));
				newEntry.Paid__c='N';
				newEntry.Type__c = 'SA';
			}
			else if(newGross < oldGross)
			{
				apexpages.addmessage(new apexpages.message(apexpages.severity.info,'newGross < oldGross'));
				if(newGross == newEntry.Amount__c)
				{
					apexpages.addmessage(new apexpages.message(apexpages.severity.info,'newGross == newEntry.Amount__c'));
					newEntry.Paid__c = 'Y';
					newEntry.Type__c = 'SA';				
				}
				else if(newGross < newEntry.Amount__c)
				{
					apexpages.addmessage(new apexpages.message(apexpages.severity.info,'newGross < newEntry.Amount__c'));
					newEntry.Amount__c = 0;
					newEntry.Paid__c = 'N';
					newEntry.Type__c = 'SA';
			
					//update previous payments
					/*
					map<double, decimal> transactionAmounts = new map<double, decimal>();
					set<double> transactionNumbers = new set<double>();
					List<Ledger_Payment_History__c> history = GetLedgerPaymentHistoryByTransactionNumber(newEntry.Type__c, (double) newEntry.Trans_No__c);
					for(Ledger_Payment_History__c l : history)
					{
						apexpages.addmessage(new apexpages.message(apexpages.severity.info,'Parent_Transaction_Number__c: '+l.Parent_Transaction_Number__c));
						transactionNumbers.add(l.Parent_Transaction_Number__c);
						transactionAmounts.put(l.Parent_Transaction_Number__c, l.Amount__c);
						
						l.Payment_Reference__c='Cancel';
						l.Cancelled__c = true;
						l.Amount__c = 0;
					}
					update history;
					
					for(Ledger__c lger : [select trans_No__c, type__c, paid__c, amount__c from ledger__c where Is_Deleted__c=false and trans_No__c in : transactionNumbers])
					{
						apexpages.addmessage(new apexpages.message(apexpages.severity.info,'parent trans_No__c: '+lger.trans_No__c));
						apexpages.addmessage(new apexpages.message(apexpages.severity.info,'parent type__c: '+lger.type__c));
						apexpages.addmessage(new apexpages.message(apexpages.severity.info,'parent Amount__c: '+lger.Amount__c));
						lger.Amount__c -= transactionAmounts.get(lger.trans_No__c);
						lger.Paid__c = 'N';
						lstLedger.add(lger);
					}
					*/
					AmendPaymentLineItems(newEntry);
				}
			}
			
			//update secondary entries
			List<Ledger__c> otherEntries = [Select l.VAT__c, l.VAT_Return_No__c, l.VAT_Return_Date__c, l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Rate__c, l.Tax_Code__c, l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, l.Nominal__c, l.Net__c, l.Id, l.Ext_Reference__c, l.Doc_ID__c, l.Details__c, l.Debit__c, l.Credit__c, l.Amount__c From Ledger__c l Where Trans_No__c=:newEntry.Trans_No__c and Show_On_Transaction__c IN (0,null) and Is_Deleted__c=false];
			for(Ledger__c l : otherEntries)
			{
				l.Debit__c = newNet;
				l.Paid__c = newEntry.Paid__c;
				l.Reference__c = newEntry.Reference__c ; 
				lstLedger.add(l);
			}
			save();
			//update balances  
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel();			
			//subtract old entry amounts
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Debtors Control Account'))  , -oldNet , string.valueOf(oldEntry.Trans_Date__c));
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountIdByCode(newEntry.Nominal__c)) , -oldNet , string.valueOf(oldEntry.Trans_Date__c));
			//add new entry amounts
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Debtors Control Account'))  , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountIdByCode(newEntry.Nominal__c)) , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.newsave();
		}
		// done		
	}
	
	public void SavePurchasePaymentAmendment(Ledger__c oldEntry, Ledger__c newEntry)
	{
		//this is not done coz errror while saving
		decimal newGross = newEntry.Debit__c ;
		decimal newNet = newEntry.Debit__c ;
		decimal newTax = newEntry.Tax__c==null?0:newEntry.Tax__c ;
		
		decimal oldGross = oldEntry.Net__c ;
		decimal oldNet = oldEntry.Net__c;
		decimal oldTax = oldEntry.Tax__c==null?0:oldEntry.Tax__c ;
		
		//save old invoice with new transaction number
		CancelLedgerEntry(oldEntry);
		
		//Save newEntry
		lstLedger.add(newEntry);
		if(newNet != oldNet || newTax != oldTax)
		{
			if(newGross > oldGross)
			{
				newEntry.Paid__c='N';
				newEntry.Type__c = 'PA';
			}
			else if(newGross < oldGross)
			{
				if(newGross == newEntry.Amount__c)
				{
					newEntry.Paid__c = 'Y';
					newEntry.Type__c = 'PA';				
				}
				else if(newGross < newEntry.Amount__c)
				{
					newEntry.Amount__c = 0;
					newEntry.Paid__c = 'N';
					newEntry.Type__c = 'PA';
			
					//update previous payments
					/*
					map<double, decimal> transactionAmounts = new map<double, decimal>();
					set<double> transactionNumbers = new set<double>();
					List<Ledger_Payment_History__c> history = GetLedgerPaymentHistoryByTransactionNumber(newEntry.Type__c, (double) newEntry.Trans_No__c);
					for(Ledger_Payment_History__c l : history)
					{
						transactionNumbers.add(l.Parent_Transaction_Number__c);
						transactionAmounts.put(l.Parent_Transaction_Number__c, l.Amount__c);
						
						l.Payment_Reference__c='Cancel';
						l.Cancelled__c = true;
						l.Amount__c = 0;
					}
					update history;
					
					for(Ledger__c lger : [select trans_No__c, type__c, paid__c, amount__c from ledger__c where trans_No__c in : transactionNumbers])
					{
						lger.Amount__c -= transactionAmounts.get(lger.trans_No__c);
						lger.Paid__c = 'N';
						lstLedger.add(lger);
					}
					*/
					AmendPaymentLineItems(newEntry);
				}
			}
			
			//update secondary entries
			List<Ledger__c> otherEntries = [Select l.VAT__c, l.VAT_Return_No__c, l.VAT_Return_Date__c, l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Rate__c, l.Tax_Code__c, l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, l.Nominal__c, l.Net__c, l.Id, l.Ext_Reference__c, l.Doc_ID__c, l.Details__c, l.Debit__c, l.Credit__c, l.Amount__c From Ledger__c l Where Trans_No__c=:newEntry.Trans_No__c and Show_On_Transaction__c IN(0,null) and Is_Deleted__c=false];
			for(Ledger__c l : otherEntries)
			{
				l.Credit__c = newNet;
				l.Paid__c = newEntry.Paid__c;
				l.reference__c = newEntry.reference__c ; 
				lstLedger.add(l);
			}
			save();
			
			//update balances
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel();
			//subtract old entry amounts
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Creditors Control Account'))  , -oldNet , string.valueOf(oldEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountIdByCode(newEntry.Nominal__c)) , -oldNet , string.valueOf(oldEntry.Trans_Date__c));
			//add new entry amounts
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Creditors Control Account'))  , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountIdByCode(newEntry.Nominal__c)) , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.newsave();
		}
		// done	
	}
	
	public void SaveSalesDiscountAmendment(Ledger__c oldEntry, Ledger__c newEntry)
	{
		//this is not done coz errror while saving
		decimal newGross = newEntry.Credit__c;
		decimal newNet = newEntry.Credit__c;
		decimal newTax = newEntry.Tax__c;
		
		decimal oldGross = oldEntry.Net__c;
		decimal oldNet = oldEntry.Net__c;
		decimal oldTax = oldEntry.Tax__c;
		
		//save old credit(same function works for invoices and credits) with new transaction number
		CancelLedgerEntry(oldEntry);
		
		//Save newEntry
		lstLedger.add(newEntry);
		if(newNet != oldNet || newTax != oldTax)
		{
			if(newGross > oldGross)
			{
				newEntry.Paid__c='N';
				newEntry.Type__c = 'SC';
			}
			else if(newGross < oldGross)
			{
				if(newGross == newEntry.Amount__c)
				{
					newEntry.Paid__c = 'Y';
					newEntry.Type__c = 'SC';				
				}
				else if(newGross < newEntry.Amount__c)
				{
					newEntry.Amount__c = 0;
					newEntry.Paid__c = 'N';
					newEntry.Type__c = 'SC';
			
					//update previous payments
					/*
					map<double, decimal> transactionAmounts = new map<double, decimal>();
					set<double> transactionNumbers = new set<double>();
					List<Ledger_Payment_History__c> history = GetLedgerPaymentHistoryByTransactionNumber(newEntry.Type__c, (double) newEntry.Trans_No__c);
					for(Ledger_Payment_History__c l : history)
					{
						transactionNumbers.add(l.Parent_Transaction_Number__c);
						transactionAmounts.put(l.Parent_Transaction_Number__c, l.Amount__c);
						
						l.Payment_Reference__c='Cancel';
						l.Cancelled__c = true;
						l.Amount__c = 0;
					}
					update history;
					
					for(Ledger__c lger : [select trans_No__c, type__c, paid__c, amount__c from ledger__c where trans_No__c in : transactionNumbers])
					{
						lger.Amount__c -= transactionAmounts.get(lger.trans_No__c);
						lger.Paid__c = 'N';
						lstLedger.add(lger);
					}
					*/
					AmendPaymentLineItems(newEntry);
				}
			}
			
			//update secondary entries
			List<Ledger__c> otherEntries = [Select l.VAT__c, l.VAT_Return_No__c, l.VAT_Return_Date__c, l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Rate__c, l.Tax_Code__c, l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, l.Nominal__c, l.Net__c, l.Id, l.Ext_Reference__c, l.Doc_ID__c, l.Details__c, l.Debit__c, l.Credit__c, l.Amount__c From Ledger__c l Where Trans_No__c=:newEntry.Trans_No__c and Show_On_Transaction__c IN(0,null) and Is_Deleted__c=false];
			for(Ledger__c l : otherEntries)
			{
				l.Debit__c = newNet;
				l.Paid__C = newEntry.Paid__c;
				l.reference__c = newEntry.reference__c ;
				lstLedger.add(l);
			}
			system.debug('this is list before save:' + lstLedger);
			save();
			//update balances
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel();			
			//subtract old entry amounts
			string discountNominalCode = Functions.getNominalAccountCode('Discounts Allowed');
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountIdByCode(discountNominalCode)) , -oldNet , string.valueOf(oldEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Debtors Control Account'))  , -oldNet , string.valueOf(oldEntry.Trans_Date__c));
			//add new entry amounts
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountIdByCode(discountNominalCode)) , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Debtors Control Account'))  , newNet , string.valueOf(newEntry.Trans_Date__c));			
			updateNominalBudget.newsave();
		}	
	}
	
	public void SavePurchaseDiscountAmendment(Ledger__c oldEntry, Ledger__c newEntry)
	{
		// this is not done coz errror while saving
		system.debug('i am in this module: ' + newEntry );
		decimal newGross = newEntry.Debit__c ;
		decimal newNet = newEntry.Debit__c;
		decimal newTax = newEntry.Tax__c;
		
		decimal oldGross = oldEntry.Net__c ;
		decimal oldNet = oldEntry.Net__c;
		decimal oldTax = oldEntry.Tax__c;
		
		//save old invoice with new transaction number
		CancelLedgerEntry(oldEntry);
		
		//Save newEntry
		lstLedger.add(newEntry);
		if(newNet != oldNet || newTax != oldTax)
		{
			if(newGross > oldGross)
			{
				newEntry.Paid__c='N';
				newEntry.Type__c = 'PC';
			}
			else if(newGross < oldGross)
			{
				if(newGross == newEntry.Amount__c)
				{
					newEntry.Paid__c = 'Y';
					newEntry.Type__c = 'PC';				
				}
				else if(newGross < newEntry.Amount__c)
				{
					newEntry.Amount__c = 0;
					newEntry.Paid__c = 'N';
					newEntry.Type__c = 'PC';
			
					//update previous payments
					AmendPaymentLineItems(newEntry);
				}
			}
			
			//update secondary entries
			List<Ledger__c> otherEntries = [Select l.VAT__c, l.VAT_Return_No__c, l.VAT_Return_Date__c, l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Rate__c, l.Tax_Code__c, l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, l.Nominal__c, l.Net__c, l.Id, l.Ext_Reference__c, l.Doc_ID__c, l.Details__c, l.Debit__c, l.Credit__c, l.Amount__c From Ledger__c l Where Trans_No__c=:newEntry.Trans_No__c and Show_On_Transaction__c IN (0,null) and Is_Deleted__c=false];
			for(Ledger__c l : otherEntries)
			{
				l.Credit__c = newNet ;
				l.Paid__c = newEntry.Paid__c;
				l.reference__c = newEntry.reference__c ;
				lstLedger.add(l);
			}
			save();
			//update balances
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel();
			//subtract old entry amounts
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Creditors Control Account'))  , -oldNet , string.valueOf(oldEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountIdByCode(newEntry.Nominal__c)) , -oldNet , string.valueOf(oldEntry.Trans_Date__c));
			//add new entry amounts
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Creditors Control Account'))  , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountIdByCode(newEntry.Nominal__c)) , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.newsave();
		}	
	}
	
	public void SaveBankPaymentAmendment(Ledger__c oldEntry, Ledger__c newEntry)
	{
		decimal newGross = newEntry.Credit__c ; 
		decimal newNet = newEntry.Credit__c - newEntry.Tax__c;
		decimal newTax = newEntry.Tax__c;
		
		decimal oldGross = oldEntry.Net__c + oldEntry.Tax__c;
		decimal oldNet = oldEntry.Net__c;
		decimal oldTax = oldEntry.Tax__c;
		
		//save old invoice with new transaction number
		CancelLedgerEntry(oldEntry);
		
		//Save newEntry
		lstLedger.add(newEntry);
		if(newNet != oldNet || newTax != oldTax)
		{
			newEntry.Amount__c = newGross;
			//update secondary entries
			List<Ledger__c> otherEntries = [Select l.VAT__c, l.VAT_Return_No__c, l.VAT_Return_Date__c, l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Rate__c, l.Tax_Code__c, l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, l.Nominal__c, l.Net__c, l.Id, l.Ext_Reference__c, l.Doc_ID__c, l.Details__c, l.Debit__c, l.Credit__c, l.Amount__c From Ledger__c l Where Trans_No__c=:newEntry.Trans_No__c and Show_On_Transaction__c IN (0,null) and Is_Deleted__c=false];
			system.debug('this is old entries list: ' + otherEntries);
			for(Ledger__c l : otherEntries)
			{
				if(l.Sub_Account_Nominal__c == Functions.getNominalAccountCode('Purchase Tax Control Account'))
				{
					l.Debit__c = newTax;
					l.Reference__c = newentry.Reference__c ;
				}
				else if(newGross < newEntry.Amount__c)
				{
					l.Debit__c = newNet;
					l.Reference__c = newentry.Reference__c ;
				}
				lstLedger.add(l);
			}
			save();
			//update balances
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel();
			//subtract old entry amounts
			// commented by Karim on 23/6/2011 6:10PM
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountIdByCode(newEntry.Nominal__c))  , -oldNet , string.valueOf(oldEntry.Trans_Date__c));
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Purchase Tax Control Account'))  , -oldTax , string.valueOf(oldEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountIdByCode(oldEntry.Sub_Account_Nominal__c)) , -oldGross , string.valueOf(oldEntry.Trans_Date__c));
			//add new entry amounts
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountIdByCode(newEntry.Nominal__c))  , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountId('Purchase Tax Control Account'))  , -newTax , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountIdByCode(newEntry.Sub_Account_Nominal__c)) , newGross , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.newSave() ;
		}	
		//Done
	}
	
	public void SaveBankReceiptAmendment(Ledger__c oldEntry, Ledger__c newEntry)
	{
		decimal newGross = newEntry.Debit__c ;
		decimal newNet = newEntry.Debit__c - newEntry.Tax__c ;
		decimal newTax = newEntry.Tax__c;
		
		decimal oldGross = oldEntry.Net__c + oldEntry.Tax__c;
		decimal oldNet = oldEntry.Net__c;
		decimal oldTax = oldEntry.Tax__c;
		
		//save old invoice with new transaction number
		CancelLedgerEntry(oldEntry);
		
		//Save newEntry
		lstLedger.add(newEntry);
		if(newNet != oldNet || newTax != oldTax)
		{
			newEntry.Amount__c = newGross;
			//update secondary entries
			List<Ledger__c> otherEntries = [Select l.VAT__c, l.VAT_Return_No__c, l.VAT_Return_Date__c, l.Type__c, l.Trans_Ref_Id__c, l.Trans_No__c, l.Trans_Date__c, l.Tax__c, l.Tax_Rate__c, l.Tax_Code__c, l.Sub_Account__c, l.Sub_Account_Nominal__c, l.Show_On_Transaction__c, l.Reference__c, l.Paid__c, l.Nominal__c, l.Net__c, l.Id, l.Ext_Reference__c, l.Doc_ID__c, l.Details__c, l.Debit__c, l.Credit__c, l.Amount__c From Ledger__c l Where Trans_No__c=:newEntry.Trans_No__c and Show_On_Transaction__c IN (0,null) and Is_Deleted__c=false];
			for(Ledger__c l : otherEntries)
			{
				if(l.Sub_Account_Nominal__c == Functions.getNominalAccountCode('Sales Tax Control Account'))
				{
					l.Credit__c = newTax;
					l.Reference__c = newentry.Reference__c ;
				}
				else
				{
					l.Credit__c = newNet;
					l.Reference__c = newentry.Reference__c ;
				}
				lstLedger.add(l);
			}
			save();
			//update balances
			CustomerRefund_BudgetModel updateNominalBudget = new CustomerRefund_BudgetModel(); 
			//subtract old entry amounts
			// commented by Karim on 23/6/2011 6:34PM
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountIdByCode(oldEntry.Sub_Account_Nominal__c)) , -oldGross , string.valueOf(oldEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountIdByCode(oldEntry.Nominal__c))  , -oldNet , string.valueOf(oldEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Sales Tax Control Account'))  , -oldTax , string.valueOf(oldEntry.Trans_Date__c));
			//add new entry amounts
			updateNominalBudget.AddDebit(string.valueof(Functions.getNominalAccountIdByCode(newEntry.Sub_Account_Nominal__c)) , newGross , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountIdByCode(newEntry.Nominal__c))  , newNet , string.valueOf(newEntry.Trans_Date__c));
			updateNominalBudget.AddCredit(string.valueof(Functions.getNominalAccountId('Sales Tax Control Account'))  , -newTax , string.valueOf(newEntry.Trans_Date__c));			
			updateNominalBudget.newsave();
		}
		// Done	
	}
	
	private void AmendSalesInvoicePayments(Ledger__c newEntry)
	{
		map<double, decimal> transactionAmounts = new map<double, decimal>();
		List<Ledger_Payment_History__c> history = GetLedgerPaymentHistoryByTransactionNumber(newEntry.Type__c, (double) newEntry.Trans_No__c);
		for(Ledger_Payment_History__c l : history)
		{
			transactionAmounts.put(l.Payment_Transaction_Number__c, l.Amount__c);
			
			l.Payment_Reference__c='Cancel';
			l.Cancelled__c = true;	
			l.Amount__c = 0;					
		}
		update history;
		
		for(Ledger__c lger : [select trans_No__c, type__c, paid__c, amount__c from ledger__c where Is_Deleted__c=false and trans_No__c in : transactionAmounts.keyset() and Show_On_Transaction__c =: showOnTransactionStatus.YES.ordinal()])
		{
			lger.Amount__c -= transactionAmounts.get(lger.trans_No__c);
			lger.Paid__c = 'N';
			if(lger.Type__c=='SR')
			{
				lger.Type__c='SA';
			}
			lstLedger.add(lger);
		}
	}
	
	private void AmendPurchaseInvoicePayments(Ledger__c newEntry)
	{
		map<double, decimal> transactionAmounts = new map<double, decimal>();
		List<Ledger_Payment_History__c> history = GetLedgerPaymentHistoryByTransactionNumber(newEntry.Type__c, (double) newEntry.Trans_No__c);
		for(Ledger_Payment_History__c l : history)
		{
			transactionAmounts.put(l.Payment_Transaction_Number__c, l.Amount__c);
			
			l.Payment_Reference__c='Cancel';
			l.Cancelled__c = true;	
			l.Amount__c = 0;					
		}
		update history;
		
		for(Ledger__c lger : [select trans_No__c, type__c, paid__c, amount__c from ledger__c where Is_Deleted__c=false and trans_No__c in : transactionAmounts.keyset() and Show_On_Transaction__c =: showOnTransactionStatus.YES.ordinal()])
		{
			lger.Amount__c -= transactionAmounts.get(lger.trans_No__c);
			lger.Paid__c = 'N';
			if(lger.Type__c=='PP')
			{
				lger.Type__c='PA';
			}
			lstLedger.add(lger);
		}
	}
	
	private void AmendPaymentLineItems(Ledger__c newEntry)
	{
		map<double, decimal> transactionAmounts = new map<double, decimal>();
		List<Ledger_Payment_History__c> history = GetLedgerPaymentHistoryByTransactionNumber(newEntry.Type__c, (double) newEntry.Trans_No__c);
		for(Ledger_Payment_History__c l : history)
		{
			transactionAmounts.put(l.Parent_Transaction_Number__c, l.Amount__c);
			
			l.Payment_Reference__c='Cancel';
			l.Cancelled__c = true;
			l.Amount__c = 0;
		}
		update history;
		
		for(Ledger__c lger : [select trans_No__c, type__c, paid__c, amount__c from ledger__c where Is_Deleted__c=false and trans_No__c in : transactionAmounts.keyset() and Show_On_Transaction__c =: showOnTransactionStatus.YES.ordinal()])
		{
			lger.Amount__c -= transactionAmounts.get(lger.trans_No__c);
			lger.Paid__c = 'N';
			lstLedger.add(lger);
		}	
	}
}