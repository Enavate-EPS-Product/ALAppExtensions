pageextension 4015 "Intelligent Cloud Extension" extends "Intelligent Cloud Management"
{
    layout
    {
        addlast(FactBoxes)
        {
            part("Show Errors"; "Hybrid GP Errors Factbox")
            {
                ApplicationArea = Basic, Suite;
                Visible = FactBoxesVisible;
            }
            part("Show Detail Snapshot Errors"; "Hist. Migration Status Factbox")
            {
                ApplicationArea = Basic, Suite;
                Visible = FactBoxesVisible;
            }
        }
    }

    actions
    {
        addafter(RunReplicationNow)
        {
            action(ConfigureGPMigration)
            {
                Enabled = HasCompletedSetupWizard;
                ApplicationArea = Basic, Suite;
                Caption = 'Configure GP Migration';
                ToolTip = 'Configure migration settings for GP.';
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Setup;

                trigger OnAction()
                var
                    GPMigrationConfiguration: Page "GP Migration Configuration";
                begin
                    GPMigrationConfiguration.ShouldShowManagementPromptOnClose(false);
                    GPMigrationConfiguration.Run();
                end;
            }

            action(RunHistoricalMigration)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Run GP Detail Snapshot';
                ToolTip = 'Start the migration of GP historical transactions based on your company settings.';
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Process;

                trigger OnAction()
                var
                    HybridCloudManagement: Codeunit "Hybrid Cloud Management";
                    HistMigrationStatusMgmt: Codeunit "Hist. Migration Status Mgmt.";
                begin
                    if not (HistMigrationStatusMgmt.GetCurrentStatus() = "Hist. Migration Step Type"::"Not Started") then
                        if Confirm(RerunAllQst) then
                            HistMigrationStatusMgmt.ResetAll();

                    HybridCloudManagement.CreateAndScheduleBackgroundJob(Codeunit::"GP Populate Hist. Tables", 'Migrate GP Historical Snapshot');
                    Message('The GP detail snapshot job is running.');
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        HybridCompany: Record "Hybrid Company";
        HybridGPWizard: Codeunit "Hybrid GP Wizard";
    begin
        if IntelligentCloudSetup.Get() then
            FactBoxesVisible := IntelligentCloudSetup."Product ID" = HybridGPWizard.ProductId();

        HybridCompany.SetRange(Replicate, true);
        HasCompletedSetupWizard := not HybridCompany.IsEmpty();
    end;

    var
        FactBoxesVisible: Boolean;
        HasCompletedSetupWizard: Boolean;
        RerunAllQst: Label 'Do you want to rerun the snapshot for all transaction types? This will clear out any previous run attempts.';
}