/**
 * @author            : Vamsi Sree Nekkanti
 * @created date      : 24-08-2022
 * @description       :
 * @testClasses       : TestGeoromaCallouts,TestGeoromaController
 * @last modified by  : Davide Desideri
 * @last modified on  : 08-06-2023
 **/

public without sharing class GeoromaController {
  public class StreetWrapper {
    @AuraEnabled
    public String streetName { get; set; }
    @AuraEnabled
    public Map<String, StreetDetail> streetDetails = new Map<String, StreetDetail>();
  }

  public class StreetDetail {
    @AuraEnabled
    public String letterStreet { get; set; }
    @AuraEnabled
    public Integer numberStreet { get; set; }
    @AuraEnabled
    public String numberStreetWithLetter { get; set; }
    @AuraEnabled
    public Double latitude { get; set; }
    @AuraEnabled
    public Double longitude { get; set; }
    @AuraEnabled
    public String municipality { get; set; }
  }

  @AuraEnabled
  public static List<String> getStreetsList(String searchStreetKey, String pageSize) {
    DebugService.printLimits('GeoromaController', 'getStreetsList', 'start');

    String streetQuery = '?indirizzo=' + searchStreetKey.replaceAll(' ', '%20') + '&page=1&size=' + pageSize;
    Set<String> streetNames = new Set<String>();
    System.debug('streetQuery: ' + streetQuery);
    ResponseGeoromaStreetsList responseStreets = GeoromaCallouts.getStreetsListCallout(streetQuery);

    if (responseStreets != null && responseStreets.indirizzi != null) {
      System.debug('streets exists');
      for (ResponseGeoromaStreetsList.Indirizzi address : responseStreets?.indirizzi) {
        streetNames.add(address.indirizzo);
      }
    }

    if (streetNames.isEmpty()) {
      System.debug('streetNames is empty');
      throw newMessageException(Label.Georoma_Errors_StreetNotFound);
    }

    System.debug('streetNames ' + streetNames);
    DebugService.printLimits('GeoromaController', 'getStreetsList', 'end');

    return new List<String>(streetNames);
  }

  @AuraEnabled
  public static StreetWrapper getStreetDetails(String streetName, String streetNumber) {
    DebugService.printLimits('GeoromaController', 'getStreetDetails', 'start');
    System.debug('streetName: ' + streetName + ' .streetNumber: ' + streetNumber);
    StreetWrapper streetWrapper = new StreetWrapper();

    ResponseGeoromaStreetDetails responseGeoromaStreetDetails = GeoromaCallouts.getStreetDetailsCallout(
      streetName.toUpperCase(),
      streetNumber
    );

    try {
      for (ResponseGeoromaStreetDetails.Features feature : responseGeoromaStreetDetails.features) {
        streetWrapper.streetName = feature.properties?.TOPONIMO;
        StreetDetail streetDetail = new StreetDetail();
        streetDetail.numberStreet = feature.properties?.NUMERO_CIVICO;
        streetDetail.numberStreetWithLetter = (String.isNotBlank(feature.properties?.LETTERA))
          ? String.valueOf(streetDetail.numberStreet) + feature.properties?.LETTERA
          : String.valueOf(streetDetail.numberStreet);
        streetDetail.letterStreet = feature.properties?.LETTERA;
        streetDetail.municipality = String.valueOf(feature.properties?.MUNICIPIO);
        streetDetail.latitude = feature.bbox[1];
        streetDetail.longitude = feature.bbox[0];
        streetWrapper.streetDetails.put(streetDetail.numberStreetWithLetter, streetDetail);
      }
      if (streetWrapper.streetDetails.isEmpty()) {
        System.debug('streetDetail is empty');
        throw newMessageException(Label.Georoma_Errors_StreetNumbersNotFound);
      }
    } catch (Exception e) {
      ErrorLogEventHandler.standardExceptionLog('GeoromaController', 'getStreetDetails', e);
    }
    System.debug('streetWrapper ' + streetWrapper);
    DebugService.printLimits('GeoromaController', 'getStreetDetails', 'end');

    return streetWrapper;
  }

  @AuraEnabled(Cacheable=true)
  public static Georoma_Map_Metadata__mdt getGeoromaMetadata() {
    DebugService.printLimits('GeoromaController', 'getGeoromaMetadata', 'start/end');
    return Georoma_Map_Metadata__mdt.getInstance(Label.Georoma_Label_MetadataName);
  }

  private static Exception newMessageException(String message) {
    DebugService.printLimits('GeoromaController', 'newMessageException', 'start');
    Exception e;
    Request reqInfo = Request.getCurrent();
    switch on reqInfo.getQuiddity() {
      when VF, AURA {
        e = new AuraHandledException(message);
      }
      when else {
        e = new StreetNotFoundException(message);
      }
    }
    DebugService.printLimits('GeoromaController', 'newMessageException', 'end');
    return e;
  }

  public class StreetNotFoundException extends Exception {
  }
}