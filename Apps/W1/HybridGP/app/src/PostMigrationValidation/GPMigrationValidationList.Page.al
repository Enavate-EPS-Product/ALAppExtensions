namespace Microsoft.DataMigration.GP;

page 40135 "GP Migration Validation List"
{
    ApplicationArea = All;
    UsageCategory = None;
    Caption = 'GP Migration Validation List';
    PageType = ListPart;
    SourceTable = "GP Migration Validation";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                }
                field("Status"; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field("Score"; Rec.CalculateScore())
                {
                    Caption = 'Score %';
                    ToolTip = 'Specifies the percent of passed tests for the Company.';
                }
                field("Failed Tests Count"; Rec."Failed Tests Count")
                {
                    ToolTip = 'Specifies the value of the Failed Tests Count field.';
                }
                field("Passed Tests Count"; Rec."Passed Tests Count")
                {
                    ToolTip = 'Specifies the value of the Passed Tests Count field.';
                }
                field("Validation Date"; Rec."Validation Date")
                {
                    ToolTip = 'Specifies the value of the Validation Date field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewDetails)
            {
                ApplicationArea = All;
                Caption = 'View Details';
                ToolTip = 'View all validation tests.';
                Image = Find;
                ShortcutKey = Return;

                trigger OnAction()
                var
                    GPCompanyValidationList: Page "GP Company Validation List";
                begin
                    GPCompanyValidationList.SetCompany(Rec.Name);
                    GPCompanyValidationList.Run();
                end;
            }
        }
    }
}