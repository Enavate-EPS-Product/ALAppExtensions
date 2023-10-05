page 41021 "Hist. Payables Apply List"
{
    ApplicationArea = All;
    Caption = 'Historical Payables Apply List';
    PageType = ListPart;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Hist. Payables Apply";
    CardPageId = "Hist. Payables Apply";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Voucher No."; Rec."Voucher No.")
                {
                    ToolTip = 'Specifies the value of the Voucher No. field.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Document Amount"; Rec."Document Amount")
                {
                    ToolTip = 'Specifies the value of the Document Amount field.';
                }
                field("Apply To Document Date"; Rec."Apply To Document Date")
                {
                    ToolTip = 'Specifies the value of the Apply To Document Date field.';
                }
                field("Apply To Voucher No."; Rec."Apply To Voucher No.")
                {
                    ToolTip = 'Specifies the value of the Apply To Voucher No. field.';
                }
            }
        }
    }

    procedure FilterByVoucherNo(DocType: Enum "Hist. Payables Doc. Type"; VoucherNo: Code[35])
    begin
        if DocType = Rec."Document Type"::Invoice then
            Rec.SetRange("Apply To Voucher No.", VoucherNo)
        else
            Rec.SetRange("Voucher No.", VoucherNo);

        CurrPage.Update();
    end;
}