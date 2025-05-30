// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.eServices;

using Microsoft.DemoTool;

codeunit 11504 "Create GB Incoming Document"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contoso Demo Tool", 'OnBeforeGeneratingDemoData', '', false, false)]
    local procedure LocalizationContosoDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        EServiceDemoDataSetup: Record "EService Demo Data Setup";
    begin
        if (Module = Enum::"Contoso Demo Data Module"::"EService") and (ContosoDemoDataLevel = Enum::"Contoso Demo Data Level"::"Setup Data") then begin
            EServiceDemoDataSetup.InitRecord();

            EServiceDemoDataSetup.Validate("Invoice Field Name", IncomingDocDescriptionLbl);
            EServiceDemoDataSetup.Modify();
        end;
    end;

    var
        IncomingDocDescriptionLbl: Label 'First Up Consultants Invoice GB D365F', Locked = true;
}
