/*-----------------------------------------------
    Author:        Rocca Luca, Alessandra Gholizadeh
    Company:       Accenture Technology 
    Description:   Utility Class for Product Creation
    Test Class :   
    History
    <Date>         <Authors Name>     <Brief Description of Change> 
    2019-02-21     Rocca Luca         Created
-----------------------------------------------*/
public class XC_CPRcomponentCreationUtility {

    public static final String REQ = 'Required : ';
    public static final String ERRORCHECK ='Error checking category';
    public static final String ERRORDOCCHAR ='error in DocumentationCharacterist';
        
    public static Map<String, List<XC_CatalogMgmt__c >> requiredControl/*Product*/(List<XC_CatalogMgmt__c> xcCatalogMgmtList) {
        if(xcCatalogMgmtList == null || xcCatalogMgmtList.isEmpty()) return null;
        Boolean isValid;
        Map<String, List<XC_CatalogMgmt__c >> mapOfValidity = new Map<String, List<XC_CatalogMgmt__c >>();
        for(XC_CatalogMgmt__c catMgmtApp: xcCatalogMgmtList){ 
            catMgmtApp.Error_Message__c = REQ + '\n'; // to cancell if isValid at End
            isValid = true;
            // commercial product required controll - Start
            if(blankControl(catMgmtApp.Country__c)){
                catMgmtApp.Error_Message__c += Schema.XC_CatalogMgmt__c.fields.Country__c.getDescribe().getLabel()+'\n';
                isValid = false;
            }
            if(blankControl(catMgmtApp.Product_Type__c)){
                catMgmtApp.Error_Message__c +=  Schema.XC_CatalogMgmt__c.fields.Product_Type__c.getDescribe().getLabel()+'\n';
                isValid = false;  
            }
            if(blankControl(catMgmtApp.Product_Name__c)){
                catMgmtApp.Error_Message__c += Schema.XC_CatalogMgmt__c.fields.Product_Name__c.getDescribe().getLabel()+'\n';
                isValid = false;
            }
            if(blankControl(catMgmtApp.Product_Category_BSN__c)){
                catMgmtApp.Error_Message__c +=  Schema.XC_CatalogMgmt__c.fields.Product_Category_BSN__c.getDescribe().getLabel()+'\n';
                isValid = false;
            }
             // commercial product required controll - End
            // catalog item controll required - Start
            if(blankControl(catMgmtApp.Max_Qty__c)){
                catMgmtApp.Error_Message__c += Schema.XC_CatalogMgmt__c.fields.Max_Qty__c.getDescribe().getLabel()+'\n'; 
                isValid= false;
            }
            if(blankControl(catMgmtApp.Min_Qty__c)){
                catMgmtApp.Error_Message__c += Schema.XC_CatalogMgmt__c.fields.Min_Qty__c.getDescribe().getLabel()+'\n'; 
                isValid= false;
            }
            if(blankControl(catMgmtApp.CurrencyIsoCode)){
                catMgmtApp.Error_Message__c += Schema.XC_CatalogMgmt__c.fields.CurrencyIsoCode.getDescribe().getLabel()+'\n';
                isValid= false;
            }
            if(blankControl(catMgmtApp.RecurringCharge_Price__c)){
                catMgmtApp.Error_Message__c += Schema.XC_CatalogMgmt__c.fields.RecurringCharge_Price__c.getDescribe().getLabel()+'\n';
                isValid= false;
            } 
            if(blankControl(catMgmtApp.OneTime_Price__c)){
                catMgmtApp.Error_Message__c += Schema.XC_CatalogMgmt__c.fields.OneTime_Price__c.getDescribe().getLabel()+'\n';
                isValid= false;
            }
            // catalog item controll required - End
            if(isValid)
                catMgmtApp.Error_Message__c = null;
                
            system.debug('mapOfValidity : ' + mapOfValidity);
            system.debug('catMgmtApp : ' + catMgmtApp);
            system.debug('isValid : ' + isValid);
            mapOfValidity = insertMapObject(mapOfValidity, catMgmtApp, isValid);
            
        }
        return mapOfValidity;
    }
    
