#if not CLEANSCHEMA25
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

// Can't remove the enum until we remove table 4857 "Auto. Acc. Page Setup"

/// <summary>
/// Automatic Acc. feature will be moved to a separate app.
/// </summary>
enum 4853 "AAC Page Setup Key"
{
    ObsoleteReason = 'Automatic Acc.functionality will be moved to a new app.';
    ObsoleteState = Pending;
#pragma warning disable AS0105
#pragma warning disable AS0072
#pragma warning disable AS0074
    ObsoleteTag = '22.0';
#pragma warning restore AS0072
#pragma warning restore AS0074
#pragma warning restore AS0105

    value(0; "Automatic Acc. Groups List")
    { }

    value(1; "Automatic Acc. Groups Card")
    { }
}
#endif