table 41006 "GP Migration Email Address"
{
    Caption = 'GP Migration Email Address';
    DataClassification = CustomerContent;
    DataPerCompany = false;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(2; "Email Address"; Text[250])
        {
            Caption = 'Email Address';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                EmailAccount: Codeunit "Email Account";
            begin
                if not EmailAccount.ValidateEmailAddress(Rec."Email Address") then
                    FieldError("Email Address", 'The email address is not valid.');
            end;
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}