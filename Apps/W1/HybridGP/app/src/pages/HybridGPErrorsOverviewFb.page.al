namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;

page 40132 "Hybrid GP Errors Overview Fb"
{
    Caption = 'GP Upgrade Errors';
    PageType = CardPart;

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
            cuegroup(FailedBatches)
            {
                ShowCaption = false;

                field("Failed Batches"; FailedBatchCount)
                {
                    Caption = 'Failed Batches';
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = (FailedBatchCount > 0);
                    ToolTip = 'Indicates the total number of failed batches, for all migrated companies.';

                    trigger OnDrillDown()
                    begin
                        Message(FailedBatchMsg);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        GPMigrationErrorOverview: Record "GP Migration Error Overview";
    begin
        MigrationErrorCount := GPMigrationErrorOverview.Count();
    end;

    trigger OnAfterGetCurrRecord()
    var
        GPMigrationErrorOverview: Record "GP Migration Error Overview";
        HybridCompanyStatus: Record "Hybrid Company Status";
        HelperFunctions: Codeunit "Helper Functions";
        TotalGLBatchCount: Integer;
        TotalItemBatchCount: Integer;
    begin
        FailedBatchCount := 0;
        FailedBatchMsg := '';

        MigrationErrorCount := GPMigrationErrorOverview.Count();
        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Failed);
        FailedCompanyCount := HybridCompanyStatus.Count();

        HybridCompanyStatus.Reset();
        HybridCompanyStatus.SetRange("Upgrade Status", HybridCompanyStatus."Upgrade Status"::Completed);
        if HybridCompanyStatus.FindSet() then
            repeat
                TotalGLBatchCount := 0;
                TotalItemBatchCount := 0;

                HelperFunctions.GetUnpostedBatchCountForCompany(HybridCompanyStatus.Name, TotalGLBatchCount, TotalItemBatchCount);
                FailedBatchCount := FailedBatchCount + TotalGLBatchCount + TotalItemBatchCount;
                if (TotalGLBatchCount > 0) or (TotalItemBatchCount > 0) then
                    FailedBatchMsg := FailedBatchMsg + HybridCompanyStatus.Name + ': GL batches failed: ' + Format(TotalGLBatchCount) + ', Item batches failed: ' + Format(TotalItemBatchCount) + '\';
            until HybridCompanyStatus.Next() = 0;

        if FailedBatchCount = 0 then
            FailedBatchMsg := 'No failed batches';
    end;

    var
        MigrationErrorCount: Integer;
        FailedCompanyCount: Integer;
        FailedBatchCount: Integer;
        FailedBatchMsg: Text;
}
