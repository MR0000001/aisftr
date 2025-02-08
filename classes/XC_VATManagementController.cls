public with sharing class XC_VATManagementController {

    public with sharing class XC_VATManagementOIsWrapper{
        @AuraEnabled
        public NE__Order__c order {get; set;}

        /*@AuraEnabled
        public List<NE__OrderItem__c> oisHijos {get; set;}*/

        @AuraEnabled
        public Map<NE__OrderItem__c, List<NE__OrderItem__c>> mapaOIPadreOIsHijos {get; set;}

        @AuraEnabled
        public NE__OrderItem__c padre {get; set;}

        @AuraEnabled
        public List<NE__OrderItem__c> hijos {get; set;}

        @AuraEnabled
        public String fullName {get; set;}

        @AuraEnabled
        public String impuesto {get; set;}
    }

    public with sharing class XC_VATManagementControllerWrapper{
        @AuraEnabled
        public List<XC_VATManagementOIsWrapper> wrappers {get; set;}

        @AuraEnabled
        public Map<Id, String> tiposImpuestos {get; set;}
    }

    @AuraEnabled
    public static List<XC_VATManagementOIsWrapper> getOIsWrapper2(Id orderId){
        Map<Id, List<NE__OrderItem__c>> mapaOIsAux = new Map<Id, List<NE__OrderItem__c>>();
        NE__Order__c order = [SELECT Id FROM NE__Order__c WHERE Id=:orderId LIMIT 1];
        List<Id> padresIds = new List<Id>();
        Map<String, List<NE__OrderItem__c>> mapaOIsName = new Map<String, List<NE__OrderItem__c>>();
        List<XC_VATManagementOIsWrapper> wrappers = new List<XC_VATManagementOIsWrapper>();

        //Buscamos ois asociados a ese order con check Apply Tax by Default desmarcado
        //List<NE__OrderItem__c> oisPadres = [SELECT Id, Name, XC_ApplyNormalTaxByDefault__c, NE__OrderId__c FROM NE__OrderItem__c WHERE NE__OrderId__c=:orderId AND XC_ApplyNormalTaxByDefault__c=false AND XC_PaymentMethodNeeded__c = true];
        List<NE__OrderItem__c> oisPadres = new List<NE__OrderItem__c>();
        List<NE__OrderItem__c> oisHijos = [SELECT Id, Name, NE__Parent_Order_Item__c, XC_ApplyNormalTaxByDefault__c, NE__OrderId__c, NE__ProdName__c, XC_Tax_Type__c, XC_Tax_Subtype__c, XC_BillingProfileLineItem__c, NE__Parent_Order_Item__r.XC_BillingProfileLineItem__c, XC_Exemptions__c, XC_Not_Subject__c, XC_Sujeto_Pasivo_ISP__c FROM NE__OrderItem__c WHERE NE__OrderId__c=:orderId AND XC_ApplyNormalTaxByDefault__c=false AND XC_PaymentMethodNeeded__c = false AND NE__Parent_Order_Item__c != null];
        
        System.debug('ALC oisHijos: '+oisHijos);
        if(!oisHijos.isEmpty()){
            for(NE__OrderItem__c oiHijo : oisHijos){
                if(mapaOIsAux.get(oiHijo.NE__Parent_Order_Item__c) == null){
                    List<NE__OrderItem__c> oisAux = new List<NE__OrderItem__c>();
                    oisAux.add(oiHijo);
                    mapaOIsAux.put(oiHijo.NE__Parent_Order_Item__c, oisAux);
                }else {
                    mapaOIsAux.get(oiHijo.NE__Parent_Order_Item__c).add(oiHijo);
                }
            }
    
            //Recogemos OIs padres para asociarlos con los hijos y tener los datos completos de ambos
            oisPadres = [SELECT Id, Name, XC_ApplyNormalTaxByDefault__c, NE__OrderId__c, NE__ProdName__c, XC_Tax_Type__c, XC_Tax_Subtype__c, XC_BillingProfileLineItem__c, XC_Exemptions__c, XC_Not_Subject__c, XC_Sujeto_Pasivo_ISP__c FROM NE__OrderItem__c WHERE Id IN: mapaOIsAux.keyset()];
            System.debug('ALC oisPadres: '+oisPadres);
    
            for(NE__OrderItem__c oiPadre : oisPadres){
                List<NE__OrderItem__c> hijos = mapaOIsAux.get(oiPadre.Id);
                System.debug('ALC oiPadre: '+oiPadre);
                //Construimos Wrapper que nos servirá para mostrar listado en componente
                XC_VATManagementOIsWrapper wrapper = new XC_VATManagementOIsWrapper();
                wrapper.order = order;
                wrapper.padre = oiPadre;
                wrapper.hijos = hijos;
                wrapper.fullName = oiPadre.Name+' '+oiPadre.NE__ProdName__c;
                System.debug('ALC wrapper: '+wrapper);
                wrappers.add(wrapper);
            }
        }else{
            List<NE__OrderItem__c> oisPadresSinHijos = [SELECT Id, Name, NE__Parent_Order_Item__c, XC_ApplyNormalTaxByDefault__c, NE__OrderId__c, NE__ProdName__c, XC_Tax_Type__c, XC_Tax_Subtype__c, XC_BillingProfileLineItem__c, NE__Parent_Order_Item__r.XC_BillingProfileLineItem__c, XC_Exemptions__c, XC_Not_Subject__c, XC_Sujeto_Pasivo_ISP__c FROM NE__OrderItem__c WHERE NE__OrderId__c=:orderId AND XC_ApplyNormalTaxByDefault__c=false];
            
            for(NE__OrderItem__c oisPadreSinHijos : oisPadresSinHijos){
                List<NE__OrderItem__c> hijos = new List<NE__OrderItem__c>();
                hijos.add(oisPadreSinHijos);
                System.debug('ALC oiPadre: '+oisPadreSinHijos);
                //Construimos Wrapper que nos servirá para mostrar listado en componente
                XC_VATManagementOIsWrapper wrapper = new XC_VATManagementOIsWrapper();
                wrapper.order = order;
                wrapper.padre = oisPadreSinHijos;
                wrapper.hijos = hijos;
                wrapper.fullName = oisPadreSinHijos.Name+' '+oisPadreSinHijos.NE__ProdName__c;
                System.debug('ALC wrapper: '+wrapper);
                wrappers.add(wrapper);
            }
        }
        

        System.debug('ALC wrappers.size(): '+wrappers.size());
        System.debug('ALC wrappers: '+wrappers);
        //System.debug('ALC wrappers[0]: '+wrappers[0]);
        //System.debug('ALC wrappers[1]: '+wrappers[1]);
        return wrappers;
    }

    @AuraEnabled
    public static Map<Id, String> getTiposImpuestos(List<XC_VATManagementOIsWrapper> wrappers){
        List<XC_BillingProfileLineItem__c> bplis;
        List<XC_Address__c> addresses;
        List<Id> bpliIds = new List<Id>();
        List<Id> addressesIds = new List<Id>();
        Map<Id, String> mapaOITipoImpuesto = new Map<Id, String>();
        Map<String, List<NE__OrderItem__c>> mapaRegionListaOIs = new Map<String, List<NE__OrderItem__c>>();
        Map<Id, List<XC_BillingProfileLineItem__c>> mapaAddressBPLIs = new Map<Id, List<XC_BillingProfileLineItem__c>>();
        Map<Id, List<NE__OrderItem__c>> mapaBPLIOIs = new Map<Id, List<NE__OrderItem__c>>();
        Map<Id, Id> mapaHijoBPLIPadre = new Map<Id, Id>();

        for(XC_VATManagementOIsWrapper wrapper : wrappers){
            System.debug('ALC padre: '+wrapper.padre);
            System.debug('ALC bpliPadre: '+wrapper.padre?.XC_BillingProfileLineItem__c);
            Id bpliPadre = wrapper.padre?.XC_BillingProfileLineItem__c;
            for(NE__OrderItem__c oiHijo : wrapper.hijos){
                List<NE__OrderItem__c> oisHijosAux = new List<NE__OrderItem__c>();
                if(oiHijo.XC_BillingProfileLineItem__c!=null){
                    bpliIds.add(oiHijo.XC_BillingProfileLineItem__c);
                }else{
                    System.debug('ALC Caso BPLI vacío, aplicamos bpli del padre: '+bpliPadre);
                    bpliIds.add(bpliPadre);
                }

                if(mapaBPLIOIs.get(oiHijo.XC_BillingProfileLineItem__c)!=null){
                    System.debug('ALC add oiHijo a mapaBPLIOIs: '+oiHijo);
                    mapaBPLIOIs.get(bpliPadre).add(oiHijo);
                }else{
                    oisHijosAux.add(oiHijo);
                    mapaBPLIOIs.put(bpliPadre, oisHijosAux);
                }

                mapaHijoBPLIPadre.put(oiHijo.Id, bpliPadre);
            }
        }
        System.debug('ALC bpliIds: '+bpliIds);
        bplis = [SELECT Id, XC_SoldToAddress__c FROM XC_BillingProfileLineItem__c WHERE Id IN: bpliIds];

        for(XC_BillingProfileLineItem__c bpli : bplis){
            List<XC_BillingProfileLineItem__c> bplisAux = new List<XC_BillingProfileLineItem__c>();
            addressesIds.add(bpli.XC_SoldToAddress__c);
            
            if(mapaAddressBPLIs.get(bpli.XC_SoldToAddress__c)!=null){
                mapaAddressBPLIs.get(bpli.XC_SoldToAddress__c).add(bpli);
            }else{
                bplisAux.add(bpli);
                mapaAddressBPLIs.put(bpli.XC_SoldToAddress__c, bplisAux);
            }
        }

        addresses = [SELECT Id, XC_PricinRegion__c FROM XC_Address__c WHERE Id IN: addressesIds];
        System.debug('ALC addresses: '+addresses);

        //Cada región tiene una lista de OIs

        for(XC_Address__c address : addresses){
            //Recuperamos las BPLI con esa dirección asociada
            List<XC_BillingProfileLineItem__c> bplisAddress = mapaAddressBPLIs.get(address.Id);
            List<NE__OrderItem__c> oisBPLIs;
            List<NE__OrderItem__c> oisBPLIsAuxPeninsula;
            List<NE__OrderItem__c> oisBPLIsAuxCanarias;
            List<NE__OrderItem__c> oisBPLIsAuxCeuta;

            //Recuperamos los OIs de esos BPLI
            for(XC_BillingProfileLineItem__c bpliAddress : bplisAddress){
                oisBPLIs = mapaBPLIOIs.get(bpliAddress.Id);
                System.debug('ALC bpliAddress l180: '+bpliAddress);
                System.debug('ALC mapaBPLIOIs l181: '+mapaBPLIOIs);
                System.debug('ALC oisBPLIS l182: '+oisBPLIs);
                for(NE__OrderItem__c oiBPLI : oisBPLIs){
                    String regionAux = address.XC_PricinRegion__c;
                    regionAux = regionAux.replace('/','');
                    switch on regionAux {
                        when  'Peninsula'{
                            if(mapaRegionListaOIs.get('Peninsula')!=null){
                                //Mapeamos los OIs de esa dirección
                                mapaRegionListaOIs.get('Peninsula').add(oiBPLI);
                            }else{
                                oisBPLIsAuxPeninsula = new List<NE__OrderItem__c>();
                                oisBPLIsAuxPeninsula.add(oiBPLI);
                                mapaRegionListaOIs.put('Peninsula', oisBPLIsAuxPeninsula);
                            }
                        }
                        when  'Canarias'{
                            if(mapaRegionListaOIs.get('Canarias')!=null){
                                //Mapeamos los OIs de esa dirección
                                mapaRegionListaOIs.get('Canarias').add(oiBPLI);
                            }else{
                                oisBPLIsAuxCanarias = new List<NE__OrderItem__c>();
                                oisBPLIsAuxCanarias.add(oiBPLI);
                                mapaRegionListaOIs.put('Canarias', oisBPLIsAuxCanarias);
                            }
                        }
                        when  'CeutaMelilla'{
                            if(mapaRegionListaOIs.get('Ceuta/Melilla')!=null){
                                //Mapeamos los OIs de esa dirección
                                mapaRegionListaOIs.get('Ceuta/Melilla').add(oiBPLI);
                            }else{
                                oisBPLIsAuxCeuta = new List<NE__OrderItem__c>();
                                oisBPLIsAuxCeuta.add(oiBPLI);
                                mapaRegionListaOIs.put('Ceuta/Melilla', oisBPLIsAuxCeuta);
                            }
                        }
                        /*when else {
                            
                        }*/
                    }
                }
            }
        }

        for(String key : mapaRegionListaOIs.keyset()){
            System.debug('ALC key: '+key);
            List<NE__OrderItem__c> oisAux = mapaRegionListaOIs.get(key);

            for(NE__OrderItem__c oiAux : oisAux){
                //mapaOITipoImpuesto.put(oiAux.Id, key);
                String impuesto = '';
                if(key=='Peninsula'){
                    impuesto = 'IVA';
                }else if(key=='Canarias'){
                    impuesto = 'IGIC';
                }else{
                    impuesto = 'IPSI';
                }
                System.debug('ALC oiAux BPLI l248: '+oiAux.XC_BillingProfileLineItem__c);
                System.debug('ALC mapaHijoBPLIPadre l252: '+mapaHijoBPLIPadre.get(oiAux.Id));
                
                mapaOITipoImpuesto.put(mapaHijoBPLIPadre.get(oiAux.Id), impuesto);
            }
        }

        System.debug('ALC mapaOITipoImpuesto: '+mapaOITipoImpuesto);

        return mapaOITipoImpuesto;

    }

    @AuraEnabled
    public static XC_VATManagementControllerWrapper wrapperMethod (Id orderId){
        List<XC_VATManagementOIsWrapper> wrappers = getOIsWrapper2(orderId);
        Map<Id, String> tiposImpuestos = getTiposImpuestos(wrappers);

        XC_VATManagementControllerWrapper fullWrapper = new XC_VATManagementControllerWrapper();
        fullWrapper.wrappers = wrappers;
        fullWrapper.tiposImpuestos = tiposImpuestos;

        return fullWrapper;
    }

    @AuraEnabled
    public static void saveTaxes(List<String> oisNames){
        Map<Id, NE__OrderItem__c> mapaOIHijoOIPadre = new Map<Id, NE__OrderItem__c>();    
        // R. Dara - 05/07/2022 - INC000087070133 - add XC_Sujeto_Pasivo_ISP__c, XC_Segment__c, XC_Country__c, XC_Tax_Type__c, XC_Tax_Subtype__c, XC_Exemptions__c, XC_Not_Subject__c into the select;                                                        
        List<NE__OrderItem__c> ois = [SELECT Id, XC_Select_Tax_Completed__c, NE__Parent_Order_Item__c, XC_Sujeto_Pasivo_ISP__c, XC_Segment__c, XC_Country__c, XC_Tax_Type__c, XC_Tax_Subtype__c, XC_Exemptions__c, XC_Not_Subject__c FROM NE__OrderItem__c WHERE Name IN: oisNames]; 
        List<NE__OrderItem__c> oisPadres;
        List<NE__OrderItem__c> oisAux = new List<NE__OrderItem__c>();
        Set<Id> padresIds = new Set<Id>();
        Map<Id, NE__OrderItem__c> taxValuesByParent = new Map<Id, NE__OrderItem__c>();

        // R. Dara - 05/07/2022 - INC000087070133 - START - Fix to bring tax fields on root order item

        for(NE__OrderItem__c oi: ois){
            System.debug('OrderItem:' + oi);
            if(oi.XC_Country__c == 'Spain' && oi.XC_Segment__c != 'B2C' && !taxValuesByParent.keySet().contains(oi.NE__Parent_Order_Item__c) && !String.isBlank(oi.NE__Parent_Order_Item__c)){
                taxValuesByParent.put(oi.NE__Parent_Order_Item__c, oi);
                System.debug('SujetoPasivo' + oi.NE__Parent_Order_Item__c + ' : ' + oi.XC_Sujeto_Pasivo_ISP__c);
            }
        
        }

        for (NE__OrderItem__c oi: ois){
            if(String.isBlank(oi.NE__Parent_Order_Item__c)){
                System.debug('Setto il valore del padre a:' + taxValuesByParent?.get(oi.id));
                oi.XC_Tax_Subtype__c = taxValuesByParent?.get(oi.id)?.XC_Tax_Subtype__c == null ? oi.XC_Tax_Subtype__c : taxValuesByParent?.get(oi.id)?.XC_Tax_Subtype__c;
                oi.XC_Sujeto_Pasivo_ISP__c = taxValuesByParent?.get(oi.id)?.XC_Sujeto_Pasivo_ISP__c == null ? oi.XC_Sujeto_Pasivo_ISP__c : taxValuesByParent?.get(oi.id)?.XC_Sujeto_Pasivo_ISP__c;
                oi.XC_Exemptions__c = taxValuesByParent?.get(oi.id)?.XC_Exemptions__c == null ? oi.XC_Exemptions__c : taxValuesByParent?.get(oi.id)?.XC_Exemptions__c;
                oi.XC_Not_Subject__c = taxValuesByParent?.get(oi.id)?.XC_Not_Subject__c == null ? oi.XC_Not_Subject__c : taxValuesByParent?.get(oi.id)?.XC_Not_Subject__c;
            
        // R. Dara - 05/07/2022 - INC000087070133 - END - Fix to bring tax fields on root order item
                
            }
            oi.XC_Select_Tax_Completed__c = true;
            oisAux.add(oi);
            padresIds.add(oi.NE__Parent_Order_Item__c);
        }

        /*oisPadres = [SELECT Id, XC_Select_Tax_Completed__c FROM NE__OrderItem__c WHERE Id IN: padresIds];

        for(NE__OrderItem__c oiPadre: oisPadres){
            oiPadre.XC_Select_Tax_Completed__c = true;
            oisAux.add(oiPadre);
        }*/

        update oisAux;
    }
}