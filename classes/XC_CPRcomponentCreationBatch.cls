global class XC_CPRcomponentCreationBatch implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{

    public static final String XCCATALOGMGMTRT  = Schema.SObjectType.XC_CatalogMgmt__c.RecordTypeInfosByName.get('Standard').RecordTypeId;
    public List<XC_CatalogMgmt_CTRL__c> objectCTRLlist = null;
    public List<NE__Catalog__c> objectCatalogList = null;
    public List<NE__Catalog_Item__c> objectCataloItemList = null;
    public List<NE__Family__c> objectFamilylist = null;
    public List<NE__ProductFamilyProperty__c> objectFamPropertylist = null;
    public List<Bit2Archetypes__Archetype__c> objectArchetypelist = null;
    public List<Bit2Archetypes__Archetype_Condition_Parameter__c> objectConditionParameterlist = null;
    public List<Bit2Archetypes__Archetype_Column_Condition__c> objectColumnConditionlist = null;
    public List<NE__Matrix_Parameter__c> objectMatrixParameterlist = null;
    global NE__Catalog__c catalogObject = null;
    global String RequestID = String.valueof(DateTime.now().getTime());
    global List<String> archetypesList = new List<String>();
    List<Bit2Archetypes.ArchetypeSuperUtilities.InstanceRowInput> inputList = new List<Bit2Archetypes.ArchetypeSuperUtilities.InstanceRowInput>(); 
    
    
    public XC_CPRcomponentCreationBatch(){
    
        if(this.objectCTRLlist == null)
            this.objectCTRLlist  = [SELECT Id,Catalog_CategoryId__c,Catalog_Id__c,Configuration_Type__c,Country__c,Generate_Asset_Item__c,Offline__c,Product_Category_BSN__c,Source_CatalogMgmtCTRL_Id__c,Families_Attributes__c,Archetype__c,Type__c,Subtype__c,Matrix_Parameter__c FROM XC_CatalogMgmt_CTRL__c];
    	if(this.objectFamilylist==null)
            this.objectFamilylist = [SELECT Id,Name FROM NE__Family__c];
        if(this.objectFamPropertylist == null)
            this.objectFamPropertylist = [SELECT Id,NE__FamilyId__c,  NE__FamilyId__r.Name, NE__PropId__c, NE__PropId__r.Name FROM NE__ProductFamilyProperty__c];
        if(this.objectArchetypelist == null)
            this.objectArchetypelist = [SELECT Id,Bit2Archetypes__Name__c FROM Bit2Archetypes__Archetype__c ];
        if(this.objectConditionParameterlist == null)
            this.objectConditionParameterlist = [SELECT Id,Bit2Archetypes__Archetype_Condition__c,Name FROM Bit2Archetypes__Archetype_Condition_Parameter__c];
        if(this.objectColumnConditionlist == null)
             this.objectColumnConditionlist = [SELECT Id,Bit2Archetypes__Archetype_Condition__c,Bit2Archetypes__Archetype__r.Bit2Archetypes__Name__c FROM Bit2Archetypes__Archetype_Column_Condition__c];
        if(this.objectCatalogList == null)
            this.objectCatalogList = [SELECT Id,NE__RequestId__c  FROM NE__Catalog__c];
        if(this.objectMatrixParameterlist == null)
            this.objectMatrixParameterlist = [SELECT Id, Name FROM NE__Matrix_Parameter__c WHERE NE__Active__c = true];
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
    
        String query;
        query= 'Select id,Name,Brand__c,Country__c,Visible_Salesforce__c,End_Date__c,Error_Message__c,Long_Description__c,Max_Qty__c,Min_Qty__c,OneTime_Price__c,Discounted_OneTime_Price__c,Product_Category_BSN__c,Product_Name__c,Product_Type__c,RecurringCharge_Price__c,Shipping_Cost__c,Short_Description__c,Source_CatalogMgmt_Id__c,Start_Date__c,Status__c,Technical_Caracteristics__c,Attribute_values__c,Product_Code__c,Metodo_de_pago__c,CurrencyIsoCode  FROM XC_CatalogMgmt__c WHERE RecordTypeId =:  XCCATALOGMGMTRT  AND Status__c = \'Approved\' ';
        return Database.getQueryLocator(query);
    
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){ 
        
        Map<String, List<XC_CatalogMgmt__c >> mapOfObjectToControll = new Map<String, List<XC_CatalogMgmt__c >>();
        system.debug('** scope size : ' + scope.size());
        List<XC_CatalogMgmt__c> myListInput = (List<XC_CatalogMgmt__c>) scope;
        system.debug('myListInput : ' + myListInput);
        /*for(XC_CatalogMgmt__c  tempCat : myListInput){
            tempCat.Status__c = 'IN PROGRESS';
        }
        update myListInput;*/
       
        mapOfObjectToControll = XC_CPRcomponentCreationUtility.requiredControl(myListInput);
        system.debug('mapOfObjectToControll : ' + mapOfObjectToControll);
        Map<String, List<XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper>> mapOfMatchingValid = XC_CPRcomponentCreationUtility.checkCategoryAndMatrix(mapOfObjectToControll.get('isValid'),this.objectCTRLlist);
        system.debug('mapOfMatchingValid : ' + mapOfMatchingValid);
        system.debug('this.objectCTRLlist : ' + this.objectCTRLlist);
        system.debug('mapOfObjectToControll.get notValid : ' + mapOfObjectToControll.get('notValid'));
        
        Map<String, List<XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper>> mapOfMatchingNotValid = XC_CPRcomponentCreationUtility.checkCategoryAndMatrix(mapOfObjectToControll.get('notValid'),this.objectCTRLlist);
        
        system.debug('mapOfMatchingNotValid : ' + mapOfMatchingNotValid);
        
        List<XC_CatalogMgmt__c> validToDocChar = new List<XC_CatalogMgmt__c>();
        List<XC_CatalogMgmt__c> notValidToDocChar = new List<XC_CatalogMgmt__c>();
        
        
        Map<String,XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper> mapIdCatalogMgmtWrapper = new Map<String,XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper>();
        
        if(mapOfMatchingValid != null && mapOfMatchingValid.containsKey('isValid') && mapOfMatchingValid.get('isValid') != null && !mapOfMatchingValid.get('isValid').isEmpty()){
            for(XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper  tempRecord : mapOfMatchingValid.get('isValid')){
                // Only update not create docChar
                validToDocChar.add(tempRecord.myObj); 
                mapIdCatalogMgmtWrapper.put(tempRecord.myObj.Id,tempRecord);
                
            }
        }
        
        if(mapOfMatchingNotValid != null && mapOfMatchingNotValid.containsKey('notValid') && mapOfMatchingNotValid.get('notValid') != null && !mapOfMatchingNotValid.get('notValid').isEmpty()){
            for(XC_CPRcomponentCreationUtility.checkCategoryAndMatrixWrapper  tempRecord : mapOfMatchingNotValid.get('notValid')){
            
                notValidToDocChar.add(tempRecord.myObj); 
                tempRecord.myObj.Status__c = 'REJECTED'; 
            }
        } 
        
        Map<Id,List<NE__DocumentationCharacterist__c>> myDocMapDocCharValid = XC_CPRcomponentCreationUtility.deserializeTechnicalChar(validToDocChar, true);
        XC_CPRcomponentCreationUtility.deserializeTechnicalChar(notValidToDocChar, false);
        
        system.debug('myDocMapDocCharValid : ' + myDocMapDocCharValid);
        system.debug('validToDocChar : ' + validToDocChar);
        system.debug('notValidToDocChar : ' + notValidToDocChar);
        
        
        //update notValidToDocChar;
         
        //NE__Catalog__c catalogObject = new NE__Catalog__c();
        catalogObject = new NE__Catalog__c();
        List<NE__DocumentationCharacterist__c> docCharListToInsert = new List<NE__DocumentationCharacterist__c>();
        List<NE__Product__c> productListToInsert = new List<NE__Product__c>();
        List<NE__ProductFamily__c> familyListToInsert = new List<NE__ProductFamily__c>();
        List<NE__Property_Override__c> propOverrideToInsert = new List<NE__Property_Override__c>();
        List<NE__Matrix_Parameter_Row__c > mprListToInsert = new List<NE__Matrix_Parameter_Row__c>();
        List<XC_CatalogMgmt__c> catalogMgmtToUpdate = new List<XC_CatalogMgmt__c>();
        List<Bit2Archetypes__Archetype_Instance__c> ArchInstanceListToInsert = new List <Bit2Archetypes__Archetype_Instance__c>();
        List<Bit2Archetypes__Archetype_Instance_Row__c> ArchInstanceRowListToInsert = new List <Bit2Archetypes__Archetype_Instance_Row__c>();
        List<NE__Catalog_Item__c> catalogItemToInsert = new List<NE__Catalog_Item__c>();
        List<NE__Catalog__c> catalogToUpsert = new List<NE__Catalog__c>();
        Map<String,NE__Catalog_Item__c> mapCatMgmtcatalogItemToInsert = new Map<String,NE__Catalog_Item__c>();
        Map<String,NE__ProductFamily__c> mapCatMgmtfamilyToInsert = new Map<String,NE__ProductFamily__c>();
        Map<String,NE__Matrix_Parameter_Row__c> mapCatMgmtMPRToInsert = new Map<String,NE__Matrix_Parameter_Row__c>();
        Map<String,Bit2Archetypes__Archetype_Instance__c>mapCatMgmtArchInstanceToInsert = new Map<String,Bit2Archetypes__Archetype_Instance__c>();
        Map<String,NE__Product__c> mapCatMgmtproductListToInsert = new Map<String,NE__Product__c>();
        Map<String,String> mapFamilyIDAttribute = new Map<String,String>();

        
        
        
        if(mapOfObjectToControll != null && mapOfObjectToControll.containsKey('isValid') && !mapOfObjectToControll.get('isValid').isEmpty() ){
            for(XC_CatalogMgmt__c tempObj : mapOfObjectToControll.get('isValid')){
            
                 //if(myDocMapDocCharValid != null && myDocMapDocCharValid.get(tempObj.Id) == null) continue;
                 
                 system.debug('entry insert object');
                 // commercial product Start
                 NE__Product__c myProd = new NE__Product__c();
                 myProd.Name = tempObj.Product_Name__c;
                 myProd.XC_LIC_Product_Name__c = tempObj.Product_Name__c;
                 myProd.NE__Description__c = tempObj.Long_Description__c;
                 myProd.XC_Short_Web_Description__c = tempObj.Short_Description__c;        
                 
                
                 productListToInsert.add(myProd);
                
                 mapCatMgmtproductListToInsert.put(tempObj.Id,myProd);
                
                
				
				//--CTRL check--
                String familiesString;
                String archetypesString;
                String matrixParamString;
				String ctrlConfType;
                
				for(XC_CatalogMgmt_CTRL__c ctrl : objectCTRLlist){
					if(ctrl.Product_Category_BSN__c == tempObj.Product_Category_BSN__c && ctrl.Country__c==tempObj.Country__c){
                        for(NE__Catalog__c tempCatalog : objectCatalogList){
                            if (ctrl.Catalog_Id__c==tempCatalog.Id )  catalogObject=tempCatalog;
                            system.debug('@@@catalogObject: ' + catalogObject);
                        }
                        myProd.XC_Product_Type__c = ctrl.Type__c;
                 		myProd.XC_Product_Subtype__c = ctrl.Subtype__c;
                        familiesString = ctrl.Families_Attributes__c;
                        archetypesString = ctrl.Archetype__c;
                        matrixParamString = ctrl.Matrix_Parameter__c;
						ctrlConfType = ctrl.Configuration_Type__c; 
                        
					}			
				}
                // commercial product End                
                
                //Product Family Start 
                system.debug('CM:: familiesString ->' + familiesString);
                
                
                if(familiesString != null && familiesString != ''){
                    
					List<String> familiesList=familiesString.split('\\;');
                    
                    system.debug('CM:: familiesList ->' + familiesList);
					String Family = '';
					String Attribute = '';
                    
                    
                    for(String tempStringFamily : familiesList){
                        if (tempStringFamily.contains('|')){
							Family = tempStringFamily.split('\\|')[0];
							Attribute = tempStringFamily.split('\\|')[1];
						}
                        for(NE__Family__c tempObjFamily : objectFamilylist ){
                            if(tempObjFamily.Name!=null && tempObjFamily.Id!=null && Family==tempObjFamily.Name){                         
                                String famid=tempObjFamily.Id;
                                mapFamilyIDAttribute.put(famid,Attribute);
                            }
                        }
                	}
                
                	system.debug('CM:: mapFamilyIDAttribute: '+mapFamilyIDAttribute);
				
                	for(String tempFamilyId : mapFamilyIDAttribute.keySet()){
                        NE__ProductFamily__c myFamily = new NE__ProductFamily__c();
                        myFamily.NE__FamilyId__c = tempFamilyId;
                        familyListToInsert.add(myFamily);
                        mapCatMgmtfamilyToInsert.put(tempObj.Id,myFamily);
                	}
                     
                    
                    
                }
				//Product Family End
				//
				//Property Override Start
				
                String Attributes = tempObj.Attribute_values__c;
                if(Attributes != '' && Attributes != null )	{
                    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(Attributes);
                    for (String key : m.keySet()){
                        Object o = m.get(key);
                        String s = JSON.serialize(o);
                        if(s != '' && s != null){
                            s = s.replace('"','');
                            s = s.replace('[','');
                            s = s.replace(']','');
                            s = s.replace(',',';');
                            system.debug(s);
                            NE__Property_Override__c property = new NE__Property_Override__c();
                            for(String tempFamAttr : mapFamilyIDAttribute.keySet()){
                                if (key==mapFamilyIDAttribute.get(tempFamAttr)) {
                                    for (NE__ProductFamilyProperty__c tempFamProp : objectFamPropertylist){
                                        if(tempFamProp.NE__PropId__r.Name == key && tempFamProp.NE__FamilyId__c==tempFamAttr){
                                            property.NE__Override_Domain_Id__c = tempFamProp.NE__PropId__c;
                                            property.NE__Override_Family_Id__c = tempFamProp.NE__FamilyId__c;
                                            property.NE__OverrideTextArea_1__c = s;
                                            property.NE__Object_Type__c = 'Property Domain';
                                        }
                                    }
                                }
                            }
                            propOverrideToInsert.add(property);
                        }
                    }
                }
				 
                //CatalogMgmt Update Start
				XC_CatalogMgmt__c catalogMGMT = new XC_CatalogMgmt__c();
				catalogMGMT.Id = tempObj.Id;
                catalogMGMT.Product_Name__c = tempObj.Product_Name__c;
                catalogMgmtToUpdate.add(catalogMGMT);
                
				//Matrix Parameter row start
				system.debug('CM:: matrixParamString ->' + matrixParamString);
                String matrixParamId;
                if(matrixParamString != null && matrixParamString != ''){                    
                    for (NE__Matrix_Parameter__c tempMP : objectMatrixParameterlist){
                        if (tempMP.Name == matrixParamString) {
                            matrixParamId = tempMP.Id;
                        }
                    }
                }
                
                if(matrixParamId != null && matrixParamId != '' && tempObj.Discounted_OneTime_Price__c != 0 && tempObj.Discounted_OneTime_Price__c != null){
                    NE__Matrix_Parameter_Row__c mpr = new NE__Matrix_Parameter_Row__c();
                    mpr.NE__Matrix_Parameter__c  = matrixParamId;
                    mpr.XC_Discounted_OneTime_price__c = tempObj.Discounted_OneTime_Price__c;
                    mpr.Product_LIC_Name__c = tempObj.Product_Name__c;
                    mpr.XC_Rule_type__c = 'Pricing';
                    mpr.CurrencyIsoCode = tempObj.CurrencyIsoCode;
                    mpr.NE__Active__c = true;
                    mprListToInsert.add(mpr);
                }
                
                
                
                //Archetype Instance Start 
                if(archetypesString != null){
                    this.archetypesList=archetypesString.split('\\;');
                    
                    system.debug('CM:: archetypesList ->' + archetypesList);
                    system.debug('CM:: objectArchetypelist ->' + objectArchetypelist);
                }
                
                
                 // Catalog Item Start
                 NE__Catalog_Item__c myCatItem = new NE__Catalog_Item__c();
                 myCatItem.XC_Brand__c = tempObj.Brand__c;
                 myCatItem.NE__Start_Date__c = tempObj.Start_Date__c;
                 myCatItem.NE__End_Date__c = tempObj.End_Date__c;
                 myCatItem.NE__UsageCode__c = tempObj.Product_Code__c;
                 myCatItem.NE__Min_Qty__c = tempObj.Min_Qty__c;
                 myCatItem.NE__Max_Qty__c = tempObj.Max_Qty__c;
                 myCatItem.XC_Category_Shipping_Cost_Override__c = tempObj.Shipping_Cost__c;
                 myCatItem.CurrencyIsoCode = tempObj.CurrencyIsoCode;
                 myCatItem.NE__Currency__c = tempObj.CurrencyIsoCode;
                 myCatItem.NE__Base_OneTime_Fee__c = tempObj.OneTime_Price__c; 
                 myCatItem.NE__Visible__c  = tempObj.Visible_Salesforce__c;
                 myCatItem.NE__BaseRecurringCharge__c = tempObj.RecurringCharge_Price__c;
                 myCatItem.NE__Catalog_Category_Name__c = mapIdCatalogMgmtWrapper.get(tempObj.Id).categoryId;
                 myCatItem.NE__Catalog_Id__c =  mapIdCatalogMgmtWrapper.get(tempObj.Id).catalogId;
                 myCatItem.NE__RequestId__c = RequestID;
				 myCatItem.NE__Configuration_Type__c = ctrlConfType;
                
                 catalogItemToInsert.add(myCatItem);
                 mapCatMgmtcatalogItemToInsert.put(tempObj.Id, myCatItem);
                 // Catalog Item End
                 
                 tempObj.Status__c = 'PROCESSED';
                 
            }
        }

        
        
        if(!productListToInsert.isEmpty())
            insert productListToInsert;
            
            
        system.debug('productListToInsert : ' + productListToInsert);
        
        if(mapCatMgmtproductListToInsert != null && mapCatMgmtproductListToInsert.keySet() != null && !mapCatMgmtproductListToInsert.keySet().isEmpty()){
            for(String tempKey : mapCatMgmtproductListToInsert.keySet()){
                
                mapCatMgmtcatalogItemToInsert.get(tempKey).NE__ProductId__c = mapCatMgmtproductListToInsert.get(tempKey).Id;
                system.debug('ProductId To Insert :: '+mapCatMgmtproductListToInsert.get(tempKey).Id);
                
				for(NE__ProductFamily__c tempProdFam : familyListToInsert){
					tempProdFam.NE__ProdId__c = mapCatMgmtproductListToInsert.get(tempKey).Id;
				}
                              
                
				
                if(myDocMapDocCharValid!=null && !myDocMapDocCharValid.isEmpty()){
                    for(NE__DocumentationCharacterist__c tempDocChar : myDocMapDocCharValid.get(tempKey)){
                        
                        tempDocChar.NE__Product__c =  mapCatMgmtproductListToInsert.get(tempKey).Id;
                        docCharListToInsert.add(tempDocChar);
                    
                    }
                }
                
                for(XC_CatalogMgmt__c tempCatMgmt : catalogMgmtToUpdate){
                    if(tempCatMgmt.Product_Name__c == mapCatMgmtproductListToInsert.get(tempKey).Name)
                       tempCatMgmt.Commercial_Product__c = mapCatMgmtproductListToInsert.get(tempKey).Id;
                }
                
            } 
        }
        
        
        if(catalogObject != null){
            catalogObject.NE__RequestId__c = RequestId;
            catalogToUpsert.add(catalogObject);
            upsert catalogToUpsert;
        } 
        
        system.debug('RequestId : ' + RequestId + 'Catalog.NE__RequestId__c : ' + catalogObject.NE__RequestId__c);

        
        
        
        if(!familyListToInsert.isEmpty())
            insert familyListToInsert;
        system.debug('familyListToInsert : ' + familyListToInsert);  
        
        if(!mprListToInsert.isEmpty())
            insert mprListToInsert;
        system.debug('mprListToInsert : ' + mprListToInsert); 
        
        
        
        
        
        if(!catalogItemToInsert.isEmpty())
            insert catalogItemToInsert;
        system.debug('catalogItemToInsert : ' + catalogItemToInsert);
        
        
        if(mapCatMgmtcatalogItemToInsert != null && mapCatMgmtcatalogItemToInsert.keySet() != null && !mapCatMgmtcatalogItemToInsert.keySet().isEmpty()){
            for(String tempCatItem : mapCatMgmtcatalogItemToInsert.keySet()){
                
                for(XC_CatalogMgmt__c tempCatMgmt : catalogMgmtToUpdate){
                    if(tempCatMgmt.Commercial_Product__c == mapCatMgmtcatalogItemToInsert.get(tempCatItem).NE__ProductId__c)
                       tempCatMgmt.Catalog_Item__c = mapCatMgmtcatalogItemToInsert.get(tempCatItem).Id;
                }
                
                for(NE__Property_Override__c tempPropOv : propOverrideToInsert){
                    tempPropOv.NE__CatalogItemId__c = mapCatMgmtcatalogItemToInsert.get(tempCatItem).Id;
                }
            }
        }
        
        
        if(!catalogMgmtToUpdate.isEmpty())
            update catalogMgmtToUpdate;
        system.debug('catalogMgmtToUpdate : ' + catalogMgmtToUpdate);
        
        
        /*
        //CREAZIONE ARCHETYPE INSTANCE ROW VECCHIA
        if(mapCatMgmtcatalogItemToInsert != null && mapCatMgmtcatalogItemToInsert.keySet() != null && !mapCatMgmtcatalogItemToInsert.keySet().isEmpty()){
            for(String tempCatItem : mapCatMgmtcatalogItemToInsert.keySet()){
            	//for(String tempStringArchetype : archetypesList){
                   // system.debug('CM:: Inside loop: tempStringArchetype -> ' + tempStringArchetype);
                    Bit2Archetypes.ArchetypeSuperUtilities.InstanceRowInput input = new Bit2Archetypes.ArchetypeSuperUtilities.InstanceRowInput();
                    input.inputsMap = new map<String,String> ();
                    Map<String,String> ConditionsParameters = new Map<String,String> ();
                	ConditionsParameters.put(a5D0D0000008OhyUAE)
                	input.inputsMap.put('archetypeName','ItemSetPriceByRegionAndAttributes');
                    if(tempStringArchetype.contains('|')){
                        List<String> ArchetypeParametersList = tempStringArchetype.split('\\|');
                        system.debug('CM:: Inside Archetypes decomposition: ArchetypeParametersList -> ' + ArchetypeParametersList);
						input.inputsMap.put('archetypeName',ArchetypeParametersList[0]);
                        if(ArchetypeParametersList.size()>0){
                            for(Integer i=1; i<ArchetypeParametersList.size(); i=i+2){
                                for(Bit2Archetypes__Archetype_Column_Condition__c tempCondColumn : objectColumnConditionlist){
                                    if(tempCondColumn.Bit2Archetypes__Archetype__r.Bit2Archetypes__Name__c == ArchetypeParametersList[0]){
                                        for(Bit2Archetypes__Archetype_Condition_Parameter__c tempCondParameter : objectConditionParameterlist){
                                            if(tempCondParameter.Bit2Archetypes__Archetype_Condition__c == tempCondColumn.Bit2Archetypes__Archetype_Condition__c && tempCondParameter.Name == ArchetypeParametersList[i]){
                                                ConditionsParameters.put(tempCondParameter.Id,ArchetypeParametersList[i+1]);
                                            }
                                        }
                                    }
                                }
                            }
                        
                            system.debug('CM:: Inside Archetypes decomposition: ConditionsParameters -> ' + ConditionsParameters);
                            system.debug('CM:: Inside Archetypes decomposition: ArchetypeName -> ' + ArchetypeParametersList[0]);
                        }
                    }
					else{
						input.inputsMap.put('archetypeName',tempStringArchetype);
					}

                    input.mapOfConditionsParameters = ConditionsParameters;
                    input.mapOfActionsParameters = new map<String,String> ();
                    input.inputsMap.put('itemId',mapCatMgmtcatalogItemToInsert.get(tempCatItem).Id);
                    input.inputsMap.put('objectType','Item');
                    input.inputsMap.put('status','Active');
                    inputList.add(input);
                    system.debug('CM:: Archetype Instance to Insert -> ' + input);
                    Bit2Archetypes.ArchetypeSuperUtilities.InstanceRowResponse resp = Bit2Archetypes.ArchetypeSuperUtilities.saveRow(inputList, mapCatMgmtcatalogItemToInsert.get(tempCatItem).Id);
                    system.debug('CM:: Archetype Instance responseMessage -> ' + resp.responseMessage);
                }
            //}
        }
        */
        

        
        if(!propOverrideToInsert.isEmpty())
            insert propOverrideToInsert;
        system.debug('propOverrideToInsert : ' + propOverrideToInsert);
        
        
        if(!docCharListToInsert.isEmpty())
            insert docCharListToInsert;
        system.debug('docCharListToInsert : ' + docCharListToInsert);
        
        
        List<XC_CatalogMgmt__c> totalListValidNotValid = new List<XC_CatalogMgmt__c>();
        if(mapOfObjectToControll != null && mapOfObjectToControll.containsKey('isValid') && mapOfObjectToControll.get('isValid') != null && !mapOfObjectToControll.get('isValid').isEmpty()) 
            totalListValidNotValid.addAll(mapOfObjectToControll.get('isValid'));
        if(notValidToDocChar != null && !notValidToDocChar.isEmpty())
            totalListValidNotValid.addAll(notValidToDocChar);
        
        if(!totalListValidNotValid.isEmpty())
            update totalListValidNotValid;
        

        
    }
        
    global void finish(Database.BatchableContext BC){
        if (catalogObject != null) {
            
            //PUBLISH
            /*system.debug('CM FINISH: CatalogRequestId ---> ' + catalogObject.NE__RequestId__c);
            XC_CPRcomponentCreationUtility.catalogPublish(RequestID);*/
            
            
            //Recreate Programs
            XC_CPRcomponentCreationUtility.recreatePrograms(RequestID);
            
            this.objectCataloItemList = [SELECT Id,NE__RequestId__c  FROM NE__Catalog_Item__c WHERE NE__RequestId__c LIKE:RequestID];
			
            //Catalog Items RequestId change
            /*this.RequestID = String.valueof(DateTime.now().getTime());
            for(NE__Catalog_Item__c tempCatalogItem : objectCataloItemList){
                tempCatalogItem.NE__RequestId__c = RequestID;
            }
            upsert this.objectCataloItemList;
            
            system.debug('CM FINISH:  Items to recreate ---> ' + objectCataloItemList);*/
            
            
            
            //CREAZIONE ARCHETYPE INSTANCE ROW
            if(objectCataloItemList != null && !objectCataloItemList.isEmpty()){
                for(NE__Catalog_Item__c tempCatItem : objectCataloItemList){
                    String catItemID = tempCatItem.Id;
                    if(archetypesList != null && !archetypesList.isEmpty()){
                        for(String tempStringArchetype : archetypesList){
                            system.debug('CM:: Inside loop: tempStringArchetype -> ' + tempStringArchetype);
                            Bit2Archetypes.ArchetypeSuperUtilities.InstanceRowInput input = new Bit2Archetypes.ArchetypeSuperUtilities.InstanceRowInput();
                            input.inputsMap = new map<String,String> ();
                            input.mapOfConditionsParameters  = new Map<String,String> ();
                            if(tempStringArchetype.contains('|')){
                                List<String> ArchetypeParametersList = tempStringArchetype.split('\\|');
                                system.debug('CM:: Inside Archetypes decomposition: ArchetypeParametersList -> ' + ArchetypeParametersList);
                                input.inputsMap.put('archetypeName',ArchetypeParametersList[0]);
                                if(ArchetypeParametersList.size()>0){
                                    for(Integer i=1; i<ArchetypeParametersList.size(); i=i+2){
                                        for(Bit2Archetypes__Archetype_Column_Condition__c tempCondColumn : objectColumnConditionlist){
                                            if(tempCondColumn.Bit2Archetypes__Archetype__r.Bit2Archetypes__Name__c == ArchetypeParametersList[0]){
                                                for(Bit2Archetypes__Archetype_Condition_Parameter__c tempCondParameter : objectConditionParameterlist){
                                                    if(tempCondParameter.Bit2Archetypes__Archetype_Condition__c == tempCondColumn.Bit2Archetypes__Archetype_Condition__c && tempCondParameter.Name == ArchetypeParametersList[i]){
                                                        String prodId = tempCondParameter.Id;
                                                        input.mapOfConditionsParameters.put(prodId,ArchetypeParametersList[i+1]);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                
                                    system.debug('CM:: Inside Archetypes decomposition: ConditionsParameters -> ' + input.mapOfConditionsParameters);
                                    system.debug('CM:: Inside Archetypes decomposition: ArchetypeName -> ' + ArchetypeParametersList[0]);
                                }
                            }
                            else{
                                input.inputsMap.put('archetypeName',tempStringArchetype);
                            }
        
                            input.mapOfActionsParameters = new map<String,String> ();
                            input.inputsMap.put('itemId',catItemID);
                            input.inputsMap.put('objectType','Item');
                            input.inputsMap.put('status','Active');
                            inputList.add(input);
                            system.debug('CM:: Archetype Instance to Insert -> ' + input);
                            Bit2Archetypes.ArchetypeSuperUtilities.InstanceRowResponse resp = Bit2Archetypes.ArchetypeSuperUtilities.saveRow(inputList, catItemID);
                            system.debug('CM:: Archetype Instance responseMessage -> ' + resp.responseMessage);
                        }
                    }
                }
            }
            

            /*
            //Catalog Items RequestId change
            this.RequestID = String.valueof(DateTime.now().getTime());
            for(NE__Catalog_Item__c tempCatalogItem : objectCataloItemList){
                tempCatalogItem.NE__RequestId__c = RequestID;
            }
            upsert this.objectCataloItemList;
            
            system.debug('CM FINISH:  Items to synch ---> ' + objectCataloItemList);
            
            Map<string,string> respsync = NE.ManageCatalogController.callService('sync', RequestID);
        	system.debug('CM FINISH: respsync ---> '+respsync);
			*/

        }
      
    }
    
}