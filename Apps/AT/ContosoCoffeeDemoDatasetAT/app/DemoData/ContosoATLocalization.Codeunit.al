// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoData.Localization;

using Microsoft.DemoData.Foundation;
using Microsoft.DemoData.Finance;
using Microsoft.DemoData.Bank;
using Microsoft.DemoData.FixedAsset;
using Microsoft.DemoData.Inventory;
using Microsoft.DemoData.Purchases;
using Microsoft.DemoData.Sales;
using Microsoft.DemoTool;

codeunit 11157 "Contoso AT Localization"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnAfterGeneratingDemoData', '', false, false)]
    local procedure OnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        if Module = Enum::"Contoso Demo Data Module"::Foundation then
            FoundationModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::Finance then
            FinanceModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::Bank then
            BankModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::Purchase then
            PurchaseModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::Inventory then
            InventoryModule(ContosoDemoDataLevel);

        if Module = Enum::"Contoso Demo Data Module"::"Human Resources Module" then
            HumanResource(ContosoDemoDataLevel);

        UnBindSubscriptionDemoData(Module);
    end;

    local procedure HumanResource(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Employee AT");
        end;
    end;

    local procedure FoundationModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create No. Series AT");
                    Codeunit.Run(Codeunit::"Create Post Code AT");
                end;
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Company Information AT");
        end;
    end;

    local procedure FinanceModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateVatPostingGroupAT: Codeunit "Create VAT Posting Group AT";
        CreatePostingGroupsAT: Codeunit "Create Posting Groups AT";
        CreateATGLAccount: Codeunit "Create AT GL Account";
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                begin
                    Codeunit.Run(Codeunit::"Create AT GL Account");
                    CreateVatPostingGroupAT.CreateVATPostingSetup();
                    CreateVatPostingGroupAT.UpdateGeneralProdPostingGroup();
                    CreateATGLAccount.UpdateVATProdPostGrpInGLAccounts();
                    CreatePostingGroupsAT.UpdateGenPostingSetup();
                    Codeunit.Run(Codeunit::"Create Currency AT");
                    Codeunit.Run(Codeunit::"Create General Ledger Setup AT");
                    Codeunit.Run(Codeunit::"Create Vat Report Setup AT");
                    Codeunit.Run(Codeunit::"Create Vat Setup Post Grp AT");
                    Codeunit.Run(Codeunit::"Create VAT Statement Name AT");
                    Codeunit.Run(Codeunit::"Create VAT Statement Line AT");
                end;

            Enum::"Contoso Demo Data Level"::"Master Data":
                begin
                    Codeunit.Run(Codeunit::"Create Currency Ex. Rate AT");
                    Codeunit.Run(Codeunit::"Create Resource AT");
                    Codeunit.Run(Codeunit::"Create VAT Template AT");
                end;
        end;
    end;

    local procedure BankModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Bank ExpImport Setup AT");
        end;
    end;

    local procedure PurchaseModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Setup Data":
                Codeunit.Run(Codeunit::"Create Purch. Payable Setup AT");
            Enum::"Contoso Demo Data Level"::"Transactional Data":
                Codeunit.Run(Codeunit::"Create Purchase Document AT");

        end;
    end;

    local procedure InventoryModule(ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
        case ContosoDemoDataLevel of
            Enum::"Contoso Demo Data Level"::"Master Data":
                Codeunit.Run(Codeunit::"Create Item Template AT");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure OnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        CreateResourceAT: Codeunit "Create Resource AT";
        CreateCurrencyExcRate: Codeunit "Create Currency Ex. Rate AT";
        CreateAccScheduleLineAT: Codeunit "Create Acc. Schedule Line AT";
        CreateBankAccPostingGrpAT: Codeunit "Create Bank Acc Posting Grp AT";
        CreateBankAccountAT: Codeunit "Create Bank Account AT";
        CreateFAPostingGrpAT: Codeunit "Create FA Posting Grp. AT";
        CreateInvPostingSetupAT: Codeunit "Create Inv. Posting Setup AT";
        CreateItemAT: Codeunit "Create Item AT";
        CreateItemChargeAT: Codeunit "Create Item Charge AT";
        CreateLoactionAT: Codeunit "Create Location AT";
        CreateVendorPostingGrpAT: Codeunit "Create Vendor Posting Grp AT";
        CreatePurchDimValueAT: Codeunit "Create Purch. Dim. Value AT";
        CreateVendorAT: Codeunit "Create Vendor AT";
        CreateCustPostingGrpAT: Codeunit "Create Cust. Posting Grp AT";
        CreateReminderLevelAT: Codeunit "Create Reminder Level AT";
        CreateCustomerAT: Codeunit "Create Customer AT";
        CreateCustomerTemplateAT: Codeunit "Create Customer Template AT";
        CreateSalesDimValueAT: Codeunit "Create Sales Dim Value AT";
        CreateShiptoAddressAT: Codeunit "Create Ship-to Address AT";
        CreatePaymentTermAT: Codeunit "Create Payment Term AT";
        CreateEmployeeAT: Codeunit "Create Employee AT";
        CreateVATTemplateAT: Codeunit "Create VAT Template AT";
        CreateEmployeeTemplateAT: Codeunit "CreateEmployee Template AT";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                BindSubscription(CreatePaymentTermAT);
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    if ContosoDemoDataLevel = Enum::"Contoso Demo Data Level"::"Setup Data" then begin
                        Codeunit.Run(Codeunit::"Create VAT Posting Group AT");
                        Codeunit.Run(Codeunit::"Create Posting Groups AT");
                    end;
                    BindSubscription(CreateResourceAT);
                    BindSubscription(CreateCurrencyExcRate);
                    BindSubscription(CreateAccScheduleLineAT);
                    BindSubscription(CreateVATTemplateAT);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    BindSubscription(CreateBankAccPostingGrpAT);
                    BindSubscription(CreateBankAccountAT);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                BindSubscription(CreateFAPostingGrpAT);
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    BindSubscription(CreateInvPostingSetupAT);
                    BindSubscription(CreateItemAT);
                    BindSubscription(CreateItemChargeAT);
                    BindSubscription(CreateLoactionAT);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    BindSubscription(CreateVendorPostingGrpAT);
                    BindSubscription(CreatePurchDimValueAT);
                    BindSubscription(CreateVendorAT);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    BindSubscription(CreateCustPostingGrpAT);
                    BindSubscription(CreateReminderLevelAT);
                    BindSubscription(CreateCustomerAT);
                    BindSubscription(CreateCustomerTemplateAT);
                    BindSubscription(CreateSalesDimValueAT);
                    BindSubscription(CreateShiptoAddressAT);
                end;
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                begin
                    BindSubscription(CreateEmployeeAT);
                    BindSubscription(CreateEmployeeTemplateAT);
                end;
        end;
    end;


    local procedure UnBindSubscriptionDemoData(Module: Enum "Contoso Demo Data Module")
    var
        CreateResourceAT: Codeunit "Create Resource AT";
        CreateCurrencyExcRate: Codeunit "Create Currency Ex. Rate AT";
        CreateAccScheduleLineAT: Codeunit "Create Acc. Schedule Line AT";
        CreateBankAccPostingGrpAT: Codeunit "Create Bank Acc Posting Grp AT";
        CreateBankAccountAT: Codeunit "Create Bank Account AT";
        CreateFAPostingGrpAT: Codeunit "Create FA Posting Grp. AT";
        CreateInvPostingSetupAT: Codeunit "Create Inv. Posting Setup AT";
        CreateItemAT: Codeunit "Create Item AT";
        CreateItemChargeAT: Codeunit "Create Item Charge AT";
        CreateLoactionAT: Codeunit "Create Location AT";
        CreateVendorPostingGrpAT: Codeunit "Create Vendor Posting Grp AT";
        CreatePurchDimValueAT: Codeunit "Create Purch. Dim. Value AT";
        CreateVendorAT: Codeunit "Create Vendor AT";
        CreateCustPostingGrpAT: Codeunit "Create Cust. Posting Grp AT";
        CreateReminderLevelAT: Codeunit "Create Reminder Level AT";
        CreateCustomerAT: Codeunit "Create Customer AT";
        CreateCustomerTemplateAT: Codeunit "Create Customer Template AT";
        CreateSalesDimValueAT: Codeunit "Create Sales Dim Value AT";
        CreateShiptoAddressAT: Codeunit "Create Ship-to Address AT";
        CreatePaymentTermAT: Codeunit "Create Payment Term AT";
        CreateEmployeeAT: Codeunit "Create Employee AT";
        CreateVATTemplateAT: Codeunit "Create VAT Template AT";
        CreateEmployeeTemplateAT: Codeunit "CreateEmployee Template AT";
    begin
        case Module of
            Enum::"Contoso Demo Data Module"::Foundation:
                UnbindSubscription(CreatePaymentTermAT);
            Enum::"Contoso Demo Data Module"::Finance:
                begin
                    UnbindSubscription(CreateResourceAT);
                    UnbindSubscription(CreateCurrencyExcRate);
                    UnbindSubscription(CreateAccScheduleLineAT);
                    UnbindSubscription(CreateVATTemplateAT);
                end;
            Enum::"Contoso Demo Data Module"::Bank:
                begin
                    UnbindSubscription(CreateBankAccPostingGrpAT);
                    UnbindSubscription(CreateBankAccountAT);
                end;
            Enum::"Contoso Demo Data Module"::"Fixed Asset Module":
                UnbindSubscription(CreateFAPostingGrpAT);
            Enum::"Contoso Demo Data Module"::Inventory:
                begin
                    UnbindSubscription(CreateInvPostingSetupAT);
                    UnbindSubscription(CreateItemAT);
                    UnbindSubscription(CreateItemChargeAT);
                    UnbindSubscription(CreateLoactionAT);
                end;
            Enum::"Contoso Demo Data Module"::Purchase:
                begin
                    UnbindSubscription(CreateVendorPostingGrpAT);
                    UnbindSubscription(CreatePurchDimValueAT);
                    UnbindSubscription(CreateVendorAT);
                end;
            Enum::"Contoso Demo Data Module"::Sales:
                begin
                    UnbindSubscription(CreateCustPostingGrpAT);
                    UnbindSubscription(CreateReminderLevelAT);
                    UnbindSubscription(CreateCustomerAT);
                    UnbindSubscription(CreateCustomerTemplateAT);
                    UnbindSubscription(CreateSalesDimValueAT);
                    UnbindSubscription(CreateShiptoAddressAT);
                end;
            Enum::"Contoso Demo Data Module"::"Human Resources Module":
                begin
                    UnbindSubscription(CreateEmployeeAT);
                    UnBindSubscription(CreateEmployeeTemplateAT);
                end;
        end;
    end;
}
