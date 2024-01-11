namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;
using Microsoft.Inventory.Item;
using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Finance.GeneralLedger.Account;

codeunit 40903 "GP Migration Validation Mgmt."
{
    trigger OnRun()
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
        GPMigrationValidation: Record "GP Migration Validation";
    begin
        if not HybridCompanyStatus.Get(CompanyName()) then
            exit;

        if not (HybridCompanyStatus."Upgrade Status" = HybridCompanyStatus."Upgrade Status"::Completed) then
            exit;

        if GPMigrationValidation.Get(HybridCompanyStatus.Name) then begin
            if GPMigrationValidation.Status > GPMigrationValidation.Status::"Not Ran" then
                exit;
        end else begin
            GPMigrationValidation.Name := HybridCompanyStatus.Name;
            GPMigrationValidation.Status := GPMigrationValidation.Status::"Not Ran";
            GPMigrationValidation.Insert();
        end;

        RunCompanyMigrationValidation(GPMigrationValidation);
    end;

    procedure StartMigrationValidation()
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
        GPMigrationValidation: Record "GP Migration Validation";
        HybridGPManagement: Codeunit "Hybrid GP Management";
        SessionId: Integer;
    begin
        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Completed);
        if HybridCompanyStatus.FindSet() then
            repeat
                if not GPMigrationValidation.Get(HybridCompanyStatus.Name) then begin
                    Clear(SessionId);
                    Session.StartSession(SessionId, Codeunit::"GP Migration Validation Mgmt.", HybridCompanyStatus.Name, HybridCompanyStatus, HybridGPManagement.GetDefaultJobTimeout());
                end;
            until HybridCompanyStatus.Next() = 0;
    end;

    procedure DeleteAllValidation()
    var
        GPMigrationValidationEntry: Record "GP Migration Validation Entry";
        GPMigrationValidation: Record "GP Migration Validation";
    begin
        if not GPMigrationValidationEntry.IsEmpty() then
            GPMigrationValidationEntry.DeleteAll();

        if not GPMigrationValidation.IsEmpty() then
            GPMigrationValidation.DeleteAll();
    end;

    local procedure RunCompanyMigrationValidation(var GPMigrationValidation: Record "GP Migration Validation")
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        if not (GPMigrationValidation.Status = GPMigrationValidation.Status::"Not Ran") then
            exit;

        if not GPCompanyAdditionalSettings.Get(GPMigrationValidation.Name) then
            exit;

        GPMigrationValidation.Status := GPMigrationValidation.Status::Pending;
        GPMigrationValidation."Validation Date" := System.CurrentDateTime();
        GPMigrationValidation.Modify();

        RunAccountMigrationValidation(GPCompanyAdditionalSettings);
        RunBankAccountMigrationValidation(GPCompanyAdditionalSettings);
        RunCustomerMigrationValidation(GPCompanyAdditionalSettings);
        RunItemMigrationValidation(GPCompanyAdditionalSettings);
        RunPurchaseOrderMigrationValidation(GPCompanyAdditionalSettings);
        RunVendorMigrationValidation(GPCompanyAdditionalSettings);

        GPMigrationValidation.Status := GPMigrationValidation.Status::Completed;
        GPMigrationValidation.Modify();
        Commit();

        OnAfterGPCompanyMigrationValidationCompleted(GPMigrationValidation.Name)
    end;

    procedure GetTestDescriptions(): Text
    var
        TestDescriptionBuilder: TextBuilder;
    begin
        TestDescriptionBuilder.Append('<p><h3>G/L Accounts</h3><ul>');
        TestDescriptionBuilder.Append('<li>Number of migrated Accounts</li>');
        TestDescriptionBuilder.Append('<li>Missing Accounts</li>');
        TestDescriptionBuilder.Append('<li>Unexpected extra Accounts</li>');
        TestDescriptionBuilder.Append('<li>Account names</li>');
        TestDescriptionBuilder.Append('<li>Account beginning balances</li>');
        TestDescriptionBuilder.Append('</ul></p>');

        TestDescriptionBuilder.Append('<p><h3>Bank Accounts</h3><ul>');
        TestDescriptionBuilder.Append('<li>Number of migrated Banks</li>');
        TestDescriptionBuilder.Append('<li>Missing Banks</li>');
        TestDescriptionBuilder.Append('<li>Unexpected extra Banks</li>');
        TestDescriptionBuilder.Append('<li>Bank names</li>');
        TestDescriptionBuilder.Append('<li>Bank balances</li>');
        TestDescriptionBuilder.Append('</ul></p>');

        TestDescriptionBuilder.Append('<p><h3>Customers</h3><ul>');
        TestDescriptionBuilder.Append('<li>Number of migrated Customers</li>');
        TestDescriptionBuilder.Append('<li>Missing Customers</li>');
        TestDescriptionBuilder.Append('<li>Unexpected extra Customers</li>');
        TestDescriptionBuilder.Append('<li>Customer names</li>');
        TestDescriptionBuilder.Append('<li>Customer balances</li>');
        TestDescriptionBuilder.Append('<li>Assigned Customer Posting Groups</li>');
        TestDescriptionBuilder.Append('</ul></p>');

        TestDescriptionBuilder.Append('<p><h3>Items</h3><ul>');
        TestDescriptionBuilder.Append('<li>Number of migrated Items</li>');
        TestDescriptionBuilder.Append('<li>Missing Items</li>');
        TestDescriptionBuilder.Append('<li>Unexpected extra Items</li>');
        TestDescriptionBuilder.Append('<li>Item description</li>');
        TestDescriptionBuilder.Append('<li>Item quantities</li>');
        TestDescriptionBuilder.Append('<li>Assigned Item Posting Group</li>');
        TestDescriptionBuilder.Append('</ul></p>');

        TestDescriptionBuilder.Append('<p><h3>Purchase Orders</h3><ul>');
        TestDescriptionBuilder.Append('<li>Number of migrated POs</li>');
        TestDescriptionBuilder.Append('<li>Missing POs</li>');
        TestDescriptionBuilder.Append('<li>Unexpected extra POs</li>');
        TestDescriptionBuilder.Append('<li>PO Line quantities</li>');
        TestDescriptionBuilder.Append('<li>PO Line received quantities</li>');
        TestDescriptionBuilder.Append('</ul></p>');

        TestDescriptionBuilder.Append('<p><h3>Vendors</h3><ul>');
        TestDescriptionBuilder.Append('<li>Number of migrated Vendors</li>');
        TestDescriptionBuilder.Append('<li>Missing Vendors</li>');
        TestDescriptionBuilder.Append('<li>Unexpected extra Vendors</li>');
        TestDescriptionBuilder.Append('<li>Vendor names</li>');
        TestDescriptionBuilder.Append('<li>Vendor balances</li>');
        TestDescriptionBuilder.Append('<li>Assigned Vendor Posting Group</li>');
        TestDescriptionBuilder.Append('</ul></p>');

        exit(TestDescriptionBuilder.ToText());
    end;

    local procedure RunAccountMigrationValidation(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    var
        GPValidationBuffer: Record "GP Migration Validation Buffer";
        BCValidationBuffer: Record "GP Migration Validation Buffer";
        GPMigrationValidationEntry: Record "GP Migration Validation Entry";
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        GPGL00100: Record "GP GL00100";
        FirstAccount: Record "GP GL00100";
        GPSY00300: Record "GP SY00300";
        GPGL40200: Record "GP GL40200";
        GPGL10111: Record "GP GL10111";
        ExpectedCount: Integer;
        ActualCount: Integer;
        GPAccountNo: Text[50];
        GPAccountDescription: Text[250];
        GPAccountBeginningBalance: Decimal;
    begin
        // GP
        if GPCompanyAdditionalSettings.GetGLModuleEnabled() then begin
            GPGL00100.SetCurrentKey(MNACSGMT);
            GPGL00100.SetRange(ACCTTYPE, 1);
            if GPGL00100.FindSet() then
                repeat
                    GPAccountBeginningBalance := 0;
                    GPAccountNo := CopyStr(GPGL00100.MNACSGMT.TrimEnd(), 1, MaxStrLen(GPAccountNo));

                    GPSY00300.SetRange(MNSEGIND, true);
                    if GPSY00300.FindFirst() then begin
                        GPGL40200.SetRange(SGMNTID, GPGL00100.MNACSGMT);
                        GPGL40200.SetRange(SGMTNUMB, GPSY00300.SGMTNUMB);
                        if GPGL40200.FindFirst() then
                            GPAccountDescription := CopyStr(GPGL40200.DSCRIPTN.TrimEnd(), 1, MaxStrLen(GPAccountDescription));
                    end;

                    if GPAccountDescription = '' then begin
                        FirstAccount.SetCurrentKey(ACTINDX);
                        FirstAccount.SetRange(MNACSGMT, GPGL00100.MNACSGMT);
                        FirstAccount.SetRange(ACCTTYPE, 1);
                        if FirstAccount.FindFirst() then
                            GPAccountDescription := CopyStr(FirstAccount.ACTDESCR.TrimEnd(), 1, MaxStrLen(GPAccountDescription));
                    end;

                    if GPCompanyAdditionalSettings."Oldest GL Year to Migrate" > 0 then
                        if not GPCompanyAdditionalSettings.GetSkipPostingAccountBatches() then begin
                            GPGL10111.SetRange(ACTINDX, GPGL00100.ACTINDX);
                            GPGL10111.SetRange(PERIODID, 0);
                            GPGL10111.SetRange(YEAR1, GPCompanyAdditionalSettings."Oldest GL Year to Migrate");
                            if GPGL10111.FindFirst() then
                                GPAccountBeginningBalance := GPGL10111.PERDBLNC;
                        end;

                    if not GPValidationBuffer.Get(GPAccountNo) then begin
                        GPValidationBuffer."No." := GPAccountNo;
                        GPValidationBuffer.TextField1 := GPAccountDescription;
                        GPValidationBuffer.DecField1 := GPAccountBeginningBalance;
                        GPValidationBuffer.Insert();
                    end;
                until GPGL00100.Next() = 0;
        end;

        ExpectedCount := GPValidationBuffer.Count();

        // BC
        if GLAccount.FindSet() then
            repeat
                if not BCValidationBuffer.Get(GLAccount."No.") then begin
                    BCValidationBuffer."No." := GLAccount."No.";
                    BCValidationBuffer.TextField1 := GLAccount.Name;

                    if GPCompanyAdditionalSettings."Oldest GL Year to Migrate" > 0 then
                        if not GPCompanyAdditionalSettings.GetSkipPostingAccountBatches() then begin
                            GLEntry.SetRange("G/L Account No.", GLAccount."No.");
                            GLEntry.SetRange("Document No.", 'GP' + Format(GPCompanyAdditionalSettings."Oldest GL Year to Migrate") + 'BB');
                            if GLEntry.FindFirst() then
                                BCValidationBuffer.DecField1 := GLEntry.Amount;
                        end;

                    BCValidationBuffer.Insert();
                end;
            until GLAccount.Next() = 0;

        ActualCount := BCValidationBuffer.Count();

        // Validation
        GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Accounts, '', 'Migrated Accounts', Format(ExpectedCount), Format(ActualCount), (ExpectedCount = ActualCount));

        if ActualCount > ExpectedCount then
            if BCValidationBuffer.FindSet() then
                repeat
                    if not GPValidationBuffer.Get(BCValidationBuffer."No.") then
                        GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Accounts, BCValidationBuffer."No.", 'Extra BC Account', 'expected not migrated', 'was migrated', false);
                until BCValidationBuffer.Next() = 0;

        GPValidationBuffer.Reset();
        if GPValidationBuffer.FindSet() then
            repeat
                if BCValidationBuffer.Get(GPValidationBuffer."No.") then begin
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Accounts, GPValidationBuffer."No.", 'Account Name', GPValidationBuffer.TextField1, BCValidationBuffer.TextField1, (GPValidationBuffer.TextField1 = BCValidationBuffer.TextField1));
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Accounts, GPValidationBuffer."No.", 'Beginning Balance', Format(GPValidationBuffer.DecField1), Format(BCValidationBuffer.DecField1), (GPValidationBuffer.DecField1 = BCValidationBuffer.DecField1));
                end else begin
                    if GPValidationBuffer."No." = '' then
                        GPValidationBuffer."No." := ' !BLANK!';
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Accounts, GPValidationBuffer."No.", 'Missing Account', 'expected migrated', 'was not migrated', false);
                end;
            until GPValidationBuffer.Next() = 0;
    end;

    local procedure RunBankAccountMigrationValidation(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    var
        GPValidationBuffer: Record "GP Migration Validation Buffer";
        BCValidationBuffer: Record "GP Migration Validation Buffer";
        GPCheckbookMSTR: Record "GP Checkbook MSTR";
        GPCheckbookTransactions: Record "GP Checkbook Transactions";
        GPCM20600: Record "GP CM20600";
        GPMigrationValidationEntry: Record "GP Migration Validation Entry";
        BankAccount: Record "Bank Account";
        ExpectedCount: Integer;
        ActualCount: Integer;
        ShouldInclude: Boolean;
        Balance: Decimal;
        ShouldFlipSign: Boolean;
    begin
        // GP
        if GPCompanyAdditionalSettings.GetBankModuleEnabled() then
            if GPCheckbookMSTR.FindSet() then
                repeat
                    ShouldInclude := true;
                    Balance := 0;

                    if not GPCompanyAdditionalSettings.GetMigrateInactiveCheckbooks() then
                        if GPCheckbookMSTR.INACTIVE then
                            ShouldInclude := false;

                    if ShouldInclude then begin
                        if not GPCompanyAdditionalSettings.GetMigrateOnlyBankMaster() then
                            if not GPCompanyAdditionalSettings.GetSkipPostingBankBatches() then begin
                                Balance := GPCheckbookMSTR.Last_Reconciled_Balance;

                                GPCheckbookTransactions.SetRange(CHEKBKID, GPCheckbookMSTR.CHEKBKID);
                                GPCheckbookTransactions.SetRange(Recond, false);
                                GPCheckbookTransactions.SetFilter(TRXAMNT, '<>%1', 0);
                                if GPCheckbookTransactions.FindSet() then
                                    repeat
                                        ShouldFlipSign := false;

                                        if GPCheckbookTransactions.ShouldFlipSign() then
                                            ShouldFlipSign := true;

                                        if GPCheckbookTransactions.CMTrxType = 7 then begin
                                            GPCM20600.SetRange(CMXFRNUM, GPCheckbookTransactions.CMTrxNum);
                                            GPCM20600.SetRange(CMFRMRECNUM, GPCheckbookTransactions.CMRECNUM);
                                            if GPCM20600.FindFirst() then
                                                if GPCM20600.Xfr_Record_Number > 0 then
                                                    ShouldFlipSign := true;
                                        end;

                                        if ShouldFlipSign then
                                            GPCheckbookTransactions.TRXAMNT := GPCheckbookTransactions.TRXAMNT * -1;

                                        Balance := Balance + GPCheckbookTransactions.TRXAMNT;
                                    until GPCheckbookTransactions.Next() = 0;
                            end;

                        if not GPValidationBuffer.Get(GPCheckbookMSTR.CHEKBKID) then begin
                            GPValidationBuffer."No." := CopyStr(GPCheckbookMSTR.CHEKBKID.TrimEnd(), 1, MaxStrLen(GPValidationBuffer."No."));
                            GPValidationBuffer.TextField1 := CopyStr(GPCheckbookMSTR.DSCRIPTN.TrimEnd(), 1, MaxStrLen(GPValidationBuffer.TextField1));
                            GPValidationBuffer.DecField1 := Balance;
                            GPValidationBuffer.Insert();
                        end;
                    end;
                until GPCheckbookMSTR.Next() = 0;

        ExpectedCount := GPValidationBuffer.Count();

        // BC
        if BankAccount.FindSet() then
            repeat
                if not BCValidationBuffer.Get(BankAccount."No.") then begin
                    BankAccount.CalcFields(Balance);

                    BCValidationBuffer."No." := BankAccount."No.";
                    BCValidationBuffer.TextField1 := BankAccount.Name;
                    BCValidationBuffer.DecField1 := BankAccount.Balance;
                    BCValidationBuffer.Insert();
                end;
            until BankAccount.Next() = 0;

        ActualCount := BCValidationBuffer.Count();

        // Validation
        GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::"Bank Accounts", '', 'Migrated Bank Accounts', Format(ExpectedCount), Format(ActualCount), (ExpectedCount = ActualCount));

        if ActualCount > ExpectedCount then
            if BCValidationBuffer.FindSet() then
                repeat
                    if not GPValidationBuffer.Get(BCValidationBuffer."No.") then
                        GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::"Bank Accounts", BCValidationBuffer."No.", 'Extra BC Bank Account', 'expected not migrated', 'was migrated', false);
                until BCValidationBuffer.Next() = 0;

        GPValidationBuffer.Reset();
        if GPValidationBuffer.FindSet() then
            repeat
                if BCValidationBuffer.Get(GPValidationBuffer."No.") then begin
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::"Bank Accounts", GPValidationBuffer."No.", 'Bank Account Name', GPValidationBuffer.TextField1, BCValidationBuffer.TextField1, (GPValidationBuffer.TextField1 = BCValidationBuffer.TextField1));
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::"Bank Accounts", GPValidationBuffer."No.", 'Bank Account Balance', Format(GPValidationBuffer.DecField1), Format(BCValidationBuffer.DecField1), (GPValidationBuffer.DecField1 = BCValidationBuffer.DecField1));
                end else begin
                    if GPValidationBuffer."No." = '' then
                        GPValidationBuffer."No." := ' !BLANK!';
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::"Bank Accounts", GPValidationBuffer."No.", 'Missing Bank Account', 'expected migrated', 'was not migrated', false);
                end;
            until GPValidationBuffer.Next() = 0;
    end;

    local procedure RunCustomerMigrationValidation(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    var
        GPValidationBuffer: Record "GP Migration Validation Buffer";
        BCValidationBuffer: Record "GP Migration Validation Buffer";
        GPMigrationValidationEntry: Record "GP Migration Validation Entry";
        Customer: Record Customer;
        GPRM00101: Record "GP RM00101";
        GPRM20101: record "GP RM20101";
        ExpectedCount: Integer;
        ActualCount: Integer;
        ShouldInclude: Boolean;
        DefaultClassName: Text[15];
        ClassName: Text[15];
        Balance: Decimal;
    begin
        DefaultClassName := 'GP';

        // GP
        if GPCompanyAdditionalSettings.GetReceivablesModuleEnabled() then
            if GPRM00101.FindSet() then
                repeat
                    Clear(Balance);
                    ShouldInclude := true;
                    if not GPCompanyAdditionalSettings.GetMigrateInactiveCustomers() then
                        if GPRM00101.INACTIVE then
                            ShouldInclude := false;

                    if ShouldInclude then begin
                        ClassName := CopyStr(GPRM00101.CUSTCLAS.TrimEnd(), 1, MaxStrLen(ClassName));
                        if ClassName = '' then
                            ClassName := DefaultClassName;

                        if not GPCompanyAdditionalSettings.GetSkipPostingCustomerBatches() then begin
                            GPRM20101.SetRange(CUSTNMBR, GPRM00101.CUSTNMBR);
                            GPRM20101.SetRange(VOIDSTTS, 0);
                            GPRM20101.SetFilter(CURTRXAM, '<>%1', 0);
                            if GPRM20101.FindSet() then
                                repeat
                                    if GPRM20101.RMDTYPAL < 7 then
                                        Balance := Balance + GPRM20101.CURTRXAM
                                    else
                                        Balance := Balance + (GPRM20101.CURTRXAM * -1);
                                until GPRM20101.Next() = 0;
                        end;

                        if not GPValidationBuffer.Get(GPRM00101.CUSTNMBR.TrimEnd()) then begin
                            GPValidationBuffer."No." := CopyStr(GPRM00101.CUSTNMBR.TrimEnd(), 1, MaxStrLen(GPValidationBuffer."No."));
                            GPValidationBuffer.TextField1 := CopyStr(GPRM00101.CUSTNAME.TrimEnd(), 1, MaxStrLen(GPValidationBuffer.TextField1));
                            GPValidationBuffer.TextField2 := ClassName;
                            GPValidationBuffer.DecField1 := Balance;
                            GPValidationBuffer.Insert();
                        end;
                    end;
                until GPRM00101.Next() = 0;

        ExpectedCount := GPValidationBuffer.Count();

        // BC
        if Customer.FindSet() then
            repeat
                if not BCValidationBuffer.Get(Customer."No.") then begin
                    Customer.CalcFields(Balance);

                    BCValidationBuffer."No." := Customer."No.";
                    BCValidationBuffer.TextField1 := Customer.Name;
                    BCValidationBuffer.TextField2 := Customer."Customer Posting Group";
                    BCValidationBuffer.DecField1 := Customer.Balance;
                    BCValidationBuffer.Insert();
                end;
            until Customer.Next() = 0;

        ActualCount := BCValidationBuffer.Count();

        // Validation
        GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Customers, '', 'Migrated Customers', Format(ExpectedCount), Format(ActualCount), (ExpectedCount = ActualCount));

        if ActualCount > ExpectedCount then
            if BCValidationBuffer.FindSet() then
                repeat
                    if not GPValidationBuffer.Get(BCValidationBuffer."No.") then
                        GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Customers, BCValidationBuffer."No.", 'Extra BC Customer', 'expected not migrated', 'was migrated', false);
                until BCValidationBuffer.Next() = 0;

        GPValidationBuffer.Reset();
        if GPValidationBuffer.FindSet() then
            repeat
                if BCValidationBuffer.Get(GPValidationBuffer."No.") then begin
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Customers, GPValidationBuffer."No.", 'Customer Name', GPValidationBuffer.TextField1, BCValidationBuffer.TextField1, (GPValidationBuffer.TextField1 = BCValidationBuffer.TextField1));
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Customers, GPValidationBuffer."No.", 'Customer Posting Group', GPValidationBuffer.TextField2, BCValidationBuffer.TextField2, (GPValidationBuffer.TextField2 = BCValidationBuffer.TextField2));
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Customers, GPValidationBuffer."No.", 'Customer Balance', Format(GPValidationBuffer.DecField1), Format(BCValidationBuffer.DecField1), (GPValidationBuffer.DecField1 = BCValidationBuffer.DecField1));
                end else begin
                    if GPValidationBuffer."No." = '' then
                        GPValidationBuffer."No." := ' !BLANK!';
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Customers, GPValidationBuffer."No.", 'Missing Customer', 'expected migrated', 'was not migrated', false);
                end;
            until GPValidationBuffer.Next() = 0;
    end;

    local procedure RunItemMigrationValidation(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    var
        GPValidationBuffer: Record "GP Migration Validation Buffer";
        BCValidationBuffer: Record "GP Migration Validation Buffer";
        GPMigrationValidationEntry: Record "GP Migration Validation Entry";
        Item: Record Item;
        GPIV00101: Record "GP IV00101";
        GPIV10200: Record "GP IV10200";
        GPIV00200: Record "GP IV00200";
        GPIV00300: Record "GP IV00300";
        ExpectedCount: Integer;
        ActualCount: Integer;
        ShouldInclude: Boolean;
        IsDiscontinued: Boolean;
        IsInventoryOrDiscontinued: Boolean;
        IsInactive: Boolean;
        DefaultClassName: Text[15];
        ClassName: Text[15];
        Quantity: Decimal;
    begin
        DefaultClassName := 'GP';

        // GP
        if GPCompanyAdditionalSettings.GetInventoryModuleEnabled() then begin
            GPIV00101.SetFilter(ITEMTYPE, '<>%1', 3);
            if GPIV00101.FindSet() then
                repeat
                    Clear(Quantity);
                    Clear(ClassName);
                    ShouldInclude := true;
                    IsInventoryOrDiscontinued := (GPIV00101.ITEMTYPE < 3);
                    IsInactive := (GPIV00101.ITEMTYPE = 2) or (GPIV00101.INACTIVE);
                    IsDiscontinued := GPIV00101.ITEMTYPE = 2;

                    if not GPCompanyAdditionalSettings.GetMigrateInactiveItems() then
                        if IsInactive then
                            ShouldInclude := false;

                    if ShouldInclude then
                        if not GPCompanyAdditionalSettings.GetMigrateDiscontinuedItems() then
                            if IsDiscontinued then
                                ShouldInclude := false;

                    if ShouldInclude then begin
                        if GPCompanyAdditionalSettings.GetMigrateItemClasses() then begin
                            if IsInventoryOrDiscontinued then
                                ClassName := CopyStr(GPIV00101.ITMCLSCD.TrimEnd(), 1, MaxStrLen(ClassName));

                            if ClassName = '' then
                                if IsInventoryOrDiscontinued then
                                    ClassName := DefaultClassName;
                        end else
                            ClassName := DefaultClassName;

                        GPIV10200.SetRange(ITEMNMBR, GPIV00101.ITEMNMBR);
                        GPIV10200.SetRange(RCPTSOLD, false);
                        GPIV10200.SetRange(QTYTYPE, 1);
                        if GPIV10200.FindSet() then
                            repeat
                                // Serial
                                if GPIV00101.ITMTRKOP = 2 then begin
                                    GPIV00200.SetRange(ITEMNMBR, GPIV10200.ITEMNMBR);
                                    GPIV00200.SetRange(LOCNCODE, GPIV10200.TRXLOCTN);
                                    GPIV00200.SetRange(DATERECD, GPIV10200.DATERECD);
                                    GPIV00200.SetRange(RCTSEQNM, GPIV10200.RCTSEQNM);
                                    GPIV00200.SetRange(QTYTYPE, 1);
                                    Quantity := Quantity + GPIV00200.Count();
                                end;

                                // Lot
                                if GPIV00101.ITMTRKOP = 3 then begin
                                    GPIV00300.SetRange(ITEMNMBR, GPIV00101.ITEMNMBR);
                                    GPIV00300.SetRange(LOCNCODE, GPIV10200.TRXLOCTN);
                                    GPIV00300.SetRange(DATERECD, GPIV10200.DATERECD);
                                    GPIV00300.SetRange(RCTSEQNM, GPIV10200.RCTSEQNM);
                                    GPIV00300.SetRange(QTYTYPE, 1);
                                    if GPIV00300.FindSet() then
                                        repeat
                                            Quantity := Quantity + (GPIV00300.QTYRECVD - GPIV00300.QTYSOLD);
                                        until GPIV00300.Next() = 0;
                                end;

                                if (GPIV00101.ITMTRKOP <> 2) and (GPIV00101.ITMTRKOP <> 3) then
                                    Quantity := Quantity + (GPIV10200.QTYRECVD - GPIV10200.QTYSOLD);
                            until GPIV10200.Next() = 0;

                        if not GPValidationBuffer.Get(GPIV00101.ITEMNMBR.TrimEnd()) then begin
                            GPValidationBuffer."No." := CopyStr(GPIV00101.ITEMNMBR.TrimEnd(), 1, MaxStrLen(GPValidationBuffer."No."));
                            GPValidationBuffer.TextField1 := CopyStr(GPIV00101.ITEMDESC.TrimEnd(), 1, MaxStrLen(GPValidationBuffer.TextField1));
                            GPValidationBuffer.TextField2 := ClassName;
                            GPValidationBuffer.DecField1 := Quantity;
                            GPValidationBuffer.Insert();
                        end;
                    end;
                until GPIV00101.Next() = 0;
        end;

        ExpectedCount := GPValidationBuffer.Count();

        // BC
        if Item.FindSet() then
            repeat
                if not BCValidationBuffer.Get(Item."No.") then begin
                    Item.CalcFields(Inventory);

                    BCValidationBuffer."No." := Item."No.";
                    BCValidationBuffer.TextField1 := Item.Description;
                    BCValidationBuffer.TextField2 := Item."Inventory Posting Group";
                    BCValidationBuffer.DecField1 := Item.Inventory;
                    BCValidationBuffer.Insert();
                end;
            until Item.Next() = 0;

        ActualCount := BCValidationBuffer.Count();

        // Validation
        GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Items, '', 'Migrated Items', Format(ExpectedCount), Format(ActualCount), (ExpectedCount = ActualCount));

        if ActualCount > ExpectedCount then
            if BCValidationBuffer.FindSet() then
                repeat
                    if not GPValidationBuffer.Get(BCValidationBuffer."No.") then
                        GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Items, BCValidationBuffer."No.", 'Extra BC Item', 'expected not migrated', 'was migrated', false);
                until BCValidationBuffer.Next() = 0;

        GPValidationBuffer.Reset();
        if GPValidationBuffer.FindSet() then
            repeat
                if BCValidationBuffer.Get(GPValidationBuffer."No.") then begin
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Items, GPValidationBuffer."No.", 'Item Name', GPValidationBuffer.TextField1, BCValidationBuffer.TextField1, (GPValidationBuffer.TextField1 = BCValidationBuffer.TextField1));
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Items, GPValidationBuffer."No.", 'Item Posting Group', GPValidationBuffer.TextField2, BCValidationBuffer.TextField2, (GPValidationBuffer.TextField2 = BCValidationBuffer.TextField2));
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Items, GPValidationBuffer."No.", 'Item Quantity', Format(GPValidationBuffer.DecField1), Format(BCValidationBuffer.DecField1), (GPValidationBuffer.DecField1 = BCValidationBuffer.DecField1));
                end else begin
                    if GPValidationBuffer."No." = '' then
                        GPValidationBuffer."No." := ' !BLANK!';
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Items, GPValidationBuffer."No.", 'Missing Item', 'expected migrated', 'was not migrated', false);
                end;
            until GPValidationBuffer.Next() = 0;
    end;

    local procedure RunPurchaseOrderMigrationValidation(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    var
        GPPOHeaderValidationBuffer: Record "GP Migration Validation Buffer";
        GPPOLineValidationBuffer: Record "GP Migration Validation Buffer";
        BCPOHeaderValidationBuffer: Record "GP Migration Validation Buffer";
        BCPOLineValidationBuffer: Record "GP Migration Validation Buffer";
        GPMigrationValidationEntry: Record "GP Migration Validation Entry";
        GPPOP10100: Record "GP POP10100";
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        POLineIdTxt: Text[50];
        ExpectedPOHeaderCount: Integer;
        ActualPOHeaderCount: Integer;
    begin
        // GP
        if GPCompanyAdditionalSettings.GetMigrateOpenPOs() then begin
            GPPOP10100.SetRange(POTYPE, GPPOP10100.POTYPE::Standard);
            GPPOP10100.SetRange(POSTATUS, 1, 4);
            GPPOP10100.SetFilter(VENDORID, '<>%1', '');
            if GPPOP10100.FindSet() then
                repeat
                    if Vendor.Get(GPPOP10100.VENDORID) then
                        if not GPPOHeaderValidationBuffer.Get(GPPOP10100.PONUMBER) then begin
                            GPPOHeaderValidationBuffer."No." := CopyStr(GPPOP10100.PONUMBER.TrimEnd(), 1, MaxStrLen(GPPOHeaderValidationBuffer."No."));
                            GPPOHeaderValidationBuffer.TextField1 := CopyStr(GPPOP10100.VENDORID.TrimEnd(), 1, MaxStrLen(GPPOHeaderValidationBuffer.TextField1));
                            GPPOHeaderValidationBuffer.Insert();

                            if not PopulatePOLineBuffer(GPPOHeaderValidationBuffer."No.", GPPOLineValidationBuffer) then
                                GPPOHeaderValidationBuffer.Delete();
                        end;
                until GPPOP10100.Next() = 0;
        end;

        ExpectedPOHeaderCount := GPPOHeaderValidationBuffer.Count();

        // BC
        if PurchaseHeader.FindSet() then
            repeat
                if not BCPOHeaderValidationBuffer.Get(PurchaseHeader."No.") then begin
                    BCPOHeaderValidationBuffer."No." := PurchaseHeader."No.";
                    BCPOHeaderValidationBuffer.TextField1 := PurchaseHeader."Buy-from Vendor No.";
                    BCPOHeaderValidationBuffer.Insert();

                    // Lines
                    PurchaseLine.SetLoadFields("Document No.", "No.", Quantity, "Quantity Received");
                    PurchaseLine.SetCurrentKey("No.");
                    PurchaseLine.SetRange("Document No.", BCPOHeaderValidationBuffer."No.");
                    if PurchaseLine.FindSet() then
                        repeat
                            POLineIdTxt := CopyStr(PurchaseHeader."No." + '_' + PurchaseLine."No.", 1, MaxStrLen(POLineIdTxt));
                            BCPOLineValidationBuffer.SetRange("No.", POLineIdTxt);
                            if BCPOLineValidationBuffer.FindFirst() then begin
                                BCPOLineValidationBuffer.DecField1 := BCPOLineValidationBuffer.DecField1 + PurchaseLine.Quantity;
                                BCPOLineValidationBuffer.DecField2 := BCPOLineValidationBuffer.DecField2 + PurchaseLine."Quantity Received";
                                BCPOLineValidationBuffer.Modify();
                            end else begin
                                BCPOLineValidationBuffer."No." := POLineIdTxt;
                                BCPOLineValidationBuffer."Parent No." := PurchaseHeader."No.";
                                BCPOLineValidationBuffer.TextField1 := PurchaseLine."No.";
                                BCPOLineValidationBuffer.DecField1 := PurchaseLine.Quantity;
                                BCPOLineValidationBuffer.DecField2 := PurchaseLine."Quantity Received";
                                BCPOLineValidationBuffer.Insert();
                            end;
                        until PurchaseLine.Next() = 0;
                end;
            until PurchaseHeader.Next() = 0;

        ActualPOHeaderCount := BCPOHeaderValidationBuffer.Count();

        // Validation
        GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::PurchaseOrders, '', 'Migrated POs', Format(ExpectedPOHeaderCount), Format(ActualPOHeaderCount), (ExpectedPOHeaderCount = ActualPOHeaderCount));

        if ActualPOHeaderCount > ExpectedPOHeaderCount then
            if BCPOHeaderValidationBuffer.FindSet() then
                repeat
                    if not GPPOHeaderValidationBuffer.Get(BCPOHeaderValidationBuffer."No.") then
                        GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::PurchaseOrders, BCPOHeaderValidationBuffer."No.", 'Extra BC PO', 'expected not migrated', 'was migrated', false);
                until BCPOHeaderValidationBuffer.Next() = 0;

        GPPOHeaderValidationBuffer.Reset();
        GPPOLineValidationBuffer.Reset();
        if GPPOHeaderValidationBuffer.FindSet() then
            repeat
                if BCPOHeaderValidationBuffer.Get(GPPOHeaderValidationBuffer."No.") then begin
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::PurchaseOrders, GPPOHeaderValidationBuffer."No.", 'PO Vendor', GPPOHeaderValidationBuffer.TextField1, BCPOHeaderValidationBuffer.TextField1, (GPPOHeaderValidationBuffer.TextField1 = BCPOHeaderValidationBuffer.TextField1));

                    GPPOLineValidationBuffer.SetRange("Parent No.", GPPOHeaderValidationBuffer."No.");
                    if GPPOLineValidationBuffer.FindSet() then
                        repeat
                            if BCPOLineValidationBuffer.Get(GPPOLineValidationBuffer."No.") then begin
                                GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::PurchaseOrders, GPPOLineValidationBuffer."No.", 'PO Line Quantity', Format(GPPOLineValidationBuffer.DecField1), Format(BCPOLineValidationBuffer.DecField1), (GPPOLineValidationBuffer.DecField1 = BCPOLineValidationBuffer.DecField1));
                                GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::PurchaseOrders, GPPOLineValidationBuffer."No.", 'PO Line Received Quantity', Format(GPPOLineValidationBuffer.DecField2), Format(BCPOLineValidationBuffer.DecField2), (GPPOLineValidationBuffer.DecField2 = BCPOLineValidationBuffer.DecField2));
                            end else
                                GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::PurchaseOrders, GPPOLineValidationBuffer."No.", 'Missing PO Line', 'expected migrated', 'was not migrated', false);
                        until GPPOLineValidationBuffer.Next() = 0;
                end else
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::PurchaseOrders, GPPOHeaderValidationBuffer."No.", 'Missing PO', 'expected migrated', 'was not migrated', false);
            until GPPOHeaderValidationBuffer.Next() = 0;
    end;

    local procedure PopulatePOLineBuffer(PONumber: Text[50]; var LineBuffer: Record "GP Migration Validation Buffer"): Boolean
    var
        GPPOP10110: Record "GP POP10110";
        GPPOPReceiptApply: Record GPPOPReceiptApply;
        GPPOPReceiptApplyLineUnitCost: Record GPPOPReceiptApply;
        LineQuantityRemaining: Decimal;
        LocationCode: Code[10];
        LastLocation: Text[12];
        LastLineUnitCost: Decimal;
        LineQtyReceivedByUnitCost: Decimal;
        LineQtyInvoicedByUnitCost: Decimal;
        HasLines: Boolean;
    begin
        GPPOP10110.SetRange(PONUMBER, PONumber);
        if not GPPOP10110.FindSet() then
            exit;

        repeat
            LastLocation := '';
            LastLineUnitCost := 0;

            LineQuantityRemaining := GPPOP10110.QTYORDER - GPPOP10110.QTYCANCE;
            if LineQuantityRemaining > 0 then begin
                HasLines := true;
                GPPOPReceiptApplyLineUnitCost.SetLoadFields(TRXLOCTN, PCHRPTCT, UOFM);
                GPPOPReceiptApplyLineUnitCost.SetCurrentKey(TRXLOCTN, PCHRPTCT);
                GPPOPReceiptApplyLineUnitCost.SetRange(PONUMBER, GPPOP10110.PONUMBER);
                GPPOPReceiptApplyLineUnitCost.SetRange(POLNENUM, GPPOP10110.ORD);
                GPPOPReceiptApplyLineUnitCost.SetRange(Status, GPPOPReceiptApplyLineUnitCost.Status::Posted);
                GPPOPReceiptApplyLineUnitCost.SetFilter(POPTYPE, '1|3');
                GPPOPReceiptApplyLineUnitCost.SetFilter(QTYSHPPD, '>%1', 0);
                GPPOPReceiptApplyLineUnitCost.SetFilter(PCHRPTCT, '>%1', 0);

                if GPPOPReceiptApplyLineUnitCost.FindSet() then
                    repeat
                        if ((LastLocation <> GPPOPReceiptApplyLineUnitCost.TRXLOCTN) or (LastLineUnitCost <> GPPOPReceiptApplyLineUnitCost.PCHRPTCT)) then begin
                            LocationCode := CopyStr(GPPOPReceiptApplyLineUnitCost.TRXLOCTN, 1, MaxStrLen(LocationCode));
                            LineQtyReceivedByUnitCost := GPPOPReceiptApply.GetSumQtyShippedByUnitCost(GPPOP10110.PONUMBER, GPPOP10110.ORD, LocationCode, GPPOPReceiptApplyLineUnitCost.PCHRPTCT);
                            LineQtyInvoicedByUnitCost := GPPOPReceiptApply.GetSumQtyInvoicedByUnitCost(GPPOP10110.PONUMBER, GPPOP10110.ORD, LocationCode, GPPOPReceiptApplyLineUnitCost.PCHRPTCT);

                            if (LineQtyReceivedByUnitCost > LineQtyInvoicedByUnitCost) then
                                InsertPOLine(PONumber, GPPOP10110, LineQuantityRemaining, LineQtyReceivedByUnitCost, LineQtyInvoicedByUnitCost, LineBuffer)
                            else
                                LineQuantityRemaining := LineQuantityRemaining - LineQtyReceivedByUnitCost;

                            LastLocation := GPPOPReceiptApplyLineUnitCost.TRXLOCTN;
                            LastLineUnitCost := GPPOPReceiptApplyLineUnitCost.PCHRPTCT;
                        end;
                    until GPPOPReceiptApplyLineUnitCost.Next() = 0;

                if LineQuantityRemaining > 0 then
                    InsertPOLine(PONumber, GPPOP10110, LineQuantityRemaining, 0, 0, LineBuffer);
            end;
        until GPPOP10110.Next() = 0;

        exit(HasLines);
    end;

    local procedure InsertPOLine(PONumber: Text[50]; var GPPOP10110: Record "GP POP10110"; var LineQuantityRemaining: Decimal; QuantityReceived: Decimal; QuantityInvoiced: Decimal; var LineBuffer: Record "GP Migration Validation Buffer")
    var
        AdjustedQuantity: Decimal;
        AdjustedQuantityReceived: Decimal;
        QuantityOverReceipt: Decimal;
        POLineIdTxt: Text[50];
    begin
        AdjustedQuantityReceived := SubtractAndZeroIfNegative(QuantityReceived, QuantityInvoiced);
        if AdjustedQuantityReceived > 0 then
            AdjustedQuantity := SubtractAndZeroIfNegative(QuantityReceived, QuantityInvoiced)
        else
            AdjustedQuantity := SubtractAndZeroIfNegative(LineQuantityRemaining, QuantityInvoiced);

        QuantityOverReceipt := SubtractAndZeroIfNegative(AdjustedQuantityReceived, AdjustedQuantity);

        if QuantityOverReceipt > 0 then
            AdjustedQuantity := AdjustedQuantityReceived;

        if AdjustedQuantity > 0 then begin
            POLineIdTxt := CopyStr(PONumber + '_' + GPPOP10110.ITEMNMBR.TrimEnd(), 1, MaxStrLen(POLineIdTxt));
            LineBuffer.SetRange("No.", POLineIdTxt);
            if LineBuffer.FindFirst() then begin
                LineBuffer.DecField1 := LineBuffer.DecField1 + AdjustedQuantity;
                LineBuffer.DecField2 := LineBuffer.DecField2 + AdjustedQuantityReceived;
                LineBuffer.Modify();
            end else begin
                LineBuffer."No." := POLineIdTxt;
                LineBuffer."Parent No." := PONumber;
                LineBuffer.TextField1 := CopyStr(GPPOP10110.ITEMNMBR.TrimEnd(), 1, MaxStrLen(LineBuffer.TextField1));
                LineBuffer.DecField1 := AdjustedQuantity;
                LineBuffer.DecField2 := AdjustedQuantityReceived;
                LineBuffer.Insert();
            end;
        end;
        LineQuantityRemaining := LineQuantityRemaining - QuantityReceived;
    end;

    local procedure SubtractAndZeroIfNegative(Minuend: Decimal; Subtrahend: Decimal): Decimal
    var
        Difference: Decimal;
    begin
        Difference := Minuend - Subtrahend;

        if Difference < 0 then
            Difference := 0;

        exit(Difference);
    end;

    local procedure RunVendorMigrationValidation(var GPCompanyAdditionalSettings: Record "GP Company Additional Settings")
    var
        GPValidationBuffer: Record "GP Migration Validation Buffer";
        BCValidationBuffer: Record "GP Migration Validation Buffer";
        GPMigrationValidationEntry: Record "GP Migration Validation Entry";
        Vendor: Record Vendor;
        GPPM00200: Record "GP PM00200";
        GPPM20000: Record "GP PM20000";
        ExpectedCount: Integer;
        ActualCount: Integer;
        ShouldInclude: Boolean;
        DefaultClassName: Text[15];
        ClassName: Text[15];
        Balance: Decimal;
        IsActive: Boolean;
    begin
        DefaultClassName := 'GP';

        // GP
        if GPCompanyAdditionalSettings.GetPayablesModuleEnabled() then
            if GPPM00200.FindSet() then
                repeat
                    Clear(Balance);
                    ShouldInclude := true;
                    IsActive := (GPPM00200.VENDSTTS = 1) or (GPPM00200.VENDSTTS = 3);
                    if not GPCompanyAdditionalSettings.GetMigrateInactiveVendors() then
                        if not IsActive then
                            ShouldInclude := false;

                    if ShouldInclude then begin
                        ClassName := CopyStr(GPPM00200.VNDCLSID.TrimEnd(), 1, MaxStrLen(ClassName));
                        if ClassName = '' then
                            ClassName := DefaultClassName;

                        if not GPCompanyAdditionalSettings.GetSkipPostingVendorBatches() then begin
                            GPPM20000.SetRange(VENDORID, GPPM00200.VENDORID);
                            GPPM20000.SetRange(VOIDED, false);
                            GPPM20000.SetFilter(CURTRXAM, '<>%1', 0);
                            if GPPM20000.FindSet() then
                                repeat
                                    if GPPM20000.DOCTYPE < 4 then
                                        Balance := Balance + GPPM20000.CURTRXAM
                                    else
                                        Balance := Balance + (GPPM20000.CURTRXAM * -1);
                                until GPPM20000.Next() = 0;
                        end;

                        if not GPValidationBuffer.Get(GPPM00200.VENDORID.TrimEnd()) then begin
                            GPValidationBuffer."No." := CopyStr(GPPM00200.VENDORID.TrimEnd(), 1, MaxStrLen(GPValidationBuffer."No."));
                            GPValidationBuffer.TextField1 := CopyStr(GPPM00200.VENDNAME.TrimEnd(), 1, MaxStrLen(GPValidationBuffer.TextField1));
                            GPValidationBuffer.TextField2 := ClassName;
                            GPValidationBuffer.DecField1 := Balance;
                            GPValidationBuffer.Insert();
                        end;
                    end;
                until GPPM00200.Next() = 0;

        ExpectedCount := GPValidationBuffer.Count();

        // BC
        if Vendor.FindSet() then
            repeat
                if not BCValidationBuffer.Get(Vendor."No.") then begin
                    Vendor.CalcFields(Balance);

                    BCValidationBuffer."No." := Vendor."No.";
                    BCValidationBuffer.TextField1 := Vendor.Name;
                    BCValidationBuffer.TextField2 := Vendor."Vendor Posting Group";
                    BCValidationBuffer.DecField1 := Vendor.Balance;
                    BCValidationBuffer.Insert();
                end;
            until Vendor.Next() = 0;

        ActualCount := BCValidationBuffer.Count();

        // Validation
        GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Vendors, '', 'Migrated Vendors', Format(ExpectedCount), Format(ActualCount), (ExpectedCount = ActualCount));

        if ActualCount > ExpectedCount then
            if BCValidationBuffer.FindSet() then
                repeat
                    if not GPValidationBuffer.Get(BCValidationBuffer."No.") then
                        GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Vendors, BCValidationBuffer."No.", 'Extra BC Vendor', 'expected not migrated', 'was migrated', false);
                until BCValidationBuffer.Next() = 0;

        GPValidationBuffer.Reset();
        if GPValidationBuffer.FindSet() then
            repeat
                if BCValidationBuffer.Get(GPValidationBuffer."No.") then begin
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Vendors, GPValidationBuffer."No.", 'Vendor Name', GPValidationBuffer.TextField1, BCValidationBuffer.TextField1, (GPValidationBuffer.TextField1 = BCValidationBuffer.TextField1));
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Vendors, GPValidationBuffer."No.", 'Vendor Posting Group', GPValidationBuffer.TextField2, BCValidationBuffer.TextField2, (GPValidationBuffer.TextField2 = BCValidationBuffer.TextField2));
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Vendors, GPValidationBuffer."No.", 'Vendor Balance', Format(GPValidationBuffer.DecField1), Format(BCValidationBuffer.DecField1), (GPValidationBuffer.DecField1 = BCValidationBuffer.DecField1));
                end else begin
                    if GPValidationBuffer."No." = '' then
                        GPValidationBuffer."No." := ' !BLANK!';
                    GPMigrationValidationEntry.AddEntry("GP Migration Validation Area"::Vendors, GPValidationBuffer."No.", 'Missing Vendor', 'expected migrated', 'was not migrated', false);
                end;
            until GPValidationBuffer.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGPCompanyMigrationValidationCompleted(CompanyNameTxt: Text[50])
    begin
    end;
}