/**
 * Created by FMARCHEGIA00 on 02/02/2021.
 */

public with sharing class CaseCDCManager {
    private static OrgManagement__c setting = OrgManagement__c.getOrgDefaults();
    private static String DEFAULT_QUEUE = setting.Default_Queue_Label__c;
    private static String MAJORROAD_QUEUE = setting.Urban_Queue_Label__c;
    private static List<Group> groupType;
    private static List<Taxonomy__c> taxonomies;
    private static Map<String, Map<String, String>> manageResultFromQueue;
    private static Boolean isMajorRoad;
    private static Boolean isPartialMajorRoad;
    private static Boolean isMajorRoadTaxnomonyEmpty;

    public static void manageCDCCase(List<Case> newCases) {
        system.debug('manageCDVCase');
        //queries
        taxonomies = TaxonomySelector.getTaxonomieForCDCCase();
        groupType = GroupsSelector.getGroupsByType('Queue');
        manageResultFromQueue = getNameFromqueue();
        isMajorRoadTaxnomonyEmpty = false;

        for ( Case newSingleCase: newCases ) {
            if ( newSingleCase.Origin.equalsIgnoreCase(Label.CASE_ORIGIN_CDC) || newSingleCase.Origin.equalsIgnoreCase(Label.CASE_ORIGIN_APP) ) {
                getGeoMunicipalyOrMajorRoadFromList(newSingleCase);
                if ( String.isNotBlank(newSingleCase.Street_Address__c) ) {
                    newSingleCase.Case_Geolocalization__c = true;
                }
            }
        }
        system.debug('newCases -> '+newCases);
    }

    private static void getGeoMunicipalyOrMajorRoadFromList(Case singleCase) {
        List<Taxonomy__c> subTaxonomies = new List<Taxonomy__c>();
        for ( Taxonomy__c singleTaxonomy: taxonomies ) {
            if ( (singleTaxonomy.Tax_Theme_Area__c.toUpperCase()).equals(singleCase.Case_Theme_Area__c.toUpperCase()) &&
                    (singleTaxonomy.Tax_Topic_Service__c.toUpperCase()).equals(singleCase.Case_Topic_Service__c.toUpperCase()) &&
                    (singleTaxonomy.Tax_Specification__c.toUpperCase()).equals(singleCase.Case_Specification__c.toUpperCase()) &&
                    (singleTaxonomy.Tax_Type__c.toUpperCase()).equals(singleCase.Type.toUpperCase()) ) {
                subTaxonomies.add(singleTaxonomy);
            }
        }
        if ( String.isNotBlank(singleCase.Street_Address__c) ) {
            List<String> resMajor = MajorRoadsController.isMajorRoards(singleCase.Street_Address__c);
            system.debug('resMajor -> '+ resMajor);
            isMajorRoad = resMajor[0].equals(MajorRoadsController.ISMAJOROARDS);
            if ( isMajorRoad ) {
                isPartialMajorRoad = resMajor[1].equals(MajorRoadsController.ISPARTIALEROADS);
            }
        } else {
            isMajorRoad = false;
            isPartialMajorRoad = false;
        }
        system.debug('isMajorRoad -> ' + isMajorRoad);
        system.debug('subTaxonomies -> ' + subTaxonomies);

        Taxonomy__c lastTaxonomy = new Taxonomy__c();
        if (isMajorRoad) {
            Boolean findTaxNoMajorRoads = true;
            for (Taxonomy__c singleSubTaxonomy : subTaxonomies) {
                if (singleSubTaxonomy.MajorRoads__c == true) {
                    system.debug('is Taxonomy MajorRoads');
                    lastTaxonomy = singleSubTaxonomy;
                    system.debug('lastTaxonomy -> '+lastTaxonomy);
                    findTaxNoMajorRoads = false;
                    break;
                }
            }
            // se mi trovo qui è perché non è stato identificata una tripletta con MajorRoads__c = true, allora cerco se c'è senza
            if ( findTaxNoMajorRoads ) {
                for (Taxonomy__c singleSubTaxonomy : subTaxonomies) {
                    if (singleSubTaxonomy.MajorRoads__c == false
                            && (String.isNotBlank(singleCase.Municipality_Category__c)
                            && String.isNotBlank(singleSubTaxonomy.Geo_Municipality__c))
                            && (singleSubTaxonomy.Geo_Municipality__c.equals(singleCase.Municipality_Category__c))) {
                        system.debug('is NOT Taxonomy MajorRoads');
                        lastTaxonomy = singleSubTaxonomy;
                        system.debug('lastTaxonomy -> ' + lastTaxonomy);
                        isMajorRoadTaxnomonyEmpty = true;
                        break;
                    }
                }
            }
        } else {
            for (Taxonomy__c singleSubTaxonomy : subTaxonomies) {
                if ((String.isNotBlank(singleCase.Municipality_Category__c)
                        && String.isNotBlank(singleSubTaxonomy.Geo_Municipality__c))
                        && (singleSubTaxonomy.Geo_Municipality__c.equals(singleCase.Municipality_Category__c))) {
                    system.debug('is Taxonomy Municipality_Category__c');
                    lastTaxonomy = singleSubTaxonomy;
                    break;
                }
            }
        }

        if ( String.isBlank(lastTaxonomy.Tax_Theme_Area__c) ) {
            for (Taxonomy__c singleSubTaxonomy : subTaxonomies) {
                if ( singleSubTaxonomy.Geo_Municipality__c == null ) {
                    lastTaxonomy = singleSubTaxonomy;
                }
            }
        }
        saveFromTaxtomonyToCase(lastTaxonomy, singleCase);
    }

    private static void saveFromTaxtomonyToCase(Taxonomy__c singleTaxonomy, Case singleCase) {

        system.debug('singleTaxonomy -> ' + singleTaxonomy);
        Map<String, String> resultFormQueueToUse = new Map<String, String>();
        String stringToFindInqueue = '';

        if (  singleTaxonomy !=  null && singleTaxonomy.Tax_Queue__c != null ) {
            if ( String.isNotBlank(singleTaxonomy.Geo_Municipality__c) ) {
                singleCase.Municipality_Category__c =  singleTaxonomy.Geo_Municipality__c;
            }
            system.debug('isMajorRoad -> '+ isMajorRoad);
            system.debug('isPartialMajorRoad -> '+ isPartialMajorRoad);
            system.debug('isMajorRoadTaxnomonyEmpty -> '+ isMajorRoadTaxnomonyEmpty);
            if ( isMajorRoad && singleTaxonomy.MajorRoads__c == true && !isMajorRoadTaxnomonyEmpty) {
                if ( isPartialMajorRoad ) {
                    system.debug('singleTaxonomy.Tax_Queue__c -> '+ singleTaxonomy.Tax_Queue__c);
                    stringToFindInqueue = singleTaxonomy.Tax_Queue__c;
                } else {
                    system.debug('MAJORROAD_QUEUE -> ' + MAJORROAD_QUEUE);
                    stringToFindInqueue = MAJORROAD_QUEUE;
                }
            } else {
                system.debug('singleTaxonomy.Tax_Queue__c -> '+ singleTaxonomy.Tax_Queue__c);
                stringToFindInqueue = singleTaxonomy.Tax_Queue__c;
            }
        } else {
            system.debug('DEFAULT_QUEUE -> ' + DEFAULT_QUEUE);
            stringToFindInqueue = DEFAULT_QUEUE;
        }

        if ( manageResultFromQueue.containsKey(stringToFindInqueue) ) {
            system.debug('founded stringToFindInqueue -> '+ stringToFindInqueue);
            resultFormQueueToUse = manageResultFromQueue.get(stringToFindInqueue);
        } else {
            system.debug('not found stringToFindInqueue, use '+ DEFAULT_QUEUE);
            resultFormQueueToUse = manageResultFromQueue.get(DEFAULT_QUEUE);
        }

        system.debug('resultFormQueueToUse -> ' + resultFormQueueToUse);
        singleCase.Estimated_Queue__c = ( singleTaxonomy.Tax_Queue__c != null ? singleTaxonomy.Tax_Queue__c : resultFormQueueToUse.get('Name'));
        singleCase.OwnerId = resultFormQueueToUse.get('Id');
        singleCase.Current_Queue__c = resultFormQueueToUse.get('Name'); //label
        singleCase.Taxonomy__c = true;


    }

    private static Map<String, Map<String, String>> getNameFromqueue() {
        Map<String, Map<String, String>> resultList = new Map<String, Map<String, String>>();
        for ( Group singleGroup: groupType) {
            Map<String, String> tmpList = new Map<String, String>();
            tmpList.put('Name', singleGroup.Name);
            tmpList.put('Id', singleGroup.Id);
            resultList.put(singleGroup.Name, tmpList);
        }
        system.debug('resultList -> '+ resultList);
        return resultList;
    }

}