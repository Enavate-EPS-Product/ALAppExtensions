page 41022 "Hist. Receivables Apply List"
{
    ApplicationArea = All;
    Caption = 'Historical Receivables Apply List';
    PageType = ListPart;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Hist. Receivables Apply";
    CardPageId = "Hist. Receivables Apply";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Apply From Document No."; Rec."Apply From Document No.")
                {
                    ToolTip = 'Specifies the value of the Apply From Document No. field.';
                }
                field("Apply From Document Type"; Rec."Apply From Document Type")
                {
                    ToolTip = 'Specifies the value of the Apply From Document Type field.';
                }
                field("Date"; Rec."Date")
                {
                    ToolTip = 'Specifies the value of the Date field.';
                }
                field("Apply To Amount"; Rec."Apply To Amount")
                {
                    ToolTip = 'Specifies the value of the Apply To Amount field.';
                }
            }
        }
    }
}