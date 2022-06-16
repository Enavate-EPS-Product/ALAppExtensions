table 40105 "GP Company Additional Settings"
{
    ReplicateData = false;
    DataPerCompany = false;
    Extensible = false;

    fields
    {
        field(1; Name; Text[30])
        {
            TableRelation = "Hybrid Company".Name;
            DataClassification = OrganizationIdentifiableInformation;
        }

        field(10; "Migrate Inactive Checkbooks"; Boolean)
        {
            InitValue = true;
            DataClassification = SystemMetadata;
        }
        field(13; "Migrate Item Classes"; Boolean)
        {
            InitValue = true;
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; Name)
        {
            Clustered = true;
        }
    }

    procedure GetMigrateInactiveCheckbooks(): Boolean
    var
        MigrateInactiveCheckbooks: Boolean;
    begin
        MigrateInactiveCheckbooks := true;
        if Rec.Get(CompanyName()) then
            MigrateInactiveCheckbooks := Rec."Migrate Inactive Checkbooks";

        exit(MigrateInactiveCheckbooks);
    end;

    procedure GetMigrateItemClasses(): Boolean
    var
        MigrateItemClasses: Boolean;
    begin
        MigrateItemClasses := true;
        if Rec.Get(CompanyName()) then
            MigrateItemClasses := Rec."Migrate Item Classes";

        exit(MigrateItemClasses);
    end;
}