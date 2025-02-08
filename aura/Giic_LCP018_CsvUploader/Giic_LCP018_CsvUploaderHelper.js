({
    
    readFile: function(component, helper, file) {
        var toShoot = false;
        if (!file) return;
        console.log('file'+file.name);
        if(!file.name.match(/\.(csv||CSV)$/)){
            return alert('Warning: only csv files are supported');
       }else{
            
            reader = new FileReader();
            reader.onerror =function errorHandler(evt) {
                switch(evt.target.error.code) {
                    case evt.target.error.NOT_FOUND_ERR:
                        alert('File Not Found!');
                        break;
                    case evt.target.error.NOT_READABLE_ERR:
                        alert('File is not readable');
                        break;
                    case evt.target.error.ABORT_ERR:
                        break; // noop
                    default:
                        alert('An error occurred reading this file.');
                };
            }
            //reader.onprogress = updateProgress;
            reader.onabort = function(e) {
                alert('File read cancelled');
            };
            reader.onloadstart = function(e) { 
                
                var output = '<ui type=\"disc\"><li><strong>'+file.name +'</strong> ('+file.type+') - '+file.size+'bytes, last modified: '+file.lastModifiedDate.toLocaleDateString()+'</li></ui>';
                component.set("v.filename",file.name);
                component.set("v.TargetFileName",output);
               
            };
            reader.onload = function(e) {
                var data=e.target.result;
                component.set("v.fileContentData",data);
                console.log("file data"+JSON.stringify(data));
                var allTextLines = data.split(/\r\n|\n/);
                var dataRows=allTextLines.length-1;
                var headers = allTextLines[0].split(',');
                
                console.log("Rows length::"+dataRows);
               
              
                	var numOfRows=component.get("v.NumOfRecords");
                    if(dataRows > numOfRows+1 || dataRows == 1 || dataRows== 0){
                   
                    alert("You can upload up to "+numOfRows+" serial numbers at a time.");
                    component.set("v.showMain",true);
                    
                } 
                else{
                    var lines = [];
                    var allSerial = [];
                    var filecontentdata;
                    var content = "<table class=\"table slds-table slds-table--bordered slds-table--cell-buffer\">";
                    content += "<thead><tr class=\"slds-text-title--caps\">";
                    for(i=0;i<headers.length; i++){
                        content += '<th scope=\"col"\>'+headers[i]+'</th>';
                    }
                    content += "</tr></thead>";
                    
                    for (var i=0; i<allTextLines.length; i++) {
                        filecontentdata = allTextLines[i].split(',');
                        if(filecontentdata[0]!=''){
                            content +="<tr>";
                            allSerial.push(filecontentdata[0]);
                            for(var j=0;j<filecontentdata.length;j++){
                                content +='<td>'+filecontentdata[j]+'</td>';
                            }
                            content +="</tr>";
                        }
                    }
                    var maxSerialNumbersAllowed = component.get("v.maxSerialNumbersAllowed");
                    if(allSerial.length > maxSerialNumbersAllowed){
                        helper.showToast(component,event,helper,'Warning: You can upload max '+maxSerialNumbersAllowed+' serials numbers!','error');
                        return;
                    }
                    content += "</table>";
                    component.set("v.allSerials", allSerial);
                    console.log('setto allSerial = '+ component.get("v.allSerials"));
                    component.set("v.TableContent", content);  
                    if(allSerial.length>0){
                        component.set("v.isReadyForShot", true);  
                        return;
                    }
					component.set("v.showMain",false);                   
                }
            }
            reader.readAsText(file);
            
        }
        var reader = new FileReader();
        reader.onloadend = function() {
         
        };
        reader.readAsDataURL(file);
        
        
     
    },
    
    
    shootRecords : function(component,event,helper){
        
        var purchaseOrderLineId = component.get("v.purchaseOrderLineId");
        var serialList = component.get("v.allSerials");
        console.log('leggo allSerial = '+ JSON.stringify(serialList));
        var map = new Map();
        map[purchaseOrderLineId] = serialList;
        //component.set("v.mapPolToSerialList", map);
        console.log('map to shoot = '+ JSON.stringify(map));
        //fire an event or chiama back-end
        var cmpEvent = $A.get("e.c:Giic_LCE018_ShootMapFromCsv");
        cmpEvent.setParams({
            "mapPolToSerialList" : JSON.stringify(map)
        }); 
        cmpEvent.fire();
        
    },
    
     showToast : function(component, event, helper, message, type) {
        
        component.find('notifLib').showToast({
            "title": message,
            "message": '',
            "variant": type
        });
    }
        
       
});