/**
 * Created by FMARCHEGIA00 on 23/02/2021.
 */

public with sharing class MajorRoadsController {

    public static final String ISPARTIALEROADS = 'isPartialRoad';
    public static final String ISMAJOROARDS = 'isMajorRoads';
    public static final String ISNOTMAJOROARDS = 'isNotMajorRoads';
    public static final String ISNOTPARTIALEROADS = 'isNotPartialRoads';

    public static List<String> isMajorRoards(String addressToFind) {
        system.debug('manageMajorRoards');
        system.debug('addressToFind -> ' + addressToFind);

        List<String> finalResult = new List<String>();
        String onlyPre;
        String finalAddressWithoutPre;
        String finalStringToFind = '';

        try {
            if (String.isNotBlank(addressToFind)) {

                final List<String> arraySSWords = new List<String>{
                        'SS.', 'Santissimo', 'Santissima', 'Santissimi', 'Santi'
                };
                final List<String> arraySWords = new List<String>{
                        'Santi', 'Santo', 'Santa', 'Sant\'', 'Sant', 'San', 'S.'
                };
                if (addressToFind.contains(' ')) {
                    finalAddressWithoutPre = addressToFind.substring(addressToFind.indexOf(' '));

                    Boolean doneCheck = false;
                    for (String singleSSWord : arraySSWords) {
                        if (finalAddressWithoutPre.contains(singleSSWord)) {
                            String strintToChange = ' (' + String.join(arraySSWords, ' OR ') + ') ';
                            finalAddressWithoutPre = finalAddressWithoutPre.replace(singleSSWord, strintToChange);
                            doneCheck = true;
                            system.debug('finalAddressWithoutPre in for -> ' + finalAddressWithoutPre);
                            break;
                        }
                    }

                    if (!doneCheck) {
                        for (String singleSWord : arraySWords) {
                            if (finalAddressWithoutPre.contains(singleSWord)) {
                                String strintToChange = ' (' + String.join(arraySWords, ' OR ') + ') ';
                                //escape for string SOQL
                                strintToChange = strintToChange.replace('\'', '\\\'');
                                finalAddressWithoutPre = finalAddressWithoutPre.replace(singleSWord, strintToChange);
                                break;
                            }
                        }
                    }

                    onlyPre = addressToFind.substring(0, addressToFind.indexOf(' '));

                    addressToFind = onlyPre + ' ' + finalAddressWithoutPre;
                    system.debug('addressToFind after for -> ' + addressToFind);
                    system.debug('finalAddressWithoutPre after for -> ' + finalAddressWithoutPre);
                }


                //exactly road
                List<List<SObject>> searchList = [FIND :addressToFind IN ALL FIELDS RETURNING MajorRoads__c(Name, PartialViability__c)];
                system.debug('addressToFind-> ' + addressToFind);
                system.debug('searchList (full)-> ' + searchList);
                if (!searchList.isEmpty() && !searchList[0].isEmpty()) {
                    List<MajorRoads__c> returnedMajorRoads = (List<MajorRoads__c>) searchList[0];
                    if (returnedMajorRoads.size() == 1) {
                        finalResult.add(ISMAJOROARDS);
                        if (returnedMajorRoads[0].PartialViability__c) {
                            finalResult.add(ISPARTIALEROADS);
                        } else {
                            finalResult.add(ISNOTPARTIALEROADS);
                        }
                        system.debug('finalResult -> ' + finalResult);
                        return finalResult;
                    } else {
                        if (String.isNotBlank(finalAddressWithoutPre)) {
                            searchList = [FIND :finalAddressWithoutPre IN ALL FIELDS RETURNING MajorRoads__c(Name, PartialViability__c)];
                            system.debug('searchList (WithoutPre)-> ' + searchList);
                            returnedMajorRoads = (List<MajorRoads__c>) searchList[0];
                        }
                        if (returnedMajorRoads.size() > 0) {
                            finalResult.add(ISMAJOROARDS);
                            if (returnedMajorRoads[0].PartialViability__c) {
                                finalResult.add(ISPARTIALEROADS);
                            } else {
                                finalResult.add(ISNOTPARTIALEROADS);
                            }
                            system.debug('finalResult, major -> ' + finalResult);
                            return finalResult;
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Exception at MajorRoadsController: ' + e.getMessage());
            Error_Log_Event__e errorEvent = ErrorLogEventHandler.createEvent(e, 'Indirizzo : ' + addressToFind);
            ErrorLogEventHandler.publishEventDMLSafe(errorEvent);
        }

        // nothing
        finalResult.add(ISNOTMAJOROARDS);
        finalResult.add(null);
        system.debug('finalResult -> ' + finalResult);
        return finalResult;
    }

}