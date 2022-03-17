codeunit 139700 "GP Checkbook Tests"
{
    // [FEATURE] [GP Data Migration]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        GPCheckbookMSTRTable: Record "GP Checkbook MSTR";
        GPCheckbookTransactionsTable: Record "GP Checkbook Transactions";
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
        BankAccount: Record "Bank Account";
        InvalidBankAccountMsg: Label '%1 should not have been created.', Comment = '%1 - bank account no.', Locked = true;
        MissingBankAccountMsg: Label '%1 should have been created.', Comment = '%1 - bank account no.', Locked = true;
        MyBankStr1: Label 'MyBank01', Comment = 'Bank name', Locked = true;
        MyBankStr2: Label 'MyBank02', Comment = 'Bank name', Locked = true;
        MyBankStr3: Label 'MyBank03', Comment = 'Bank name', Locked = true;
        MyBankStr4: Label 'MyBank04', Comment = 'Bank name', Locked = true;
        MyBankStr5: Label 'MyBank05', Comment = 'Bank name', Locked = true;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPCheckbookMigrationIncludeInactive()
    var
        BankAccount: Record "Bank Account";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        // [SCENARIO] CheckBooks are migrated from GP
        // [GIVEN] There are no records in the BankAcount table
        ClearTables();

        // [GIVEN] Some records are created in the staging table
        CreateCheckbookData();

        // [GIVEN] Inactive checkbooks are to be migrated
        ConfigureMigrationSettings(true);

        // [WHEN] Checkbook migration code is called
        Migrate();

        // [THEN] Bank Accounts are created
        Assert.RecordCount(BankAccount, 5);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPCheckbookMigrationExcludeInactive()
    var
        BankAccount: Record "Bank Account";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        // [SCENARIO] CheckBooks are migrated from GP
        // [GIVEN] There are no records in the BankAcount table
        ClearTables();

        // [GIVEN] Some records are created in the staging table
        CreateCheckbookData();

        // [GIVEN] Inactive checkbooks are NOT to be migrated
        ConfigureMigrationSettings(false);

        // [WHEN] Checkbook migration code is called
        Migrate();
        HelperFunctions.PostGLTransactions();

        // [THEN] Active Bank Accounts are created
        Assert.RecordCount(BankAccount, 3);

        // [THEN] Active Bank Accounts are created with correct settings
        BankAccount.SetRange("No.", MyBankStr1);
        Assert.IsFalse(BankAccount.FindFirst(), StrSubstNo(InvalidBankAccountMsg, MyBankStr1));

        BankAccount.SetRange("No.", MyBankStr2);
        Assert.IsTrue(BankAccount.FindFirst(), StrSubstNo(MissingBankAccountMsg, MyBankStr2));

        BankAccount.SetRange("No.", MyBankStr3);
        Assert.IsFalse(BankAccount.FindFirst(), StrSubstNo(InvalidBankAccountMsg, MyBankStr3));

        BankAccount.SetRange("No.", MyBankStr4);
        Assert.IsTrue(BankAccount.FindFirst(), StrSubstNo(MissingBankAccountMsg, MyBankStr4));

        BankAccount.SetRange("No.", MyBankStr5);
        Assert.IsTrue(BankAccount.FindFirst(), StrSubstNo(MissingBankAccountMsg, MyBankStr5));
    end;

    local procedure ClearTables()
    begin
        BankAccount.DeleteAll();
        BankAccountPostingGroup.DeleteAll();
        GPCheckbookMSTRTable.DeleteAll();
        GPCompanyMigrationSettings.DeleteAll();
    end;

    local procedure Migrate()
    begin
        GPCheckbookMSTRTable.MoveStagingData();
    end;

    local procedure ConfigureMigrationSettings(MigrateInactive: Boolean)
    begin
        GPCompanyMigrationSettings.Init();
        GPCompanyMigrationSettings.Name := 'Setup';
        GPCompanyMigrationSettings."Migrate Inactive Checkbooks" := MigrateInactive;
        GPCompanyMigrationSettings.Insert(true);
    end;

    local procedure CreateCheckbookData()
    begin
        GPCheckbookMSTRTable.Init();
        GPCheckbookMSTRTable.CHEKBKID := MyBankStr1;
        GPCheckbookMSTRTable.INACTIVE := true;
        GPCheckbookMSTRTable.Insert(true);

        GPCheckbookMSTRTable.Reset();
        GPCheckbookMSTRTable.Init();
        GPCheckbookMSTRTable.CHEKBKID := MyBankStr2;
        GPCheckbookMSTRTable.INACTIVE := false;
        GPCheckbookMSTRTable.Insert(true);

        GPCheckbookMSTRTable.Reset();
        GPCheckbookMSTRTable.Init();
        GPCheckbookMSTRTable.CHEKBKID := MyBankStr3;
        GPCheckbookMSTRTable.INACTIVE := true;
        GPCheckbookMSTRTable.Insert(true);

        GPCheckbookMSTRTable.Reset();
        GPCheckbookMSTRTable.Init();
        GPCheckbookMSTRTable.CHEKBKID := MyBankStr4;
        GPCheckbookMSTRTable.INACTIVE := false;
        GPCheckbookMSTRTable.Insert(true);

        GPCheckbookMSTRTable.Reset();
        GPCheckbookMSTRTable.Init();
        GPCheckbookMSTRTable.CHEKBKID := MyBankStr5;
        GPCheckbookMSTRTable.INACTIVE := false;
        GPCheckbookMSTRTable.Insert(true);

        // Transactions
        GPCheckbookTransactionsTable.Init();
        GPCheckbookTransactionsTable.CMRECNUM := 497.00;
        GPCheckbookTransactionsTable.CHEKBKID := MyBankStr1;
        GPCheckbookTransactionsTable.CMTrxType := 3;
        GPCheckbookTransactionsTable.TRXDATE := 20230801D;
        GPCheckbookTransactionsTable.TRXAMNT := -395.59;
        GPCheckbookTransactionsTable.Insert(true);

    end;
}