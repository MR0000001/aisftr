/**
* @author Andrea Di Cicco
* @date Creation 15/09/2020
* @date Modification dd/mm/yyyy
* @description - 
*/
public class XC_LCC205_SendSAP {
	private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('XC_LCC205_SendSAP');
    
    public class XC_PurchaseLineSapWrapper {
    	@AuraEnabled
    	public String polId = '';
    	@AuraEnabled
    	public String Name = '';
        @AuraEnabled
    	public String product = '';
        @AuraEnabled
    	public Decimal quantity;
    	@AuraEnabled
    	public String applicantUnitDefault = '';
    	@AuraEnabled 
    	public String division = '';
    	@AuraEnabled
    	public String category = ''; 
    	@AuraEnabled
    	public Boolean readOnly = false;
        @AuraEnabled
    	public String priceBookEntryName = '';
    	@AuraEnabled
    	public String definitionOfDivision = ''; 
    	@AuraEnabled
    	public List<Map<String,String>> purchaseOrganizationMap = new List<Map<String,String>>(); 
    	@AuraEnabled
    	public List<Map<String,String>> purchaseOrganizationToDefinition = new List<Map<String,String>>(); 
    	@AuraEnabled
    	public List<Map<String,String>> divisionToDefinition = new List<Map<String,String>>(); 
    	@AuraEnabled
    	public List<Map<String,String>> divisionMap = new List<Map<String,String>>(); 
    	@AuraEnabled
    	public List<Map<String,String>> applicantUnitMap = new List<Map<String,String>>();
        @AuraEnabled
    	public String resultMessage = '';
        @AuraEnabled
    	public String purchaseOrganization;
        
    }
    
