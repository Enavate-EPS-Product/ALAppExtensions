table 40905 "Hist. Payables Document"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Voucher No."; Code[35])
        {
            Caption = 'Voucher No.';
            NotBlank = true;
        }
        field(2; "Vendor No."; Code[35])
        {
            Caption = 'Vendor No.';
            NotBlank = true;
        }
        field(3; "Document Type"; enum "Hist. Payables Doc. Type")
        {
            Caption = 'Document Type';
            NotBlank = true;
        }
        field(4; "Document No."; Code[35])
        {
            Caption = 'Document No.';
            NotBlank = true;
        }
        field(5; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(6; "Document Amount"; Decimal)
        {
            Caption = 'Document Amount';
        }
        field(7; "Currency Code"; Code[10])
        {
            Caption = 'Currency';
        }
        field(8; "Current Trx. Amount"; Decimal)
        {
            Caption = 'Current Trx. Amount';
        }
        field(9; "Disc. Taken Amount"; Decimal)
        {
            Caption = 'Disc. Taken Amount';
        }
        field(10; "Batch No."; Code[35])
        {
            Caption = 'Batch No.';
        }
        field(11; "Batch Source"; Text[50])
        {
            Caption = 'Batch Source';
        }
        field(12; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(13; "Purchase No."; Code[35])
        {
            Caption = 'Purchase No.';
        }
        field(14; "Audit Code"; Code[35])
        {
            Caption = 'Audit Code';
        }
        field(15; "Trx. Description"; Text[50])
        {
            Caption = 'Trx. Description';
        }
        field(16; "Post Date"; Date)
        {
            Caption = 'Post Date';
        }
        field(17; User; Text[50])
        {
            Caption = 'User';
        }
        field(18; "Misc. Amount"; Decimal)
        {
            Caption = 'Misc. Amount';
        }
        field(19; "Freight Amount"; Decimal)
        {
            Caption = 'Freight Amount';
        }
        field(20; "Tax Amount"; Decimal)
        {
            Caption = 'Tax Amount';
        }
        field(21; "Total Payments"; Decimal)
        {
            Caption = 'Total Payments';
        }
        field(22; Voided; Boolean)
        {
            Caption = 'Voided';
            InitValue = false;
        }
        field(23; "Invoice Paid Off Date"; Date)
        {
            Caption = 'Invoice Paid Off Date';
        }
        field(24; "Ship Method"; Text[50])
        {
            Caption = 'Ship Method';
        }
        field(25; "1099 Amount"; Decimal)
        {
            Caption = '1099 Amount';
        }
        field(26; "Write Off Amount"; Decimal)
        {
            Caption = 'Write Off Amount';
        }
        field(27; "Trade Discount Amount"; Decimal)
        {
            Caption = 'Trade Discount Amount';
        }
        field(28; "Payment Terms ID"; Text[50])
        {
            Caption = 'Payment Terms ID';
        }
        field(29; "1099 Type"; Text[50])
        {
            Caption = '1099 Type';
        }
        field(30; "1099 Box Number"; Text[50])
        {
            Caption = '1099 Box Number';
        }
        field(31; "PO Number"; Code[35])
        {
            Caption = 'PO Number';
        }
    }

    keys
    {
        key(Key1; "Voucher No.", "Document Type", "Document No.")
        {
            Clustered = true;
        }
        key(Key2; "Audit Code")
        {
        }
        key(Key3; "Vendor No.")
        {
        }
    }
}