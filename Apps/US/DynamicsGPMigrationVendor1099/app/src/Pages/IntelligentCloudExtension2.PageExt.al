pageextension 41002 "Intelligent Cloud Extension 2" extends "Intelligent Cloud Management"
{
    actions
    {
        /*addafter(RunReplicationNow)
        {
            action(Run1099Migration)
            {
                ApplicationArea = All;
                Caption = 'Run 1099 Migration';
                ToolTip = 'Run 1099 Migration';
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Image = TaxSetup;

                trigger OnAction()
                var
                    GPPopulateVendor1099Data: Codeunit "GP Populate Vendor 1099 Data";
                begin
                    GPPopulateVendor1099Data.UpdateAllVendorTaxInfo();
                end;
            }
        }*/
    }
}