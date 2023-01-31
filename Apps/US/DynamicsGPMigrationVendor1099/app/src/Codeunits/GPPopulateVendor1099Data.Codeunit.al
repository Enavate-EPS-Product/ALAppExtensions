codeunit 42003 "GP Populate Vendor 1099 Data"
{
    var
        VendorTaxBatchNameTxt: Label 'GPVENDTAX', Locked = true;
        VendorTaxNoSeriesTxt: Label 'VENDTAX', Locked = true;
        SourceCodeTxt: Label 'GENJNL', Locked = true;
        NoSeriesDescriptionTxt: Label 'GP Vendor 1099', Locked = true;
        PayablesAccountCode: Code[20];

    [EventSubscriber(ObjectType::Codeunit, CodeUnit::"Data Migration Mgt.", 'OnAfterMigrationFinished', '', true, true)]
    local procedure OnAfterMigrationFinishedSubscriber(var DataMigrationStatus: Record "Data Migration Status"; WasAborted: Boolean; StartTime: DateTime; Retry: Boolean)
    var
        HelperFunctions: Codeunit "Helper Functions";
    begin
        if not (DataMigrationStatus."Migration Type" = HelperFunctions.GetMigrationTypeTxt()) then
            exit;

        UpdateAllVendorTaxInfo();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post", 'OnBeforeCode', '', true, true)]
    local procedure OnBeforeCode(var GenJournalLine: Record "Gen. Journal Line"; var HideDialog: Boolean)
    begin
        HideDialog := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post", 'OnBeforeShowPostResultMessage', '', true, true)]
    local procedure OnBeforeShowPostResultMessage(var GenJnlLine: Record "Gen. Journal Line"; TempJnlBatchName: Code[10]; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    procedure UpdateAllVendorTaxInfo()
    begin
        Initialize();
        UpdateVendorTaxInfo();
    end;

    procedure GetVendorLatest1099Period(VendorNo: Code[20]; var TaxYear: Integer; var Period: Integer)
    var
        GPPM00204: Record "GP PM00204";
    begin
        GPPM00204.SetRange(VENDORID, VendorNo);
        GPPM00204.SetFilter(TEN99AMNT, '>0');
        GPPM00204.SetCurrentKey(YEAR1, PERIODID);
        GPPM00204.SetAscending(YEAR1, false);
        GPPM00204.SetAscending(PERIODID, false);
        GPPM00204.SetLoadFields(YEAR1, PERIODID);

        if GPPM00204.FindFirst() then begin
            TaxYear := GPPM00204.YEAR1;
            Period := GPPM00204.PERIODID;
        end;
    end;

    local procedure Initialize()
    var
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        CreateNoSeriesIfNeeded();
        PayablesAccountCode := HelperFunctions.GetPostingAccountNumber('PayablesAccount');
        DataMigrationFacadeHelper.CreateGeneralJournalBatchIfNeeded(VendorTaxBatchNameTxt, '', '');
        DataMigrationFacadeHelper.CreateSourceCodeIfNeeded(SourceCodeTxt);
    end;

    local procedure UpdateVendorTaxInfo()
    var
        Vendor: Record Vendor;
        GPPM00200: Record "GP PM00200";
        GPVendor1099MappingHelpers: Codeunit "GP Vendor 1099 Mapping Helpers";
        IRS1099Code: Code[10];
    begin
        GPPM00200.SetRange(TEN99TYPE, 2, 5);
        if not GPPM00200.FindSet() then
            exit;

        repeat
            if Vendor.Get(GPPM00200.VENDORID) then
                if Vendor."IRS 1099 Code" = '' then begin
                    IRS1099Code := GPVendor1099MappingHelpers.GetIRS1099BoxCode(System.Date2DMY(System.Today(), 3), GPPM00200.TEN99TYPE, GPPM00200.TEN99BOXNUMBER);

                    if IRS1099Code <> '' then
                        Vendor.Validate("IRS 1099 Code", IRS1099Code);

                    if GPPM00200.TXIDNMBR <> '' then
                        Vendor.Validate("Federal ID No.", GPPM00200.TXIDNMBR);

                    if (IRS1099Code <> '') or (GPPM00200.TXIDNMBR <> '') then begin
                        Vendor.Validate("Tax Identification Type", Vendor."Tax Identification Type"::"Legal Entity");
                        if Vendor.Modify() then
                            AddVendor1099Values(Vendor."No.")
                        else
                            LogLastError(Vendor."No.");
                    end else
                        LogVendorSkipped(Vendor."No.");
                end else
                    LogVendorSkipped(Vendor."No.");
        until GPPM00200.Next() = 0;
    end;

    local procedure AddVendor1099Values(VendorNo: Code[20])
    var
        GPPM00204: Record "GP PM00204";
        InvoiceGenJournalLine: Record "Gen. Journal Line";
        PaymentGenJournalLine: Record "Gen. Journal Line";
        GPVendor1099MappingHelpers: Codeunit "GP Vendor 1099 Mapping Helpers";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        LastReportedYear: Integer;
        LastReportedPeriodOfYear: Integer;
        IRS1099Code: Code[10];
        InvoiceDocumentNo: Code[20];
        PaymentDocumentNo: Code[20];
        InvoiceCreated: Boolean;
        PaymentCreated: Boolean;
    begin
        GetVendorLatest1099Period(VendorNo, LastReportedYear, LastReportedPeriodOfYear);
        if LastReportedYear > 0 then
            if LastReportedPeriodOfYear > 0 then begin
                GPPM00204.SetRange(VENDORID, VendorNo);
                GPPM00204.SetFilter(TEN99AMNT, '>0');
                GPPM00204.SetRange(YEAR1, LastReportedYear);
                GPPM00204.SetRange(PERIODID, LastReportedPeriodOfYear);
                if GPPM00204.FindSet() then
                    repeat
                        IRS1099Code := GPVendor1099MappingHelpers.GetIRS1099BoxCode(LastReportedYear, GPPM00204.TEN99TYPE, GPPM00204.TEN99BOXNUMBER);

                        if IRS1099Code <> '' then begin

                            // Invoice
                            InvoiceDocumentNo := NoSeriesManagement.GetNextNo(VendorTaxNoSeriesTxt, 0D, true);
                            InvoiceCreated := CreateGeneralJournalLine(InvoiceGenJournalLine,
                                                VendorNo,
                                                "Gen. Journal Document Type"::Invoice,
                                                InvoiceDocumentNo,
                                                IRS1099Code,
                                                VendorNo,
                                                -GPPM00204.TEN99AMNT,
                                                PayablesAccountCode,
                                                IRS1099Code,
                                                VendorNo + '-' + IRS1099Code + '-INV');

                            // Payment
                            PaymentDocumentNo := NoSeriesManagement.GetNextNo(VendorTaxNoSeriesTxt, 0D, true);
                            PaymentCreated := CreateGeneralJournalLine(PaymentGenJournalLine,
                                                VendorNo,
                                                "Gen. Journal Document Type"::Payment,
                                                PaymentDocumentNo,
                                                IRS1099Code,
                                                VendorNo,
                                                GPPM00204.TEN99AMNT,
                                                PayablesAccountCode,
                                                IRS1099Code,
                                                VendorNo + '-' + IRS1099Code + '-PMT');

                            if InvoiceCreated and PaymentCreated then begin
                                InvoiceGenJournalLine.SendToPosting(Codeunit::"Gen. Jnl.-Post");
                                PaymentGenJournalLine.SendToPosting(Codeunit::"Gen. Jnl.-Post");
                                ApplyEntries(VendorNo, InvoiceDocumentNo, PaymentDocumentNo, VendorNo + '-' + IRS1099Code + '-INV');
                            end;
                        end else
                            LogVendor1099DetailSkipped(VendorNo, GPPM00204.TEN99TYPE, GPPM00204.TEN99BOXNUMBER, IRS1099Code);
                    until GPPM00204.Next() = 0;
            end;
    end;

    local procedure CreateGeneralJournalLine(var GenJournalLine: Record "Gen. Journal Line";
                                                 VendorNo: Code[20];
                                                 DocumentType: enum "Gen. Journal Document Type";
                                                 DocumentNo: Code[20];
                                                 Description: Text[50];
                                                 AccountNo: Code[20];
                                                 Amount: Decimal;
                                                 BalancingAccount: Code[20];
                                                 IRS1099Code: Code[10];
                                                 ExternalDocumentNo: Code[35]): boolean
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLineCurrent: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        LineNum: Integer;
        DocDate: Date;
    begin
        DocDate := Today();
        GenJournalBatch.Get(CreateGenJournalTemplateIfNeeded(VendorTaxBatchNameTxt), VendorTaxBatchNameTxt);

        GenJournalLineCurrent.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLineCurrent.SetRange("Journal Batch Name", GenJournalBatch.Name);
        if GenJournalLineCurrent.FindLast() then
            LineNum := GenJournalLineCurrent."Line No." + 10000
        else
            LineNum := 10000;

        GenJournalTemplate.Get(GenJournalBatch."Journal Template Name");

        Clear(GenJournalLine);
        GenJournalLine.SetHideValidation(true);
        GenJournalLine.Validate("Source Code", GenJournalTemplate."Source Code");
        GenJournalLine.Validate("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.Validate("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.Validate("Line No.", LineNum);
        GenJournalLine.Validate("Account Type", "Gen. Journal Account Type"::Vendor);
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate("Account No.", AccountNo);
        GenJournalLine.Validate(Description, Description);
        GenJournalLine.Validate("Document Date", DocDate);
        GenJournalLine.Validate("Posting Date", DocDate);
        GenJournalLine.Validate("Due Date", DocDate);
        GenJournalLine.Validate(Amount, Amount);
        GenJournalLine.Validate("Amount (LCY)", Amount);
        GenJournalLine.Validate("Currency Code", '');
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.Validate("Bal. Account No.", BalancingAccount);
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::" ");
        GenJournalLine.Validate("Bal. Gen. Bus. Posting Group", '');
        GenJournalLine.Validate("Bal. Gen. Prod. Posting Group", '');
        GenJournalLine.Validate("Bal. VAT Prod. Posting Group", '');
        GenJournalLine.Validate("Bal. VAT Bus. Posting Group", '');
        GenJournalLine.Validate("IRS 1099 Code", IRS1099Code);
        GenJournalLine.Validate("Document Type", DocumentType);
        GenJournalLine.Validate("Source Code", SourceCodeTxt);
        GenJournalLine.Validate("External Document No.", ExternalDocumentNo);

        if GenJournalLine.Insert(true) then
            exit(true)
        else
            LogLastError(VendorNo);

        exit(false);
    end;

    local procedure CreateGenJournalTemplateIfNeeded(GenJournalBatchCode: Code[10]): Code[10]
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::General);
        GenJournalTemplate.SetRange(Recurring, false);
        if not GenJournalTemplate.FindFirst() then begin
            GenJournalTemplate.Init();
            GenJournalTemplate.Validate(Name, GenJournalBatchCode);
            GenJournalTemplate.Validate(Type, GenJournalTemplate.Type::General);
            GenJournalTemplate.Validate(Recurring, false);
            GenJournalTemplate.Insert(true);
        end;
        exit(GenJournalTemplate.Name);
    end;

    local procedure ApplyEntries(VendorNo: Code[20]; InvoiceDocumentNo: Code[20]; PaymentDocumentNo: Code[20]; ExternalDocumentNo: Code[35])
    var
        PaymentVendorLedgerEntry: Record "Vendor Ledger Entry";
        InvoiceVendorLedgerEntry: Record "Vendor Ledger Entry";
        ApplyUnapplyParameters: Record "Apply Unapply Parameters";
        VendEntrySetApplID: Codeunit "Vend. Entry-SetAppl.ID";
        VendEntryApplyPostedEntries: Codeunit "VendEntry-Apply Posted Entries";
    begin
        PaymentVendorLedgerEntry.SetRange("Vendor No.", VendorNo);
        PaymentVendorLedgerEntry.SetRange("Document Type", "Gen. Journal Document Type"::Payment);
        PaymentVendorLedgerEntry.SetRange("Document No.", PaymentDocumentNo);
        if PaymentVendorLedgerEntry.FindFirst() then begin
            InvoiceVendorLedgerEntry.SetRange("Vendor No.", VendorNo);
            InvoiceVendorLedgerEntry.SetRange("Document Type", "Gen. Journal Document Type"::Invoice);
            InvoiceVendorLedgerEntry.SetRange("Document No.", InvoiceDocumentNo);

            if InvoiceVendorLedgerEntry.FindFirst() then begin
                PaymentVendorLedgerEntry.CalcFields(Amount);
                InvoiceVendorLedgerEntry.CalcFields(Amount);
                InvoiceVendorLedgerEntry.Validate("Applying Entry", true);
                InvoiceVendorLedgerEntry.Validate("Applies-to ID", PaymentVendorLedgerEntry."Document No.");
                InvoiceVendorLedgerEntry.CalcFields("Remaining Amount");
                InvoiceVendorLedgerEntry.Validate("Amount to Apply", InvoiceVendorLedgerEntry.Amount);
                Codeunit.Run(Codeunit::"Vend. Entry-Edit", InvoiceVendorLedgerEntry);
                Commit();

                VendEntrySetApplID.SetApplId(PaymentVendorLedgerEntry, InvoiceVendorLedgerEntry, PaymentVendorLedgerEntry."Document No.");

                ApplyUnapplyParameters."Account Type" := "Gen. Journal Account Type"::Vendor;
                ApplyUnapplyParameters."Account No." := VendorNo;
                ApplyUnapplyParameters."Document Type" := InvoiceVendorLedgerEntry."Document Type";
                ApplyUnapplyParameters."Document No." := InvoiceVendorLedgerEntry."Document No.";
                ApplyUnapplyParameters."Posting Date" := InvoiceVendorLedgerEntry."Posting Date";
                ApplyUnapplyParameters."External Document No." := ExternalDocumentNo;
                VendEntryApplyPostedEntries.Apply(InvoiceVendorLedgerEntry, ApplyUnapplyParameters);
            end;
        end;
    end;

    local procedure CreateNoSeriesIfNeeded()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if not NoSeries.Get(VendorTaxNoSeriesTxt) then begin
            NoSeries."Code" := VendorTaxNoSeriesTxt;
            NoSeries.Description := NoSeriesDescriptionTxt;
            NoSeries."Default Nos." := true;
            NoSeries."Manual Nos." := false;
            NoSeries.Insert();

            NoSeriesLine."Series Code" := VendorTaxNoSeriesTxt;
            NoSeriesLine."Starting No." := 'VT000001';
            NoSeriesLine."Ending No." := 'VT999999';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Open := true;
            NoSeriesLine.Insert();
        end;
    end;

    local procedure LogLastError(VendorNo: Code[20])
    var
        GP1099MigrationLog: Record "GP 1099 Migration Log";
    begin
        GP1099MigrationLog."Vendor No." := VendorNo;
        GP1099MigrationLog.IsError := true;
        GP1099MigrationLog."Error Code" := CopyStr(GetLastErrorCode(), 1, MaxStrLen(GP1099MigrationLog."Error Code"));
        GP1099MigrationLog.SetErrorMessage(GetLastErrorCallStack());
        GP1099MigrationLog.Insert();
        ClearLastError();
    end;

    local procedure LogVendorSkipped(VendorNo: Code[20])
    var
        GP1099MigrationLog: Record "GP 1099 Migration Log";
    begin
        GP1099MigrationLog."Vendor No." := VendorNo;
        GP1099MigrationLog.WasSkipped := true;
        GP1099MigrationLog.Insert();
    end;

    local procedure LogVendor1099DetailSkipped(VendorNo: Code[20]; GP1099Type: Integer; GP1099BoxNo: Integer; BCIRS1099Code: Code[10])
    var
        GP1099MigrationLog: Record "GP 1099 Migration Log";
    begin
        GP1099MigrationLog."Vendor No." := VendorNo;
        GP1099MigrationLog.WasSkipped := true;
        GP1099MigrationLog."GP 1099 Type" := GP1099Type;
        GP1099MigrationLog."GP 1099 Box No." := GP1099BoxNo;
        GP1099MigrationLog."BC IRS 1099 Code" := BCIRS1099Code;
        GP1099MigrationLog.Insert();
    end;
}