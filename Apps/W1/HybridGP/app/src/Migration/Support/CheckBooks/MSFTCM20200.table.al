table 40104 MSFTCM20200
{
    Extensible = false;
    Permissions = tableData "Bank Account Ledger Entry" = rim;
    DataClassification = CustomerContent;
    Description = 'GP Checkbook Transactions';

    fields
    {
        field(1; CMRECNUM; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(2; sRecNum; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(3; RCRDSTTS; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(4; CHEKBKID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(5; CMTrxNum; Text[21])
        {
            DataClassification = CustomerContent;
        }
        ///        1        2        3                  4                    5                  6                  7
        ///     Deposit, Receipt, APCheck, "Withdrawl/Payroll Check", IncreaseAdjustment, DecreaseAdjustment, BankTransfer;
        ///         
        field(6; CMTrxType; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(7; TRXDATE; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(8; GLPOSTDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(9; TRXAMNT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(10; CURNCYID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(11; CMLinkID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(12; paidtorcvdfrom; Text[65])
        {
            DataClassification = CustomerContent;
        }
        field(13; DSCRIPTN; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(14; Recond; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(15; RECONUM; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(16; ClrdAmt; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(17; clearedate; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(18; VOIDED; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(19; VOIDDATE; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(20; VOIDPDATE; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(21; VOIDDESC; Text[31])
        {
            DataClassification = CustomerContent;
        }
        field(22; NOTEINDX; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(23; AUDITTRAIL; Text[13])
        {
            DataClassification = CustomerContent;
        }
        field(24; DEPTYPE; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(25; SOURCDOC; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(26; SRCDOCTYP; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(27; SRCDOCNUM; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(28; POSTEDDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(29; PTDUSRID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(30; MODIFDT; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(31; MDFUSRID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(32; USERDEF1; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(33; USERDEF2; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(34; ORIGAMT; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(35; Checkbook_Amount; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(36; RATETPID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(37; EXGTBLID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(38; XCHGRATE; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(39; EXCHDATE; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(40; TIME1; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(41; RTCLCMTD; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(42; EXPNDATE; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(43; CURRNIDX; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(44; DECPLCUR; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(45; DENXRATE; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(46; MCTRXSTT; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(47; Xfr_Record_Number; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(48; EFTFLAG; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(49; VNDCHKNM; Text[65])
        {
            DataClassification = CustomerContent;
        }
        field(50; DEX_ROW_ID; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; CMRECNUM)
        {
            Clustered = true;
        }
    }

    var
        BatchNameTxt: Label 'GPBANK', Locked = true;

    procedure MoveStagingData(BankAccountNo: Code[20]; BankAccPostingGroupCode: Code[20]; CheckbookID: Text[15])
    var
        AccountNo: Code[20];
    begin
        AccountNo := GetBankAccPostingAccountNo(BankAccPostingGroupCode);
        SetRange(CHEKBKID, CheckbookID);
        if FindSet() then
            repeat
                CreateGeneralJournalLine(Format(CMRECNUM), DSCRIPTN, DT2Date(TRXDATE), AccountNo, TRXAMNT, BankAccountNo);
            until Next() = 0;
    end;

    procedure CreateGeneralJournalLine(DocumentNo: Code[20]; Description: Text[50]; PostingDate: Date; OffsetAccount: Code[20]; TrxAmount: Decimal; BankAccount: Code[20])
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalLineCurrent: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        JournalTemplateName: Code[10];
        LineNum: Integer;
    begin
        JournalTemplateName := 'GENERAL';
        CreateGeneralJournalBatchIfNeeded(JournalTemplateName, 'GJNL-GEN');

        GenJournalLineCurrent.SetRange("Journal Template Name", JournalTemplateName);
        GenJournalLineCurrent.SetRange("Journal Batch Name", BatchNameTxt);
        if GenJournalLineCurrent.FindLast() then
            LineNum := GenJournalLineCurrent."Line No." + 10000
        else
            LineNum := 10000;

        GenJournalTemplate.Get(JournalTemplateName);

        GenJournalLine.Init();
        GenJournalLine.SetHideValidation(true);
        GenJournalLine.Validate("Source Code", GenJournalTemplate."Source Code");
        GenJournalLine.Validate("Journal Template Name", JournalTemplateName);
        GenJournalLine.Validate("Journal Batch Name", BatchNameTxt);
        GenJournalLine.Validate("Line No.", LineNum);
        GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::" ");
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"Bank Account");
        GenJournalLine.Validate("Account No.", BankAccount);
        GenJournalLine.Validate(Description, Description);
        GenJournalLine.Validate("Document Date", PostingDate);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate(Amount, TrxAmount);
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.Validate("Bal. Account No.", OffsetAccount);
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::" ");
        GenJournalLine.Validate("Bal. Gen. Bus. Posting Group", '');
        GenJournalLine.Validate("Bal. Gen. Prod. Posting Group", '');
        GenJournalLine.Validate("Bal. VAT Prod. Posting Group", '');
        GenJournalLine.Validate("Bal. VAT Bus. Posting Group", '');
        GenJournalLine.Insert(true);
    end;

    local procedure CreateGeneralJournalBatchIfNeeded(JournalTemplateName: Code[10]; NoSeries: Code[20])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.SetRange(Name, BatchNameTxt);
        GenJournalBatch.SetRange("Journal Template Name", JournalTemplateName);
        GenJournalBatch.SetRange("No. Series", NoSeries);

        if not GenJournalBatch.FindFirst() then begin
            GenJournalBatch.Init();
            GenJournalBatch.Validate(Name, BatchNameTxt);
            GenJournalBatch.Validate("Journal Template Name", JournalTemplateName);
            GenJournalBatch.Validate("No. Series", NoSeries);

            GenJournalBatch.SetupNewBatch();
            GenJournalBatch.Insert(true);
        end;
    end;

    local procedure GetBankAccPostingAccountNo(BankAccPostingGroup: Code[20]): Code[20]
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
    begin
        if BankAccountPostingGroup.Get(BankAccPostingGroup) then
            exit(BankAccountPostingGroup."G/L Account No.");

        exit('InvalidAccount');
    end;
}