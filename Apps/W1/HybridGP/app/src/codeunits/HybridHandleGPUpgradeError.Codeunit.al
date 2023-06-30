codeunit 40020 "Hybrid Handle GP Upgrade Error"
{
    TableNo = "Hybrid Replication Summary";

    trigger OnRun()
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
        GPMigrationNotifier: Codeunit "GP Migration Notifier";
        FailureMessageOutStream: OutStream;
        ErrorText: Text;
    begin
        HybridCompanyStatus.Get(CompanyName);
        HybridCompanyStatus."Upgrade Status" := HybridCompanyStatus."Upgrade Status"::Failed;
        HybridCompanyStatus."Upgrade Failure Message".CreateOutStream(FailureMessageOutStream);

        ErrorText := GetLastErrorText();
        FailureMessageOutStream.Write(ErrorText);
        HybridCompanyStatus.Modify();
        Commit();

        Rec.Find();
        Rec.Status := Rec.Status::UpgradeFailed;
        Rec.Modify();

        GPMigrationNotifier.SendMigrationNotification("Migration Event Type"::"Migration Failed", ErrorText);
    end;
}