    /*public static Map<String,List<XC_CatalogMgmt__c>>  requiredControlCatalogItem (List<XC_CatalogMgmt__c> xcCatalogMgmtObj){
        if(xcCatalogMgmtObj == null || xcCatalogMgmtObj.isEmpty()) return null;
        Map<String,List<XC_CatalogMgmt__c>> mapOfValidity = new Map<String,List<XC_CatalogMgmt__c>>(); // key : {isValid, notValid} ,  value : list of XC_CatalogMgmt__c object 
        
        for(XC_CatalogMgmt__c CatalogMgmtTemp : xcCatalogMgmtObj){ 
            
            Boolean isValid = true;
            if(blankControl(CatalogMgmtTemp.Max_Qty__c)){
                CatalogMgmtTemp.Error_Message__c += Schema.XC_CatalogMgmt__c.fields.Max_Qty__c.getDescribe().getLabel()+'\n'; 
                isValid= false;
            }
            if(blankControl(CatalogMgmtTemp.Min_Qty__c)){
                CatalogMgmtTemp.Error_Message__c += Schema.XC_CatalogMgmt__c.fields.Min_Qty__c.getDescribe().getLabel()+'\n'; 
                isValid= false;
            }
            if(blankControl(CatalogMgmtTemp.CurrencyIsoCode)){
                CatalogMgmtTemp.Error_Message__c += Schema.XC_CatalogMgmt__c.fields.CurrencyIsoCode.getDescribe().getLabel()+'\n';
                isValid= false;
            }
            if(blankControl(CatalogMgmtTemp.RecurringCharge_Price__c)){
                CatalogMgmtTemp.Error_Message__c += Schema.XC_CatalogMgmt__c.fields.RecurringCharge_Price__c.getDescribe().getLabel()+'\n';
                isValid= false;
            }
            if(blankControl(CatalogMgmtTemp.OneTime_Price__c)){
                CatalogMgmtTemp.Error_Message__c += Schema.XC_CatalogMgmt__c.fields.OneTime_Price__c.getDescribe().getLabel()+'\n';
                isValid= false;
            }
            
            mapOfValidity = insertMapObject(mapOfValidity,CatalogMgmtTemp,isValid);
        }
        return mapOfValidity;
    }*/
    
    /*****************************************************************************************************************************************
    * @description Used to check if a generic entity of type Object is null/empty/blank
    * @param Object
    * @return Boolean: false if the object is not null/empty/blank 
    */
    public static Boolean blankControl(Object fieldCNT){
        
       String fieldCNTCast = String.valueOf(fieldCNT);
       return String.isBlank(fieldCNTCast) ? true : false;
        
    }
    

    public static Boolean checkEqualFields (Object field1, Object field2){
       return !blankControl(field1) ? String.valueOf(field1).equalsIgnoreCase(String.valueOf(field2)) : false;
    }
    
