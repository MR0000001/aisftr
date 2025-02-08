({
    init: function(cmp, evt, helper) {
        var myPageRef = cmp.get("v.pageReference");
        //var PaginationList = myPageRef.state.c__PaginationList;
        var tributes = myPageRef.state.c__tributes;
        var tributesYear = myPageRef.state.c__tributesYear;
        var tributeTypology = myPageRef.state.c__tributeTypology;
        var startPage = myPageRef.state.c__startPage;
        var endPage = myPageRef.state.c__endPage;
        var totalrecords = myPageRef.state.c__totalrecords;
        var totalPages = myPageRef.state.c__totalPages;
        var showadditionalparameters = myPageRef.state.c__showadditionalparameters;
        var fiscalCode = myPageRef.state.c__fiscalCode;
        var positions = myPageRef.state.c__positions;
        var year = myPageRef.state.c__year;
        
        //console.log("@@@ PaginationList "+JSON.stringify(PaginationList));
        console.log("@@@ tributes "+tributes);
        console.log("@@@ tributesYear "+tributesYear);
        console.log("@@@ tributeTypology "+tributeTypology);
        console.log("@@@ startPage "+startPage);
        console.log("@@@ endPage "+endPage);
        console.log("@@@ totalrecords "+totalrecords);
        console.log("@@@ totalPages "+totalPages);
        console.log("@@@ lunghezza "+tributes.length);
        //cmp.set("v.PaginationList", PaginationList);
       // console.log("@@@ lunghezza "+cmp.get("v.PaginationList").length);
        cmp.set("v.tributes", tributes);
        cmp.set("v.tributesYear", tributesYear);
        cmp.set("v.tributeTypology", tributeTypology);
        cmp.set("v.startPage", startPage);
        cmp.set("v.endPage", endPage);
        cmp.set("v.totalrecords", totalrecords);
        cmp.set("v.totalPages", totalPages);
        cmp.set("v.showadditionalparameters", showadditionalparameters);
        cmp.set("v.fiscalCode", fiscalCode);
        cmp.set("v.positions", positions);
        cmp.set("v.year", year);

    }
})