({
	loadpdf:function(component,event){
		try{
			var pdfData = component.get('v.pdfData');
			var pdfjsframe = component.find('pdfFrame')

			let uint8ArrayPdf = new Uint8Array(pdfData.length)
			for (let i = 0; i < pdfData.length; i++) {
			  uint8ArrayPdf[i] = pdfData.charCodeAt(i)
			}

			if(typeof pdfData != 'undefined'){
				pdfjsframe.getElement().contentWindow.postMessage(pdfData,'*');	
			}
		}catch(e){
			alert('Error: ' + e.message);
		}
	}
})