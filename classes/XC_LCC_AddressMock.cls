@isTest
global class XC_LCC_AddressMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) { 
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        //response.setBody('{"streetTypeText":null,"streetType":null,"streetNumber":"750","stair":null,"provinceCode":null,"province":"METROPOLITANA DE SANTIAGO","postalCode":"123456789","municipality":"COLINA","gas":null,"floor":null,"electric":null,"door":null,"country":"Chile","clarifValue":null,"clarifType":null,"cityCode":null,"city":"CHACABUCO","category":null,"address":"CALLE C","account":null}');
        String json = '{"JSON": {												'+
'    "Codigo": 1,                                       '+
'    "Glosa": "FindTextoLibre",                         '+
'    "Descripcion": "16295 items encontrados en 68ms"   '+
'  },                                                   '+
'  "Address": []  ,                                   '+
'  "Resultados": [                                      '+
'    {                                                  '+
'      "Error_Code": "0",                                   '+
'      "Id": "562980824",                               '+
'      "DireccionOrPOI": "CALLE C",                     '+
'      "IdNivel": "4",                                  '+
'      "Tipo": 6,                                       '+
'      "Pais": "56",                                    '+
'      "Locacion": "-70.67355558,-33.19668032",         '+
'      "Calle": "CALLE C",                              '+
'      "Numero": "750",                                 '+
'      "EntreCalle": "",                                '+
'      "Urbanizacion": "",                              '+
'      "Comuna": "COLINA",                              '+
'      "Provincia": "CHACABUCO",                        '+
'      "Region": "METROPOLITANA DE SANTIAGO",           '+
'      "IdTipo": 6,                                     '+
'      "NombreCalleGeneradora": ""                      '+
'    }]}                                                ';
        response.setBody(json);
        return response;
    }
    }