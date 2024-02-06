namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;

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
            group(General)
            {
                Caption = 'General';
                field(KeepUserPermissions; KeepUserPermissions)
                {
                    ApplicationArea = All;
                    Caption = 'Keep User Permissions';
                    ToolTip = 'Specify if the permissions should be removed from users during upgrades.';

                    trigger OnValidate()
                    var
                        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
                        HybridGPWizard: Codeunit "Hybrid GP Wizard";
                    begin
                        IntelligentCloudSetup.SetRange("Product ID", HybridGPWizard.ProductId());
                        if IntelligentCloudSetup.FindFirst() then begin
                            IntelligentCloudSetup.Validate("Keep User Permissions", KeepUserPermissions);
                            IntelligentCloudSetup.Modify();
                        end;
                    end;
                }
            }

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
        }
    }

    trigger OnOpenPage()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        Rec.GetonInsertGPUpgradeSettings(Rec);

        IntelligentCloudSetup.SetRange("Product ID", HybridGPWizard.ProductId());
        if IntelligentCloudSetup.FindFirst() then
            KeepUserPermissions := IntelligentCloudSetup."Keep User Permissions";
    end;

    var
        KeepUserPermissions: Boolean;
}