/**
* @author FirstName : LORENZO ORLANDUCCI
* @date Creation 11/11/2019
* @date Modification dd/mm/yyyy
* @description - 
*/
public without sharing class giic_LCC004_SendSap {  
    
    private final static Boolean DEBUGACTIVE = XC_UTIL_Debug.isActive('giic_LCC004_SendSap');
    
    public class Giic_PurchaseLineSapWrapper {
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
    	public Boolean forClosedContract = false;
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
        public map<String,String> applicantUnitNameToDesc = new map<String,String>();
        @AuraEnabled
    	public String resultMessage = '';
        @AuraEnabled
    	public String purchaseOrganization;
        @AuraEnabled
        public Boolean applicantUnitOnPBE = false;
        @AuraEnabled
        public Boolean plantOnPBE = false;
        
    }
    
    public class Giic_ApplicantUnitWrapper {
        @AuraEnabled
        public List<Map<String,String>> applicantUnitMap = new List<Map<String,String>>();
        @AuraEnabled
        public map<String,String> applicantUnitNameToDescription = new map<String,String>();
        
        
    }
    
    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description retrivePoInfo
    *@param recordId the record id
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper retrivePoInfo(String recordId) {
        XC_UTIL_Debug.debug(DEBUGACTIVE,'In retrivePoInfo');
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        List<Map<String,String>> purchaseGroupToDefinition = new List<Map<String,String>>(); 
        List<Map<String,String>> purchaseOrgToOrgDefinition = new List<Map<String,String>>(); 
        map<String,String> purchaseOrganizToDefinitionMap = new map<String,String>();
        rw.success=false;
        List<String> purchaseGroup = new  List<String>();
        List<String> purchaseOrganization = new  List<String>();
        List<String> defOfPurchaseGroup =  new List<String>();
        List<String> defOfPurchaseOrganization =  new List<String>();
        gii__PurchaseOrder__c po = [SELECT Id, giic_Contract__c,  giic_Contract__r.XC_LegalEntity__c,giic_ForClosedContract__c,  giic_Contract__r.XC_PurchasingOrganization__c,giic_Contract__r.XC_CompanyCode__c,giic_PurchasingGroup__c,giic_PurchasingOrganization__c FROM gii__PurchaseOrder__c WHERE Id=:recordId];
        
        List<Giic_CM_PlantPurchasingOrg__mdt> data = [SELECT Giic_Company__c,Giic_PurchasingGroup__c,Giic_PurchasingGroupDefinition__c,Giic_Plant__c,Giic_PlantDefinition__c,Giic_PurchasingOrganization__c,
                                                     Giic_PurchasingOrgDefinition__c FROM Giic_CM_PlantPurchasingOrg__mdt WHERE Giic_Company__c=:po.giic_Contract__r.XC_CompanyCode__c];
        
        if(po.giic_Contract__c!=null && po.giic_Contract__r.XC_CompanyCode__c!=null){
            rw.success=true;
            rw.resultMessage = po.giic_Contract__r.XC_CompanyCode__c;
        }else{
            rw.resultMessage = Label.giic_ErrorCompanyCode ; // 'No Company Code found!';
        }
        if(po.giic_PurchasingOrganization__c!=null){
                rw.parentObjectGlovia = po.giic_PurchasingOrganization__c;
               System.debug('rw.parentObjectGlovia = '+rw.parentObjectGlovia );
        }else{
            rw.parentObjectGlovia = '';
        }
        rw.legalEntity = po.giic_Contract__r.XC_LegalEntity__c;
        
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
             purchaseOrganizToDefinitionMap.put(m.Giic_PurchasingOrganization__c, m.Giic_PurchasingOrgDefinition__c);
             purchaseOrgToOrgDefinition.add(acrMap2);
             Map<String,String> acrMap = new Map<String,String>();
             acrMap.put('key',   m.Giic_PurchasingGroup__c);
             acrMap.put('value', m.Giic_PurchasingGroupDefinition__c);
             purchaseGroupToDefinition.add(acrMap);
            
        }
        /*
        if(po.giic_Contract__r.XC_LegalEntity__c=='EndesaX'){
             String correctPurchaseOrg = po.giic_Contract__r.XC_PurchasingOrganization__c;
             rw.parentObjectGlovia = correctPurchaseOrg;
             boolean alreadyAdded = false;
             for(String pstring : purchaseOrganization){
                 if(pstring == correctPurchaseOrg){
                     alreadyAdded = true;
                 }
             }
             if(!alreadyAdded){
             	purchaseOrganization.add(correctPurchaseOrg);
             	defOfPurchaseOrganization.add(purchaseOrganizToDefinitionMap.get(correctPurchaseOrg) ); 
             }
             savePurchaseOrganization(po.Id, rw.parentObjectGlovia);
              
        }
*/
        rw.typeMessage = po.giic_PurchasingGroup__c;
        rw.fieldName =  JSON.serialize(purchaseGroup);
        rw.fieldName2 = JSON.serialize(defOfPurchaseGroup);
        rw.fieldName3 = JSON.serialize(purchaseOrgToOrgDefinition);
        rw.fieldName4 = JSON.serialize(defOfPurchaseOrganization);
        rw.fieldName5 =  JSON.serialize(purchaseOrganization);
        rw.objectInfo = JSON.serialize(purchaseGroupToDefinition);
        return rw;
            
    }
    
       /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description retrivePoInfo
    *@param recordId the record id
    *@return A List of Giic_PurchaseLineSapWrapper
    */
    @AuraEnabled
    public static List<Giic_PurchaseLineSapWrapper> retrivePoLInformation(String recordId) {
        List<Giic_PurchaseLineSapWrapper> rwList = new List<Giic_PurchaseLineSapWrapper>();
        List<String> purchaseGroup = new  List<String>();
        Map<Id,gii__PurchaseOrderLine__c> idToPol = new Map<Id,gii__PurchaseOrderLine__c>();
        Map<Id,Id> idProdRefToPOLId = new Map<Id,Id>();
        Map<Id,String> idProdRefToPOLName = new Map<Id,String>();
        List<String> defOfPurchaseGroup =  new List<String>();
        Map<Id, gii__PriceBookEntry__c> prodRefIdToPBE = new  Map<Id, gii__PriceBookEntry__c>();
        gii__PurchaseOrder__c po = [SELECT Id,gii__PriceBookName__c,giic_PriceBookId__c,giic_PurchasingOrganization__c,giic_ForClosedContract__c, giic_Contract__c,giic_Contract__r.XC_CompanyCode__c,(SELECT Id,Name, gii__Product__c, giic_UnitRequisitioner__c,gii__Product__r.Name,gii__OrderQuantity__c,giic_Plant__c,giic_AccountAssignmentCategory__c FROM gii__Purchase_Order_Lines__r) FROM gii__PurchaseOrder__c WHERE Id=:recordId];
        List<gii__PurchaseOrderLine__c> poLine = po.gii__Purchase_Order_Lines__r;
        for(gii__PurchaseOrderLine__c pol : poLine){
            idToPol.put(pol.Id, pol);
            idProdRefToPOLId.put(pol.gii__Product__c, pol.Id);
            idProdRefToPOLName.put(pol.gii__Product__c, pol.Name);
        }
        if(po.giic_PriceBookId__c==null){
            Giic_PurchaseLineSapWrapper lsw = new Giic_PurchaseLineSapWrapper();                
            lsw.resultMessage = Label.giic_ErrorNoPriceBook ; // ': No PriceBook on this Purchase Order.';
            rwList.add(lsw);       
            return rwList;                 
        }
        Map<Id, gii__PriceBookEntry__c> peMap = new map<Id, gii__PriceBookEntry__c>([SELECT Id, Name, giic_AccountAssignmentCategory__c, giic_UnitRequisitioner__c, giic_Plant__c, gii__Product__c
                                                                                     FROM gii__PriceBookEntry__c WHERE gii__PriceBook__c =: po.giic_PriceBookId__c AND gii__Product__c IN: idProdRefToPOLId.keySet()]);
        
        if(peMap.values().isEmpty()){
            Giic_PurchaseLineSapWrapper lsw = new Giic_PurchaseLineSapWrapper();                
            lsw.resultMessage =  'No PriceBook Entry found on this Purchase Order';
            rwList.add(lsw);       
            return rwList;  
            
        }
        for(gii__PriceBookEntry__c pen : peMap.values()){
                prodRefIdToPBE.put(pen.gii__Product__c, pen);
        }
        for(gii__PurchaseOrderLine__c pol : poLine){
            Giic_PurchaseLineSapWrapper r = new Giic_PurchaseLineSapWrapper();
            r.polId = pol.Id;
            r.category = prodRefIdToPBE.get(pol.gii__Product__c).giic_AccountAssignmentCategory__c;
            System.debug('  r.category = '+  r.category);
            /*if(r.category == null || r.category =='' || pol.giic_AccountAssignmentCategory__c!=null){
                if(pol.giic_AccountAssignmentCategory__c!=null){
                 	r.category = pol.giic_AccountAssignmentCategory__c;
                 	System.debug('  r.category1 = '+  r.category);
                }
            }*/
            if((r.category=='K' || r.category=='P') &&  pol.giic_AccountAssignmentCategory__c == null ){
                r.readOnly = true;
                System.debug('esco con category = '+  r.category);
            }else{
                r.readOnly = false;
                if(pol.giic_AccountAssignmentCategory__c!=null){
                 	r.category = pol.giic_AccountAssignmentCategory__c;
                 	System.debug('  r.category1 = '+  r.category);
                }
            }
            
            if(po.giic_PurchasingOrganization__c!=null){
                r.purchaseOrganization = po.giic_PurchasingOrganization__c;
            }
            if(prodRefIdToPBE.containsKey(pol.gii__Product__c)){
                 r.priceBookEntryName = prodRefIdToPBE.get(pol.gii__Product__c).Name;
            }
           
            r.product = pol.gii__Product__r.Name;
            r.quantity = pol.gii__OrderQuantity__c;
            r.Name = pol.Name;
            
            
            Giic_ApplicantUnitWrapper auw = populateApplicantUnitMap(po.giic_Contract__r.XC_CompanyCode__c);
            r.applicantUnitMap = auw.applicantUnitMap;
            r.applicantUnitNameToDesc = auw.applicantUnitNameToDescription;
            
            if(pol.giic_UnitRequisitioner__c == null){
                if(prodRefIdToPBE.containsKey(pol.gii__Product__c)){
            		r.applicantUnitDefault = prodRefIdToPBE.get(pol.gii__Product__c).giic_UnitRequisitioner__c;
                    r.applicantUnitOnPBE = true;
                }
                
            }else{
                r.applicantUnitDefault  = pol.giic_UnitRequisitioner__c;
            }
            if(pol.giic_Plant__c == null){
                if(prodRefIdToPBE.containsKey(pol.gii__Product__c)){
            		r.division = prodRefIdToPBE.get(pol.gii__Product__c).giic_Plant__c;
                    r.plantOnPBE = true;
                }
            }else{
                r.division  = pol.giic_Plant__c;
            }
            System.debug('r.applicantUnitDefault = '+  r.applicantUnitDefault);
            // nuovo per NR1108
            if(po.giic_ForClosedContract__c){
                 r.applicantUnitDefault = prodRefIdToPBE.get(pol.gii__Product__c).giic_UnitRequisitioner__c;
                 r.division = prodRefIdToPBE.get(pol.gii__Product__c).giic_Plant__c;
                 r.forClosedContract = true;
                 
            }
            System.debug(' r.division = '+ r.division );
           // if(r.division!=null){
             //   populateDivisionFieldWithDivision(r, po.giic_Contract__r.XC_CompanyCode__c);
            //}else{
                populateDivisionFieldWithoutDivision(r, po.giic_Contract__r.XC_CompanyCode__c, po.giic_PurchasingOrganization__c);
            //}
            rwList.add(r);
        }
        return rwList;


        }

        /*
        for(gii__PriceBookEntry__c pen : peMap.values()){
            Giic_PurchaseLineSapWrapper r = new Giic_PurchaseLineSapWrapper();
            r.polId = idProdRefToPOLId.get(pen.gii__Product__c);
            r.category = pen.giic_AccountAssignmentCategory__c;
            if(r.category=='K' || r.category=='P' ){
                r.readOnly = true;
            }
            if(po.giic_PurchasingOrganization__c!=null){
                r.purchaseOrganization = po.giic_PurchasingOrganization__c;
            }
            r.priceBookEntryName = pen.Name;
            r.product = idToPol.get(r.polId).gii__Product__r.Name;
            r.quantity = idToPol.get(r.polId).gii__OrderQuantity__c;
            r.Name = idProdRefToPOLName.get(pen.gii__Product__c);
            r.applicantUnitDefault  = idToPol.get(r.polId).giic_UnitRequisitioner__c;
            r.applicantUnitMap = populateApplicantUnitMap(po.giic_Contract__r.XC_CompanyCode__c);
            r.division = pen.giic_Plant__c;
           // if(r.division!=null){
             //   populateDivisionFieldWithDivision(r, po.giic_Contract__r.XC_CompanyCode__c);
            //}else{
                populateDivisionFieldWithoutDivision(r, po.giic_Contract__r.XC_CompanyCode__c, po.giic_PurchasingOrganization__c);
            //}
            rwList.add(r);
        }
        return rwList;
   }
    
    
    /*
     private static void populateDivisionFieldWithDivision(Giic_PurchaseLineSapWrapper r, String companyCode) {
         System.debug('Enter in populateDivisionFieldWithDivision');
         List<Giic_CM_PlantPurchasingOrg__mdt> data = [SELECT Giic_Company__c,Giic_PurchasingGroup__c,Giic_PurchasingGroupDefinition__c,Giic_Plant__c,Giic_PlantDefinition__c,Giic_PurchasingOrganization__c,
         Giic_PurchasingOrgDefinition__c FROM Giic_CM_PlantPurchasingOrg__mdt WHERE Giic_Company__c=:companyCode AND Giic_Plant__c=: r.division];
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
             if(divisionMapElemet.get('key') != cm.Giic_Plant__c) {
             divisionMapElemet.put('key',   cm.Giic_Plant__c);
             divisionMapElemet.put('value',   cm.Giic_PlantDefinition__c);
             divisionToDefinition.add(divisionMapElemet);
             }
             Map<String,String> onlyDivisionValue = new Map<String,String>();
              if(onlyDivisionValue.get('key') != cm.Giic_Plant__c){
             onlyDivisionValue.put('key',   cm.Giic_Plant__c);
             onlyDivisionValue.put('value',   cm.Giic_Plant__c);
             divisionMap.add(onlyDivisionValue);
                  }
             Map<String,String> onlyOrganizationValue = new Map<String,String>();
             onlyOrganizationValue.put('key',   cm.Giic_PurchasingOrganization__c);
             onlyOrganizationValue.put('value',   cm.Giic_PurchasingOrganization__c);
             purchaseOrganizationMap.add(onlyOrganizationValue);
         }
         r.divisionToDefinition = divisionToDefinition;
         r.purchaseOrganizationToDefinition = accIdAccName;
         r.divisionMap = divisionMap;
         r.purchaseOrganizationMap = purchaseOrganizationMap;
        System.debug('  r.divisionToDefinition = '+  r.divisionToDefinition);
     }
*/    
     private static void populateDivisionFieldWithoutDivision(Giic_PurchaseLineSapWrapper r, String companyCode, String purchaseOrganization) {
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
    
    
    private static Giic_ApplicantUnitWrapper  populateApplicantUnitMap(String companyCode) {
        Giic_ApplicantUnitWrapper auw = new Giic_ApplicantUnitWrapper();
        List<Map<String,String>> applicantUnitMap = new List<Map<String,String>>(); 
        map<String,String> applicantNameToDescription = new  map<String,String>();
    	List<Giic_CM_ApplicantUnit__mdt> data = [SELECT Giic_Company__c, Giic_ApplicantName__c,Giic_ApplicantUnitDescription__c
                                                         FROM Giic_CM_ApplicantUnit__mdt WHERE Giic_Company__c=:companyCode ]; 
        
        for(Giic_CM_ApplicantUnit__mdt cm : data){
             Map<String,String> acrMap = new Map<String,String>();
             acrMap.put('key',   cm.Giic_ApplicantName__c);
             acrMap.put('value', cm.Giic_ApplicantName__c);
             applicantNameToDescription.put(cm.Giic_ApplicantName__c,cm.Giic_ApplicantUnitDescription__c);
             applicantUnitMap.add(acrMap);
        }
        
        auw.applicantUnitMap = applicantUnitMap;
        auw.applicantUnitNameToDescription = applicantNameToDescription;
        return auw;
    }
    
     /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description retrivePoInfo
    *@param recordId the record id
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper savePurchaseGroup(String poId, String purchasesGroup) {
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        gii__PurchaseOrder__c p = new gii__PurchaseOrder__c(Id=poId, giic_PurchasingGroup__c = purchasesGroup);
        update p;
        return rw;
    }

    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description retrivePoInfo
    *@param recordId the record id
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper savePurchaseOrganization(String poId, String purchasingOrganization) {
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        gii__PurchaseOrder__c p = new gii__PurchaseOrder__c(Id=poId, giic_PurchasingOrganization__c = purchasingOrganization);
        update p;
        return rw;
    }
    
    
    /**
    * @author Lorenzo Orlanducci - lorenzo.orlanducci@nttdata.com 
    *@description retrivePoInfo
    *@param recordId the record id
    *@return the x C UTI L result wrapper
    */
    @AuraEnabled
    public static XC_UTIL_ResultWrapper updatePOLine(String polData) {
        System.debug('Enter in updatePOLine con '+polData);
        XC_UTIL_ResultWrapper rw = new XC_UTIL_ResultWrapper();
        rw.success = true;
        List<gii__PurchaseOrderLine__c> polToUpdate = new List<gii__PurchaseOrderLine__c>();
        List<gii__PurchaseOrder__c> poToUpdate = new List<gii__PurchaseOrder__c>();
        Map<String, Object> optionsMap = (Map<String, Object>)JSON.deserializeUntyped(polData);
        gii__PurchaseOrderLine__c pol = new gii__PurchaseOrderLine__c();
        
        if(optionsMap.containsKey('polId') && String.valueOf(optionsMap.get('polId'))!=null){
            pol.Id=String.valueOf(optionsMap.get('polId'));
            pol.giic_AccountAssignmentCategory__c =  String.valueOf(optionsMap.get('category')); //modifica della P obbligatoria  = 'P'
            pol.giic_UnitRequisitioner__c= String.valueOf(optionsMap.get('applicantUnit'));
            pol.giic_Plant__c  = String.valueOf(optionsMap.get('division'));
            System.debug('pol.giic_Plant__c == '+pol.giic_Plant__c);
            polToUpdate.add(pol);
        }
        gii__PurchaseOrder__c po = new gii__PurchaseOrder__c();
        if(optionsMap.containsKey('purchaseOrderId') && String.valueOf(optionsMap.get('purchaseOrderId'))!=null){
            po.Id=String.valueOf(optionsMap.get('purchaseOrderId'));
          
            po.giic_PurchasingOrganization__c = String.valueOf(optionsMap.get('purchaseOrganization'));
            poToUpdate.add(po);
        }
        /*if(pol.Id!=null  && optionsMap.containsKey('purchaseOrderId') && String.valueOf(optionsMap.get('purchaseOrderId'))!=null){
                gii__PurchaseOrderLine__c currentPOLine = [SELECT Id,gii__Product__c,gii__PurchaseOrder__c,gii__PurchaseOrder__r.giic_PriceBookId__c FROM gii__PurchaseOrderLine__c WHERE Id=:pol.Id limit 1];
                gii__PriceBookEntry__c currentPEntry = [SELECT Id, giic_Plant__c,giic_AccountAssignmentCategory__c FROM gii__PriceBookEntry__c WHERE gii__Product__c=: currentPOLine.gii__Product__c AND gii__PriceBook__c=:currentPOLine.gii__PurchaseOrder__r.giic_PriceBookId__c LIMIT 1];
                if(pol.giic_Plant__c!=null){
                	currentPEntry.giic_Plant__c  = pol.giic_Plant__c;
                }
                if(pol.giic_AccountAssignmentCategory__c!=null){
                	currentPEntry.giic_AccountAssignmentCategory__c  = pol.giic_AccountAssignmentCategory__c;
                }
                if(po.giic_UnitRequisitioner__c!=null){
                    currentPEntry.giic_UnitRequisitioner__c = po.giic_UnitRequisitioner__c;
                }
                
                
                update currentPEntry;
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
        if(rw.success){
        	 Database.SaveResult[] srList2 = Database.update(poToUpdate, false);
        	 for (Database.SaveResult sr : srList2) {
        	 	if (!sr.isSuccess()) {
        			rw.success = false;
                    for(Database.Error err : sr.getErrors()) {
            			System.debug('The following error has occurred.');                    
            			System.debug(err.getStatusCode() + ': ' + err.getMessage());
            			System.debug('Fields that affected this error: ' + err.getFields());
                    	rw.resultMessage = err.getMessage();
        			}
            
            	}
        	 }
        }
        return rw;
        
    }
    

}