namespace Microsoft.DataMigration.GP;

table 41008 "GP Migration Validation Buffer"
{
    Caption = 'GP Migration Validation Buffer';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "No."; Text[50])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2; TextField1; Text[250])
        {
            Caption = 'TextField1';
        }
        field(3; TextField2; Text[250])
        {
            Caption = 'TextField2';
        }
        field(4; TextField3; Text[250])
        {
            Caption = 'TextField3';
        }
        field(5; IntField1; Integer)
        {
            Caption = 'IntField1';
        }
        field(6; IntField2; Integer)
        {
            Caption = 'IntField2';
        }
        field(7; IntField3; Integer)
        {
            Caption = 'IntField3';
        }
        field(8; BoolField1; Boolean)
        {
            Caption = 'BoolField1';
        }
        field(9; BoolField2; Boolean)
        {
            Caption = 'BoolField2';
        }
        field(10; BoolField3; Boolean)
        {
            Caption = 'BoolField3';
        }
        field(11; DecField1; Decimal)
        {
            Caption = 'DecField1';
        }
        field(12; DecField2; Decimal)
        {
            Caption = 'DecField2';
        }
        field(13; DecField3; Decimal)
        {
            Caption = 'DecField3';
        }
        field(14; DecField4; Decimal)
        {
            Caption = 'DecField4';
        }
        field(15; "Parent No."; Text[50])
        {
            Caption = 'Parent No.';
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Parent No.")
        {
        }
    }

    procedure Clear()
    var
        GPMigrationValidationBuffer: Record "GP Migration Validation Buffer";
    begin
        if not GPMigrationValidationBuffer.IsEmpty() then
            GPMigrationValidationBuffer.DeleteAll();
    end;
}