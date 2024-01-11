namespace Microsoft.DataMigration.GP;

table 41007 "GP Migration Validation Entry"
{
    Caption = 'GP Migration Validation Entry';
    DataClassification = CustomerContent;
    DataPerCompany = false;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = SystemMetadata;
        }
        field(3; "Validation Area"; enum "GP Migration Validation Area")
        {
            Caption = 'Validation Area';
            DataClassification = SystemMetadata;
        }
        field(4; Context; Text[75])
        {
            Caption = 'Context';
        }
        field(5; "Test Description"; Text[75])
        {
            Caption = 'Test Description';
            DataClassification = SystemMetadata;
        }
        field(6; Expected; Text[250])
        {
            Caption = 'Expected';
        }
        field(7; Actual; Text[250])
        {
            Caption = 'Actual';
        }
        field(8; "Validation Passed"; Boolean)
        {
            Caption = 'Validation Passed';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
        key(Key2; Name, "Validation Area")
        {
            IncludedFields = "Validation Passed";
        }
        key(Key3; Name, "Validation Passed")
        {
            IncludedFields = "Validation Area";
        }
    }

    procedure AddEntry(EntryArea: enum "GP Migration Validation Area"; EntryContext: Text[75]; EntryDescription: Text[75]; EntryExpected: Text[250]; EntryActual: Text[250]; EntryPassed: Boolean)
    var
        GPMigrationValidationEntry: Record "GP Migration Validation Entry";
    begin
        GPMigrationValidationEntry.Name := CopyStr(CompanyName(), 1, MaxStrLen(GPMigrationValidationEntry.Name));
        GPMigrationValidationEntry."Validation Area" := EntryArea;
        GPMigrationValidationEntry.Context := EntryContext;
        GPMigrationValidationEntry."Test Description" := EntryDescription;
        GPMigrationValidationEntry.Expected := EntryExpected;
        GPMigrationValidationEntry.Actual := EntryActual;
        GPMigrationValidationEntry."Validation Passed" := EntryPassed;
        GPMigrationValidationEntry.Insert();
    end;
}