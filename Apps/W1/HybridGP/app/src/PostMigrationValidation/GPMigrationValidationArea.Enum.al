namespace Microsoft.DataMigration.GP;

enum 40011 "GP Migration Validation Area"
{

    value(0; Accounts)
    {
        Caption = 'Accounts';
    }
    value(1; "Bank Accounts")
    {
        Caption = 'Bank Accounts';
    }
    value(2; Customers)
    {
        Caption = 'Customers';
    }
    value(3; Items)
    {
        Caption = 'Items';
    }
    value(4; Vendors)
    {
        Caption = 'Vendors';
    }
    value(5; PurchaseOrders)
    {
        Caption = 'PurchaseOrders';
    }
}