
function print_orc(orc){
    console.log(orc)

    
    doc = new jsPDF({
        orientation: 'portrait',
        format: 'a4'
    }) 

    plotImg('assets/reports/head.png',0,0,210)

    console.log(doc.internal.pageSize.getWidth())
    
//    doc.addImage(logo, 'png', 24, 10, 50, 15.5);

    doc.setFontSize(20);
    txt.y = 35
//    doc.text('Comanda Virtual',22,txt.y)
    addLine(2)
//    line(txt.y)
    addLine()
/*    doc.setFontSize(36);
    doc.text(comanda.id.padStart(5,0),30,txt.y)
    addLine(2)
    doc.setFontSize(18);
    doc.text(`${comanda.data} - ${comanda.hora}`,17,txt.y)
    addLine(2)
    doc.setFontSize(12);
    doc.text(comanda.nome.toUpperCase(),5,txt.y)
    addLine(1)
    let base64Image = document.querySelector('#qr_code img').src
    doc.addImage(base64Image, 'png', 5, txt.y, 85, 85);
    txt.y += 85
    addLine()
    doc.setFontSize(12);
    doc.text(`Acompanhe sua comanda por este QR-Code`,5,txt.y)
*/
    const blob = doc.output('blob')
    openPDF(doc,'orcamento')
   
}