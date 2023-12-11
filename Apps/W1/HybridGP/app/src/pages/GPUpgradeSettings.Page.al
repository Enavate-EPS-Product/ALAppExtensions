namespace Microsoft.DataMigration.GP;

page 40043 "GP Upgrade Settings"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "GP Upgrade Settings";

    layout
    {
        area(Content)
        {
            group(ErrorHandling)
            {
                Caption = 'Error Handling';
                field(CollectAllErrors; Rec."Collect All Errors")
                {
                    ApplicationArea = All;
                    Caption = 'Attempt to upgrade all companies';
                    ToolTip = 'Specifies whether to stop upgrade on first company failure or to attempt to upgrade all companies.';
                }
                field(LogAllRecordChanges; Rec."Log All Record Changes")
                {
                    ApplicationArea = All;
                    Caption = 'Log all record changes';
                    ToolTip = 'Specifies whether to log all record changes during upgrade. This method will make the data upgrade slower.';
                }
            }

            group(OneStepUpgradeGroup)
            {
                Caption = 'One Step Upgrade';
                field(OneStepUpgrade; Rec."One Step Upgrade")
                {
                    ApplicationArea = All;
                    Caption = 'Run upgrade after replication';
                    ToolTip = 'Specifies whether to run upgrade immediatelly after replication, without manually invoking the data upgrade action.';
                }
                field(OneStepUpgradeDelay; Rec."One Step Upgrade Delay")
                {
                    ApplicationArea = All;
                    Caption = 'Run upgrade after replication delay';
                    ToolTip = 'Specifies whether to log all record changes during upgrade. This method will make the data upgrade slower.';
                }
            }

            group(HistoricalSnapshot)
            {
                Caption = 'Historical Snapshot';
                field(SnapshotMode; Rec."Snapshot Mode")
                {
                    ApplicationArea = All;
                    Caption = 'Snapshot Mode';
                    ToolTip = 'Specifies whether to schedule the Historical Snapshot as a Session or Job Queue.';
                }
                field(SnapshotTimeout; Rec."Snapshot Timeout")
                {
                    ApplicationArea = All;
                    Caption = 'Snapshot Timeout';
                    ToolTip = 'Specifies the timeout duration of the Historical Snapshot Session or Job.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetonInsertGPUpgradeSettings(Rec);
    end;
}