codeunit 40900 "GP Populate Hist. Tables"
{
    var
        PayrollSeriesId: Integer;

    trigger OnRun()
    begin
        PayrollSeriesId := 6;
        PopulateHistoricalTables();
    end;

    internal procedure PopulateHistoricalTables()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        if GPCompanyAdditionalSettings.GetMigrateHistGLTrx() then
            PopulateGLDetail();

        if GPCompanyAdditionalSettings.GetMigrateHistARTrx() then begin
            PopulateSalesTransactions();
            PopulateRecvDocuments();
        end;

        if GPCompanyAdditionalSettings.GetMigrateHistAPTrx() then
            PopulatePayablesDocuments();

        if GPCompanyAdditionalSettings.GetMigrateHistInvTrx() then
            PopulateInventoryTransactions();

        if GPCompanyAdditionalSettings.GetMigrateHistPurchTrx() then
            PopulatePurchaseRecvTransactions();
    end;

    local procedure PopulateGLDetail()
    begin
        PopulateHistGLAccounts();
        PopulateOpenYearPostedTransactions();
        PopulateHistoricalYearPostedTransactions();
    end;

    local procedure PopulateHistGLAccounts()
    var
        GPGL00105: Record "GP GL00105";
        GPGL00100: Record "GP GL00100";
        HistGLAccount: Record "Hist. G/L Account";
    begin
        if GPGL00105.FindSet() then
            repeat
                Clear(HistGLAccount);
                if GPGL00100.Get(GPGL00105.ACTINDX) then begin
                    HistGLAccount."No." := CopyStr(Format(GPGL00105.ACTNUMST), 1, MaxStrLen(HistGLAccount."No."));
                    HistGLAccount.Name := GPGL00100.ACTDESCR;
                    HistGLAccount.Insert();
                end;
            until GPGL00105.Next() = 0;
    end;

    local procedure PopulateOpenYearPostedTransactions()
    var
        GPGL20000: Record "GP GL20000";
        GPGL00105: Record "GP GL00105";
        HistGenJournalLine: Record "Hist. Gen. Journal Line";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        OutlookSynchTypeConv: Codeunit "Outlook Synch. Type Conv";
        InitialHistYear: Integer;
    begin
        InitialHistYear := GPCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then
            GPGL20000.SetFilter(OPENYEAR, '>=%1', InitialHistYear);

        GPGL20000.SetFilter(SERIES, '<>%1', PayrollSeriesId);

        if GPGL20000.FindSet() then
            repeat
                Clear(HistGenJournalLine);
                if GPGL00105.Get(GPGL20000.ACTINDX) then begin
                    HistGenJournalLine."No." := 'OpenYear-' + Format(GPGL20000.DEX_ROW_ID);

#pragma warning disable AA0139
                    HistGenJournalLine."Source Type" := ConvertSeriesToSourceType(GPGL20000.SERIES, GPGL20000.SOURCDOC.TrimEnd());
                    HistGenJournalLine."Orig. Document No." := GPGL20000.ORDOCNUM.TrimEnd();
#pragma warning restore AA0139

                    HistGenJournalLine."Journal Entry No." := Format(GPGL20000.JRNENTRY);
                    HistGenJournalLine."Account No." := CopyStr(Format(GPGL00105.ACTNUMST), 1, MaxStrLen(HistGenJournalLine."Account No."));
                    HistGenJournalLine."Sequence No." := GPGL20000.SEQNUMBR;
                    HistGenJournalLine."Audit Code" := GPGL20000.TRXSORCE;
                    HistGenJournalLine.Closed := false;
                    HistGenJournalLine.Year := GPGL20000.OPENYEAR;
                    HistGenJournalLine."Date" := DT2Date(OutlookSynchTypeConv.LocalDT2UTC(GPGL20000.TRXDATE));
                    HistGenJournalLine."Currency Code" := CopyStr(GPGL20000.CURNCYID, 1, MaxStrLen(HistGenJournalLine."Currency Code"));
                    HistGenJournalLine."Debit Amount" := GPGL20000.DEBITAMT;
                    HistGenJournalLine."Orig. Debit Amount" := GPGL20000.ORDBTAMT;
                    HistGenJournalLine."Credit Amount" := GPGL20000.CRDTAMNT;
                    HistGenJournalLine."Orig. Credit Amount" := GPGL20000.ORCRDAMT;
                    HistGenJournalLine."Document Type" := GPGL20000.SOURCDOC;
                    HistGenJournalLine."Reference Desc." := GPGL20000.REFRENCE;
                    HistGenJournalLine."Description" := GPGL20000.DSCRIPTN;
                    HistGenJournalLine."User" := GPGL20000.USWHPSTD;
                    HistGenJournalLine."Source No." := GPGL20000.ORMSTRID;
                    HistGenJournalLine."Source Name" := CopyStr(GPGL20000.ORMSTRNM, 1, MaxStrLen(HistGenJournalLine."Source Name"));
                    HistGenJournalLine."Orig. Trx. Source No." := GPGL20000.ORTRXSRC;
                    HistGenJournalLine."Custom1" := GPGL20000.User_Defined_Text01;
                    HistGenJournalLine."Custom2" := GPGL20000.User_Defined_Text02;

                    HistGenJournalLine.Insert();
                end;
            until GPGL20000.Next() = 0;
    end;

    local procedure PopulateHistoricalYearPostedTransactions()
    var
        GPGL30000: Record "GP GL30000";
        GPGL00105: Record "GP GL00105";
        HistGenJournalLine: Record "Hist. Gen. Journal Line";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        OutlookSynchTypeConv: Codeunit "Outlook Synch. Type Conv";
        InitialHistYear: Integer;
    begin
        InitialHistYear := GPCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then
            GPGL30000.SetFilter(HSTYEAR, '>=%1', InitialHistYear);

        GPGL30000.SetFilter(SERIES, '<>%1', PayrollSeriesId);
        if GPGL30000.FindSet() then
            repeat
                Clear(HistGenJournalLine);
                if GPGL00105.Get(GPGL30000.ACTINDX) then begin
                    HistGenJournalLine."No." := 'HistYear-' + Format(GPGL30000.DEX_ROW_ID);

#pragma warning disable AA0139
                    HistGenJournalLine."Source Type" := ConvertSeriesToSourceType(GPGL30000.SERIES, GPGL30000.SOURCDOC.TrimEnd());
                    HistGenJournalLine."Orig. Document No." := GPGL30000.ORDOCNUM.TrimEnd();
#pragma warning restore AA0139

                    HistGenJournalLine."Journal Entry No." := Format(GPGL30000.JRNENTRY);
                    HistGenJournalLine."Account No." := CopyStr(Format(GPGL00105.ACTNUMST), 1, MaxStrLen(HistGenJournalLine."Account No."));
                    HistGenJournalLine."Sequence No." := GPGL30000.SEQNUMBR;
                    HistGenJournalLine."Audit Code" := GPGL30000.TRXSORCE;
                    HistGenJournalLine.Closed := true;
                    HistGenJournalLine.Year := GPGL30000.HSTYEAR;
                    HistGenJournalLine."Date" := DT2Date(OutlookSynchTypeConv.LocalDT2UTC(GPGL30000.TRXDATE));
                    HistGenJournalLine."Currency Code" := CopyStr(GPGL30000.CURNCYID, 1, MaxStrLen(HistGenJournalLine."Currency Code"));
                    HistGenJournalLine."Debit Amount" := GPGL30000.DEBITAMT;
                    HistGenJournalLine."Orig. Debit Amount" := GPGL30000.ORDBTAMT;
                    HistGenJournalLine."Credit Amount" := GPGL30000.CRDTAMNT;
                    HistGenJournalLine."Orig. Credit Amount" := GPGL30000.ORCRDAMT;
                    HistGenJournalLine."Document Type" := GPGL30000.SOURCDOC;
                    HistGenJournalLine."Reference Desc." := GPGL30000.REFRENCE;
                    HistGenJournalLine."Description" := GPGL30000.DSCRIPTN;
                    HistGenJournalLine."User" := GPGL30000.USWHPSTD;
                    HistGenJournalLine."Source No." := GPGL30000.ORMSTRID;
                    HistGenJournalLine."Source Name" := CopyStr(GPGL30000.ORMSTRNM, 1, MaxStrLen(HistGenJournalLine."Source Name"));
                    HistGenJournalLine."Orig. Trx. Source No." := GPGL30000.ORTRXSRC;
                    HistGenJournalLine."Custom1" := GPGL30000.User_Defined_Text01;
                    HistGenJournalLine."Custom2" := GPGL30000.User_Defined_Text02;

                    HistGenJournalLine.Insert();
                end;
            until GPGL30000.Next() = 0;
    end;

    local procedure PopulateSalesTransactions()
    var
        GPSOPTrxHist: Record GPSOPTrxHist;
        HistSalesTrxHeader: Record "Hist. Sales Trx. Header";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        InitialHistYear: Integer;
        DocumentNo: Code[35];
    begin
        InitialHistYear := GPCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then
            GPSOPTrxHist.SetFilter(DOCDATE, '>=%1', System.DMY2Date(1, 1, InitialHistYear));

        if not GPSOPTrxHist.FindSet() then
            exit;

        repeat
            Clear(HistSalesTrxHeader);

#pragma warning disable AA0139
            DocumentNo := GPSOPTrxHist.SOPNUMBE.TrimEnd();
            HistSalesTrxHeader."Customer No." := GPSOPTrxHist.CUSTNMBR.TrimEnd();
#pragma warning restore AA0139

            HistSalesTrxHeader."No." := DocumentNo;
            HistSalesTrxHeader."Sales Trx. Type" := ConvertGPSOPTypeToHistSalesTrxType(GPSOPTrxHist.SOPTYPE);
            HistSalesTrxHeader."Sales Trx. Status" := ConvertSOPStatusToSalesTrxStatus(GPSOPTrxHist.SOPSTATUS);
            HistSalesTrxHeader."Currency Code" := CopyStr(GPSOPTrxHist.CURNCYID, 1, MaxStrLen(HistSalesTrxHeader."Currency Code"));
            HistSalesTrxHeader."Sub Total" := GPSOPTrxHist.SUBTOTAL;
            HistSalesTrxHeader."Tax Amount" := GPSOPTrxHist.TAXAMNT;
            HistSalesTrxHeader."Trade Disc. Amount" := GPSOPTrxHist.TRDISAMT;
            HistSalesTrxHeader."Freight Amount" := GPSOPTrxHist.FRTAMNT;
            HistSalesTrxHeader."Misc. Amount" := GPSOPTrxHist.MISCAMNT;
            HistSalesTrxHeader."Payment Recv. Amount" := GPSOPTrxHist.PYMTRCVD;
            HistSalesTrxHeader."Disc. Taken Amount" := GPSOPTrxHist.DISTKNAM;
            HistSalesTrxHeader."Total" := GPSOPTrxHist.DOCAMNT;
            HistSalesTrxHeader."Document Date" := GPSOPTrxHist.DOCDATE;
            HistSalesTrxHeader."Due Date" := GPSOPTrxHist.DUEDATE;
            HistSalesTrxHeader."Actual Ship Date" := GPSOPTrxHist.ACTLSHIP;
            HistSalesTrxHeader."Customer Name" := GPSOPTrxHist.CUSTNAME;
            HistSalesTrxHeader."Ship Method" := GPSOPTrxHist.SHIPMTHD;
            HistSalesTrxHeader."Ship-to Code" := GPSOPTrxHist.PRSTADCD;
            HistSalesTrxHeader."Ship-to Name" := GPSOPTrxHist.ShipToName;
            HistSalesTrxHeader."Ship-to Address" := GPSOPTrxHist.ADDRESS1;
            HistSalesTrxHeader."Ship-to Address 2" := CopyStr(GPSOPTrxHist.ADDRESS2, 1, MaxStrLen(HistSalesTrxHeader."Ship-to Address 2"));
            HistSalesTrxHeader."Ship-to City" := GPSOPTrxHist.CITY;
            HistSalesTrxHeader."Ship-to State" := GPSOPTrxHist.STATE;
            HistSalesTrxHeader."Ship-to Zipcode" := GPSOPTrxHist.ZIPCODE;
            HistSalesTrxHeader."Ship-to Country" := CopyStr(GPSOPTrxHist.COUNTRY, 1, MaxStrLen(HistSalesTrxHeader."Ship-to Country"));
            HistSalesTrxHeader."Contact Person Name" := GPSOPTrxHist.CNTCPRSN;
            HistSalesTrxHeader."Salesperson No." := GPSOPTrxHist.SLPRSNID;
            HistSalesTrxHeader."Sales Territory" := GPSOPTrxHist.SALSTERR;
            HistSalesTrxHeader."Customer Purchase No." := GPSOPTrxHist.CSTPONBR;
            HistSalesTrxHeader."Original No." := GPSOPTrxHist.ORIGNUMB;
            HistSalesTrxHeader."Audit Code" := GPSOPTrxHist.TRXSORCE;
            HistSalesTrxHeader.Insert();

            PopulateSalesTransactionLines(GPSOPTrxHist, DocumentNo);
        until GPSOPTrxHist.Next() = 0;
    end;

    local procedure PopulateSalesTransactionLines(GPSOPTrxHist: Record GPSOPTrxHist; DocumentNo: Code[35])
    var
        GPSOPTrxAmountsHist: Record GPSOPTrxAmountsHist;
        HistSalesTrxLine: Record "Hist. Sales Trx. Line";
    begin
        GPSOPTrxAmountsHist.SetRange(SOPTYPE, GPSOPTrxHist.SOPTYPE);
        GPSOPTrxAmountsHist.SetRange(SOPNUMBE, GPSOPTrxHist.SOPNUMBE);
        if not GPSOPTrxAmountsHist.FindSet() then
            exit;

        repeat
            Clear(HistSalesTrxLine);
            HistSalesTrxLine."Sales Header No." := DocumentNo;
            HistSalesTrxLine."Sales Trx. Type" := ConvertGPSOPTypeToHistSalesTrxType(GPSOPTrxAmountsHist.SOPTYPE);
            HistSalesTrxLine."Line Item Sequence No." := GPSOPTrxAmountsHist.LNITMSEQ;
            HistSalesTrxLine."Component Sequence" := GPSOPTrxAmountsHist.CMPNTSEQ;
            HistSalesTrxLine."Item No." := GPSOPTrxAmountsHist.ITEMNMBR;
            HistSalesTrxLine."Item Description" := CopyStr(GPSOPTrxAmountsHist.ITEMDESC, 1, MaxStrLen(HistSalesTrxLine."Item Description"));
            HistSalesTrxLine."Unit of Measure" := GPSOPTrxAmountsHist.UOFM;
            HistSalesTrxLine."Unit Cost" := GPSOPTrxAmountsHist.UNITCOST;
            HistSalesTrxLine."Unit Price" := GPSOPTrxAmountsHist.UNITPRCE;
            HistSalesTrxLine.Quantity := GPSOPTrxAmountsHist.QUANTITY;
            HistSalesTrxLine."Ext. Cost" := GPSOPTrxAmountsHist.EXTDCOST;
            HistSalesTrxLine."Ext. Price" := GPSOPTrxAmountsHist.XTNDPRCE;
            HistSalesTrxLine."Tax Amount" := GPSOPTrxAmountsHist.TAXAMNT;
            HistSalesTrxLine."Location Code" := GPSOPTrxAmountsHist.LOCNCODE;
            HistSalesTrxLine."Ship-to Name" := CopyStr(GPSOPTrxAmountsHist.ShipToName, 1, MaxStrLen(HistSalesTrxLine."Ship-to Name"));
            HistSalesTrxLine.Insert();
        until GPSOPTrxAmountsHist.Next() = 0;
    end;

    local procedure PopulateRecvDocuments()
    begin
        PopulateRecvOpenDocuments();
        PopulateRecvHistoricalDocuments();
    end;

    local procedure PopulateRecvOpenDocuments()
    var
        GPRM20101: Record "GP RM20101";
        HistReceivablesDocument: Record "Hist. Receivables Document";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPRM00101: Record "GP RM00101";
        CustomerName: Text[100];
        InitialHistYear: Integer;
    begin
        InitialHistYear := GPCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then
            GPRM20101.SetFilter(DOCDATE, '>=%1', System.DMY2Date(1, 1, InitialHistYear));

        if not GPRM20101.FindSet() then
            exit;

        if GPRM00101.Get(GPRM20101.CUSTNMBR) then
            CustomerName := GPRM00101.CUSTNAME;

        repeat
            Clear(HistReceivablesDocument);

#pragma warning disable AA0139
            HistReceivablesDocument."Document No." := GPRM20101.DOCNUMBR.TrimEnd();
            HistReceivablesDocument."Customer No." := GPRM20101.CUSTNMBR.TrimEnd();
#pragma warning restore AA0139

            HistReceivablesDocument."Customer Name" := CustomerName;
            HistReceivablesDocument."Document Type" := ConvertGPDocTypeToHistReceivablesDocType(GPRM20101.RMDTYPAL);
            HistReceivablesDocument."Batch No." := GPRM20101.BACHNUMB;
            HistReceivablesDocument."Batch Source" := GPRM20101.BCHSOURC;
            HistReceivablesDocument."Audit Code" := GPRM20101.TRXSORCE;
            HistReceivablesDocument."Trx. Description" := GPRM20101.TRXDSCRN;
            HistReceivablesDocument."Document Date" := GPRM20101.DOCDATE;
            HistReceivablesDocument."Due Date" := GPRM20101.DUEDATE;
            HistReceivablesDocument."Post Date" := GPRM20101.POSTDATE;
            HistReceivablesDocument."User" := GPRM20101.PSTUSRID;
            HistReceivablesDocument."Currency Code" := CopyStr(GPRM20101.CURNCYID, 1, MaxStrLen(HistReceivablesDocument."Currency Code"));
            HistReceivablesDocument."Orig. Trx. Amount" := GPRM20101.ORTRXAMT;
            HistReceivablesDocument."Current Trx. Amount" := GPRM20101.CURTRXAM;
            HistReceivablesDocument."Sales Amount" := GPRM20101.SLSAMNT;
            HistReceivablesDocument."Cost Amount" := GPRM20101.COSTAMNT;
            HistReceivablesDocument."Freight Amount" := GPRM20101.FRTAMNT;
            HistReceivablesDocument."Misc. Amount" := GPRM20101.MISCAMNT;
            HistReceivablesDocument."Tax Amount" := GPRM20101.TAXAMNT;
            HistReceivablesDocument."Disc. Taken Amount" := GPRM20101.DISTKNAM;
            HistReceivablesDocument."Customer Purchase No." := GPRM20101.CSPORNBR;
            HistReceivablesDocument."Salesperson No." := GPRM20101.SLPRSNID;
            HistReceivablesDocument."Sales Territory" := GPRM20101.SLSTERCD;
            HistReceivablesDocument."Ship Method" := GPRM20101.SHIPMTHD;
            HistReceivablesDocument."Cash Amount" := GPRM20101.CASHAMNT;
            HistReceivablesDocument."Commission Dollar Amount" := GPRM20101.COMDLRAM;
            HistReceivablesDocument."Invoice Paid Off Date" := GPRM20101.DINVPDOF;
            HistReceivablesDocument."Payment Terms ID" := GPRM20101.PYMTRMID;
            HistReceivablesDocument."Write Off Amount" := GPRM20101.WROFAMNT;
            HistReceivablesDocument.Insert();
        until GPRM20101.Next() = 0;
    end;

    local procedure PopulateRecvHistoricalDocuments()
    var
        GPRMHist: Record GPRMHist;
        HistReceivablesDocument: Record "Hist. Receivables Document";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPRM00101: Record "GP RM00101";
        CustomerName: Text[100];
        InitialHistYear: Integer;
    begin
        InitialHistYear := GPCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then
            GPRMHist.SetFilter(DOCDATE, '>=%1', System.DMY2Date(1, 1, InitialHistYear));

        if not GPRMHist.FindSet() then
            exit;

        if GPRM00101.Get(GPRMHist.CUSTNMBR) then
            CustomerName := GPRM00101.CUSTNAME;

        repeat
            Clear(HistReceivablesDocument);

#pragma warning disable AA0139
            HistReceivablesDocument."Document No." := GPRMHist.DOCNUMBR.TrimEnd();
            HistReceivablesDocument."Customer No." := GPRMHist.CUSTNMBR.TrimEnd();
#pragma warning restore AA0139

            HistReceivablesDocument."Customer Name" := CustomerName;
            HistReceivablesDocument."Document Type" := ConvertGPDocTypeToHistReceivablesDocType(GPRMHist.RMDTYPAL);
            HistReceivablesDocument."Batch No." := GPRMHist.BACHNUMB;
            HistReceivablesDocument."Batch Source" := GPRMHist.BCHSOURC;
            HistReceivablesDocument."Audit Code" := GPRMHist.TRXSORCE;
            HistReceivablesDocument."Trx. Description" := GPRMHist.TRXDSCRN;
            HistReceivablesDocument."Document Date" := GPRMHist.DOCDATE;
            HistReceivablesDocument."Due Date" := GPRMHist.DUEDATE;
            HistReceivablesDocument."Post Date" := GPRMHist.POSTDATE;
            HistReceivablesDocument."User" := GPRMHist.PSTUSRID;
            HistReceivablesDocument."Currency Code" := CopyStr(GPRMHist.CURNCYID, 1, MaxStrLen(HistReceivablesDocument."Currency Code"));
            HistReceivablesDocument."Orig. Trx. Amount" := GPRMHist.ORTRXAMT;
            HistReceivablesDocument."Current Trx. Amount" := GPRMHist.CURTRXAM;
            HistReceivablesDocument."Sales Amount" := GPRMHist.SLSAMNT;
            HistReceivablesDocument."Cost Amount" := GPRMHist.COSTAMNT;
            HistReceivablesDocument."Freight Amount" := GPRMHist.FRTAMNT;
            HistReceivablesDocument."Misc. Amount" := GPRMHist.MISCAMNT;
            HistReceivablesDocument."Tax Amount" := GPRMHist.TAXAMNT;
            HistReceivablesDocument."Disc. Taken Amount" := GPRMHist.DISTKNAM;
            HistReceivablesDocument."Customer Purchase No." := GPRMHist.CSPORNBR;
            HistReceivablesDocument."Salesperson No." := GPRMHist.SLPRSNID;
            HistReceivablesDocument."Sales Territory" := GPRMHist.SLSTERCD;
            HistReceivablesDocument."Ship Method" := GPRMHist.SHIPMTHD;
            HistReceivablesDocument."Cash Amount" := GPRMHist.CASHAMNT;
            HistReceivablesDocument."Commission Dollar Amount" := GPRMHist.COMDLRAM;
            HistReceivablesDocument."Invoice Paid Off Date" := GPRMHist.DINVPDOF;
            HistReceivablesDocument."Payment Terms ID" := GPRMHist.PYMTRMID;
            HistReceivablesDocument."Write Off Amount" := GPRMHist.WROFAMNT;
            HistReceivablesDocument.Insert();
        until GPRMHist.Next() = 0;
    end;

    local procedure PopulatePayablesDocuments()
    begin
        PopulatePayablesOpenDocuments();
        PopulatePayablesHistoricalDocuments();
    end;

    local procedure PopulatePayablesOpenDocuments()
    var
        GPPM20000: Record "GP PM20000";
        HistPayablesDocument: Record "Hist. Payables Document";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        InitialHistYear: Integer;
    begin
        InitialHistYear := GPCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then
            GPPM20000.SetFilter(DOCDATE, '>=%1', System.DMY2Date(1, 1, InitialHistYear));

        if not GPPM20000.FindSet() then
            exit;

        repeat
            Clear(HistPayablesDocument);

#pragma warning disable AA0139
            HistPayablesDocument."Document No." := GPPM20000.DOCNUMBR.TrimEnd();
            HistPayablesDocument."Voucher No." := GPPM20000.VCHRNMBR.TrimEnd();
            HistPayablesDocument."Vendor No." := GPPM20000.VENDORID.TrimEnd();
#pragma warning restore AA0139

            HistPayablesDocument."Document Type" := ConvertGPDocTypeToHistPayablesDocType(GPPM20000.DOCTYPE);
            HistPayablesDocument."Document Date" := GPPM20000.DOCDATE;
            HistPayablesDocument."Document Amount" := GPPM20000.DOCAMNT;
            HistPayablesDocument."Currency Code" := CopyStr(GPPM20000.CURNCYID, 1, MaxStrLen(HistPayablesDocument."Currency Code"));
            HistPayablesDocument."Current Trx. Amount" := GPPM20000.CURTRXAM;
            HistPayablesDocument."Disc. Taken Amount" := GPPM20000.DISTKNAM;
            HistPayablesDocument."Batch Source" := GPPM20000.BCHSOURC;
            HistPayablesDocument."Batch No." := GPPM20000.BACHNUMB;
            HistPayablesDocument."Due Date" := GPPM20000.DUEDATE;
            HistPayablesDocument."Purchase No." := GPPM20000.PORDNMBR;
            HistPayablesDocument."Audit Code" := GPPM20000.TRXSORCE;
            HistPayablesDocument."Trx. Description" := GPPM20000.TRXDSCRN;
            HistPayablesDocument."Post Date" := DT2Date(GPPM20000.POSTEDDT);
            HistPayablesDocument."User" := GPPM20000.PTDUSRID;
            HistPayablesDocument."Misc. Amount" := GPPM20000.MSCCHAMT;
            HistPayablesDocument."Freight Amount" := GPPM20000.FRTAMNT;
            HistPayablesDocument."Tax Amount" := GPPM20000.TAXAMNT;
            HistPayablesDocument."Total Payments" := GPPM20000.TTLPYMTS;
            HistPayablesDocument."Voided" := GPPM20000.VOIDED;
            HistPayablesDocument."Invoice Paid Off Date" := DT2Date(GPPM20000.DINVPDOF);
            HistPayablesDocument."Ship Method" := GPPM20000.SHIPMTHD;
            HistPayablesDocument."1099 Amount" := GPPM20000.TEN99AMNT;
            HistPayablesDocument."Write Off Amount" := GPPM20000.WROFAMNT;
            HistPayablesDocument."Trade Discount Amount" := GPPM20000.TRDISAMT;
            HistPayablesDocument."Payment Terms ID" := GPPM20000.PYMTRMID;
            HistPayablesDocument."1099 Type" := Get1099TypeText(GPPM20000.TEN99TYPE);
            HistPayablesDocument."1099 Box Number" := Format(GPPM20000.TEN99BOXNUMBER);
            HistPayablesDocument."PO Number" := GPPM20000.PONUMBER;
            HistPayablesDocument.Insert();
        until GPPM20000.Next() = 0;
    end;

    local procedure PopulatePayablesHistoricalDocuments()
    var
        GPPMHist: Record GPPMHist;
        HistPayablesDocument: Record "Hist. Payables Document";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        InitialHistYear: Integer;
    begin
        InitialHistYear := GPCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then
            GPPMHist.SetFilter(DOCDATE, '>=%1', System.DMY2Date(1, 1, InitialHistYear));

        if not GPPMHist.FindSet() then
            exit;

        repeat
            Clear(HistPayablesDocument);

#pragma warning disable AA0139
            HistPayablesDocument."Document No." := GPPMHist.DOCNUMBR.TrimEnd();
            HistPayablesDocument."Voucher No." := GPPMHist.VCHRNMBR.TrimEnd();
            HistPayablesDocument."Vendor No." := GPPMHist.VENDORID.TrimEnd();
#pragma warning restore AA0139

            HistPayablesDocument."Document Type" := ConvertGPDocTypeToHistPayablesDocType(GPPMHist.DOCTYPE);
            HistPayablesDocument."Document Date" := GPPMHist.DOCDATE;
            HistPayablesDocument."Document Amount" := GPPMHist.DOCAMNT;
            HistPayablesDocument."Currency Code" := CopyStr(GPPMHist.CURNCYID, 1, MaxStrLen(HistPayablesDocument."Currency Code"));
            HistPayablesDocument."Current Trx. Amount" := GPPMHist.CURTRXAM;
            HistPayablesDocument."Disc. Taken Amount" := GPPMHist.DISTKNAM;
            HistPayablesDocument."Batch Source" := GPPMHist.BCHSOURC;
            HistPayablesDocument."Batch No." := GPPMHist.BACHNUMB;
            HistPayablesDocument."Due Date" := GPPMHist.DUEDATE;
            HistPayablesDocument."Purchase No." := GPPMHist.PORDNMBR;
            HistPayablesDocument."Audit Code" := GPPMHist.TRXSORCE;
            HistPayablesDocument."Trx. Description" := GPPMHist.TRXDSCRN;
            HistPayablesDocument."Post Date" := GPPMHist.POSTEDDT;
            HistPayablesDocument."User" := GPPMHist.PTDUSRID;
            HistPayablesDocument."Misc. Amount" := GPPMHist.MSCCHAMT;
            HistPayablesDocument."Freight Amount" := GPPMHist.FRTAMNT;
            HistPayablesDocument."Tax Amount" := GPPMHist.TAXAMNT;
            HistPayablesDocument."Total Payments" := GPPMHist.TTLPYMTS;
            HistPayablesDocument."Voided" := GPPMHist.VOIDED;
            HistPayablesDocument."Invoice Paid Off Date" := GPPMHist.DINVPDOF;
            HistPayablesDocument."Ship Method" := GPPMHist.SHIPMTHD;
            HistPayablesDocument."1099 Amount" := GPPMHist.TEN99AMNT;
            HistPayablesDocument."Write Off Amount" := GPPMHist.WROFAMNT;
            HistPayablesDocument."Trade Discount Amount" := GPPMHist.TRDISAMT;
            HistPayablesDocument."Payment Terms ID" := GPPMHist.PYMTRMID;
            HistPayablesDocument."1099 Type" := Get1099TypeText(GPPMHist.TEN99TYPE);
            HistPayablesDocument."1099 Box Number" := Format(GPPMHist.TEN99BOXNUMBER);
            HistPayablesDocument."PO Number" := GPPMHist.PONUMBER;
            HistPayablesDocument.Insert();
        until GPPMHist.Next() = 0;
    end;

    local procedure PopulateInventoryTransactions()
    var
        GPIVTrxHist: Record GPIVTrxHist;
        HistInventoryTrxHeader: Record "Hist. Inventory Trx. Header";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        InitialHistYear: Integer;
        DocumentNo: Code[35];
    begin
        InitialHistYear := GPCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then
            GPIVTrxHist.SetFilter(DOCDATE, '>=%1', System.DMY2Date(1, 1, InitialHistYear));

        if not GPIVTrxHist.FindSet() then
            exit;

        repeat
            Clear(HistInventoryTrxHeader);

#pragma warning disable AA0139
            DocumentNo := GPIVTrxHist.DOCNUMBR.TrimEnd();
#pragma warning restore AA0139

            HistInventoryTrxHeader."Audit Code" := GPIVTrxHist.TRXSORCE;
            HistInventoryTrxHeader."Document Type" := ConvertGPDocTypeToHistInventoryDocType(GPIVTrxHist.IVDOCTYP);
            HistInventoryTrxHeader."Document No." := DocumentNo;
            HistInventoryTrxHeader."Document Date" := GPIVTrxHist.DOCDATE;
            HistInventoryTrxHeader."Batch No." := GPIVTrxHist.BACHNUMB;
            HistInventoryTrxHeader."Batch Source" := GPIVTrxHist.BCHSOURC;
            HistInventoryTrxHeader."Post Date" := GPIVTrxHist.GLPOSTDT;
            HistInventoryTrxHeader."Source Reference No." := GPIVTrxHist.SRCRFRNCNMBR;
            HistInventoryTrxHeader."Source Indicator" := GetInventoryTrxSourceIndicatorText(GPIVTrxHist.SOURCEINDICATOR);
            HistInventoryTrxHeader.Insert();

            PopulateInventoryTrxLines(GPIVTrxHist, DocumentNo);
        until GPIVTrxHist.Next() = 0;
    end;

    local procedure PopulateInventoryTrxLines(GPIVTrxHist: Record GPIVTrxHist; DocumentNo: Code[35])
    var
        GPIVTrxAmountsHist: Record GPIVTrxAmountsHist;
        HistInventoryTrxLine: Record "Hist. Inventory Trx. Line";
    begin
        GPIVTrxAmountsHist.SetRange(TRXSORCE, GPIVTrxHist.TRXSORCE);
        GPIVTrxAmountsHist.SetRange(DOCNUMBR, GPIVTrxHist.DOCNUMBR);

        if not GPIVTrxAmountsHist.FindSet() then
            exit;

        repeat
            Clear(HistInventoryTrxLine);

#pragma warning disable AA0139
            HistInventoryTrxLine."Item No." := GPIVTrxAmountsHist.ITEMNMBR.TrimEnd();
            HistInventoryTrxLine."Customer No." := GPIVTrxAmountsHist.CUSTNMBR.TrimEnd();
#pragma warning restore AA0139

            HistInventoryTrxLine."Audit Code" := GPIVTrxAmountsHist.TRXSORCE;
            HistInventoryTrxLine."Document Type" := ConvertGPDocTypeToHistInventoryDocType(GPIVTrxAmountsHist.DOCTYPE);
            HistInventoryTrxLine."Document No." := DocumentNo;
            HistInventoryTrxLine."Line Item Sequence" := GPIVTrxAmountsHist.LNSEQNBR;
            HistInventoryTrxLine."Date" := GPIVTrxAmountsHist.DOCDATE;
            HistInventoryTrxLine."Source Description" := GPIVTrxAmountsHist.HSTMODUL;
            HistInventoryTrxLine."Unit of Measure" := GPIVTrxAmountsHist.UOFM;
            HistInventoryTrxLine."Quantity" := GPIVTrxAmountsHist.TRXQTY;
            HistInventoryTrxLine."Unit Cost" := GPIVTrxAmountsHist.UNITCOST;
            HistInventoryTrxLine."Ext. Cost" := GPIVTrxAmountsHist.EXTDCOST;
            HistInventoryTrxLine."Location Code" := GPIVTrxAmountsHist.TRXLOCTN;
            HistInventoryTrxLine."Transfer To Location Code" := GPIVTrxAmountsHist.TRNSTLOC;
            HistInventoryTrxLine."Reason Code" := GPIVTrxAmountsHist.Reason_Code;
            HistInventoryTrxLine.Insert();
        until GPIVTrxAmountsHist.Next() = 0;
    end;

    local procedure PopulatePurchaseRecvTransactions()
    var
        GPPOPReceiptHist: Record GPPOPReceiptHist;
        HistPurchaseRecvHeader: Record "Hist. Purchase Recv. Header";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        InitialHistYear: Integer;
        ReceiptNo: Code[35];
    begin
        InitialHistYear := GPCompanyAdditionalSettings.GetHistInitialYear();
        if InitialHistYear > 0 then
            GPPOPReceiptHist.SetFilter("receiptdate", '>=%1', System.DMY2Date(1, 1, InitialHistYear));

        if not GPPOPReceiptHist.FindSet() then
            exit;

        repeat
            Clear(HistPurchaseRecvHeader);

#pragma warning disable AA0139
            ReceiptNo := GPPOPReceiptHist.POPRCTNM.TrimEnd();
            HistPurchaseRecvHeader."Vendor No." := GPPOPReceiptHist.VENDORID.TrimEnd();
#pragma warning restore AA0139

            HistPurchaseRecvHeader."Receipt No." := ReceiptNo;
            HistPurchaseRecvHeader."Document Type" := ConvertGPDocTypeToHistPurchaseRecvDocType(GPPOPReceiptHist.POPTYPE);
            HistPurchaseRecvHeader."Vendor Document No." := GPPOPReceiptHist.VNDDOCNM;
            HistPurchaseRecvHeader."Receipt Date" := GPPOPReceiptHist.receiptdate;
            HistPurchaseRecvHeader."Post Date" := GPPOPReceiptHist.GLPOSTDT;
            HistPurchaseRecvHeader."Actual Ship Date" := GPPOPReceiptHist.ACTLSHIP;
            HistPurchaseRecvHeader."Batch No." := GPPOPReceiptHist.BACHNUMB;
            HistPurchaseRecvHeader."Vendor Name" := GPPOPReceiptHist.VENDNAME;
            HistPurchaseRecvHeader."Subtotal" := GPPOPReceiptHist.SUBTOTAL;
            HistPurchaseRecvHeader."Trade Discount Amount" := GPPOPReceiptHist.TRDISAMT;
            HistPurchaseRecvHeader."Freight Amount" := GPPOPReceiptHist.FRTAMNT;
            HistPurchaseRecvHeader."Misc. Amount" := GPPOPReceiptHist.MISCAMNT;
            HistPurchaseRecvHeader."Tax Amount" := GPPOPReceiptHist.TAXAMNT;
            HistPurchaseRecvHeader."1099 Amount" := GPPOPReceiptHist.TEN99AMNT;
            HistPurchaseRecvHeader."Payment Terms ID" := GPPOPReceiptHist.PYMTRMID;
            HistPurchaseRecvHeader."Discount Percent Amount" := GPPOPReceiptHist.DSCPCTAM;
            HistPurchaseRecvHeader."Discount Dollar Amount" := GPPOPReceiptHist.DSCDLRAM;
            HistPurchaseRecvHeader."Discount Available Amount" := GPPOPReceiptHist.DISAVAMT;
            HistPurchaseRecvHeader."Discount Date" := GPPOPReceiptHist.DISCDATE;
            HistPurchaseRecvHeader."Due Date" := GPPOPReceiptHist.DUEDATE;
            HistPurchaseRecvHeader."Reference" := GPPOPReceiptHist.REFRENCE;
            HistPurchaseRecvHeader."Void" := ConvertGPVoidOptionToBoolean(GPPOPReceiptHist.VOIDSTTS);
            HistPurchaseRecvHeader."User" := GPPOPReceiptHist.PTDUSRID;
            HistPurchaseRecvHeader."Audit Code" := GPPOPReceiptHist.TRXSORCE;
            HistPurchaseRecvHeader."Voucher No." := GPPOPReceiptHist.VCHRNMBR;
            HistPurchaseRecvHeader."Currency Code" := GPPOPReceiptHist.CURNCYID;
            HistPurchaseRecvHeader."Invoice Receipt Date" := GPPOPReceiptHist.InvoiceReceiptDate;
            HistPurchaseRecvHeader."Prepayment Amount" := GPPOPReceiptHist.PrepaymentAmount;
            HistPurchaseRecvHeader.Insert();

            PopulatePurchaseRecvLines(GPPOPReceiptHist, ReceiptNo);
        until GPPOPReceiptHist.Next() = 0;
    end;

    local procedure PopulatePurchaseRecvLines(GPPOPReceiptHist: Record GPPOPReceiptHist; ReceiptNo: Code[35])
    var
        GPPOPReceiptLineHist: Record GPPOPReceiptLineHist;
        GPPOPReceiptApply: Record GPPOPReceiptApply;
        HistPurchaseRecvLine: Record "Hist. Purchase Recv. Line";
    begin
        GPPOPReceiptLineHist.SetRange(POPRCTNM, GPPOPReceiptHist.POPRCTNM);

        if not GPPOPReceiptLineHist.FindSet() then
            exit;

        repeat
            Clear(HistPurchaseRecvLine);

#pragma warning disable AA0139
            HistPurchaseRecvLine."PO Number" := GPPOPReceiptLineHist.PONUMBER.TrimEnd();
            HistPurchaseRecvLine."Item No." := GPPOPReceiptLineHist.ITEMNMBR.TrimEnd();
#pragma warning restore AA0139

            HistPurchaseRecvLine."Receipt No." := ReceiptNo;
            HistPurchaseRecvLine."Line No." := GPPOPReceiptLineHist.RCPTLNNM;
            HistPurchaseRecvLine."Item Desc." := CopyStr(GPPOPReceiptLineHist.ITEMDESC, 1, MaxStrLen(HistPurchaseRecvLine."Item Desc."));
            HistPurchaseRecvLine."Vendor Item No." := GPPOPReceiptLineHist.VNDITNUM;
            HistPurchaseRecvLine."Vendor Item Desc." := CopyStr(GPPOPReceiptLineHist.VNDITDSC, 1, MaxStrLen(HistPurchaseRecvLine."Vendor Item Desc."));
            HistPurchaseRecvLine."Base UofM Qty." := GPPOPReceiptLineHist.UMQTYINB;
            HistPurchaseRecvLine."Actual Ship Date" := GPPOPReceiptLineHist.ACTLSHIP;
            HistPurchaseRecvLine."Unit of Measure" := GPPOPReceiptLineHist.UOFM;
            HistPurchaseRecvLine."Unit Cost" := GPPOPReceiptLineHist.UNITCOST;
            HistPurchaseRecvLine."Ext. Cost" := GPPOPReceiptLineHist.EXTDCOST;
            HistPurchaseRecvLine."Tax Amount" := GPPOPReceiptLineHist.TAXAMNT;
            HistPurchaseRecvLine."Location Code" := GPPOPReceiptLineHist.LOCNCODE;
            HistPurchaseRecvLine."Audit Code" := GPPOPReceiptLineHist.TRXSORCE;
            HistPurchaseRecvLine."Ship Method" := GPPOPReceiptLineHist.SHIPMTHD;
            HistPurchaseRecvLine."Orig. Unit Cost" := GPPOPReceiptLineHist.ORUNTCST;
            HistPurchaseRecvLine."Orig. Ext. Cost" := GPPOPReceiptLineHist.OREXTCST;
            HistPurchaseRecvLine."Orig. Disc. Taken Amount" := GPPOPReceiptLineHist.ORDISTKN;
            HistPurchaseRecvLine."Orig. Trade Disc. Amount" := GPPOPReceiptLineHist.ORTDISAM;
            HistPurchaseRecvLine."Orig. Freight Amount" := GPPOPReceiptLineHist.ORFRTAMT;
            HistPurchaseRecvLine."Orig. Misc. Amount" := GPPOPReceiptLineHist.ORMISCAMT;

            GPPOPReceiptApply.SetRange(POPRCTNM, GPPOPReceiptLineHist.POPRCTNM);
            GPPOPReceiptApply.SetRange(RCPTLNNM, GPPOPReceiptLineHist.RCPTLNNM);
            if GPPOPReceiptApply.FindFirst() then begin
                HistPurchaseRecvLine."Quantity Shipped" := GPPOPReceiptApply.QTYSHPPD;
                HistPurchaseRecvLine."Quantity Invoiced" := GPPOPReceiptApply.QTYINVCD;
            end;

            HistPurchaseRecvLine.Insert();
        until GPPOPReceiptLineHist.Next() = 0;
    end;

    local procedure ConvertSeriesToSourceType(Series: Integer; SourceDocType: Code[35]): enum "Hist. Source Type";
    var
        HistSourceType: enum "Hist. Source Type";
    begin
        HistSourceType := "Hist. Source Type"::Other;

        case Series of
            3:
                HistSourceType := "Hist. Source Type"::Receivables;
            4:
                HistSourceType := "Hist. Source Type"::Payables;
            5:
                HistSourceType := "Hist. Source Type"::Inventory;
        end;

        if HistSourceType = "Hist. Source Type"::Payables then
            if SourceDocType = 'RECVG' then
                HistSourceType := "Hist. Source Type"::"Purchase Receivables";

        exit(HistSourceType);
    end;

    local procedure ConvertGPSOPTypeToHistSalesTrxType(SOPTYPE: Integer): enum "Hist. Sales Trx. Type";
    begin
        case SOPTYPE of
            1:
                exit("Hist. Sales Trx. Type"::Quote);
            2:
                exit("Hist. Sales Trx. Type"::"Order");
            3:
                exit("Hist. Sales Trx. Type"::Invoice);
            4:
                exit("Hist. Sales Trx. Type"::"Return Order");
            5:
                exit("Hist. Sales Trx. Type"::"Back Order");
            6:
                exit("Hist. Sales Trx. Type"::"Fulfillment Order");
        end;

        exit("Hist. Sales Trx. Type"::Unknown);
    end;

    local procedure ConvertSOPStatusToSalesTrxStatus(SOPSTATUS: Integer): enum "Hist. Sales Trx. Status";
    begin
        case SOPSTATUS of
            1:
                exit("Hist. Sales Trx. Status"::"New");
            2:
                exit("Hist. Sales Trx. Status"::"Ready to Print Pick Ticket");
            3:
                exit("Hist. Sales Trx. Status"::"Unconfirmed Pick");
            4:
                exit("Hist. Sales Trx. Status"::"Ready to Print Pack Slip");
            5:
                exit("Hist. Sales Trx. Status"::"Unconfirmed Pack");
            6:
                exit("Hist. Sales Trx. Status"::Shipped);
            7:
                exit("Hist. Sales Trx. Status"::"Ready to Post");
            8:
                exit("Hist. Sales Trx. Status"::"In Process");
            9:
                exit("Hist. Sales Trx. Status"::Complete)
        end;

        exit("Hist. Sales Trx. Status"::Unknown);
    end;

    local procedure ConvertGPDocTypeToHistReceivablesDocType(GPDocTypeId: Integer): enum "Hist. Receivables Doc. Type";
    begin
        case GPDocTypeId of
            0:
                exit("Hist. Receivables Doc. Type"::Balance);
            1:
                exit("Hist. Receivables Doc. Type"::SaleOrInvoice);
            2:
                exit("Hist. Receivables Doc. Type"::"Scheduled Payment");
            3:
                exit("Hist. Receivables Doc. Type"::"Debit Memo");
            4:
                exit("Hist. Receivables Doc. Type"::"Finance Charge");
            5:
                exit("Hist. Receivables Doc. Type"::"Service Repair");
            6:
                exit("Hist. Receivables Doc. Type"::Warranty);
            7:
                exit("Hist. Receivables Doc. Type"::"Credit Memo");
            8:
                exit("Hist. Receivables Doc. Type"::Return);
            9:
                exit("Hist. Receivables Doc. Type"::Payment);
        end;

        exit("Hist. Receivables Doc. Type"::Unknown);
    end;

    local procedure ConvertGPDocTypeToHistPayablesDocType(GPDocTypeId: Integer): enum "Hist. Payables Doc. Type";
    begin
        case GPDocTypeId of
            1:
                exit("Hist. Payables Doc. Type"::Invoice);
            2:
                exit("Hist. Payables Doc. Type"::"Finance Charge");
            3:
                exit("Hist. Payables Doc. Type"::"Misc. Charges");
            4:
                exit("Hist. Payables Doc. Type"::Return);
            5:
                exit("Hist. Payables Doc. Type"::"Credit Memo");
            6:
                exit("Hist. Payables Doc. Type"::Payment);
        end;

        exit("Hist. Payables Doc. Type"::Unknown);
    end;

    local procedure Get1099TypeText(Ten99Type: Integer): Text[50];
    begin
        case Ten99Type of
            1:
                exit('Not a 1099 Vendor');
            2:
                exit('Dividend');
            3:
                exit('Interest');
            4:
                exit('Miscellaneous');
            5:
                exit('Withholding');
        end;
    end;

    local procedure ConvertGPDocTypeToHistInventoryDocType(GPDocTypeId: Integer): enum "Hist. Inventory Doc. Type";
    begin
        case GPDocTypeId of
            1:
                exit("Hist. Inventory Doc. Type"::"Inventory Adjustment");
            2:
                exit("Hist. Inventory Doc. Type"::Variance);
            3:
                exit("Hist. Inventory Doc. Type"::"Inventory Transfer");
            4:
                exit("Hist. Inventory Doc. Type"::"Purchase Receipt");
            5:
                exit("Hist. Inventory Doc. Type"::"Sales Returns");
            6:
                exit("Hist. Inventory Doc. Type"::"Sales Invoices");
            7:
                exit("Hist. Inventory Doc. Type"::"Assembly");
            8, 11:
                exit("Hist. Inventory Doc. Type"::"Inventory cost adjustment");
        end;

        exit("Hist. Inventory Doc. Type"::Unknown);
    end;

    local procedure GetInventoryTrxSourceIndicatorText(SourceIndicator: Integer): Text[65];
    begin
        case SourceIndicator of
            1:
                exit('(none)');
            2:
                exit('Issue');
            3:
                exit('Reverse Issue');
            4:
                exit('Finished Good Post');
            5:
                exit('Reverse Finished Good Post');
            6:
                exit('Stock Count');
            7:
                exit('Field Service - Service Call');
            8:
                exit('Field Service - Return Material Authorization');
            9:
                exit('Field Service - Return to Vendor');
            10:
                exit('Field Service - Work Order');
            11:
                exit('Project Accounting');
            12:
                exit('In-Transit Inventory Transfer');
        end;
    end;

    local procedure ConvertGPDocTypeToHistPurchaseRecvDocType(GPDocTypeId: Integer): enum "Hist. Purchase Recv. Doc. Type"
    begin
        case GPDocTypeId of
            1:
                exit("Hist. Purchase Recv. Doc. Type"::Shipment);
            2:
                exit("Hist. Purchase Recv. Doc. Type"::Invoice);
            3:
                exit("Hist. Purchase Recv. Doc. Type"::"Shipment/Invoice");
            4:
                exit("Hist. Purchase Recv. Doc. Type"::"Return");
            5:
                exit("Hist. Purchase Recv. Doc. Type"::"Return w/Credit");
            6:
                exit("Hist. Purchase Recv. Doc. Type"::"Inventory Return");
            7:
                exit("Hist. Purchase Recv. Doc. Type"::"Inventory Return w/Credit");
            8:
                exit("Hist. Purchase Recv. Doc. Type"::"Intransit Transfer");
        end;

        exit("Hist. Purchase Recv. Doc. Type"::Unknown);
    end;

    local procedure ConvertGPVoidOptionToBoolean(OptionIntValue: Integer): Boolean
    begin
        if OptionIntValue = 0 then
            exit(false);

        exit(true);
    end;
}