
function print_orc(orc){
//    console.log(orc)

    doc = new jsPDF({
        orientation: 'portrait',
        format: 'a4'
    }) 

    if(Number(orc.capa)){
        plotImg('assets/reports/capa01.png',0,0,210)
        addPage(0)
        plotImg('assets/reports/capa02.png',0,0,210)
        addPage(0)

    }


    fillEscopo()
    
    async function fillEscopo(){
/*        
        plotImg('assets/reports/head.png',0,0,210)
        doc.setFontSize(10);
*/
        orc.produtos = ''
        for(let i=0; i< orc.itens.length; i++){
            orc.produtos += orc.itens[i].nome+', '
            addItem(i)
        }

        addPage()
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
//        addPage(0)
        txt.y = 75

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
            doc.text((j+1)+'- '+orc.itens[i].escopo[j].titulo,5,txt.y)
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

function print_relatorio(obj){

    loading(1)

    let img = 'assets/icons/icon.png'

    doc = new jsPDF({
        orientation: 'portrait',
        format: 'a4'
    }) 

    const rev = obj.rev[obj.rev.length-1]

    function newPage(Y=55){
        doc.addPage();
        head()   
        txt.y = Y 
    }

    function addLine(N=1, botton=0){
        txt.y += txt.lineHeigth * N
        if(txt.y >= doc.internal.pageSize.getHeight() - botton){
            botton ? newPage() : null
            return false
        }
        return true
    }


    function head(){

        plotImg(img,10,10,20,20)

        doc.rect(5,5,doc.internal.pageSize.getWidth()-10,30)
        doc.rect(35,5,130,30)
        doc.setFontSize(20);
        txt.y = 22
        doc.setFont(undefined, 'bold')
        center_text(obj.task.nome,[55,150])
        doc.setFontSize(10);
        try{
            doc.text('Código: '+obj.task.cod,168,15)
            doc.text('Data: '+rev.data_hora.viewDate(),168,20)
            doc.text('Revisão: '+rev.revisao.padStart(2,0),168,25)
        }catch{
            doc.text('Código: ',168,15)
            doc.text('Data: ',168,20)
            doc.text('Revisão: ',168,25)    
        }
    }

    function setores(){
        doc.rect(5,40,doc.internal.pageSize.getWidth()-10,80)
        doc.line(60,40,60,120)
        doc.line(110,40,110,120)

        doc.setFont(undefined, 'bold')
        doc.setFontSize(12)
        doc.line(5,46,doc.internal.pageSize.getWidth()-5,46)
        doc.text('Elaboração',20,44.5)
        doc.text('Setores Aplicáveis',67,44.5)
        doc.text('Sumário',146,44.5)

        doc.line(5,70,60,70)
        doc.line(5,76,60,76)
        doc.text('Aprovação',20,74)

        doc.setFont(undefined, 'normal')

        try{
            box(rev.elab,10,55,50)
            box(rev.aprov,10,85,50)
        }catch{
            null
        }


        txt.y = 53
        for(let i=0; i<obj.setores.length; i++){
            doc.text('\u2022 '+obj.setores[i].setor,62,txt.y)
            addLine(1.5)
        }

        txt.y = 53
        for(let i=0; i<obj.perguntas.length; i++){
            doc.text((i+1)+' - '+obj.perguntas[i].titulo,115,txt.y)
            addLine(1.5)
        }
    }

    function revisoes(){
        doc.setFont(undefined, 'bold')
        doc.setFontSize(12);

        doc.rect(5,130,doc.internal.pageSize.getWidth()-10,6)
        doc.line(30,130,30,136)
        doc.line(60,130,60,136)
        doc.text('Revisão',10,134.5)
        doc.text('Data',40,134.5)
        doc.text('Histórico',120,134.5)

        doc.setFont(undefined, 'normal')
        for(let i=0; i<obj.rev.length; i++){
            doc.text(obj.rev[i].revisao.padStart(2,0),15,(140.5+6*i))
            doc.text(obj.rev[i].data_hora.viewDate(),34,(140.5+6*i))
            doc.text(obj.rev[i].historico.padStart(2,0),62,(140.5+6*i))

            doc.line(5,(142+6*i),doc.internal.pageSize.getWidth()-5,(142+6*i))
            doc.line(5,(136+6*i),5,(142+6*i))
            doc.line(30,(136+6*i),30,(142+6*i))
            doc.line(60,(136+6*i),60,(142+6*i))
            doc.line(doc.internal.pageSize.getWidth()-5,(136+6*i),doc.internal.pageSize.getWidth()-5,(142+6*i))
        }
    }

    function questoes(){
        newPage()
        for(let i=0; i<obj.perguntas.length; i++){
            doc.setFont(undefined, 'bold')
            doc.setFontSize(12)
            doc.text((i+1).toString().padStart(2,0)+'   '+obj.perguntas[i].titulo,15,txt.y)
            addLine(1)

            doc.setFont(undefined, 'normal')
            doc.setFontSize(10)
            box(obj.perguntas[i].resposta,15,txt.y,doc.internal.pageSize.getWidth()-30,1)
            addLine(3)
//                const quebras = (obj.perguntas[i].resposta.match(/\r?\n/g) || []).length
//                addLine(quebras,i+1<obj.perguntas.length)
        }
    }

    function print(){
        openPDF(doc,'relatorio')
    }

    const back = backFunc({'filename':`../../files/logos/${obj.id_cliente}.jpg`},1)
    back.then((resp)=>{
        img = JSON.parse(resp) ? `../files/logos/${obj.id_cliente}.jpg` : 'assets/icons/icon.png'
        head()
        setores()
        revisoes()
        questoes()
        print()
    })  

}
