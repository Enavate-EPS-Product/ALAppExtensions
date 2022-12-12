permissionset 4700 "GP Hist. Trx. - Read"
{
    Assignable = true;
    Access = Public;
    Caption = 'GP Historical Transactions - Read';

    Permissions = tabledata "Hist. Gen. Journal Line" = R,
                  tabledata "Hist. G/L Account" = R,
                  tabledata "Hist. Sales Trx. Header" = R,
                  tabledata "Hist. Sales Trx. Line" = R,
                  tabledata "Hist. Receivables Document" = R,
                  tabledata "Hist. Payables Document" = R,
                  tabledata "Hist. Inventory Trx. Header" = R,
                  tabledata "Hist. Inventory Trx. Line" = R,
                  tabledata "Hist. Purchase Recv. Header" = R,
                  tabledata "Hist. Purchase Recv. Line" = R;
}