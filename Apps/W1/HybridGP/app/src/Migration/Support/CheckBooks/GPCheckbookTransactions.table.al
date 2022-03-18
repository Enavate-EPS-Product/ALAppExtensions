table 40101 "GP Checkbook Transactions"
{
    ReplicateData = false;
    Extensible = false;
    Permissions = tableData "Bank Account Ledger Entry" = rim;

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
        field(6; CMTrxType; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(7; TRXDATE; Date)
        {
            DataClassification = CustomerContent;
        }
        field(8; GLPOSTDT; Date)
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
        field(17; clearedate; Date)
        {
            DataClassification = CustomerContent;
        }
        field(18; VOIDED; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(19; VOIDDATE; Date)
        {
            DataClassification = CustomerContent;
        }
        field(20; VOIDPDATE; Date)
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
        field(28; POSTEDDT; Date)
        {
            DataClassification = CustomerContent;
        }
        field(29; PTDUSRID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(30; MODIFDT; Date)
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
        field(39; EXCHDATE; Date)
        {
            DataClassification = CustomerContent;
        }
        field(40; TIME1; Time)
        {
            DataClassification = CustomerContent;
        }
        field(41; RTCLCMTD; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(42; EXPNDATE; Date)
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
        key(PK; CMRECNUM)
        {
            Clustered = true;
        }
    }

    var
        PostingGroupCodeTxt: Label 'GP', Locked = true;
        BankBatchNameTxt: Label 'GPBANK', Locked = true;


    procedure MoveStagingData(BankAccount: Text; BankAccountNo: Code[20])
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        Amount: Decimal;
    begin
        SetRange(CHEKBKID, BankAccount);
        if FindSet() then
            repeat
                /*  
                    GP CMTrxType we support
                    -- 2 = cash receipt
                    -- 3 = payment
                */
                if CMTrxType = 2 then begin
                    Amount := TRXAMNT;
                end else begin
                    Amount := -TRXAMNT;
                end;

                CreateGeneralJournalBatchIfNeeded(CopyStr(BankBatchNameTxt, 1, 7), CMTrxType);

                CreateGeneralJournalLine(GenJournalLine,
                    Format(CMRECNUM),
                    DSCRIPTN,
                    TRXDATE,
                    BankAccountNo,
                    Amount,
                    CMTrxType
                );

            until Next() = 0;
    end;

    local procedure CreateGeneralJournalBatchIfNeeded(GeneralJournalBatchCode: Code[10]; TrxType: Integer)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        TemplateName: Code[10];
    begin
        GenJournalBatch.SetRange(Name, GeneralJournalBatchCode);

        if TrxType = 2 then begin
            GenJournalBatch.SetRange("Journal Template Name", 'CASHRCPT');
            GenJournalBatch.SetRange("No. Series", 'GJNL-RCPT');
        end else begin
            GenJournalBatch.SetRange("Journal Template Name", 'PAYMENT');
            GenJournalBatch.SetRange("No. Series", 'GJNL-PMT');
        end;

        if not GenJournalBatch.FindFirst then begin
            GenJournalBatch.Init();
            GenJournalBatch.Validate(Name, GeneralJournalBatchCode);

            if TrxType = 2 then begin
                GenJournalBatch.Validate("Journal Template Name", 'CASHRCPT');
            end else begin
                GenJournalBatch.Validate("Journal Template Name", 'PAYMENT');
            end;

            GenJournalBatch.SetupNewBatch;

            if TrxType = 2 then begin
                GenJournalBatch.Validate("No. Series", 'GJNL-RCPT');
            end else begin
                GenJournalBatch.Validate("No. Series", 'GJNL-PMT');
            end;

            GenJournalBatch.Validate(Name, GeneralJournalBatchCode);
            GenJournalBatch.Validate(Description, GeneralJournalBatchCode);
            GenJournalBatch.Insert(true);
        end;
    end;

    procedure CreateGeneralJournalLine(var GenJournalLine: Record "Gen. Journal Line"; DocumentNo: Code[20]; Description: Text[50]; PostingDate: Date; AccountNo: Code[20]; Amount: Decimal; CMTrxType: Integer)
    var
        GenJournalLineCurrent: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        JournalTemplateName: Code[10];
        LineNum: Integer;
    begin
        if CMTrxType = 2 then begin
            JournalTemplateName := 'CASHRCPT';
        end else begin
            JournalTemplateName := 'PAYMENT';
        end;

        GenJournalLineCurrent.SetRange("Journal Batch Name", BankBatchNameTxt);
        GenJournalLineCurrent.SetRange("Journal Template Name", JournalTemplateName);
        if GenJournalLineCurrent.FindLast then
            LineNum := GenJournalLineCurrent."Line No." + 10000
        else
            LineNum := 10000;

        GenJournalTemplate.Get(JournalTemplateName);

        GenJournalLine.Init();
        GenJournalLine.SetHideValidation(true);
        GenJournalLine.Validate("Source Code", GenJournalTemplate."Source Code");
        GenJournalLine.Validate("Journal Template Name", JournalTemplateName);
        GenJournalLine.Validate("Journal Batch Name", BankBatchNameTxt);
        GenJournalLine.Validate("Line No.", LineNum);
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"Bank Account");
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate(Description, Description);
        GenJournalLine.Validate("Document Date", PostingDate);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Account No.", AccountNo);
        GenJournalLine.Validate(Amount, Amount);
        GenJournalLine.Validate("Amount (LCY)", Amount);
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::" ");
        GenJournalLine.Validate("Bal. Gen. Bus. Posting Group", '');
        GenJournalLine.Validate("Bal. Gen. Prod. Posting Group", '');
        GenJournalLine.Validate("Bal. VAT Prod. Posting Group", '');
        GenJournalLine.Validate("Bal. VAT Bus. Posting Group", '');
        GenJournalLine.Insert(true);
    end;
}