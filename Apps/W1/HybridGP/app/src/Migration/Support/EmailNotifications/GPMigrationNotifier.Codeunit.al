codeunit 40109 "GP Migration Notifier"
{
    procedure SendMigrationNotification(MigrationEventType: Enum "Migration Event Type")
    begin
        SendMigrationNotification(MigrationEventType, '');
    end;

    procedure SendMigrationNotification(MigrationEventType: Enum "Migration Event Type"; AdditionalText: Text)
    var
        GPMigrationEmailAddress: Record "GP Migration Email Address";
        HybridCompanyStatus: Record "Hybrid Company Status";
        EmailMessage: Codeunit "Email Message";
        EnvironmentInformation: Codeunit "Environment Information";
        TenantGuid: Text;
        EnvironmentName: Text;
        RecipientList: List of [Text];
        RecipientCsv: Text;
        Subject: Text;
        Body: TextBuilder;
    begin
        if GPMigrationEmailAddress.FindSet() then
            repeat
                RecipientList.Add(GPMigrationEmailAddress."Email Address");

                if RecipientCsv <> '' then
                    RecipientCsv := RecipientCsv + ';';

                RecipientCsv := RecipientCsv + GPMigrationEmailAddress."Email Address";
            until GPMigrationEmailAddress.Next() = 0;

        if RecipientList.Count() > 0 then begin
            TenantGuid := TenantId();
            EnvironmentName := EnvironmentInformation.GetEnvironmentName();
            Subject := Text.StrSubstNo(SubjectLbl, EnvironmentName, MigrationEventType);
            Body.Append('<div>');
            Body.Append('<p><a href="' + System.GetUrl(ClientType::Web) + '">Go to ' + EnvironmentName + '</a></p>');
            Body.Append('<p><b>Tenant Id:</b> ' + TenantGuid + '</p>');
            Body.Append('<p><b>Environment:</b> ' + EnvironmentName + '</p>');
            Body.Append('<p><b>Company:</b> ' + CompanyName() + '</p>');
            Body.Append('<p><b>Date:</b> ' + Format(System.CurrentDateTime()) + '</p>');
            Body.Append('<p><b>Status:</b> ' + Format(MigrationEventType) + '</p>');

            if HybridCompanyStatus.FindSet() then begin
                Body.Append('<h3>Per company status</h3>');
                Body.Append('<ul>');
                repeat
                    Body.Append('<li>' + HybridCompanyStatus.Name + ' (' + Format(HybridCompanyStatus."Upgrade Status") + ')' + '</li>');
                until HybridCompanyStatus.Next() = 0;
                Body.Append('</ul>');
            end;

            if AdditionalText <> '' then begin
                Body.Append('<h3>Additional Information</h3>');
                Body.Append('<p>' + AdditionalText + '</p>');
            end;
            Body.Append('</div>');

            EmailMessage.Create(RecipientCsv, Subject, Body.ToText(), true);
            Send(EmailMessage, RecipientList);
        end;
    end;

    procedure Send(EmailMessage: Codeunit "Email Message"; RecipientList: List of [Text])
    var
        EmailOutlookAPIClient: Codeunit "Email - Outlook API Client";
        EmailOAuthClient: Codeunit "Email - OAuth Client";

        [NonDebuggable]
        AccessToken: Text;
    begin
        EmailOAuthClient.GetAccessToken(AccessToken);
        EmailOutlookAPIClient.SendEmail(AccessToken, EmailMessageToJson(EmailMessage, RecipientList));
    end;

    local procedure EmailMessageToJson(var EmailMessage: Codeunit "Email Message"; RecipientList: List of [Text]): JsonObject
    var
        MessageJson: JsonObject;
        MessageText: Text;
        EmailBody: JsonObject;
        EmailMessageJson: JsonObject;
    begin
        EmailMessageJson := CreateEmailMessageJson();

        if EmailMessage.IsBodyHTMLFormatted() then
            EmailBody.Add('contentType', 'HTML')
        else
            EmailBody.Add('contentType', 'text');

        EmailBody.Add('content', EmailMessage.GetBody());

        EmailMessageJson.Add('subject', EmailMessage.GetSubject());
        EmailMessageJson.Add('body', EmailBody);
        EmailMessageJson.Add('toRecipients', GetEmailRecipients(RecipientList));

        EmailMessageJson.WriteTo(MessageText);

        EmailMessageJson.WriteTo(MessageText);
        MessageJson.Add('message', EmailMessageJson);
        MessageJson.Add('saveToSentItems', true);

        exit(MessageJson);
    end;

    local procedure GetEmailRecipients(RecipientList: List of [Text]): JsonArray
    var
        Address: JsonObject;
        RecipientsJson: JsonArray;
        EmailAddress: JsonObject;
        Value: Text;
    begin
        foreach value in RecipientList do begin
            clear(Address);
            clear(EmailAddress);
            Address.Add('address', value);
            EmailAddress.Add('emailAddress', Address);
            RecipientsJson.Add(EmailAddress);
        end;
        exit(RecipientsJson);
    end;

    local procedure CreateEmailMessageJson(): JsonObject
    var
        FromEmailAddress: Text[250];
        EmailMessageJson: JsonObject;
        EmailAddressJson: JsonObject;
        FromJson: JsonObject;
    begin
        FromEmailAddress := GetCurrentUserEmailAddress();
        if FromEmailAddress = '' then
            Error('From email address cannot be empty!');

        EmailAddressJson.Add('address', FromEmailAddress);
        EmailAddressJson.Add('name', 'User');

        FromJson.Add('emailAddress', EmailAddressJson);
        EmailMessageJson.Add('from', FromJson);

        exit(EmailMessageJson);
    end;

    local procedure GetCurrentUserEmailAddress(): Text[250]
    var
        User: Record User;
    begin
        if User.Get(Database.UserSecurityId()) then
            exit(User."Contact Email");

        exit('');
    end;

    var
        SubjectLbl: Label '%1 migration status update: %2', Locked = true;
}