     /*****************************************************************************************************************************************
    * @description Used to build a map in order to divide valid records of type XC_CatalogMgmt__c from invalid ones after execution of controls
    * @param Map with key of type String and value of type List<XC_CatalogMgmt__c>
    * @param XC_CatalogMgmt__c object (to be added to the input map)
    * @param boolean to tell if the XC_CatalogMgmt__c object to be added is valid or not
    * @return the modified input map 
    */
    public static Map<String,List<XC_CatalogMgmt__c>> insertMapObject(Map<String,List<XC_CatalogMgmt__c>> mapObject, XC_CatalogMgmt__c obj, Boolean isValid){
        if(mapObject == null  ||  obj == null || isValid == null) return null;
        try{
            if(isValid){
                if(mapObject.containsKey('isValid') && mapObject.get('isValid') != null ){mapObject.get('isValid').add(obj);}
                else{
                    List<XC_CatalogMgmt__c> myListValid = new List<XC_CatalogMgmt__c>();
                    myListValid.add(obj);
                    mapObject.put('isValid', myListValid);
                }
            }
            else{
                if(mapObject.containsKey('notValid') && mapObject.get('notValid') != null ){mapObject.get('notValid').add(obj);}
                else{
                    List<XC_CatalogMgmt__c> myListNotValid = new List<XC_CatalogMgmt__c>();
                    myListNotValid.add(obj);
                    mapObject.put('notValid', myListNotValid); 
                }
            }
        }
        catch(Exception e){
            System.debug('Errore insertMapObject: '+e.getMessage()+ ' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
        }    
        return mapObject; 
    }


    public static Map<String, List<XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper>>  insertMapObject(Map<String, List<XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper>> mapObject, XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper obj, Boolean isValid){
        if(mapObject == null  || obj == null || obj.myObj == null) return null;
        try{
            system.debug('isValid : ' + isValid);
            if(isValid){
                if(mapObject.containsKey('isValid') && mapObject.get('isValid') != null ){mapObject.get('isValid').add(obj);}
                else{
                    List<XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper> myListValid = new List<XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper>();
                    myListValid.add(obj);
                    mapObject.put('isValid', myListValid); 
                }
            }
            else{
                if(mapObject.containsKey('notValid') && mapObject.get('notValid') != null ){mapObject.get('notValid').add(obj);}
                else{
                    List<XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper> myListNotValid = new List<XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper>();
                    myListNotValid.add(obj);
                    mapObject.put('notValid', myListNotValid); 
                }
            }  
        }
        catch(Exception e){
             System.debug('Errore insertMapObjectOverload : '+e.getMessage()+ ' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
        }  
        return mapObject; 
    }


    /*******************************************************************************************************
    * @description Performs a deserialization of the Json strings containing documentation characteristics associated to some XC_CatalogMgmt__c records
    * @param List of XC_CatalogMgmt__c objects
    * @return A map with Id of XC_CatalogMgmt__c as key and list of corresponding NE__DocumentationCharacterist__c as value
    */
     public static Map<Id,List<NE__DocumentationCharacterist__c>> deserializeTechnicalChar(List<XC_CatalogMgmt__c> objctList, Boolean isValid){
        if(objctList == null || objctList.isEmpty()) return null;
        Map<Id,List<NE__DocumentationCharacterist__c>> mapIdListOfDocChar= new Map<Id,List<NE__DocumentationCharacterist__c>>();
        List<NE__DocumentationCharacterist__c> myDocCharList;
        for(XC_CatalogMgmt__c objTemp : objctList){
            myDocCharList = new List<NE__DocumentationCharacterist__c>();
            XC_DoccharWrapper myWrapper = new XC_DoccharWrapper();
            Try{
                if(!String.isBlank(objTemp.Technical_Caracteristics__c))
                    myWrapper = XC_DoccharWrapper.parse(objTemp.Technical_Caracteristics__c);
                else{
                    mapIdListOfDocChar.put(objTemp.Id,null);
                    objTemp.Error_Message__c += ERRORDOCCHAR + '\n';
                    continue;
                }
            }
            Catch(Exception e){
                System.debug('Errore: '+e.getMessage()+ ' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
                mapIdListOfDocChar.put(objTemp.Id,null);
                objTemp.Error_Message__c += ERRORDOCCHAR + '\n';
                continue;
            } 
            if(isValid){
                for(XC_DoccharWrapper.DoccharList myCurrentDoc: myWrapper.doccharList){
                    NE__DocumentationCharacterist__c myDocChar = new NE__DocumentationCharacterist__c();
                    
                    // NE__Product__c required of object is M-D to CommercialProduct
                    myDocChar.Name = myCurrentDoc.Name; 
                    myDocChar.NE__Value__c = myCurrentDoc.Value;
                    if(myCurrentDoc.Filter != null)
                        myDocChar.XC_Filter__c = Boolean.valueOf(myCurrentDoc.Filter);
                    if(myCurrentDoc.Compare != null)
                        myDocChar.XC_Compare__c = Boolean.valueOf(myCurrentDoc.Compare);
                    if(myCurrentDoc.Sequence != null)
                        myDocChar.NE__Sequence__c = Integer.valueOf(myCurrentDoc.Sequence);
                    myDocCharList.add(myDocChar);
                 }
                 mapIdListOfDocChar.put(objTemp.Id, myDocCharList);
            }
        }
        return mapIdListOfDocChar;
    }
    
    public static Map<String, List<XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper>> checkCategoryAndMatrix(List<XC_CatalogMgmt__c> catMgmtList, List<XC_CatalogMgmt_CTRL__c> catMgmtCTRLlist){
        if(catMgmtList == null || catMgmtList.isEmpty() || catMgmtCTRLlist == null || catMgmtCTRLlist.isEmpty()) return null;
        system.debug('entry checkCategoryAndMatrix');
        Map<String, List<XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper>> mapOfCatMgmtWrapp = new Map<String, List<XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper>>();
        try{
            for(XC_CatalogMgmt__c catMgmtApp: catMgmtList){
                Boolean check = false;
                for(XC_CatalogMgmt_CTRL__c caMgmtCTRLApp : catMgmtCTRLlist){ 
                    if(checkEqualFields(catMgmtApp.Country__c, caMgmtCTRLApp.Country__c) && checkEqualFields(catMgmtApp.Product_Category_BSN__c, caMgmtCTRLApp.Product_Category_BSN__c)){
                       XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper myObjeWrapper = new XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper();
                       myObjeWrapper.myObj = catMgmtApp;
                       myObjeWrapper.categoryId = caMgmtCTRLApp.Catalog_CategoryId__c;
                       myObjeWrapper.catalogId = caMgmtCTRLApp.Catalog_Id__c;
                       check = true; 
                       mapOfCatMgmtWrapp = insertMapObject(mapOfCatMgmtWrapp, myObjeWrapper, check);
                       break;
                    }
                }
                if(!check){
                    system.debug('check : ' + check);
                    system.debug('catMgmtApp check false : ' + catMgmtApp);
                    XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper myObjeWrapper = new XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper();
                    catMgmtApp.Error_Message__c += ERRORCHECK + '\n';
                    myObjeWrapper.myObj = catMgmtApp;
                    mapOfCatMgmtWrapp = insertMapObject(mapOfCatMgmtWrapp, myObjeWrapper, check);
                }   
             
            }
        }
        catch(Exception e){
            System.debug('Errore checkCategoryAndMatrix : '+e.getMessage()+ ' at line: '+e.getLineNumber()+' stack trace: '+e.getStackTraceString());
        }
        return mapOfCatMgmtWrapp;  
    }  

    public class checkCategoryAndMatrixWrapper{

        public XC_CatalogMgmt__c myObj;
        public String categoryId;
        public String catalogId;

    }
    
    
    public static void catalogPublish(String RequestID){
        Map<String,String> CatalogPublishMap = NE.ManageCatalogController.callService('publish', RequestID , null);
        system.debug('CM FINISH: Catalog Publish ---> ' + CatalogPublishMap);
        
    }
    

    public static void recreatePrograms(String RequestID){
        Map<String,String> respRecreate =  NE.ManageCatalogController.callService('recreate', RequestID, '{"splitPrograms":true}');
        system.debug('CM FINISH:  respRecreate ---> '+respRecreate);
    }
    

    
}