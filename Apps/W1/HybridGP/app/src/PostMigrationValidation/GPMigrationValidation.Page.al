namespace Microsoft.DataMigration.GP;

page 40133 "GP Migration Validation"
{
    Caption = 'GP Migration Validation';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    AdditionalSearchTerms = 'test, validation';
    AccessByPermission = page "GP Migration Validation" = X;

    layout
    {
        area(content)
        {
            group(ResultList)
            {
                Caption = 'Validation Results';

                part("GP Migration Validation List"; "GP Migration Validation List")
                {
                    Caption = 'Companies that have had validation run.';
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group(TestDescriptions)
            {
                Caption = 'Tests performed';

                field("TestDescriptionText"; TestDescriptions)
                {
                    Caption = 'Overview of the current tests perfomed';
                    ToolTip = 'Indicates a brief description of the tests performed in each area.';
                    ApplicationArea = All;
                    ExtendedDatatype = RichContent;
                    MultiLine = true;
                    Editable = false;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        GPMigrationValidationMgmt: Codeunit "GP Migration Validation Mgmt.";
    begin
        TestDescriptions := GPMigrationValidationMgmt.GetTestDescriptions();
    end;

    var
        TestDescriptions: Text;
}