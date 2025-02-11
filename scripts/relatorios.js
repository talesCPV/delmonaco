
function print_orc(orc){
    console.log(orc)

    doc = new jsPDF({
        orientation: 'portrait',
        format: 'a4'
    }) 

    plotImg('assets/reports/capa01.png',0,0,210)
    addPage(0)
    plotImg('assets/reports/capa02.png',0,0,210)

    fillEscopo()
    
    async function fillEscopo(){

        const fila = []
        for(let i=0; i< orc.itens.length; i++){
            const params = new Object;
                params.id = orc.itens[i].id_prod
            fila.push( queryDB(params,'PROD-2').then((resolve)=>{
                const json = JSON.parse(resolve)
                orc.itens[i].escopo = json
                addItem(i)
            }))
        }

        await Promise.all(fila)
        
        addPage(0)
        plotImg('assets/reports/head.png',0,0,210)
        doc.setFontSize(10);
        txt.y = 75
        
        for(let i=0; i<orc.textos.length; i++){
            doc.setFont(undefined, 'bold')
            doc.text((i+1)+'- '+orc.textos[i].titulo,5,txt.y)
            addLine()
            doc.setFont(undefined, 'normal')
            box(orc.textos[i].texto,5,txt.y,205,1)
            addLine()
        }

        const blob = doc.output('blob')
        openPDF(doc,'orcamento')

    }

    function addItem(i){
        addPage(0)
        plotImg('assets/reports/head.png',0,0,210)
        doc.setFontSize(10);
        txt.y = 75
        doc.setFont(undefined, 'bold')
        doc.text('Proposta Comercial para '+orc.itens[i].nome,5,txt.y)
        addLine(2)
        doc.setFont(undefined, 'normal')
        doc.text(orc.cliente+' - '+orc.razao_social,5,txt.y)
        addLine(2)
        doc.text('CNPJ: '+getCNPJ(getNum(orc.cnpj)),5,txt.y)
        addLine(2)
        doc.text('Data: '+orc.data.viewFullDate(),5,txt.y)
        addLine(2)
        doc.text('Prezado(s) Senhor(es),',5,txt.y)
        addLine(2)
        box(`Agradecemos a oportunidade de apresentar nossa proposta para a consultoria de implantação da ${orc.itens[i].nome} para a ${orc.cliente} - ${orc.razao_social}`,5,txt.y,205)
        addLine()
        box(`A Del Mônaco Assessoria e Projetos é especializada na implantação e adequação de sistemas de gestão da qualidade e oferece uma solução personalizada para atender às necessidades da sua empresa, visando não apenas a ${orc.itens[i].nome}, mas também a melhoria contínua dos processos internos e o alinhamento com as melhores práticas do mercado.`,5,txt.y,205)
        addLine(1)

        doc.setFont(undefined, 'bold')
        doc.text('Escopo da Consultoria',5,txt.y)
        addLine(2)
        for(let j=0; j<orc.itens[i].escopo.length; j++){
            doc.setFont(undefined, 'bold')
            doc.text((j+1)+'- '+orc.itens[i].escopo[j].nome,5,txt.y)
            addLine()
            doc.setFont(undefined, 'normal')
            box(orc.itens[i].escopo[j].texto,5,txt.y,205,1)
            addLine()
        }
    }
   
}