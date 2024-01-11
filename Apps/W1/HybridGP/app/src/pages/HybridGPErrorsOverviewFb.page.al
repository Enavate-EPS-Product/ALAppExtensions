namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;

page 40132 "Hybrid GP Errors Overview Fb"
{
    Caption = 'GP Migration Overview';
    PageType = CardPart;
    InsertAllowed = false;
    DelayedInsert = false;
    ModifyAllowed = false;
    SourceTable = "GP Migration Error Overview";

    layout
    {
        area(Content)
        {
            cuegroup(Statistics)
            {
                ShowCaption = false;

                field("Migration Errors"; MigrationErrorCount)
                {
                    Caption = 'Migration Errors';
                    ApplicationArea = Basic, Suite;
                    Style = Unfavorable;
                    StyleExpr = (MigrationErrorCount > 0);
                    ToolTip = 'Indicates the number of errors that occurred during the migration.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"GP Migration Error Overview");
                    end;
                }
            }
            cuegroup(FailedCompanies)
            {
                ShowCaption = false;

                field("Failed Companies"; FailedCompanyCount)
                {
                    Caption = 'Failed Companies';
                    ApplicationArea = Basic, Suite;
                    Style = Unfavorable;
                    StyleExpr = (FailedCompanyCount > 0);
                    ToolTip = 'Indicates the number of companies that failed to upgrade.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Hybrid GP Failed Companies");
                    end;
                }
            }
            cuegroup(FailedValidation)
            {
                ShowCaption = false;

                field("Failed Validation"; FailedValidationCount)
                {
                    Caption = 'Failed Validation';
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = (FailedValidationCount > 0);
                    ToolTip = 'Indicates the number of failed migration tests.';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"GP Migration Validation");
                    end;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        MigrationErrorCount := Rec.Count();
    end;

    trigger OnAfterGetCurrRecord()
    var
        HybridCompanyUpgrade: Record "Hybrid Company Status";
        GPMigrationValidationEntry: Record "GP Migration Validation Entry";
    begin
        MigrationErrorCount := Rec.Count();
        HybridCompanyUpgrade.SetRange("Upgrade Status", HybridCompanyUpgrade."Upgrade Status"::Failed);
        FailedCompanyCount := HybridCompanyUpgrade.Count();
        
        GPMigrationValidationEntry.SetRange("Validation Passed", false);
        FailedValidationCount := GPMigrationValidationEntry.Count();
    end;

    var
        MigrationErrorCount: Integer;
        FailedCompanyCount: Integer;
        FailedValidationCount: Integer;
}
