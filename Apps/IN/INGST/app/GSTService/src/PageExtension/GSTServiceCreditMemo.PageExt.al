﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Document;

using Microsoft.Finance.GST.Services;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

pageextension 18444 "GST Service Credit Memo" extends "Service Credit Memo"
{
    layout
    {
        modify("Posting Date")
        {
            trigger OnAfterValidate()
            var
                GSTServiceValidations: Codeunit "GST Service Validations";
            begin
                GSTServiceValidations.CallTaxEngineOnServiceHeader(Rec);
            end;
        }
        modify("Location Code")
        {
            trigger OnAfterValidate()
            var
                GSTServiceValidations: Codeunit "GST Service Validations";
            begin
                GSTServiceValidations.CallTaxEngineOnServiceHeader(Rec);
            end;
        }
        modify("Currency Code")
        {
            trigger OnAfterValidate()
            var
                GSTServiceValidations: Codeunit "GST Service Validations";
            begin
                GSTServiceValidations.CallTaxEngineOnServiceHeader(Rec);
            end;
        }
        addfirst(factboxes)
        {
            part(TaxInformation; "Tax Information Factbox")
            {
                Provider = ServLines;
                SubPageLink = "Table ID Filter" = const(5902), "Document Type Filter" = field("Document Type"), "Document No. Filter" = field("Document No."), "Line No. Filter" = field("Line No.");
                ApplicationArea = Basic, Suite;
            }
        }
        addafter("Assigned User Id")
        {
            field("GST Reason Type"; Rec."GST Reason Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the reason of return or credit memo of a posted document where gst is applicable. For example Deficiency in Service/Correction in Invoice etc.';
            }
        }
        addafter("Applies-to ID")
        {
            field(Trading; Rec.Trading)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if trading is applicable for the transaction or not.';
            }
        }
        addafter(Application)
        {
            group(GST)
            {
                field("GST Bill-to State Code"; Rec."GST Bill-to State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bill-to state code of the customer on the service document.';
                }
                field("GST Ship-to State Code"; Rec."GST Ship-to State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ship-to state code of the customer on the service document';
                }
                field("Location State Code"; Rec."Location State Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sate code mentioned of the location used in the transaction';
                }
                field("Location GST Reg. No."; Rec."Location GST Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST registration number of the Location specified on the service document.';
                }
                field("Customer GST Reg. No."; Rec."Customer GST Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST registration number of the customer specified on the service document.';
                }
                field("Ship-to GST Reg. No."; Rec."Ship-to GST Reg. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST registration number of the shipping address specified on the service document.';
                }
                field("Nature of Supply"; Rec."Nature of Supply")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the nature of GST transaction. For example, B2B/B2C.';
                }
                field("GST Customer Type"; Rec."GST Customer Type")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the type of the customer. For example, Registered/Unregistered/Export/Exempted/SEZ Unit/SEZ Development etc.';
                }
                field("Invoice Type"; Rec."Invoice Type")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the invoice type on the service document. For example, Bill of supply, Export, Supplementary, Debit Note, Non-GST and Taxable.';
                }
                field("GST Without Payment of Duty"; Rec."GST Without Payment of Duty")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether with or without payment of duty.';

                    trigger OnValidate()
                    var
                        GSTServiceValidations: Codeunit "GST Service Validations";
                    begin
                        CurrPage.SaveRecord();
                        GSTServiceValidations.CallTaxEngineOnServiceHeader(Rec);
                    end;
                }
                field("Bill Of Export No."; Rec."Bill Of Export No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bill of export number. It is a document number which is submitted to custom department .';
                }
                field("Bill Of Export Date"; Rec."Bill Of Export Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry date defined in bill of export document.';
                }
                field("Reference Invoice No."; Rec."Reference Invoice No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Reference Invoice number.';
                }
                field("Rate Change Applicable"; Rec."Rate Change Applicable")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if rate change is applicable on the service document.';

                    trigger OnValidate()
                    begin
                        IsRateChangeEnabled := Rec."Rate Change Applicable";

                        if not IsRateChangeEnabled then begin
                            Rec."Supply Finish Date" := Rec."Supply Finish Date"::" ";
                            Rec."Payment Date" := Rec."Payment Date"::" ";
                        end;
                    end;
                }
                field("Supply Finish Date"; Rec."Supply Finish Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the supply finish date. For example, Before rate change/After rate change.';
                }
                field("Payment Date"; Rec."Payment Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the payment date. For example, Before rate change/After rate change.';
                }
                field("GST Inv. Rounding Precision"; Rec."GST Inv. Rounding Precision")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies Rounding Precision on the service document.';
                }
                field("GST Inv. Rounding Type"; Rec."GST Inv. Rounding Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies Rounding Type on the service document.';
                }
                field("POS Out Of India"; Rec."POS Out Of India")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the place of supply of invoice is out of India.';
                }
            }
        }
        addbefore("Ship-to Name")
        {
            field("Ship-to Code"; Rec."Ship-to Code")
            {
                ApplicationArea = Service;
                ToolTip = 'Specifies a code for an alternate shipment address if you want to ship to another address than the one that has been defined automatically. This field is also used in case of drop shipment.';

                trigger OnValidate()
                begin
                    ShiptoCodeOnAfterValidate();
                end;
            }
        }
    }
    actions
    {
        addafter("Get Prepaid Contract E&ntries")
        {
            action("Update Reference Invoice No.")
            {
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;
                Image = ApplyEntries;
                ToolTip = 'Specifies the function through which reference number can be updated in the document.';

                trigger OnAction()
                begin
                    OnActionUpdateRefInvNo(Rec);
                end;

            }
        }
    }

    local procedure ShiptoCodeOnAfterValidate()
    begin
        CurrPage.Update();
    end;

    var
        IsRateChangeEnabled: Boolean;

    [IntegrationEvent(false, false)]
    local procedure OnActionUpdateRefInvNo(Rec: Record "Service Header")
    begin
    end;

}
