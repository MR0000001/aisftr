/**
 * Created by SNEKKANTI00 on 10/12/2020.
 */

@isTest
global with sharing class MockHttpResponseIntegrazioneNIC implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');

        res.setStatusCode(200);
        if(req.getEndpoint().containsIgnoreCase('41.830142%2012.494440')) {
            res.setBody(getXMLBody());
        } else {
            res.setBody(getXMLBodyError());
        }
        return res;
    }

    global String getXMLBody() {

        //You need to structure you'r sample JSON reponse into a String. In this reponse you'll need to specify values that you'll be using to do an Assert at the end of TestBatchClass
        String xmlBody = '<?xml version="1.0" encoding="UTF-8"?><wfs:FeatureCollection xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:wfs="http://www.opengis.net/wfs" xmlns:gml="http://www.opengis.net/gml" xmlns:toponomastica="http://it.romacapitale.sit-i/toponomastica" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" numberOfFeatures="1" timeStamp="2020-12-10T14:49:21.576Z" xsi:schemaLocation="http://it.romacapitale.sit-i/toponomastica https://www.comune.roma.it/TERRITORIO/geoserver/toponomastica/wfs?service=WFS&amp;version=1.1.0&amp;request=DescribeFeatureType&amp;typeName=toponomastica%3AMunicipiToponomastica http://www.opengis.net/wfs https://www.comune.roma.it/TERRITORIO/geoserver/schemas/wfs/1.1.0/wfs.xsd"><gml:featureMembers><toponomastica:MunicipiToponomastica gml:id="MunicipiToponomastica.8"><toponomastica:MUNICIPIO>8</toponomastica:MUNICIPIO><toponomastica:NUMERO_ROMANO>VIII</toponomastica:NUMERO_ROMANO><toponomastica:ID_MUNICIPIO>8</toponomastica:ID_MUNICIPIO></toponomastica:MunicipiToponomastica></gml:featureMembers></wfs:FeatureCollection>';
        return xmlBody;
    }

    global String getXMLBodyError() {

        //You need to structure you'r sample JSON reponse into a String. In this reponse you'll need to specify values that you'll be using to do an Assert at the end of TestBatchClass
        String xmlBody = '<ows:ExceptionReport xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ows="http://www.opengis.net/ows" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.0.0" xsi:schemaLocation="http://www.opengis.net/ows https://www.comune.roma.it/TERRITORIO/geoserver/schemas/ows/1.0.0/owsExceptionReport.xsd"><blank></blank><ows:Exception exceptionCode="NoApplicableCode"><blank></blank><ows:ExceptionText>Could not parse CQL filter list.Encountered ")" at line 1, column 27.Was expecting one of:"-" ... &lt;INTEGER_LITERAL&gt; ... &lt;FLOATING_LITERAL&gt; ...Parsing : CONTAINS(GEOMETRIA, Point()).</ows:ExceptionText></ows:Exception></ows:ExceptionReport>';
        return xmlBody;
    }

}