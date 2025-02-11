
function print_orc(orc){
    console.log(orc)

    
    doc = new jsPDF({
        orientation: 'portrait',
        format: 'a4'
    }) 

    plotImg('assets/reports/capa01.png',0,0,210)
    addPage(0)
    plotImg('assets/reports/capa02.png',0,0,210)
    addPage(0)
    plotImg('assets/reports/head.png',0,0,210)

    doc.setFontSize(12);
    txt.y = 75
    doc.setFont(undefined, 'bold')
    doc.text(orc.cliente+' - '+orc.razao_social,22,txt.y)
    addLine(2)
    doc.setFont(undefined, 'normal')
    doc.text('CNPJ: '+getCNPJ(getNum(orc.cnpj)),22,txt.y)


    const blob = doc.output('blob')
    openPDF(doc,'orcamento')
   
}