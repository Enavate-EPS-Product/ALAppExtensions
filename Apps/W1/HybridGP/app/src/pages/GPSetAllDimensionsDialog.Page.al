page 4052 "GP Set All Dimensions Dialog"
{
    Caption = 'Set All Company Dimensions';
    PageType = NavigatePage;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            label(HeaderText)
            {
                ApplicationArea = All;
                Caption = 'Select the two segments from Dynamics GP you would like as the global dimensions. The remaining segments will automatically be set up as shortcut dimensions.';
            }

            field("Dimension 1"; Dimension1)
            {
                Caption = 'Dimension 1';
                TableRelation = "GP Segment Name" where("Company Name" = const(''));
                ApplicationArea = Basic, Suite;
            }

            field("Dimension 2"; Dimension2)
            {
                Caption = 'Dimension 2';
                TableRelation = "GP Segment Name" where("Company Name" = const(''));
                ApplicationArea = Basic, Suite;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionOK)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'OK';
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                begin
                    ConfirmedYes := true;
                    CurrPage.Close();
                end;
            }

            action(ActionCancel)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Cancel';
                Image = Cancel;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        GenerateUniqueSegmentIndex();
    end;

    local procedure GenerateUniqueSegmentIndex()
    var
        GPSegmentName: Record "GP Segment Name";
        GPSegmentNameUnique: Record "GP Segment Name";
    begin
        GPSegmentName.SetFilter("Company Name", '<>%1', '');
        if GPSegmentName.FindSet() then begin
            repeat
                if not GPSegmentNameUnique.Get(GPSegmentName."Segment Name", '') then begin
                    GPSegmentNameUnique."Company Name" := '';
                    GPSegmentNameUnique."Segment Name" := GPSegmentName."Segment Name";
                    GPSegmentNameUnique."Segment Number" := GPSegmentName."Segment Number";
                    GPSegmentNameUnique.Insert();
                end;
            until GPSegmentName.Next() = 0;
        end;
    end;

    procedure GetDimension1(): Text[30]
    begin
        exit(Dimension1);
    end;

    procedure GetDimension2(): Text[30]
    begin
        exit(Dimension2);
    end;

    procedure GetConfirmedYes(): Boolean
    begin
        exit(ConfirmedYes);
    end;

    var
        Dimension1: Text[30];
        Dimension2: Text[30];
        ConfirmedYes: Boolean;
}