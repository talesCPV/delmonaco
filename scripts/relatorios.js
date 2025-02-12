
function print_orc(orc){
    console.log(orc)

    doc = new jsPDF({
        orientation: 'portrait',
        format: 'a4'
    }) 

    if(Number(orc.capa)){
        plotImg('assets/reports/capa01.png',0,0,210)
        addPage(0)
        plotImg('assets/reports/capa02.png',0,0,210)
    }


    fillEscopo()
    
    async function fillEscopo(){

        const fila = []
        orc.produtos = ''
        for(let i=0; i< orc.itens.length; i++){
            orc.produtos += orc.itens[i].nome+', '
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

        doc.setFont(undefined, 'bold')
        doc.text('Investimento',5,txt.y)
        addLine()
        doc.setFont(undefined, 'normal')
        box('A seguir detalhamos os custos relativos à consultoria:',5,txt.y,205,1)
        addLine()
        for(let i=0; i< orc.itens.length; i++){
            doc.text(orc.itens[i].nome,5,txt.y)
            addLine()
            doc.text('* Valor: R$'+Number(orc.itens[i].valor).toFixed(2),5,txt.y)
            addLine()
        }
        addLine(2)

        addTextos()

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
        box(`Agradecemos a oportunidade de apresentar nossa proposta para a consultoria de implantação da ${orc.itens[i].nome} para a ${orc.cliente} - ${orc.razao_social}`,5,txt.y,200)
        addLine()
        box(`A Del Mônaco Assessoria e Projetos é especializada na implantação e adequação de sistemas de gestão da qualidade e oferece uma solução personalizada para atender às necessidades da sua empresa, visando não apenas a ${orc.itens[i].nome}, mas também a melhoria contínua dos processos internos e o alinhamento com as melhores práticas do mercado.`,5,txt.y,200)
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
   
    function addTextos(){
        for(let i=0; i<orc.textos.length; i++){
            let texto = orc.textos[i].texto
            texto = texto.replaceAll('@produto', orc.produtos)
            texto = texto.replaceAll('@cliente', orc.cliente+'-'+orc.razao_social)
            
            let prazo = texto.split('@prazo-')
            if(prazo.length>1){
                for(let j=1; j<prazo.length; j++){
                    let k=0;
                    const dias = Number(getNum(prazo[j].split(' ')[0]))
                    const pz =  new Date(orc.data)
                    texto = texto.replaceAll('@prazo-'+dias, pz.overday(dias).viewFullDate())
                }
            }

            doc.setFont(undefined, 'bold')
            doc.text(orc.textos[i].titulo,5,txt.y)
            addLine()
            doc.setFont(undefined, 'normal')
            box(texto,5,txt.y,205,1)
            addLine()
        }
    }

}