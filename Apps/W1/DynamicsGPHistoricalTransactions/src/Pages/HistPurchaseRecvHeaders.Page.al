page 41014 "Hist. Purchase Recv. Headers"
{
    ApplicationArea = All;
    Caption = 'Historical Purchase Recv. List';
    PageType = List;
    CardPageId = "Hist. Purchase Recv.";
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Hist. Purchase Recv. Header";
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Receipt No."; Rec."Receipt No.")
                {
                    ToolTip = 'Specifies the value of the Receipt No. field.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ToolTip = 'Specifies the value of the Vendor No. field.';
                }
                field("Vendor Document No."; Rec."Vendor Document No.")
                {
                    ToolTip = 'Specifies the value of the Vendor Document No. field.';
                }
                field("Receipt Date"; Rec."Receipt Date")
                {
                    ToolTip = 'Specifies the value of the Receipt Date field.';
                }
                field("Post Date"; Rec."Post Date")
                {
                    ToolTip = 'Specifies the value of the Post Date field.';
                }
                field("Actual Ship Date"; Rec."Actual Ship Date")
                {
                    ToolTip = 'Specifies the value of the Actual Ship Date field.';
                }
                field("Batch No."; Rec."Batch No.")
                {
                    ToolTip = 'Specifies the value of the Batch No. field.';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ToolTip = 'Specifies the value of the Vendor Name field.';
                }
                field(Subtotal; Rec.Subtotal)
                {
                    ToolTip = 'Specifies the value of the Subtotal field.';
                }
                field("Trade Discount Amount"; Rec."Trade Discount Amount")
                {
                    ToolTip = 'Specifies the value of the Trade Discount Amount field.';
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
                field("1099 Amount"; Rec."1099 Amount")
                {
                    ToolTip = 'Specifies the value of the 1099 Amount field.';
                }
                field("Payment Terms ID"; Rec."Payment Terms ID")
                {
                    ToolTip = 'Specifies the value of the Payment Terms ID field.';
                }
                field("Discount Percent Amount"; Rec."Discount Percent Amount")
                {
                    ToolTip = 'Specifies the value of the Discount Percent Amount field.';
                }
                field("Discount Dollar Amount"; Rec."Discount Dollar Amount")
                {
                    ToolTip = 'Specifies the value of the Discount Dollar Amount field.';
                }
                field("Discount Available Amount"; Rec."Discount Available Amount")
                {
                    ToolTip = 'Specifies the value of the Discount Available Amount field.';
                }
                field("Discount Date"; Rec."Discount Date")
                {
                    ToolTip = 'Specifies the value of the Discount Date field.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ToolTip = 'Specifies the value of the Due Date field.';
                }
                field(Reference; Rec.Reference)
                {
                    ToolTip = 'Specifies the value of the Reference field.';
                }
                field(Void; Rec.Void)
                {
                    ToolTip = 'Specifies the value of the Void field.';
                }
                field(User; Rec.User)
                {
                    ToolTip = 'Specifies the value of the User field.';
                }
                field("Voucher No."; Rec."Voucher No.")
                {
                    ToolTip = 'Specifies the value of the Voucher No. field.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.';
                }
                field("Audit Code"; Rec."Audit Code")
                {
                    ToolTip = 'Specifies the value of the Audit Code field.';
                }
                field("Invoice Receipt Date"; Rec."Invoice Receipt Date")
                {
                    ToolTip = 'Specifies the value of the Invoice Receipt Date field.';
                }
                field("Prepayment Amount"; Rec."Prepayment Amount")
                {
                    ToolTip = 'Specifies the value of the Prepayment Amount field.';
                }
            }
        }
    }
}