    /**
    * @author adicicco / dpalamides
    *@description retrivePoInfo
    *@param recordId the record id
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper retrivePositionInfo(String recordId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In retrivePoInfo');
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        List<Map<String,String>> purchaseGroupToDefinition = new List<Map<String,String>>(); 
        List<Map<String,String>> purchaseOrgToOrgDefinition = new List<Map<String,String>>(); 
        rw.success=false;
        List<String> purchaseGroup = new  List<String>();
        List<String> purchaseOrganization = new  List<String>();
        List<String> defOfPurchaseGroup =  new List<String>();
        List<String> defOfPurchaseOrganization =  new List<String>();
        WorkOrderLineItem po = [SELECT Id, XC_ContractId__c,  XC_ContractId__r.XC_LegalEntity__c,  XC_ContractId__r.XC_PurchasingOrganization__c,XC_ContractId__r.XC_CompanyCode__c, XC_PurchasingOrganization__c, XC_PurchasingGroup__c, Status FROM WorkOrderLineItem WHERE Id=:recordId];
        
        List<Giic_CM_PlantPurchasingOrg__mdt> data = [SELECT Giic_Company__c,Giic_PurchasingGroup__c,Giic_PurchasingGroupDefinition__c,Giic_Plant__c,Giic_PlantDefinition__c,Giic_PurchasingOrganization__c,
                                                     Giic_PurchasingOrgDefinition__c FROM Giic_CM_PlantPurchasingOrg__mdt WHERE Giic_Company__c=:po.XC_ContractId__r.XC_CompanyCode__c];


        if(po.Status != 'Approved'){
            rw.resultMessage =Label.XC_CL_WoliNotApproved;
            rw.success = false;
            rw.typeMessage ='Error';
            rw.titleMessage = '';
            return rw;
        }

        if(po.XC_ContractId__r!=null && po.XC_ContractId__r.XC_CompanyCode__c!=null){
            rw.success=true;
            rw.resultMessage = po.XC_ContractId__r.XC_CompanyCode__c;
        }else{
            rw.resultMessage = Label.giic_ErrorCompanyCode ; // 'No Company Code found!';
        }

        rw.parentObjectGlovia = po.XC_PurchasingOrganization__c;

        rw.legalEntity = po.XC_ContractId__r.XC_LegalEntity__c;
        /*if(po.giic_Contract__r.XC_LegalEntity__c=='EndesaX'){
             rw.parentObjectGlovia = po.giic_Contract__r.XC_PurchasingOrganization__c;
             purchaseOrganization.add(po.giic_Contract__r.XC_PurchasingOrganization__c);
             savePurchaseOrganization(po.Id, rw.parentObjectGlovia);

        }*/
        for(Giic_CM_PlantPurchasingOrg__mdt m : data){
            if(!purchaseGroup.contains(m.Giic_PurchasingGroup__c)){
                if(m.Giic_PurchasingGroup__c!=null){
            		purchaseGroup.add(m.Giic_PurchasingGroup__c);
                }
            }
            if(!purchaseOrganization.contains(m.Giic_PurchasingOrganization__c)){
                if(m.Giic_PurchasingOrganization__c!=null){
            		purchaseOrganization.add(m.Giic_PurchasingOrganization__c);
                }
            }
            if(!defOfPurchaseOrganization.contains(m.Giic_PurchasingOrgDefinition__c)){
             	defOfPurchaseOrganization.add(m.Giic_PurchasingOrgDefinition__c);  
            }
            
            if(m.Giic_PurchasingGroupDefinition__c!=null){
            	defOfPurchaseGroup.add(m.Giic_PurchasingGroupDefinition__c);
            }
             Map<String,String> acrMap2 = new Map<String,String>();
             acrMap2.put('key',   m.Giic_PurchasingOrganization__c);
             acrMap2.put('value', m.Giic_PurchasingOrgDefinition__c);
             purchaseOrgToOrgDefinition.add(acrMap2);
            Map<String,String> acrMap = new Map<String,String>();
            acrMap.put('key',   m.Giic_PurchasingGroup__c);
            acrMap.put('value', m.Giic_PurchasingGroupDefinition__c);
            purchaseGroupToDefinition.add(acrMap);
            
        }
        rw.typeMessage = po.XC_PurchasingGroup__c;
        rw.fieldName =  JSON.serialize(purchaseGroup);
        rw.fieldName2 = JSON.serialize(defOfPurchaseGroup);
        rw.fieldName3 = JSON.serialize(purchaseOrgToOrgDefinition);
        rw.fieldName4 = JSON.serialize(defOfPurchaseOrganization);
        rw.fieldName5 =  JSON.serialize(purchaseOrganization);
        rw.objectInfo = JSON.serialize(purchaseGroupToDefinition);
        return rw;
            
    }
    
       /**
    * @author adicicco / dpalamides
    *@description retrivePoInfo
    *@param recordId the record id
    *@return A List of XC_PurchaseLineSapWrapper
    */
    @AuraEnabled
    public static List<XC_PurchaseLineSapWrapper> retrivePoLInformation(String recordId) {
        List<XC_PurchaseLineSapWrapper> rwList = new List<XC_PurchaseLineSapWrapper>();
        List<String> purchaseGroup = new  List<String>();
        Map<Id,XC_RequiredPosition__c> idToPol = new Map<Id,XC_RequiredPosition__c>();
        Map<Id,Id> idProdRefToPOLId = new Map<Id,Id>();
        Map<Id,String> idProdRefToPOLName = new Map<Id,String>();
        List<String> defOfPurchaseGroup =  new List<String>();
        Map<String, XC_UTIL_ReadGloviaInfoODA.PricebookEntryWrapper> prodRefIdToPBE = new  Map<String, XC_UTIL_ReadGloviaInfoODA.PricebookEntryWrapper>();
        WorkOrderLineItem po = [SELECT Id, XC_PurchasingOrganization__c, XC_ContractId__c,XC_ContractId__r.XC_CompanyCode__c,
                                        (SELECT Id,XC_UnitRequisitioner__c,XC_Plant__c, XC_AccountAssignmentCategory__c, XC_PositionCode__c,XC_PricebookEntry__c, Name, XC_ProductRequired__r.Product2Id, XC_ProductRequired__r.Product2.Name,XC_Quantity__c FROM Required_Positions__r)
                                 FROM WorkOrderLineItem WHERE Id=:recordId];
        List<XC_RequiredPosition__c> poLine = po.Required_Positions__r;
        for(XC_RequiredPosition__c pol : poLine){
            idToPol.put(pol.Id, pol);
            idProdRefToPOLId.put(pol.XC_ProductRequired__r.Product2Id, pol.Id);
            idProdRefToPOLName.put(pol.XC_ProductRequired__r.Product2Id, pol.XC_PositionCode__c+' - '+pol.XC_ProductRequired__r.Product2.Name);
        }

        Map<String,XC_UTIL_ReadGloviaInfoODA.PricebookEntryWrapper>  peMap = XC_UTIL_ReadGloviaInfoODA.getPricebookEntryRecord(XC_UTIL_Sobject.getListFieldValues(poLine,'XC_PricebookEntry__c'));


          /*      new map<Id, gii__PriceBookEntry__c>([SELECT Id, Name, giic_AccountAssignmentCategory__c, giic_UnitRequisitioner__c, giic_Plant__c, gii__Product__c
                                                                                     FROM gii__PriceBookEntry__c WHERE gii__PriceBook__c =: po.giic_PriceBookId__c AND gii__Product__c IN: idProdRefToPOLId.keySet()]);
        */
        for(XC_UTIL_ReadGloviaInfoODA.PricebookEntryWrapper pen : peMap.values()){
                prodRefIdToPBE.put(pen.product, pen);
        }

        Set<String> positions = new Set<String>();
        for(XC_RequiredPosition__c pol : poLine){
            if(!positions.contains(pol.XC_PositionCode__c)) {
                XC_PurchaseLineSapWrapper r = new XC_PurchaseLineSapWrapper();
                r.polId = pol.Id;
                r.category = prodRefIdToPBE.get(pol.XC_ProductRequired__r.Product2Id)!= null ? prodRefIdToPBE.get(pol.XC_ProductRequired__r.Product2Id).accountAssignmentCategory : '';
                if (r.category == 'K' || r.category == 'P') {
                    r.readOnly = true;
                }
                if (po.XC_PurchasingOrganization__c != null) {
                    r.purchaseOrganization = po.XC_PurchasingOrganization__c;
                }
                r.priceBookEntryName = prodRefIdToPBE.get(pol.XC_ProductRequired__r.Product2Id)!= null ? prodRefIdToPBE.get(pol.XC_ProductRequired__r.Product2Id).productName : '';
                r.product = pol.XC_ProductRequired__r.Product2.Name;
                r.quantity = pol.XC_Quantity__c;
                r.Name = pol.XC_PositionCode__c;// + ' - ' + pol.XC_ProductRequired__r.Product2.Name;
                r.applicantUnitDefault = pol.XC_UnitRequisitioner__c;
                r.applicantUnitMap = populateApplicantUnitMap(po.XC_ContractId__r.XC_CompanyCode__c);
                r.division = pol.XC_Plant__c != null? pol.XC_Plant__c : prodRefIdToPBE.get(pol.XC_ProductRequired__r.Product2Id).plant;
                // if(r.division!=null){
                //   populateDivisionFieldWithDivision(r, po.giic_Contract__r.XC_CompanyCode__c);
                //}else{
                populateDivisionFieldWithoutDivision(r, po.XC_ContractId__r.XC_CompanyCode__c, po.XC_PurchasingOrganization__c);
                //}
                rwList.add(r);
                positions.add(pol.XC_PositionCode__c);
            }
        }
        return rwList;


        }


     private static void populateDivisionFieldWithoutDivision(XC_PurchaseLineSapWrapper r, String companyCode, String purchaseOrganization) {
         List<Giic_CM_PlantPurchasingOrg__mdt> data = [SELECT Giic_Company__c,Giic_PurchasingGroup__c,Giic_PurchasingGroupDefinition__c,Giic_Plant__c,Giic_PlantDefinition__c,Giic_PurchasingOrganization__c,
         Giic_PurchasingOrgDefinition__c FROM Giic_CM_PlantPurchasingOrg__mdt WHERE Giic_Company__c=:companyCode AND Giic_PurchasingOrganization__c =:purchaseOrganization];
         List<Map<String,String>> accIdAccName = new List<Map<String,String>>();
         List<Map<String,String>> divisionToDefinition = new List<Map<String,String>>();
         List<Map<String,String>> divisionMap = new List<Map<String,String>>(); 
         List<Map<String,String>> purchaseOrganizationMap = new List<Map<String,String>>(); 
         for(Giic_CM_PlantPurchasingOrg__mdt cm : data){
             Map<String,String> acrMap = new Map<String,String>();
             acrMap.put('key',   cm.Giic_PurchasingOrganization__c);
             acrMap.put('value', cm.Giic_PurchasingOrgDefinition__c);
             accIdAccName.add(acrMap);
             Map<String,String> divisionMapElemet = new Map<String,String>();
               if(divisionMapElemet.get('key') != cm.Giic_Plant__c){
                 
             divisionMapElemet.put('key',   cm.Giic_Plant__c);
             divisionMapElemet.put('value',   cm.Giic_PlantDefinition__c);
             divisionToDefinition.add(divisionMapElemet);
               }
             Map<String,String> onlyDivisionValue = new Map<String,String>();
              Map<String,String> firstElementInList = new  Map<String,String>();
            
             
             		onlyDivisionValue.put('key',   cm.Giic_Plant__c);
             		onlyDivisionValue.put('value',   cm.Giic_Plant__c);
             		divisionMap.add(onlyDivisionValue);            
                    
             Map<String,String> onlyOrganizationValue = new Map<String,String>();
             onlyOrganizationValue.put('key',   cm.Giic_PurchasingOrganization__c);
             onlyOrganizationValue.put('value',   cm.Giic_PurchasingOrganization__c);
             purchaseOrganizationMap.add(onlyOrganizationValue);
         }
         if(r.division!=null && r.division!=''){  
               Map<String,String> divisionValueFromPen = new Map<String,String>();
               Map<String,String> defValue = new Map<String,String>();
               divisionValueFromPen.put('key', r.division);
               divisionValueFromPen.put('value', r.division);
               divisionMap.add(divisionValueFromPen);
               defValue.put('key', 'undefined');
               defValue.put('value', 'undefined');
               divisionToDefinition.add(defValue);

         }
         if(!divisionMap.isEmpty()){
         		Map<String,String> first = divisionMap[0];
         		Integer j = 1;
				while (j < divisionMap.size()){
  					if(divisionMap.get(j) == first){
                		first = divisionMap.get(j);
    					divisionMap.remove(j);
  					}else{
    					j++;
  					}
				}
         }
         r.divisionToDefinition = divisionToDefinition;
         r.purchaseOrganizationToDefinition = accIdAccName;
         r.divisionMap = divisionMap;
         r.purchaseOrganizationMap = purchaseOrganizationMap;
    
     }
    
    
    private static List<Map<String,String>>  populateApplicantUnitMap(String companyCode) {
         List<Map<String,String>> applicantUnitMap = new List<Map<String,String>>(); 
    	 List<Giic_CM_ApplicantUnit__mdt> data = [SELECT Giic_Company__c, Giic_ApplicantName__c
                                                         FROM Giic_CM_ApplicantUnit__mdt WHERE Giic_Company__c=:companyCode ]; 
        for(Giic_CM_ApplicantUnit__mdt cm : data){
             Map<String,String> acrMap = new Map<String,String>();
             acrMap.put('key',   cm.Giic_ApplicantName__c);
             acrMap.put('value', cm.Giic_ApplicantName__c);
             applicantUnitMap.add(acrMap);
        }
        return applicantUnitMap;
    }
    
     /**
    * @author adicicco / dpalamides
    *@description retrivePoInfo
    *@param recordId the record id
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper savePurchaseGroup(String poId, String purchasesGroup) {
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        WorkOrderLineItem p = new WorkOrderLineItem(Id=poId, XC_PurchasingGroup__c = purchasesGroup);
        update p;
        return rw;
    }

    /**
    * @author adicicco / dpalamides
    *@description retrivePoInfo
    *@param recordId the record id
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper savePurchaseOrganization(String poId, String purchasingOrganization) {
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        WorkOrderLineItem p = new WorkOrderLineItem(Id=poId, XC_PurchasingOrganization__c = purchasingOrganization);
        update p;
        return rw;
    }

    /**
    * @author Eleni Tsiolaki - etsiolaki@deloitte.gr
    *@description NR2254 - retrieve the Invoice Issuer from the Partner Roles object based on the purchasingOrganization
    *@param paramsMap
    *@return XC_UTIL_ResultWrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper searchInvoiceIssuer(Map<String,Object> paramsMap) {
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;

        String recordId = String.valueOf(paramsMap.get('recordId'));
        String purchasingOrganization = String.valueOf(paramsMap.get('purchasingOrganization'));
        WorkOrderLineItem po = [SELECT Id, XC_PurchasingOrganization__c, XC_ContractId__c,XC_ContractId__r.XC_CompanyCode__c, XC_AccountId__c 
                                 FROM WorkOrderLineItem WHERE Id=:recordId];
        List<XC_Contract_Partner__c> cPartners = [SELECT Id, XC_Default__c, XC_AccountPartner__r.Name, XC_SupplierCode__c, XC_Partner_Role__c, XC_Contract__r.XC_SupplierCodeEF__c FROM XC_Contract_Partner__c
                                            WHERE XC_Contract__c =: po.XC_ContractId__c
                                            AND XC_PurchasingOrganization__c =:purchasingOrganization];
        List<String> invoiceIssuers = new List<String>();
        List<String> supplierCodes = new List<String>();
        for(XC_Contract_Partner__c c: cPartners) {
            String value = c.XC_AccountPartner__r.Name + ' - ' + c.XC_SupplierCode__c;
            invoiceIssuers.add(value);
            supplierCodes.add(c.XC_SupplierCode__c);
            if(c.XC_Default__c) {
                rw.fieldName = value;
            }
        }
        rw.objectInfo = JSON.serialize(invoiceIssuers);
        rw.fieldName2 = JSON.serialize(supplierCodes);
        return rw;
    }
    
    /**
    * @author adicicco / dpalamides
    *@description retrivePoInfo
    *@param recordId the record id
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper updatePOLine(String polData) {
        System.debug('Enter in updatePOLine con '+polData);
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        List<XC_RequiredPosition__c> polToUpdate = new List<XC_RequiredPosition__c>();
        //List<gii__PurchaseOrder__c> poToUpdate = new List<gii__PurchaseOrder__c>();
        Map<String, Object> optionsMap = (Map<String, Object>)JSON.deserializeUntyped(polData);

        XC_RequiredPosition__c reqPosition = [select id,XC_PositionCode__c,XC_WorkOrderLineItem__c from XC_RequiredPosition__c where id = :String.valueOf(optionsMap.get('polId'))];
        List<XC_RequiredPosition__c> reqPositionsList = [select id from XC_RequiredPosition__c where XC_WorkOrderLineItem__c = :reqPosition.XC_WorkOrderLineItem__c and XC_PositionCode__c = :reqPosition.XC_PositionCode__c];
        for(XC_RequiredPosition__c pol : reqPositionsList) {
            //XC_RequiredPosition__c pol = new XC_RequiredPosition__c();
            if (optionsMap.containsKey('polId') && String.valueOf(optionsMap.get('polId')) != null) {
                //pol.Id = String.valueOf(optionsMap.get('polId'));
                pol.XC_AccountAssignmentCategory__c= String.valueOf(optionsMap.get('category'));
                pol.XC_UnitRequisitioner__c= String.valueOf(optionsMap.get('applicantUnit'));
                pol.XC_Plant__c  = String.valueOf(optionsMap.get('division'));
                System.debug('pol.XC_Plant__c == ' + String.valueOf(optionsMap.get('division')));
                polToUpdate.add(pol);
            }
        }
       /* gii__PurchaseOrder__c po = new gii__PurchaseOrder__c();
        if(optionsMap.containsKey('purchaseOrderId') && String.valueOf(optionsMap.get('purchaseOrderId'))!=null){
            po.Id=String.valueOf(optionsMap.get('purchaseOrderId'));
          
            po.giic_PurchasingOrganization__c = String.valueOf(optionsMap.get('purchaseOrganization'));
            poToUpdate.add(po);
        }*/

        Database.SaveResult[] srList = Database.update(polToUpdate, false);
        for (Database.SaveResult sr : srList) {
        	if (!sr.isSuccess()) {
        	// Operation was successful, so get the ID of the record that was processed
        		rw.success = false;
                for(Database.Error err : sr.getErrors()) {
            		System.debug('The following error has occurred.');                    
            		System.debug(err.getStatusCode() + ': ' + err.getMessage());
            		System.debug('Fields that affected this error: ' + err.getFields());
                    rw.resultMessage = err.getMessage();
        		}
            	
            }
        }

        return rw;
        
    }

    /**
    * @author adicicco / dpalamides
    *@description retrivePoInfo
    *@param recordId the record id
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper checkAndSendToSAP(String woliId, String invoiceIssuer) {
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();

        WorkOrderLineItem woli = [select id,XC_PurchasingGroup__c,XC_PurchasingOrganization__c,
                                    (select id,
                                            XC_UnitRequisitioner__c,
                                            XC_Plant__c,
                                            XC_AccountAssignmentCategory__c from Required_Positions__r)
                                    from WorkOrderLineItem where id = :woliId limit 1];
        Boolean missingInfo = woli.XC_PurchasingOrganization__c == null || woli.XC_PurchasingGroup__c == null;

        if(missingInfo){
            rw.success = false;
            rw.resultMessage = 'Provide all required information on the Partner Engagement';
        }
        else{
            for(XC_RequiredPosition__c pos : woli.Required_Positions__r){
                missingInfo = pos.XC_AccountAssignmentCategory__c == null || pos.XC_Plant__c == null || pos.XC_UnitRequisitioner__c == null;
                if(missingInfo){
                    rw.success = false;
                    rw.resultMessage = 'Provide all required information on the positions';
                    break;
                }
            }
        }

        if(missingInfo){
            return rw;
        }else{
            //NR2254 - Eleni Tsiolaki - added the invoiceIssuer parameter
            rw = XC_UTIL_ReadGloviaInfoODA.sendODA(woliId, invoiceIssuer);
        }


        return rw;
    }

}