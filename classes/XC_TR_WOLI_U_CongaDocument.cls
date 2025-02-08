public without sharing class XC_TR_WOLI_U_CongaDocument {

    public static void checkDocumentType(List<WorkOrderLineItem> listWOLI){ 
        List<WorkOrderLineItem> listLCLdocument = new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> listModArt26 = new List<WorkOrderLineItem>();
        //[CR729 start sooraji.sajan@accenture.com 09.05.2022]
        List<WorkOrderLineItem> listSospensione = new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> listProroga = new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> listRipresa = new List<WorkOrderLineItem>();
        //[CR729 End sooraji.sajan@accenture.com 09.05.2022]
        //[saikat.garai@accenture.com 06.01.2022 NR2251 start]
        List<WorkOrderLineItem> listChiusuraLavoriDoc = new List<WorkOrderLineItem>();
        //[saikat.garai@accenture.com 06.01.2022 NR2251 end]
        for(WorkOrderLineItem woli: listWOLI){
          if(woli.XC_RequestType__c==null){ //[CR729 sooraji.sajan@accenture.com 09.05.2022]
            if (woli.XC_LCLDocument__c != null && woli.XC_LCLDocument__c== 'LCL' && woli.XC_LCLDocumentRequired__c == true) {
                listLCLdocument.add(woli);
            }
            if (woli.XC_LCLDocument__c != null && woli.XC_LCLDocument__c== 'ModArt26'&& woli.XC_LCLDocumentRequired__c == true) {
                listModArt26.add(woli);
            }
            //[saikat.garai@accenture.com 06.01.2022 NR2251 start]
            if (woli.XC_LCLDocument__c != null && woli.XC_LCLDocument__c== 'Chiusura Lavori' && woli.XC_LCLDocumentRequired__c == true){
                listChiusuraLavoriDoc.add(woli);
            }
            //[saikat.garai@accenture.com 06.01.2022 NR2251 end]
            //[CR729 start sooraji.sajan@accenture.com 09.05.2022]
           }else{
            if (woli.XC_RequestType__c != null && woli.XC_RequestType__c== 'Sospensione' && woli.XC_LCLDocumentRequired__c == true){
                listSospensione.add(woli);
            }
            if (woli.XC_RequestType__c != null && woli.XC_RequestType__c== 'Proroga' && woli.XC_LCLDocumentRequired__c == true){
                listProroga.add(woli);
            }
            if (woli.XC_RequestType__c != null && woli.XC_RequestType__c== 'Ripresa' && woli.XC_LCLDocumentRequired__c == true){
                listRipresa.add(woli);
            }
            
            
        }
         //[CR729 End sooraji.sajan@accenture.com 09.05.2022]
        }
        if(!listLCLdocument.isEmpty()){
            XC_TR_WorkOrderLineItem_U_CongaWOLI.congaTemplateIdForWoli(listLCLdocument);
        }
         if(!listModArt26.isEmpty()){
            XC_TR_WorkOrderLineItem_U_CongaWOLI.congaTemplateIdForWoliModArt26(listModArt26);
        }
        //[saikat.garai@accenture.com 06.01.2022 NR2251 start]
        if(!listChiusuraLavoriDoc.isEmpty()){
            XC_TR_WorkOrderLineItem_U_CongaWOLI.congaTemplateIdForWoliChiusuraLavori(listChiusuraLavoriDoc);
        }
        //[saikat.garai@accenture.com 06.01.2022 NR2251 end]
        //[CR729 start sooraji.sajan@accenture.com 09.05.2022]
        if(!listSospensione.isEmpty()){
            XC_TR_WorkOrderLineItem_U_CongaWOLI.congaTemplateIdForWoliSospensione(listSospensione);
        }
        if(!listProroga.isEmpty()){
            XC_TR_WorkOrderLineItem_U_CongaWOLI.congaTemplateIdForWoliProroga(listProroga);
        }
        if(!listRipresa.isEmpty()){
            XC_TR_WorkOrderLineItem_U_CongaWOLI.congaTemplateIdForWoliRipresa(listRipresa);
        }
        //[CR729 ENd sooraji.sajan@accenture.com 09.05.2022]
    }
}