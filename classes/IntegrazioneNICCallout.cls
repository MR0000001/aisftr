/**
 * Created by SNEKKANTI00 on 07/12/2020.
 */

public with sharing class IntegrazioneNICCallout {

    public static ResponseNIC IntegrazioneNICCallout(String latitude, String longitude) {
        Long startTime = Datetime.now().getTime();
        Long finishTime;
        Long totalTime;
        String numMunicipio;
        String coordinates = latitude + '%20' + longitude;
        String endpointParams = '?service=wfs&version=1.1.0&request=GetFeature&TYPENAME=toponomastica:MunicipiToponomastica&CQL_FILTER=CONTAINS(GEOMETRIA,%20Point('
            + coordinates + '))';

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setTimeout(60000);
        req.setMethod('GET');
        req.setEndPoint('callout:NIC'+endpointParams);

        ResponseNIC respNic = new ResponseNIC();
        HttpResponse res = null;
        Dom.Document xml = null;
        Dom.XmlNode root = null;
        System.debug('Request from IntegrazioneNIC class: ' + req);

        try {
            finishTime = Datetime.now().getTime();
            totalTime = (finishTime - startTime) / 1000;
            res = http.send(req);
            CalloutLoggerService.initializeUpdateCalloutLog(req, res, req.getBody(), totalTime, '', 'NIC', 'callout:NIC', '');

            xml = res.getBodyDocument();
            root = xml.getRootElement();
            if(!root.getChildren().isEmpty()) {
                Dom.XmlNode firstChildNode = root.getChildElement(System.Label.first_level_child, root.getChildren()[0].getNamespace());
                System.debug('firstChildNode ');

                if(firstChildNode == null) {
                    Dom.XmlNode exceptionXml = root.getChildElement(System.Label.Exception_NIC, root.getChildren()[1].getNamespace());
                    String exceptionCode = exceptionXml.getAttributeValue(exceptionXml.getAttributeKeyAt(0), exceptionXml.getAttributeKeyNsAt(0));
                    String exceptionText = exceptionXml.getChildElement(System.Label.Exception_Text_NIC, exceptionXml.getChildren()[1].getNamespace()).getText();

                    respNic.nicError = new ResponseNIC.NICError('Exception Code: ' + exceptionCode + '; Exception Text: ' + exceptionText);
                } else {
                    Dom.XmlNode secondChildNode = firstChildNode.getChildElement(System.Label.second_level_child, firstChildNode.getChildren()[0].getNamespace());
                    String secondChildNamespace = secondChildNode.getNamespace();
                    System.debug('secondChildNode ');

                    numMunicipio = 'Municipio ' + secondChildNode.getChildElement(System.Label.third_level_child, secondChildNamespace).getText();

                    respNic.municipio.numberMunicipio = Integer.valueOf(secondChildNode.getChildElement(System.Label.third_level_child, secondChildNamespace).getText());
                    respNic.municipio.romanNumeralMunicipio = secondChildNode.getChildElement('NUMERO_ROMANO', secondChildNamespace).getText();
                    respNic.municipio.IdMunicipio = Integer.valueOf(secondChildNode.getChildElement('ID_MUNICIPIO', secondChildNamespace).getText());
                }
            } else {
                System.debug('Not found');
                respNic.nicError = new ResponseNIC.NICError('Not Found');
            }

        } catch (Exception e) {
            System.debug('Exception at IntegrazioneNIC: ' + e.getMessage());
            Error_Log_Event__e errorEvent = null;
            if (res == null) {
                CalloutLoggerService.initializeUpdateCalloutLog(req, null, req.getBody(), totalTime, '', 'NIC', 'callout:NIC', '');
                errorEvent = ErrorLogEventHandler.createInfoEvent(e);
            } else {
                errorEvent = ErrorLogEventHandler.createEvent(e);
            }
            system.debug('errorEvent -> '+ errorEvent);
            respNic.nicError = new ResponseNIC.NICError(e.getMessage());
        }

        System.debug('numMunicipio: ' + numMunicipio);

        return respNic;
    }
}