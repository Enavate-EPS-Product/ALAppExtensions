page 41016 "Hist. Receivables Documents"
{
    ApplicationArea = All;
    Caption = 'Historical Receivables Documents';
    PageType = List;
    CardPageId = "Hist. Receivables Document";
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Hist. Receivables Document";
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(Main)
            {
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the value of the Customer Name field.';
                }
                field("Batch No."; Rec."Batch No.")
                {
                    ToolTip = 'Specifies the value of the Batch No. field.';
                }
                field("Batch Source"; Rec."Batch Source")
                {
                    ToolTip = 'Specifies the value of the Batch Source field.';
                }
                field("Audit Code"; Rec."Audit Code")
                {
                    ToolTip = 'Specifies the value of the Audit Code field.';
                }
                field("Trx. Description"; Rec."Trx. Description")
                {
                    ToolTip = 'Specifies the value of the Trx. Description field.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ToolTip = 'Specifies the value of the Document Date field.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ToolTip = 'Specifies the value of the Due Date field.';
                }
                field("Post Date"; Rec."Post Date")
                {
                    ToolTip = 'Specifies the value of the Post Date field.';
                }
                field(User; Rec.User)
                {
                    ToolTip = 'Specifies the value of the User field.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency field.';
                }
                field("Orig. Trx. Amount"; Rec."Orig. Trx. Amount")
                {
                    ToolTip = 'Specifies the value of the Orig. Trx. Amount field.';
                }
                field("Current Trx. Amount"; Rec."Current Trx. Amount")
                {
                    ToolTip = 'Specifies the value of the Current Trx. Amount field.';
                }
                field("Sales Amount"; Rec."Sales Amount")
                {
                    ToolTip = 'Specifies the value of the Sales Amount field.';
                }
                field("Cost Amount"; Rec."Cost Amount")
                {
                    ToolTip = 'Specifies the value of the Cost Amount field.';
                }
                field("Freight Amount"; Rec."Freight Amount")
                {
                    ToolTip = 'Specifies the value of the Freight Amount field.';
                }
                field("Misc. Amount"; Rec."Misc. Amount")
                {
                    ToolTip = 'Specifies the value of the Misc. Amount field.';
                }
                field("Tax Amount"; Rec."Tax Amount")
                {
                    ToolTip = 'Specifies the value of the Tax Amount field.';
                }
                field("Disc. Taken Amount"; Rec."Disc. Taken Amount")
                {
                    ToolTip = 'Specifies the value of the Disc. Taken Amount field.';
                }
                field("Customer Purchase No."; Rec."Customer Purchase No.")
                {
                    ToolTip = 'Specifies the value of the Customer Purchase No. field.';
                }
                field("Salesperson No."; Rec."Salesperson No.")
                {
                    ToolTip = 'Specifies the value of the Salesperson No. field.';
                }
                field("Sales Territory"; Rec."Sales Territory")
                {
                    ToolTip = 'Specifies the value of the Sales Territory field.';
                }
                field("Ship Method"; Rec."Ship Method")
                {
                    ToolTip = 'Specifies the value of the Ship Method field.';
                }
                field("Cash Amount"; Rec."Cash Amount")
                {
                    ToolTip = 'Specifies the value of the Cash Amount field.';
                }
                field("Commission Dollar Amount"; Rec."Commission Dollar Amount")
                {
                    ToolTip = 'Specifies the value of the Commission Dollar Amount field.';
                }
                field("Invoice Paid Off Date"; Rec."Invoice Paid Off Date")
                {
                    ToolTip = 'Specifies the value of the Invoice Paid Off Date field.';
                }
                field("Payment Terms ID"; Rec."Payment Terms ID")
                {
                    ToolTip = 'Specifies the value of the Payment Terms ID field.';
                }
                field("Write Off Amount"; Rec."Write Off Amount")
                {
                    ToolTip = 'Specifies the value of the Write Off Amount field.';
                }
            }
        }
    }
}