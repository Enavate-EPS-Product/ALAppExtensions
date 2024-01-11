namespace Microsoft.DataMigration.GP;

page 40134 "GP Company Validation List"
{
    ApplicationArea = All;
    UsageCategory = None;
    Caption = 'GP Company Validation Entries';
    PageType = List;
    SourceTable = "GP Migration Validation Entry";
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Validation Area"; Rec."Validation Area")
                {
                    ToolTip = 'Specifies the value of the Validation Area field.';
                }
                field("Validation Passed"; Rec."Validation Passed")
                {
                    ToolTip = 'Specifies the value of the Validation Passed field.';
                }
                field(Context; Rec.Context)
                {
                    ToolTip = 'Specifies the value of the Context field.';
                }
                field("Test Description"; Rec."Test Description")
                {
                    ToolTip = 'Specifies the value of the Test Description field.';
                }
                field(Expected; Rec.Expected)
                {
                    ToolTip = 'Specifies the value of the Expected field.';
                }
                field(Actual; Rec.Actual)
                {
                    ToolTip = 'Specifies the value of the Actual field.';
                }
            }
        }
    }

    procedure SetCompany(CompanyTxt: Text)
    begin
        Rec.SetRange(Name, CompanyTxt);
        Rec.SetRange("Validation Passed", false);
    end;
}