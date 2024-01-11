namespace Microsoft.DataMigration.GP;

table 41006 "GP Migration Validation"
{
    Caption = 'GP Migration Validation';
    DataClassification = SystemMetadata;
    DataPerCompany = false;

    fields
    {
        field(1; Name; Text[50])
        {
            Caption = 'Name';
        }
        field(2; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = "Not Ran","Pending","Completed";
        }
        field(3; "Passed Tests Count"; Integer)
        {
            Caption = 'Passed Tests Count';
            FieldClass = FlowField;

            CalcFormula = count("GP Migration Validation Entry" where(Name = field(Name),
                                                                      "Validation Passed" = const(true)));
        }
        field(4; "Failed Tests Count"; Integer)
        {
            Caption = 'Failed Tests Count';
            FieldClass = FlowField;

            CalcFormula = count("GP Migration Validation Entry" where(Name = field(Name),
                                                                      "Validation Passed" = const(false)));
        }
        field(5; "Validation Date"; DateTime)
        {
            Caption = 'Validation Date';
        }
    }
    keys
    {
        key(PK; Name)
        {
            Clustered = true;
        }
    }

    procedure CalculateScore(): Decimal
    var
        TotalTestsCount: Integer;
    begin
        if not (Rec.Status = Rec.Status::Completed) then
            exit;

        Rec.CalcFields("Passed Tests Count", "Failed Tests Count");

        TotalTestsCount := Rec."Passed Tests Count" + Rec."Failed Tests Count";

        if TotalTestsCount = 0 then
            exit;

        exit(Rec."Passed Tests Count" / TotalTestsCount * 100);
    end;
}