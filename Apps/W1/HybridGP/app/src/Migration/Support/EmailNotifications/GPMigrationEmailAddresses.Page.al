page 44103 "GP Migration Email Addresses"
{
    ApplicationArea = All;
    Caption = 'GP Migration Email Addresses';
    PageType = List;
    SourceTable = "GP Migration Email Address";
    UsageCategory = Administration;
    InsertAllowed = true;
    DeleteAllowed = true;
    ModifyAllowed = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Email Address"; Rec."Email Address")
                {
                    ToolTip = 'Specify the Email Address for migration notifications.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(TestEmail)
            {
                Caption = 'Test Notification';
                ToolTip = 'Test Notification';
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = Email;

                trigger OnAction()
                var
                    GPMigrationEmailAddress: Record "GP Migration Email Address";
                    GPMigrationNotifier: Codeunit "GP Migration Notifier";
                begin
                    if GPMigrationEmailAddress.IsEmpty() then begin
                        Message('No email addresses to send the notification to.');
                        exit;
                    end;

                    GPMigrationNotifier.SendMigrationNotification("Migration Event Type"::"Test Notification");
                    Message('Test sent');
                end;
            }
        }
    }
}